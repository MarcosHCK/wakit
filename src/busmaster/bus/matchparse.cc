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
#include <charconv>
#include <common/constmap.h>
#include <regex>
#include <system_error>

[[gnu::always_inline]] static inline bool collect_eavesdrop (WakitBusmasterBusMatchElement* element,
                                                             gboolean* out_eavesdrop)
{

  auto value = element->value;

  if ('t' == value [0] && g_str_equal ("rue", 1 + value))
    return (*out_eavesdrop = TRUE, true);

  else if ('f' == value [0] && g_str_equal ("alse", 1 + value))
    return (*out_eavesdrop = FALSE, true);

return false;
}

[[gnu::always_inline]] static inline bool collect_message_type (WakitBusmasterBusMatchElement* element,
                                                                GDBusMessageType* out_type)
{

  constexpr std::pair<std::string_view, GDBusMessageType> _type_map_pairs [] =
    {
      { "error", G_DBUS_MESSAGE_TYPE_ERROR },
      { "method_call", G_DBUS_MESSAGE_TYPE_METHOD_CALL },
      { "method_return", G_DBUS_MESSAGE_TYPE_METHOD_RETURN },
      { "signal", G_DBUS_MESSAGE_TYPE_SIGNAL },
    };

  constexpr auto _type_map = constmap::make_constmap (_type_map_pairs);

  auto view = std::string_view (element->value);

  if (auto iter = _type_map.find (view); iter == _type_map.end ())

    return false;
  else
    return (*out_type = iter->second, true);
}

[[gnu::always_inline]] static inline bool parse_key (WakitBusmasterBusMatchElement* element,
                                                     std::string_view view) noexcept
{

  constexpr std::pair<std::string_view, WakitBusmasterBusMatchElementType> _type_map_pairs [] =
    {
      { "arg0namespace", WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_ARG0NAMESPACE },
      { "destination", WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_DESTINATION },
      { "eavesdrop", WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_EAVESDROP },
      { "interface", WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_INTERFACE },
      { "member", WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_MEMBER },
      { "path_namespace", WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_PATH_NAMESPACE },
      { "path", WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_PATH },
      { "sender", WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_SENDER },
      { "type", WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_MESSAGE_TYPE },
    };

  constexpr auto _type_map = constmap::make_constmap (_type_map_pairs);

  if (auto iter = _type_map.find (view); iter != _type_map.end ())
    return (element->type = iter->second, true);

  else if (G_UNLIKELY (! view.starts_with ("arg")))
    return false;

  auto digits = view.substr (3, view.substr (3).find_first_not_of ("0123456789"));
  auto leftover = view.substr (3 + digits.size ());

  if (G_UNLIKELY (0 == digits.size () || (0 != leftover.size () && "path" != leftover)))
    return false;

  auto [ptr, ec] = std::from_chars (digits.begin (), digits.end (), element->argn);

  if (G_UNLIKELY (ec != std::errc () || ptr != digits.end ()))
    return false;

  element->type = 0 == leftover.size () ? WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_ARGN
                                        : WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_ARGNPATH;

return true;
}

[[gnu::always_inline]] static inline bool parse_value (WakitBusmasterBusMatchElement* element,
                                                       std::string_view view) noexcept
{

  enum
    {
      state_escape,
      state_quote,
      state_unset,
    };

  const gchar* end = view.end ();
  const gchar* iter = view.begin ();
  int state = state_unset;

  GString* builder = g_string_sized_new (view.size ());

  for (; iter < end; iter = g_utf8_next_char (iter))

    switch (gunichar c = g_utf8_get_char (iter); state)
      {

      case state_escape: if ('\'' != c)
                          g_string_append_c (builder, '\\');

                         g_string_append_unichar (builder, c);
                         state = state_unset;
        break;

      case state_quote: if ('\'' == c)

                          state = state_unset;
                        else
                          g_string_append_unichar (builder, c);
        break;

      case state_unset: switch (c)
        {

        case '\'': state = state_quote;
          break;

        case '\\': state = state_escape;
          break;

        default: g_string_append_unichar (builder, c);
          break;
        }
      }

  switch (state)
    {

    case state_escape: g_string_append_c (builder, '\\');
      G_GNUC_FALLTHROUGH;

    case state_unset: element->value_length = builder->len;
                      element->value = g_string_free_and_steal (builder);
      return true;

    default:
      G_GNUC_FALLTHROUGH;

    case state_quote: g_string_free (builder, TRUE);
      return false;
    }
}

std::regex pair_pattern (R"(\s*(\w+)\s*=\s*([^,]+?)(?=\s*(?:,|$)))",
  std::regex_constants::ECMAScript | std::regex_constants::optimize);

GArray* wakit_busmaster_bus_match_parse_impl (const gchar* value, gboolean* out_eavesdrop,
                                              GDBusMessageType* out_type)
{

  auto ar = g_array_new (FALSE, FALSE, sizeof (WakitBusmasterBusMatchElement));
  auto sv = std::string_view (value);

  std::regex_iterator begin (sv.begin (), sv.end (), pair_pattern);

  for (decltype (begin) end, iter = begin; iter != end; ++iter)
    {

      WakitBusmasterBusMatchElement element;
      auto& info = *iter;

      if (std::string_view sv_ (info [1].first, info [1].second); G_UNLIKELY (! parse_key (&element, sv_)))
        return (g_array_unref (ar), nullptr);

      if (std::string_view sv_ (info [2].first, info [2].second); G_UNLIKELY (! parse_value (&element, sv_)))
        return (g_array_unref (ar), nullptr);

      switch (element.type)
        {

        case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_EAVESDROP: collect_eavesdrop (&element, out_eavesdrop);
          wakit_busmaster_bus_element_clear (&element);
          break;

        case WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_MESSAGE_TYPE: collect_message_type (&element, out_type);
          wakit_busmaster_bus_element_clear (&element);
          break;

        default: g_array_append_vals (ar, &element, 1);
          break;
    } }
return ar;
}