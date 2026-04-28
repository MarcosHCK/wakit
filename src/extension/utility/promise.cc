/* Copyright (C) 2025-2026 MarcosHCK
 * This file is part of wakit.
 *
 * wakit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wakit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
#include <config.h>
#include <common/boxing.h>
#include <common/slice.h>
#include <extension/utility/promise.h>

struct _ExecutorData
{

  WakitPromiseCallback callback;
  JSCContext* context;
  gpointer user_data;
};

struct _WakitPromise
{

	JSCContext* context;
  GMainContext* main_context;
	JSCValue* reject;
	JSCValue* resolve;
};

static void create (JSCValue* resolve, JSCValue* reject, struct _ExecutorData* data)
{

  auto p = wakit_promise_new (data->context, reject, resolve);
  auto u = data->user_data;

  data->callback (p, u);
}

JSCValue* wakit_promise_create (JSCContext* context, WakitPromiseCallback callback, gpointer user_data)
{

  g_return_val_if_fail (JSC_IS_CONTEXT (context), NULL);

  auto data = _ExecutorData { .callback = callback, .context = context, .user_data = user_data };
  auto prom = jsc_value_new_promise (context, (JSCExecutor) create, &data);
return prom;
}

[[gnu::always_inline]]
static inline void finish (JSCContext* context, JSCValue* callback, JSCValue* value)
{

  value = nullptr != value
        ? g_object_ref (value)
        : jsc_value_new_undefined (context);

  g_object_unref (jsc_value_function_callv (callback, 1, &value));
  g_object_unref (value);
}

struct _FinishData
{

  boxing::object<JSCValue> _callback;
  boxing::object<JSCContext> _context;
  boxing::object<JSCValue> _value;

  inline _FinishData (JSCContext* context, JSCValue* callback, JSCValue* value) noexcept:
      _callback (g_object_ref (callback)),
      _context (g_object_ref (context)),
      _value (g_object_ref (value))
    { }
};

static gboolean finish_callback (struct _FinishData* data)
{

  (finish) (*data->_context, *data->_callback, *data->_value);
return G_SOURCE_REMOVE;
}

[[gnu::always_inline]]
static inline void finish_foreign (JSCContext* context, JSCValue* callback, JSCValue* value, GMainContext* main_context)
{

  auto data = g_slice_new_<_FinishData> (g_object_ref (context), g_object_ref (callback), g_object_ref (value));

  g_main_context_invoke_full (main_context, G_PRIORITY_DEFAULT, G_SOURCE_FUNC (finish_callback), data, g_slice_free_<_FinishData>);
}

#define finish(context,callback,value) (G_GNUC_EXTENSION ({ \
 ; \
    JSCContext* __context = ((context)); \
    JSCValue* __callback = ((callback)); \
    JSCValue* __value = ((value)); \
 ; \
    if (g_main_context_is_owner (self->main_context)) \
      (finish) (__context, __callback, __value); \
    else \
      finish_foreign (__context, __callback, __value, self->main_context); \
  }))

void wakit_promise_reject (WakitPromise* self, JSCValue* value)
{

  g_return_if_fail (NULL != self);
  g_return_if_fail (NULL == value || JSC_IS_VALUE (value));

  finish (self->context, self->reject, value);
}

extern "C" gpointer wakit_error_new_take (GError* error);
extern "C" JSCValue* wakit_error_to_value (gpointer error, JSCContext* context);

static JSCValue* _gerror_to_jsc (JSCContext* context, GError* g_error)
{

  auto error = wakit_error_new_take (g_error);
  auto value = wakit_error_to_value (error, context);
return (g_object_unref (error), value);
}

void wakit_promise_reject_gerror (WakitPromise* self, GError* error)
{

  g_return_if_fail (NULL != self);
  g_return_if_fail (NULL != error);
  JSCValue* value;

  finish (self->context, self->reject, value = _gerror_to_jsc (self->context, error));
return g_object_unref (value);
}

void wakit_promise_reject_literal (WakitPromise* self, const gchar* literal)
{

  g_return_if_fail (NULL != self);
  g_return_if_fail (NULL != literal);
  JSCValue* value;

  finish (self->context, self->reject, value = jsc_value_new_string (self->context, literal));
return g_object_unref (value);
}

void wakit_promise_reject_printf (WakitPromise* self, const gchar* fmt, ...)
{

  g_return_if_fail (NULL != self);
  g_return_if_fail (NULL != fmt);

  va_list l;
  va_start (l, fmt);

  auto message = g_strdup_vprintf (fmt, l);
  auto value = jsc_value_new_string (self->context, message);
  g_free (message);

  finish (self->context, self->reject, value);

return (va_end (l), g_object_unref (value));
}

void wakit_promise_resolve (WakitPromise* self, JSCValue* value)
{

  g_return_if_fail (NULL != self);
  g_return_if_fail (NULL == value || JSC_IS_VALUE (value));

  finish (self->context, self->resolve, value);
}