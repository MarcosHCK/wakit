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
#include <extension/utility/promise.h>

struct _ExecutorData
{

  WakitPromiseCallback callback;
  JSCContext* context;
  gpointer user_data;
};

struct _WakitPromise
{

	JSCContext* _context;
	JSCValue* _reject;
	JSCValue* _resolve;
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

void wakit_promise_reject (WakitPromise* self, JSCValue* value)
{

  g_return_if_fail (NULL != self);
  g_return_if_fail (NULL == value || JSC_IS_VALUE (value));

  finish (self->_context, self->_reject, value);
}

extern "C" gpointer wakit_error_new_take (GError* error);
extern "C" JSCValue* wakit_error_to_value (gpointer error);

static JSCValue* _gerror_to_jsc (GError* g_error)
{

  auto error = wakit_error_new_take (g_error);
  auto value = wakit_error_to_value (error);
return (g_object_unref (error), value);
}

void wakit_promise_reject_gerror (WakitPromise* self, GError* error)
{

  g_return_if_fail (NULL != self);
  g_return_if_fail (NULL != error);
  JSCValue* value;

  finish (self->_context, self->_reject, value = _gerror_to_jsc (error));
return g_object_unref (value);
}

void wakit_promise_reject_literal (WakitPromise* self, const gchar* literal)
{

  g_return_if_fail (NULL != self);
  g_return_if_fail (NULL != literal);
  JSCValue* value;

  finish (self->_context, self->_reject, value = jsc_value_new_string (self->_context, literal));
return g_object_unref (value);
}

void wakit_promise_reject_printf (WakitPromise* self, const gchar* fmt, ...)
{

  g_return_if_fail (NULL != self);
  g_return_if_fail (NULL != fmt);

  va_list l;
  va_start (l, fmt);

  auto message = g_strdup_vprintf (fmt, l);
  auto value = jsc_value_new_string (self->_context, message);
  g_free (message);

  finish (self->_context, self->_reject, value);

return (va_end (l), g_object_unref (value));
}

void wakit_promise_resolve (WakitPromise* self, JSCValue* value)
{

  g_return_if_fail (NULL != self);
  g_return_if_fail (NULL == value || JSC_IS_VALUE (value));

  finish (self->_context, self->_resolve, value);
}