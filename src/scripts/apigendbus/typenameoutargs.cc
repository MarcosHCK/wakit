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
#include <stdexcept>

static inline void _typename_from_out_container (std::ostream& typename_, const GVariantType* v_type);
static inline void _typename_from_out_type (std::ostream& typename_, const GVariantType* v_type);

static inline void _typename_from_out_container (std::ostream& typename_, const GVariantType* v_type)
{

  bool first = true;

  typename_ << "[";

  for (auto iter = g_variant_type_first (v_type); NULL != iter; iter = g_variant_type_next (iter))
    {

      typename_ << (!first ? ", " : (first = false, ""));

      _typename_from_out_type (typename_, iter);
    }
return (typename_ << "]", ({ }));
}

static inline void _typename_from_out_type (std::ostream& typename_, const GVariantType* v_type)
{

  switch (g_variant_type_peek_string (v_type) [0])
    {

    case '(': G_GNUC_FALLTHROUGH;
    case '{': return _typename_from_out_container (typename_, v_type);

    case 'a': switch (auto child = g_variant_type_element (v_type); g_variant_type_peek_string (child) [0])
      {

      case '{':
        {

          typename_ << "Record<";

          const GVariantType* p;
          _typename_from_out_type (typename_, p = g_variant_type_first (child));
          _typename_from_out_type (typename_ << ", ", g_variant_type_next (p));

        return (typename_ << ">", ({}));
        }

      case 'd': return (typename_ << "Float64Array", ({ }));
      case 'h': G_GNUC_FALLTHROUGH;
      case 'i': return (typename_ << "Int32Array", ({ }));
      case 'n': return (typename_ << "Int16Array", ({ }));
      case 'q': return (typename_ << "Uint16Array", ({ }));
      case 't': return (typename_ << "Uint64Array", ({ }));
      case 'u': return (typename_ << "Uint32Array", ({ }));
      case 'y': return (typename_ << "string", ({ }));
      case 'x': return (typename_ << "Int64Array", ({ }));

      default: _typename_from_out_type (typename_, child);
        return (typename_ << "[]", ({ }));
      }

    case 'b': return (typename_ << "boolean", ({ }));
    case 'd': G_GNUC_FALLTHROUGH;
    case 'h': G_GNUC_FALLTHROUGH;
    case 'i': return (typename_ << "number", ({ }));

    case 'm': { auto child = g_variant_type_element (v_type);
                return (typename_ << (_typename_from_out_type (typename_, child), " | undefined"), ({ })); }

    case 'n': G_GNUC_FALLTHROUGH;
    case 'q': return (typename_ << "number", ({ }));

    case 's': G_GNUC_FALLTHROUGH;
    case 'o': G_GNUC_FALLTHROUGH;
    case 'g': return (typename_ << "string", ({ }));

    case 't': G_GNUC_FALLTHROUGH;
    case 'u': return (typename_ << "number", ({ }));

    case 'v': return (typename_ << "unknown", ({ }));

    default: { auto type = std::string (g_variant_type_peek_string (v_type),
                                        g_variant_type_get_string_length (v_type));
               throw std::out_of_range ("unhandled variant type '" + type + "'"); }
    }
}

nlohmann::json impl::_callback_typename_from_out_args (std::vector<const nlohmann::json*>& args)
{

  assert (args [0]->is_array ());

  auto& arg_infos = *args [0];

  if (0 == arg_infos.size ())
    return "void";

  std::stringstream typename_;

  if (1 < arg_infos.size ())
    typename_ << "[";

  for (bool first = true; const auto& arg_info: arg_infos)
    {

      auto signature = arg_info ["signature"].get<std::string_view> ();
      auto variant_type = _parse_signature (signature);

      typename_ << (! first ? ", " : (first = false, ""));

      _typename_from_out_type (typename_, variant_type);
    }
return (1 == arg_infos.size () ? typename_ : (typename_ << "]", typename_)).str ();
}

nlohmann::json impl::_callback_typename_from_signature (std::vector<const nlohmann::json*>& args)
{

  assert (args [0]->is_string ());

  auto typename_ = std::stringstream ();
  auto signature = args [0]->get<std::string_view> ();

  auto variant_type = _parse_signature (signature);

  _typename_from_out_type (typename_, variant_type);
return typename_.str ();
}