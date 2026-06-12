<?php
namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function register(Request $request)
{
    $request->validate([
        'nama'     => 'required|string',   // ← ubah username → nama
        'email'    => 'required|email|unique:users',
        'password' => 'required|min:6',
        'role'     => 'in:admin,kasir',
    ]);

    $user = User::create([
        'nama'     => $request->nama,      // ← ubah username → nama
        'email'    => $request->email,
        'password' => Hash::make($request->password),
        'role'     => $request->role ?? 'kasir',
    ]);

    $token = $user->createToken('auth_token')->plainTextToken;
    return response()->json(['token' => $token, 'user' => $user], 201);
}

    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Email atau password salah'], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;
        return response()->json(['token' => $token, 'user' => $user]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logout berhasil']);
    }

    public function me(Request $request)
    {
        return response()->json($request->user());
    }

    public function loginWithGoogle(Request $request)
    {
        $request->validate([
            'id_token' => 'required|string',
        ]);

        $idToken = $request->id_token;

        try {
            // Verify ID Token via Google's API endpoint
            $response = Http::get('https://oauth2.googleapis.com/tokeninfo', [
                'id_token' => $idToken,
            ]);

            if ($response->failed()) {
                return response()->json(['message' => 'Token Google tidak valid atau gagal diverifikasi'], 400);
            }

            $payload = $response->json();
            $email = $payload['email'] ?? null;
            $nama = $payload['name'] ?? 'Google Cashier';

            if (!$email) {
                return response()->json(['message' => 'Email tidak ditemukan dari akun Google'], 400);
            }

            $user = User::where('email', $email)->first();

            if (!$user) {
                $user = User::create([
                    'nama' => $nama,
                    'email' => $email,
                    'password' => Hash::make(Str::random(32)),
                    'role' => 'kasir',
                ]);
            }

            $token = $user->createToken('auth_token')->plainTextToken;
            return response()->json(['token' => $token, 'user' => $user]);

        } catch (\Exception $e) {
            return response()->json(['message' => 'Terjadi kesalahan sistem saat verifikasi Google: ' . $e->getMessage()], 500);
        }
    }

    public function loginWithFacebook(Request $request)
    {
        $request->validate([
            'access_token' => 'required|string',
        ]);

        $accessToken = $request->access_token;

        try {
            // Fetch user profile from Facebook Graph API
            $response = Http::get('https://graph.facebook.com/me', [
                'fields' => 'id,name,email',
                'access_token' => $accessToken,
            ]);

            if ($response->failed()) {
                return response()->json(['message' => 'Access Token Facebook tidak valid atau gagal diverifikasi'], 400);
            }

            $payload = $response->json();
            $email = $payload['email'] ?? null;
            $nama = $payload['name'] ?? 'Facebook Cashier';

            // Facebook accounts sometimes don't have email if registered via phone number.
            // If email is missing, we fallback to facebook_id@umkmart.com
            if (!$email) {
                $email = ($payload['id'] ?? 'fb_' . Str::random(10)) . '@umkmart.com';
            }

            $user = User::where('email', $email)->first();

            if (!$user) {
                $user = User::create([
                    'nama' => $nama,
                    'email' => $email,
                    'password' => Hash::make(Str::random(32)),
                    'role' => 'kasir',
                ]);
            }

            $token = $user->createToken('auth_token')->plainTextToken;
            return response()->json(['token' => $token, 'user' => $user]);

        } catch (\Exception $e) {
            return response()->json(['message' => 'Terjadi kesalahan sistem saat verifikasi Facebook: ' . $e->getMessage()], 500);
        }
    }
}