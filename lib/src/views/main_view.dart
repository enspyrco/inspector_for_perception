import 'dart:async';

import 'package:astro_error_handling/astro_error_handling.dart';
import 'package:astro_inspector_screen/astro_inspector_screen.dart';
import 'package:astro_locator/astro_locator.dart';
import 'package:astro_types/core_types.dart';
import 'package:astro_types/json_types.dart';
import 'package:flutter/widgets.dart';

import '../missions/add_mission_report.dart';
import '../missions/remove_all.dart';
import 'app_state_view/app_state_view.dart';
import 'missions_history_view/missions_history_view.dart';

/// The [MainView] lays out the [MissionsHistoryView] and [AppStateView].
///
/// The [MainView] takes a [Stream] of mission updates from [MissionControl],
/// listens to the stream and starts an appropriate Mission (as we are also
/// using astro for our state management) for each incoming event.
class MainView extends StatefulWidget {
  const MainView(this._onMissionReport, {super.key});

  final Stream<JsonMap>? _onMissionReport;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  StreamSubscription<JsonMap>? _subscription;

  @override
  void initState() {
    super.initState();

    if (widget._onMissionReport != null) {
      _subscription = widget._onMissionReport!.listen(
        (update) {
          if (update['type'] == 'astro:mission_update') {
            locate<MissionControl<InspectorState>>()
                .land(AddMissionReport(update['data']));
          } else if (update['type'] == 'astro:remove_all') {
            locate<MissionControl<InspectorState>>().land(RemoveAll());
          }
        },
        onError: (Object error, StackTrace trace) =>
            locate<MissionControl<InspectorState>>().land(
          CreateErrorReport(error, trace),
        ),
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (widget._onMissionReport == null)
        ? const Text('Not connected to app...')
        : Row(
            children: [
              const MissionsHistoryView(),
              AppStateView(),
            ],
          );
  }
}