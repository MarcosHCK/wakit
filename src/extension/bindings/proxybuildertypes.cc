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
#include <common/ccompat.h>
#include <common/hashing.h>
#include <extension/bindings/proxybuildertypes.h>
#include <gio/gio.h>

template<typename T>
using cmp_ar_func = bool (*) (T item1, T item2) noexcept;

template<typename T, cmp_ar_func<T> _func>
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_ar (const T* ar1, const T* ar2) noexcept G_GNUC_PURE;
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_arg (const GDBusArgInfo* info_a, const GDBusArgInfo* info_b) noexcept G_GNUC_PURE;
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_interface (const GDBusInterfaceInfo* info_a, const GDBusInterfaceInfo* info_b) noexcept G_GNUC_PURE;
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_method (const GDBusMethodInfo* info_a, const GDBusMethodInfo* info_b) noexcept G_GNUC_PURE;
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_property (const GDBusPropertyInfo* info_a, const GDBusPropertyInfo* info_b) noexcept G_GNUC_PURE;
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_signal (const GDBusSignalInfo* info_a, const GDBusSignalInfo* info_b) noexcept G_GNUC_PURE;
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_string (const char* string1, const char* string2) noexcept G_GNUC_PURE;

template<typename T, cmp_ar_func<T> _func>
[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_ar (const T* ar1, const T* ar2) noexcept
{

  if (nullptr == ar1) return nullptr == ar2;
  if (nullptr == ar2) return false;

  if (auto [ equal, length ] = ccompat::_st_length_cmp (ar1, ar2); !equal)
    return false;

  else for (std::remove_cvref_t<decltype (length)> i = 0; i < length; ++i)
    {

      if (! _func (ar1 [i], ar2 [i]))
        return false;
    }
return true;
}

[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_arg (const GDBusArgInfo* info_a, const GDBusArgInfo* info_b) noexcept
{

return cmp_string (info_a->signature, info_b->signature);
}

[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_interface (const GDBusInterfaceInfo* info_a, const GDBusInterfaceInfo* info_b) noexcept
{

  if (! cmp_ar<const GDBusMethodInfo*, cmp_method> (info_a->methods, info_b->methods))
    return false;

  if (! cmp_string (info_a->name, info_b->name))
    return false;

  if (! cmp_ar<const GDBusPropertyInfo*, cmp_property> (info_a->properties, info_b->properties))
    return false;

return cmp_ar<const GDBusSignalInfo*, cmp_signal> (info_a->signals, info_b->signals);
}

[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_method (const GDBusMethodInfo* info_a, const GDBusMethodInfo* info_b) noexcept
{

  if (! cmp_ar<const GDBusArgInfo*, cmp_arg> (info_a->in_args, info_b->in_args))
    return false;

  if (! cmp_string (info_a->name, info_b->name))
    return false;

return cmp_ar<const GDBusArgInfo*, cmp_arg> (info_a->out_args, info_b->out_args);
}

[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_property (const GDBusPropertyInfo* info_a, const GDBusPropertyInfo* info_b) noexcept
{

  if (info_a->flags != info_b->flags)
    return false;

  if (! cmp_string (info_a->name, info_b->name))
    return false;

return cmp_string (info_a->signature, info_b->signature);
}

[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_signal (const GDBusSignalInfo* info_a, const GDBusSignalInfo* info_b) noexcept
{

  if (! cmp_ar<const GDBusArgInfo*, cmp_arg> (info_a->args, info_b->args))
    return false;

return cmp_string (info_a->name, info_b->name);
}

[[gnu::always_inline]] [[gnu::pure]]
static inline constexpr bool cmp_string (const char* string1, const char* string2) noexcept
{

  if constexpr (! std::is_constant_evaluated ())

    return g_str_equal (string1, string2);
  else
    return std::string_view (string1) == std::string_view (string2);
}

gboolean g_dbus_interface_info_equal (gconstpointer _info_a, gconstpointer _info_b)
{

  auto info_a = (GDBusInterfaceInfo*) _info_a;
  auto info_b = (GDBusInterfaceInfo*) _info_b;

return cmp_interface (info_a, info_b) ? TRUE : FALSE;
}

guint g_dbus_interface_info_hash (gconstpointer _dbus_info)
{

  auto dbus_info = (GDBusInterfaceInfo*) _dbus_info;
  auto name_hash = hashing::fnv_1a<guint, char> (std::string_view (dbus_info->name));

return name_hash;
}