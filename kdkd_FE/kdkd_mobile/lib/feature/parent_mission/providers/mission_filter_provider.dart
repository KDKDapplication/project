import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';

final missionFilterProvider = StateProvider<MissionStatus>((ref) => MissionStatus.IN_PROGRESS);

final missionFilterSelectedProvider = StateProvider<List<bool>>((ref) => [true, false]);
