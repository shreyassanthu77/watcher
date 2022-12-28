/*
   Test Watcher
   Event Targets
*/

/* REQUIRE,
   TEST_CASE */
#include <snatch/snatch.hpp>
/* event */
#include <vector>
#include <watcher/watcher.hpp>
/* watch_gather */
#include <test_watcher/test_watcher.hpp>
/* get */
#include <tuple>
/* cout, endl */
#include <iostream>

/* Test that files are scanned */
TEST_CASE("Event Targets", "[event_targets]")
{
  using namespace wtr::watcher;

  static constexpr auto path_count = 10;

  auto const store_path
      = wtr::test_watcher::test_store_path / "event_targets_store";

  auto [event_sent_list, event_recv_list] = wtr::test_watcher::watch_gather(
      "Event Targets", store_path, path_count);

  for (size_t i = 0;
       i < std::min(event_sent_list.size(), event_recv_list.size()); ++i)
  {
    if (event_sent_list[i].kind != wtr::watcher::event::kind::watcher) {
      if (event_sent_list[i].where != event_recv_list[i].where)
        std::cout << "[ where ] [ " << i << " ] sent "
                  << event_sent_list[i].where << ", but received "
                  << event_recv_list[i].where << "\n";
      if (event_sent_list[i].what != event_recv_list[i].what)
        std::cout << "[ what ] [ " << i << " ] sent " << event_sent_list[i].what
                  << ", but received " << event_recv_list[i].what << "\n";
      if (event_sent_list[i].kind != event_recv_list[i].kind)
        std::cout << "[ kind ] [ " << i << " ] sent " << event_sent_list[i].kind
                  << ", but received " << event_recv_list[i].kind << "\n";
      REQUIRE(event_sent_list[i].where == event_recv_list[i].where);
      REQUIRE(event_sent_list[i].what == event_recv_list[i].what);
      REQUIRE(event_sent_list[i].kind == event_recv_list[i].kind);
    }
  }

  REQUIRE(event_sent_list.size() == event_recv_list.size());
};
