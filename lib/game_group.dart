import 'player.dart';
import '../models/match_options.dart';

class group {
  String group_name;
  List<player> players;
  MatchOptions matchOptions;
  group(this.group_name, this.players, this.matchOptions);
}
