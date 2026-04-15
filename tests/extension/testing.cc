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
#include <tests/extension/testing.h>
#include <tests/testing.h>
using namespace testing;

testing::JSCContainer::~JSCContainer ()
{

  _ct = (g_object_unref (_ct), nullptr);
  _vm = (g_object_unref (_vm), nullptr);
}

static void error_handler (JSCContext* G_GNUC_UNUSED, JSCException* ex, gpointer user_data G_GNUC_UNUSED)
{

  auto cn = jsc_exception_get_column_number (ex);
  auto ln = jsc_exception_get_line_number (ex);
  auto ms = jsc_exception_get_message (ex);

  g_printerr ("%u: %u: %s\n", ln, cn, ms);
}

static auto make_toString (JSCContext* context)
{

  auto size = (gsize) 0;
  auto buffer = g_read_offsource ("extension/testing.js", &size);

  JSCValue* value;

  g_object_unref (jsc_context_evaluate_in_object (context, buffer, size, nullptr, nullptr,
    "file://" SOURCE_DIR "/testing.js", 1, &(value = nullptr)));
  g_free (buffer);

  // NOLINTNEXTLINE(bugprone-sizeof-expression)
  g_set_object (&value, jsc_value_object_get_property (value, "toString"));

return value;
}

testing::JSCContainer::JSCContainer () noexcept:
  _vm (jsc_virtual_machine_new ()),
  _ct (jsc_context_new_with_virtual_machine (_vm))
{

  jsc_context_push_exception_handler (_ct, error_handler, this, NULL);
  _ts = make_toString (_ct);
}

gchar* testing::JSCContainer::to_string (JSCValue* value) const noexcept
{

  auto val = jsc_value_function_callv (_ts, 1, &value);
  auto vas = jsc_value_to_string (val);

return (g_object_unref (val), vas);
}