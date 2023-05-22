import 'player.dart';
import '../models/match_options.dart';

enum GroupState { notStarted, running, finished }

class Group {
  String group_name;
  List<Player> players;
  MatchOptions matchOptions;
  GroupState state = GroupState.notStarted;
  Group(this.group_name, this.players, this.matchOptions,
      {this.state = GroupState.notStarted});
}
