import 'player.dart';
import '../models/match_options.dart';

enum GroupState { notStarted, running, dead, finished }

class Group {
  String group_name;
  List<Player> players;
  MatchOptions matchOptions;

  String groupHost;
  GroupState state = GroupState.notStarted;
  Group(this.group_name, this.players, this.matchOptions, this.groupHost,
      {this.state = GroupState.notStarted});

  @override
  String toString() {
    String result = "Group: " + group_name + "\n";
    result += "Players: \n";
    for (int i = 0; i < players.length; i++) {
      result += players[i].toString() + "\n";
    }
    result += "Match Options: \n";
    result += matchOptions.toString() + "\n";
    return result;
  }
}
