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
#include <glib/gi18n-lib.h>
#include <wakit/common/appbus/address.h>

static void parse_options (const gchar* first, const gchar* list, guint length, WakitAppBusAddressForeachOption callback, gpointer user_data, GError** error)
{

  const gchar* curr = list;
  const gchar* last = NULL;
  const gchar* next = NULL;

  for (; curr != NULL; curr = next)
    {

      if ((next = last = g_strstr_len (curr, length, ",")) != NULL)

        ++next;
      else
        last = list + length;

      if (auto sep = g_strstr_len (curr, last - curr, "="); G_UNLIKELY (sep == NULL))
        g_set_error (error, G_IO_ERROR, G_IO_ERROR_INVALID_ARGUMENT, _ ("bad address (%li: missing '=')"), curr - first + 1);

      else if (auto ext = g_strstr_len (1 + sep, last - sep - 1, "="); G_UNLIKELY (ext == NULL))

        callback (curr, sep - curr, 1 + sep, last - (1 + sep), user_data);
      else
        g_set_error (error, G_IO_ERROR, G_IO_ERROR_INVALID_ARGUMENT, _ ("bad address (%li: unexpected '=') %.*s"), ext - first + 1, (int) (last - curr), sep);
    }
}

const gchar* wakit_app_bus_address_parse (const gchar* address, guint* out_length, WakitAppBusAddressForeachOption callback, gpointer user_data, GError** error)
{

  const gchar* curr = address;
  const gchar* last = NULL;
  const gchar* next = NULL;
  GError* tmperr = NULL;
  guint i, length;

  guint __length = 0;
  out_length = NULL == out_length ? &__length : out_length;

  for (i = 0, length = strlen (address); curr != NULL; curr = next, ++i)
    {

      if ((next = last = g_strstr_len (curr, length, ":")) != NULL)

        ++next;
      else
        last = address + length;

      switch (i)
        {

        case 0: *out_length = last - curr;
          break;

        case 1: if (parse_options (address, curr, last - curr, callback, user_data, &tmperr); G_UNLIKELY (NULL != tmperr))
                  return (g_propagate_error (error, tmperr), nullptr);
          break;

        case 2: g_set_error (error, G_IO_ERROR, G_IO_ERROR_INVALID_ARGUMENT, _ ("bad address (%li, unexpected ':')"), last - address);
          return NULL;
    } }
return address;
}