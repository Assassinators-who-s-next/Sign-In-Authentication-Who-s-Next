import 'player.dart';
import '../models/match_options.dart';

enum GroupState { notStarted, running, finished }

class Group {
  String group_name;
  List<Player> players;
  MatchOptions matchOptions;
  String groupHost;
  GroupState state = GroupState.notStarted;
  Group(this.group_name, this.players, this.matchOptions, this.groupHost,
      {this.state = GroupState.notStarted});
}
