class MatchOptions
{
  String eliminationType;
  String respawnTimeType;
  int respawnDuration;
  String totalGameTimeType;
  int totalGameTimeDuration;
  String offLimitAreas;
  String safetyMethods;

  MatchOptions(this.eliminationType,
   this.respawnTimeType, 
   this.respawnDuration, 
   this.totalGameTimeType, 
   this.totalGameTimeDuration, 
   this.offLimitAreas, 
   this.safetyMethods);
}