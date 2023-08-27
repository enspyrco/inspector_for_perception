import 'package:json_utils/json_utils.dart';
import 'package:types_for_perception/beliefs.dart';

class ParentedLandingMission<S extends CoreBeliefs>
    implements LandingMission<S> {
  ParentedLandingMission(this._mission, this.parent);

  // The inner mission, wrapped by this class
  final LandingMission<S> _mission;

  // The mission that created _mission
  final AwayMission<S>? parent;

  @override
  JsonMap toJson() => {
        'name_': _mission.toJson()['name_'],
        'state_': _mission.toJson()['state_'],
        'type_': 'sync',
        'id_': _mission.hashCode,
        'parent_': parent?.hashCode,
      };

  @override
  S landingInstructions(S state) => _mission.landingInstructions(state);
}

class ParentedAwayMission<S extends CoreBeliefs> implements AwayMission<S> {
  ParentedAwayMission(this._mission, this.parent);

  // The inner mission, wrapped by this class
  final AwayMission<S> _mission;

  // The mission that created _mission
  final AwayMission<S>? parent;

  @override
  JsonMap toJson() => {
        'name_': _mission.toJson()['name_'],
        'state_': _mission.toJson()['state_'],
        'type_': 'async',
        'id_': _mission.hashCode,
        'parent_': parent?.hashCode,
      };

  @override
  Future<void> flightPlan(MissionControl<S> missionControl) =>
      _mission.flightPlan(missionControl);
}
