// Backend configuration (Python FastAPI backend)

const String RENDER_BASE_URL = "https://autocompanion-backend.onrender.com";
const String LOCAL_BASE_URL = "http://192.168.0.103:3000";
const int API_TIMEOUT_MS = 15000;
class BackendConfig {
  static const String renderBaseUrl =
      "https://autocompanion-backend.onrender.com";

  static const String localBaseUrl =
      "http://192.168.0.103:3000"; // your laptop IP if connected via USB/Wi-Fi

  // Automatically choose Render → fallback to local
  static String get activeBaseUrl => renderBaseUrl;
}
