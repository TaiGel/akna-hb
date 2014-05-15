using System.Windows.Media;
using Styx.Common;

namespace IronpawTokens.Helpers {
    internal class CustomLog {

        // ===========================================================
        // Constants
        // ===========================================================

        // ===========================================================
        // Fields
        // ===========================================================

        // ===========================================================
        // Constructors
        // ===========================================================

        // ===========================================================
        // Getter & Setter
        // ===========================================================

        private static string PreviusNormal { get; set; }
        private static string PreviusDiagnostic { get; set; }

        // ===========================================================
        // Methods for/from SuperClass/Interfaces
        // ===========================================================

        // ===========================================================
        // Methods
        // ===========================================================

        public static void Normal(string message, params object[] args) {
            if(message == PreviusNormal) {
                return;
            }

            PreviusNormal = message;
            CustomNormalLog(message, args);
        }

        public static void Diagnostic(string message, params object[] args) {
            if(message == PreviusDiagnostic) {
                return;
            }

            PreviusDiagnostic = message;
            CustomDiagnosticLog(message, args);
        }

        // ===========================================================
        // Inner and Anonymous Classes
        // ===========================================================

        private static void CustomNormalLog(string message, params object[] args) {
            if(args.Length <= 0) {
                Logging.Write(Colors.DeepSkyBlue, "[IronpawTokens]: " + message);
                return;
            }

            Logging.Write(Colors.DeepSkyBlue, "[IronpawTokens]: " + message, args);
        }

        private static void CustomDiagnosticLog(string message, params object[] args) {
            if(args.Length <= 0) {
                Logging.WriteDiagnostic(Colors.Orange, "[IronpawTokens Diag]: " + message);
                return;
            }

            Logging.WriteDiagnostic(Colors.Orange, "[IronpawTokens Diag]: " + message, args);
        }
    }
}
