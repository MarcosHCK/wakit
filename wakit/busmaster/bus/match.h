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
#pragma once
#include <gio/gio.h>

enum _WakitBusmasterBusMatchElementType
{
  WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_ARG0NAMESPACE,
  WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_ARGN,
  WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_ARGNPATH,
  WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_DESTINATION,
  WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_EAVESDROP,
  WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_INTERFACE,
  WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_MEMBER,
  WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_MESSAGE_TYPE,
  WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_PATH_NAMESPACE,
  WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_PATH,
  WAKIT_BUSMASTER_BUS_MATCH_ELEMENT_TYPE_SENDER,
};

struct _WakitBusmasterBusMatchElement
{

  guint16 argn;
  enum _WakitBusmasterBusMatchElementType type;
  gchar* value;
  guint value_length;
};

typedef struct _WakitBusmasterBusServer WakitBusmasterBusServer;
typedef struct _WakitBusmasterBusMatchElement WakitBusmasterBusMatchElement;
typedef enum _WakitBusmasterBusMatchElementType WakitBusmasterBusMatchElementType;

G_BEGIN_DECLS

  G_GNUC_INTERNAL void wakit_busmaster_bus_element_clear (WakitBusmasterBusMatchElement* element);

  G_GNUC_INTERNAL gboolean wakit_busmaster_bus_match_equal_impl (WakitBusmasterBusMatchElement* a,
                                                                 WakitBusmasterBusMatchElement* b,
                                                                 guint n_elements);

  G_GNUC_INTERNAL gboolean wakit_busmaster_bus_match_matches_impl (GDBusMessage* message, gboolean has_destination,
                                                                   WakitBusmasterBusServer* server,
                                                                   guint n_elements,
                                                                   WakitBusmasterBusMatchElement* elements);

  G_GNUC_INTERNAL GArray* wakit_busmaster_bus_match_parse_impl (const gchar* value, gboolean* out_eavesdrop,
                                                                GDBusMessageType* out_type);

  gboolean wakit_busmaster_bus_server_match_name (WakitBusmasterBusServer* server,
                                                  const gchar* against, const gchar* to);

G_END_DECLS