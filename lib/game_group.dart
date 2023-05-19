import 'player.dart';
import '../models/match_options.dart';

class Group {
  String group_name;
  List<Player> players;
  MatchOptions matchOptions;
  Group(this.group_name, this.players, this.matchOptions);
}
