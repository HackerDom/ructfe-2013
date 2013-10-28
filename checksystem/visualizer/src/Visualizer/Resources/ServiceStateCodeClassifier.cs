using System.Collections.Generic;

namespace Visualizer.Resources {
    public static class ServiceStateCodeClassifier {
        private readonly static Dictionary <ServiceStateCode, string> dictionary;
        private readonly static string default_string;

        static ServiceStateCodeClassifier () {
            dictionary = new Dictionary <ServiceStateCode, string> {
                                                                       {
                                                                           ServiceStateCode.STATE_OK,
                                                                           LocalizedStrings.Service_OK
                                                                           },
                                                                       {
                                                                           ServiceStateCode.STATE_DOWN,
                                                                           LocalizedStrings.Service_DOWN
                                                                           },
                                                                       {
                                                                           ServiceStateCode.STATE_INCORRECT,
                                                                           LocalizedStrings.Service_MUMBLE
                                                                           },
                                                                       {
                                                                           ServiceStateCode.STATE_NOT_FLAG,
                                                                           LocalizedStrings.Service_NOTFLAG
                                                                           },
                                                                       {
                                                                           ServiceStateCode.CHECKER_ERROR,
                                                                           LocalizedStrings.Checker_Error
                                                                           }
                                                                   };

            default_string = LocalizedStrings.Service_UNKNOWN;
        }

        public static string FriendlyNamed (ServiceStateCode code) {
            return dictionary.ContainsKey (code) ? dictionary [code] : default_string;
        }
    }
}