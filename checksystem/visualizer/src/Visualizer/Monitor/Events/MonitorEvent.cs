namespace Visualizer {
    public static class MonitorEvent {
        public static IMonitorEvent Parse (string str) {
            if (str == null || str.Length < 2)
                return null;

            try {
                switch (str.Substring (0, 2)) {
                    case "f " :
                        return new GetFlagEvent (str);

                    case "s " :
                        return new CheckServiceEvent (str);

                    case "at" :
                        return new AddScoresEvent (AddScoresEvent.Types.ATTACK, str);

                    case "de" :
                        return new AddScoresEvent (AddScoresEvent.Types.DEFENCE, str);

                    case "ad" :
                        return new AddScoresEvent (AddScoresEvent.Types.ADVISORY, str);

                    case "ta" :
                        return new AddScoresEvent (AddScoresEvent.Types.TASK, str);

                    default :
                        return null;
                }
            }
            catch {
                return null;
            }
        }
    }
}