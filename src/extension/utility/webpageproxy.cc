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
#include <common/value.h>
#include <extension/utility/webpageproxy.h>
#include <extension/utility/wakit-extension-utility-marshals.h>

struct _WakitWebPageProxy
{

  GObject parent;

  /*<private>*/
  GWeakRef web_page;
};

enum
{
  prop_0,
  prop_web_page,
  prop_number,
};

enum
{
  sig_user_message_received,
  sig_number,
};

static G_DEFINE_QUARK (wakit-web-page-proxy-default-quark, default)

static GParamSpec* properties [prop_number] = { 0 };
static guint signals [sig_number] = { 0 };

struct _WakitWebPageProxyClass { GObjectClass parent; };
#define WAKIT_WEB_PAGE_PROXY_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), WAKIT_TYPE_WEB_PAGE_PROXY, WakitWebPageProxyClass))
#define WAKIT_IS_WEB_PAGE_PROXY_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), WAKIT_TYPE_WEB_PAGE_PROXY))
#define WAKIT_WEB_PAGE_PROXY_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), WAKIT_TYPE_WEB_PAGE_PROXY, WakitWebPageProxyClass))
typedef struct _WakitWebPageProxyClass WakitWebPageProxyClass;

G_DEFINE_FINAL_TYPE (WakitWebPageProxy, wakit_web_page_proxy, G_TYPE_OBJECT)

static gboolean true_if_any (GSignalInvocationHint* ihint, GValue* accum, const GValue* handler_return, gpointer data)
{

  if (g_value_get_boolean (handler_return))
      g_value_set_boolean (accum, TRUE);

return TRUE;
}

static GObject* wakit_web_page_proxy_class_constructor (GType g_type, guint n_params, GObjectConstructParam* params)
{

  WebKitWebPage* web_page = NULL;

  for (decltype (n_params) i = 0; i < n_params; ++i)

    if (params [i].pspec == properties [prop_web_page])
      { web_page = (WebKitWebPage*) g_value_dup_object (params [i].value); break; }

  g_return_val_if_fail (WEBKIT_IS_WEB_PAGE (web_page), NULL);

  auto self = (WakitWebPageProxy*) G_OBJECT_CLASS (wakit_web_page_proxy_parent_class)->constructor (g_type, n_params, params);

  g_signal_connect_object (web_page, "user-message-received", G_CALLBACK (wakit_web_page_proxy_user_message_received),
                           self, G_CONNECT_SWAPPED);
  g_object_unref (web_page);

return &self->parent;
}

static void wakit_web_page_proxy_class_dispose (GObject* pself)
{

  auto self = (WakitWebPageProxy*) pself;

  g_weak_ref_clear (&self->web_page);

G_OBJECT_CLASS (wakit_web_page_proxy_parent_class)->dispose (pself);
}

static void wakit_web_page_proxy_class_get_property (GObject* pself, guint property_id, GValue* value, GParamSpec* pspec)
{

  switch (auto self = (WakitWebPageProxy*) pself; property_id)
    {

    case prop_web_page: g_value_set_object (value, g_weak_ref_get (&self->web_page));
      break;

    default: G_OBJECT_WARN_INVALID_PROPERTY_ID (self, property_id, pspec);
      break;
    }
}

static void wakit_web_page_proxy_class_set_property (GObject* pself, guint property_id, const GValue* value, GParamSpec* pspec)
{

  switch (auto self = (WakitWebPageProxy*) pself; property_id)
    {

    case prop_web_page: g_weak_ref_set (&self->web_page, g_value_get_object (value));
      break;

    default: G_OBJECT_WARN_INVALID_PROPERTY_ID (self, property_id, pspec);
      break;
    }
}

static void wakit_web_page_proxy_class_init (WakitWebPageProxyClass* klass)
{

  G_OBJECT_CLASS (klass)->constructor = wakit_web_page_proxy_class_constructor;
  G_OBJECT_CLASS (klass)->dispose = wakit_web_page_proxy_class_dispose;
  G_OBJECT_CLASS (klass)->get_property = wakit_web_page_proxy_class_get_property;
  G_OBJECT_CLASS (klass)->set_property = wakit_web_page_proxy_class_set_property;

  auto g_type = G_TYPE_FROM_CLASS (klass);

  constexpr GParamFlags prop_flag1 = G_PARAM_READWRITE;
  constexpr GParamFlags prop_flag2 = G_PARAM_CONSTRUCT_ONLY;
  constexpr GParamFlags prop_flag3 = (GParamFlags) G_PARAM_STATIC_STRINGS;
  constexpr GParamFlags prop_flags1 = (GParamFlags) (prop_flag1 | prop_flag2 | prop_flag3);

  properties [prop_web_page] = g_param_spec_object ("web-page", "web-page", "web-page", WEBKIT_TYPE_WEB_PAGE, prop_flags1);

  g_object_class_install_properties (G_OBJECT_CLASS (klass), prop_number, properties);

  constexpr GSignalFlags signal_flag1 = G_SIGNAL_RUN_FIRST;
  constexpr GSignalFlags signal_flags = signal_flag1;

  signals [sig_user_message_received] = g_signal_new ("user-message-received", g_type, signal_flags, 0, true_if_any, NULL,
                                          g_cclosure_user_marshal_BOOLEAN__OBJECT, G_TYPE_BOOLEAN, 1, WEBKIT_TYPE_USER_MESSAGE);

  g_signal_set_va_marshaller (signals [sig_user_message_received], g_type, g_cclosure_user_marshal_BOOLEAN__OBJECTv);
}

static void wakit_web_page_proxy_init (WakitWebPageProxy* self)
{
}

WakitWebPageProxy* wakit_web_page_proxy_get_default (WebKitWebPage* web_page)
{

  g_return_val_if_fail (WEBKIT_IS_WEB_PAGE (web_page), NULL);

  const auto quark = default_quark ();
  WakitWebPageProxy* self;

  if (G_UNLIKELY (nullptr == (self = (WakitWebPageProxy*) g_object_get_qdata ((GObject*) web_page, quark))))
    
    g_object_set_qdata_full ((GObject*) web_page, quark, self = (WakitWebPageProxy*) g_object_new (WAKIT_TYPE_WEB_PAGE_PROXY,
      "web-page", web_page, NULL), g_object_unref);

return self;
}

WebKitWebPage* wakit_web_page_proxy_get_web_page (WakitWebPageProxy* proxy)
{

  g_return_val_if_fail (WAKIT_IS_WEB_PAGE_PROXY (proxy), NULL);
return (WebKitWebPage*) g_weak_ref_get (&proxy->web_page);
}

gboolean wakit_web_page_proxy_user_message_received (WakitWebPageProxy* proxy, WebKitUserMessage* message)
{

  GValue result = G_VALUE_INIT;
  GValue values [2] = { G_VALUE_INIT, G_VALUE_INIT };

  g_value_init_from_instance (&values [0], proxy);
  g_value_init_from_instance (&values [1], message);
  g_value_init (&result, G_TYPE_BOOLEAN);

  guint signal_id = signals [sig_user_message_received];
  gboolean handled = (g_signal_emitv (values, signal_id, 0, &result), g_value_get_boolean (&result));

  g_value_unset_ (&result, &values [0], &values [1]);
return handled;
}