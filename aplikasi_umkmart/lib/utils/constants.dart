class AppConstants {
  // ── API Server ────────────────────────────────────────────────────────────────
  // Ganti dengan IP laptop 
  static const String baseUrl = 'http://192.168.0.xxx:8000/api';

  // ── Auth tokens ───────────────────────────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userKey  = 'user_data';
  static const int nilaiPoin   = 10000;

  // ── Gemini AI ─────────────────────────────────────────────────────────────────
  // Daftarkan di: https://aistudio.google.com/app/apikey
  // Isi API key Anda di sini untuk mengaktifkan fitur AI Bisnis
  static const String geminiApiKey = "YOUR_API_KEY_HERE";
}