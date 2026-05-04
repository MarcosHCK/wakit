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
#include <glib.h>
#include <scripts/apigendbus/genimpl.h>
#include <sstream>

static inline std::ostream& _typename_from_in_container (std::ostream& typename_, const GVariantType* v_type);
static inline std::ostream& _typename_from_in_type (std::ostream& typename_, const GVariantType* v_type);

static inline std::ostream& _typename_from_in_container (std::ostream& typename_, const GVariantType* v_type)
{

  bool first = true;

  typename_ << "[";

  for (auto iter = g_variant_type_first (v_type); NULL != iter; iter = g_variant_type_next (iter))
    {

      typename_ << (!first ? ", " : (first = false, ""));

      _typename_from_in_type (typename_, iter);
    }
return typename_ << "]";
}

static inline std::ostream& _typename_from_in_type (std::ostream& typename_, const GVariantType* v_type)
{

  switch (g_variant_type_peek_string (v_type) [0])
    {

    case '(': G_GNUC_FALLTHROUGH;
    case '{': return _typename_from_in_container (typename_, v_type);

    case 'a': switch (auto child = g_variant_type_element (v_type); g_variant_type_peek_string (child) [0])
      {

      case '{':
        {
          typename_ << "Record<";

          const GVariantType* p;
          _typename_from_in_type (typename_, p = g_variant_type_first (child));
          _typename_from_in_type (typename_ << ", ", g_variant_type_next (p));

        return typename_ << ">";
        }

      case 'd': typename_ << "Float64Array";
        goto fallback;

      case 'h': G_GNUC_FALLTHROUGH;
      case 'i': typename_ << "Int32Array";
        goto fallback;

      case 'n': typename_ << "Int16Array";
        goto fallback;

      case 'q': typename_ << "Uint16Array";
        goto fallback;

      case 't': typename_ << "Uint64Array";
        goto fallback;

      case 'u': typename_ << "Uint32Array";
        goto fallback;

      case 'y': typename_ << "string";
        goto fallback;

      case 'x': typename_ << "Int64Array";
        goto fallback;

      fallback:
        typename_ << " | ";

        G_GNUC_FALLTHROUGH;
      default:
        return _typename_from_in_type (typename_, child) << "[]";
      }

    case 'b': return  typename_ << "boolean";
    case 'd': return  typename_ << "number";
    case 'g': return  typename_ << "string";
    case 'h': G_GNUC_FALLTHROUGH;
    case 'i': return  typename_ << "number";

    case 'm': { auto child = g_variant_type_element (v_type);
                return _typename_from_in_type (typename_ << "undefined | ", child); }

    case 'n': return  typename_ << "number";
    case 'o': return  typename_ << "string";
    case 'q': return  typename_ << "number";
    case 's': return  typename_ << "string";
    case 't': G_GNUC_FALLTHROUGH;
    case 'u': G_GNUC_FALLTHROUGH;
    case 'x': G_GNUC_FALLTHROUGH;
    case 'y': return  typename_ << "number";

    default: { auto type = std::string (g_variant_type_peek_string (v_type),
                                        g_variant_type_get_string_length (v_type));
               throw std::out_of_range ("unhandled variant type '" + type + "'"); }
    }
}

nlohmann::json impl::_callback_typename_from_in_args (std::vector<const nlohmann::json*>& args)
{

  assert (args [0]->is_array ());

  std::stringstream typename_;

  for (bool first = true; const auto& arg_info: *args [0])
    {

      typename_ << (!first ? ", " : (first = false, ""));
      typename_ << arg_info ["name"].get<std::string_view> () << ": ";

      _typename_from_in_type (typename_, _parse_signature (arg_info ["signature"].get<std::string_view> ()));
    }
return typename_.str ();
}