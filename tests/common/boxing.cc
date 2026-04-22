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
#include <common/boxing.h>
#include <tests/testing.h>
using namespace boxing;
using namespace testing;

template<typename T> static void _should_not_destroy (T* value G_GNUC_UNUSED)
{
  g_assert_not_reached ();
}

int main (int argc, char* argv[])
{

  g_test_init (&argc, &argv, NULL);

  g_test_add_ (TESTPATHROOT "/boxing/unset", []
    {

      destructible_box<void, _should_not_destroy> box;
      (void) box;
    });

  g_test_add_ (TESTPATHROOT "/boxing/unset_and_null_free_func", []
    {

      destructible_box<void, nullptr> box;
      (void) box;
    });

  g_test_add_ (TESTPATHROOT "/boxing/set", []
    {

      auto tester = dtor_tester ();
      using tester_t = decltype (tester.make_tester ());

      G_STMT_START {
        destructible_box<tester_t, _free_with_delete<tester_t>> box (tester.new_tester ());
        (void) box;
      } G_STMT_END;

      g_assert_true (tester.get_dtor_ed ());
    });

  g_test_add_ (TESTPATHROOT "/boxing/set_and_null_free_func", []
    {

      auto tester = dtor_tester ();
      using tester_t = decltype (tester.make_tester ());
      tester_t* fail;

      G_STMT_START {
        destructible_box<tester_t, nullptr> box (fail = tester.new_tester ());
        (void) box;
      } G_STMT_END;

      g_assert_false (tester.get_dtor_ed ());
      delete fail;
    });

  g_test_add_ (TESTPATHROOT "/boxing/copy", []
    {

      auto destroyed = (gboolean) FALSE;
      auto monitor = testing_ref_count_monitor_new (&destroyed);

      auto box = object<TestingRefCountMonitor> (monitor);

      g_assert_cmpuint (1, ==, ((GObject*) *box)->ref_count);

      G_STMT_START {

        auto box2 = box;

        g_assert_cmpuint (2, ==, ((GObject*) *box)->ref_count);
        g_assert_cmp (*box, ==, *box2);
        (void) box2;
      } G_STMT_END;

      g_assert_cmpuint (1, ==, ((GObject*) *box)->ref_count);
      g_object_unref (box.steal ());

      g_assert_true (destroyed);
    });

  g_test_add_ (TESTPATHROOT "/boxing/assign", []
    {

      auto destroyed = (gboolean) FALSE;
      auto monitor = testing_ref_count_monitor_new (&destroyed);

      auto box = object<TestingRefCountMonitor> (monitor);

      g_assert_cmpuint (1, ==, ((GObject*) *box)->ref_count);

      G_STMT_START {

        auto box2 = object<TestingRefCountMonitor> ();

        g_assert_cmpuint (1, ==, ((GObject*) *box)->ref_count);
        box2 = box;

        g_assert_cmpuint (2, ==, ((GObject*) *box)->ref_count);
        g_assert_cmp (*box, ==, *box2);
        (void) box2;
      } G_STMT_END;

      g_assert_cmpuint (1, ==, ((GObject*) *box)->ref_count);
      g_object_unref (box.steal ());

      g_assert_true (destroyed);
    });

  g_test_add_ (TESTPATHROOT "/boxing/assign/move", []
    {

      auto destroyed = (gboolean) FALSE;
      auto monitor = testing_ref_count_monitor_new (&destroyed);

      auto box = object<TestingRefCountMonitor> (monitor);

      g_assert_cmpuint (1, ==, ((GObject*) *box)->ref_count);

      G_STMT_START {

        auto box2 = object<TestingRefCountMonitor> ();

        g_assert_cmpuint (1, ==, ((GObject*) *box)->ref_count);
        box2 = std::move (box);

        g_assert_cmpuint (1, ==, ((GObject*) *box2)->ref_count);

        g_assert_cmp (monitor, ==, *box2);
        g_assert_cmp (*box, ==, (TestingRefCountMonitor*) NULL);
        (void) box2;
      } G_STMT_END;

      g_assert_true (destroyed);
    });
return g_test_run ();
}