import 'player.dart';
import '../models/match_options.dart';

enum GroupState { notStarted, running, finished }

class Group {
  String groupName;
  Map<String, Player> players;
  MatchOptions matchOptions;

  DateTime timeStarted;
  DateTime timeEnding;

  String groupHost;
  GroupState state = GroupState.notStarted;
  Group(this.groupName, this.players, this.matchOptions, this.groupHost,
      this.timeStarted, this.timeEnding,
      {this.state = GroupState.notStarted});

  Player? get(String uid) => players[uid];

  @override
  String toString() {
    String result = "Group: $groupName\n";
    result += "Players: \n";
    for (int i = 0; i < players.length; i++) {
      result += "${players[i]}\n";
    }
    result += "Match Options: \n";
    result += "$matchOptions\n";
    return result;
  }
}
