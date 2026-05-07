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
#include <busmaster/bus/match.h>
#include <string_view>
#include <utility>

#define BUS_NAME "org.freedesktop.DBus"

[[gnu::always_inline]] static inline bool element_matches (GDBusMessage* message, gboolean has_destination,
                                                           WakitBusmasterBusServer* server,
                                                           WakitBusmasterBusMatchElement* element);

gboolean wakit_busmaster_bus_match_matches_impl (GDBusMessage* message, gboolean has_destination,
                                                 WakitBusmasterBusServer* server,
                                                 guint n_elements,
                                                 WakitBusmasterBusMatchElement* elements)
{

  for (decltype (n_elements) i = 0; i < n_elements; ++i)

    if (! element_matches (message, has_destination, server, &elements [i]))
      return FALSE;

return TRUE;
}

enum class check_type
{
  name,
  namespace_prefix,
  path_prefix,
  path_related,
  string,
};

[[gnu::always_inline]] static inline auto collect_argn (GDBusMessage* message, int n, bool allow_path)
{

  const auto body = g_dbus_message_get_body (message);
  const gchar* result = NULL;

  if (NULL != body && g_variant_is_of_type (body, G_VARIANT_TYPE_TUPLE))
    {

      auto item = g_variant_get_child_value (body, n);

      if (                g_variant_is_of_type (item, G_VARIANT_TYPE_STRING)
        || (allow_path && g_variant_is_of_type (item, G_VARIANT_TYPE_OBJECT_PATH)))

        result = g_variant_get_string (item, NULL);

      g_variant_unref (item);
    }
return result;
}

[[gnu::always_inline]] static inline auto collect_check (GDBusMessage* message,
                                                         WakitBusmasterBusMatchElement* element)
{

  const gchar* against;
  check_type check_type = check_type::string;

  switch (element->type)
    {

    case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_ARG0NAMESPACE: against = collect_argn (message, 0, false);
                                                               check_type = check_type::namespace_prefix;
      break;

    case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_ARGN: against = collect_argn (message, element->argn, false);
      break;

    case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_ARGNPATH: against = collect_argn (message, element->argn, true);
      break;

    case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_DESTINATION: against = g_dbus_message_get_destination (message);
                                                             check_type = check_type::name;
      break;

    case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_EAVESDROP: g_assert_not_reached ();

    case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_INTERFACE: against = g_dbus_message_get_interface (message);
      break;

    case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_MEMBER: against = g_dbus_message_get_member (message);
      break;

    case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_MESSAGE_TYPE: g_assert_not_reached ();

    case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_PATH_NAMESPACE: check_type = check_type::path_prefix;
      G_GNUC_FALLTHROUGH;

    case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_PATH: against = g_dbus_message_get_path (message);
      break;

    case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_SENDER: against = g_dbus_message_get_sender (message);
                                                        against = nullptr != against ? against : BUS_NAME;
                                                        check_type = check_type::name;
    }
return std::make_pair (against, check_type);
}

[[gnu::always_inline]] static inline bool element_matches (GDBusMessage* message, gboolean has_destination,
                                                           WakitBusmasterBusServer* server,
                                                           WakitBusmasterBusMatchElement* element)
{

  auto [ against_, check_type ] = collect_check (message, element);

  if (G_UNLIKELY (NULL == against_))
    return false;

  switch (auto against = std::string_view (against_); check_type)
    {

    case check_type::name:
    
      if (! wakit_busmaster_bus_server_match_name (server, against.data (), element->value))
        return false;
      break;

    case check_type::namespace_prefix:
    
      if (auto view = std::string_view (element->value);
          false == (against.starts_with (view) && (0 == against [view.length ()] || '.' == against [view.length ()])))
        return false;
      break;

    case check_type::path_prefix:

      if (auto view = std::string_view (element->value);
          view.length () > 1 && (! against.starts_with (view) || against.length () < view.length () || 0 != against [view.length ()] || '/' != against [view.length ()]))
        return false;
      break;

    case check_type::path_related:

      if (auto view = std::string_view (element->value);
          false == (against == view || (against.length () > 0 && '/' == against [against.length () - 1] && view.starts_with (against))
                                    || (view.length () > 0 && '/' == view [view.length () - 1] && against.starts_with (view))))
        return false;
      break;

    case check_type::string:

      if (auto view = std::string_view (element->value); against != view)
        return false;
      break;
    }
return true;
}