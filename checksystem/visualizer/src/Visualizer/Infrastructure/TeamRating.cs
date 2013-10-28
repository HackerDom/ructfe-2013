#region

using System.Collections.Generic;
using System.Linq;

#endregion

namespace Visualizer {
    internal static class TeamRating {
        public static int Rating (Team team, IEnumerable <Team> teams) {
            var max = teams.Max (_ => Attack (_, teams) + Defence (_, teams) + Advisory (_, teams) + Task (_, teams));
            if (max == 0)
                return 0;

            return ((Attack (team, teams) + Defence (team, teams) + Advisory (team, teams) + Task (team, teams)) * 100) / max;
        }

        public static int Attack (Team team, IEnumerable <Team> teams) {
            var max = teams.Max (_ => _.AttackScores);
            if (max == 0)
                return 0;

            return (100 * team.AttackScores) / max;
        }

        public static int Defence (Team team, IEnumerable <Team> teams) {
            var max = teams.Max (_ => _.DefenceScores);
            if (max == 0)
                return 0;

            return (100 * team.DefenceScores) / max;
        }

        public static int Advisory (Team team, IEnumerable <Team> teams) {
            var max = teams.Max (_ => _.AdvisoryScores);
            if (max == 0)
                return 0;

            return (100 * team.AdvisoryScores) / max;
        }

        public static int Task (Team team, IEnumerable <Team> teams) {
            var max = teams.Max (_ => _.TaskScores);
            if (max == 0)
                return 0;

            return (100 * team.TaskScores) / max;
        }
    }
}