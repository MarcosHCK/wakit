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
#include <jsc/jsc.h>

typedef struct _WakitPromise WakitPromise;
typedef void (*WakitPromiseCallback) (WakitPromise* promise, gpointer user_data);

G_BEGIN_DECLS

  JSCValue* wakit_promise_create (JSCContext* context,
                                  WakitPromiseCallback callback,
                                  gpointer callback_target);

  WakitPromise* wakit_promise_new (JSCContext* context,
                                   JSCValue* reject,
                                   JSCValue* resolve);

  void wakit_promise_reject (WakitPromise* self,
                             JSCValue* value);
  void wakit_promise_reject_gerror (WakitPromise* self,
                                    GError* _error_);
  void wakit_promise_reject_literal (WakitPromise* self,
                                     const gchar* value);
  void wakit_promise_reject_printf (WakitPromise* self,
                                    const gchar* fmt,
                                    ...)  G_GNUC_PRINTF (2,3);
  void wakit_promise_resolve (WakitPromise* self,
                              JSCValue* value);

G_END_DECLS