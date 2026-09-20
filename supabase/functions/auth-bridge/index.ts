import "https://deno.land/x/xhr@0.3.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { SignJWT, createRemoteJWKSet, jwtVerify } from "https://deno.land/x/jose@v4.14.4/index.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID"); // e.g. storemate-saas-app
const PROJECT_JWT_SECRET = Deno.env.get("PROJECT_JWT_SECRET");

// Google's public JWKS endpoint for Firebase Auth tokens (RS256)
const JWKS = createRemoteJWKSet(
  new URL("https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com")
);

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(JSON.stringify({ error: "Missing or invalid Authorization header" }), {
        status: 401,
        headers: { "Content-Type": "application/json", 'Access-Control-Allow-Origin': '*' },
      });
    }

    const firebaseToken = authHeader.split("Bearer ")[1];

    // Verify Firebase ID token using Google's public JWKS keys (RS256)
    // This is the correct way to verify Firebase Auth tokens.
    let payload;
    try {
      const verifyOptions: Record<string, unknown> = {};

      // Only enforce issuer/audience if FIREBASE_PROJECT_ID is configured
      if (FIREBASE_PROJECT_ID && FIREBASE_PROJECT_ID !== '') {
        verifyOptions.issuer = `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`;
        verifyOptions.audience = FIREBASE_PROJECT_ID;
      }

      const result = await jwtVerify(firebaseToken, JWKS, verifyOptions);
      payload = result.payload;
    } catch (verifyError: any) {
      console.error("Firebase token verification failed:", verifyError.message);
      return new Response(JSON.stringify({ error: "Invalid Firebase token", detail: verifyError.message }), {
        status: 401,
        headers: { "Content-Type": "application/json", 'Access-Control-Allow-Origin': '*' },
      });
    }

    // Extract user info from the verified token payload
    const firebaseUid = (payload as any).user_id || payload.sub;
    const phone_number = (payload as any).phone_number;

    if (!firebaseUid) {
      return new Response(JSON.stringify({ error: "No user_id found in token" }), {
        status: 401,
        headers: { "Content-Type": "application/json", 'Access-Control-Allow-Origin': '*' },
      });
    }

    // Mint Supabase JWT
    if (!PROJECT_JWT_SECRET) {
      throw new Error("PROJECT_JWT_SECRET is not set");
    }

    const secret = new TextEncoder().encode(PROJECT_JWT_SECRET);
    
    // We create a custom JWT that Supabase will accept.
    // Note: 'sub' cannot be the firebase_uid directly if auth.uid() casts it to UUID.
    // So we put it in a custom claim `firebase_uid`.
    const jwt = await new SignJWT({
      role: "authenticated",
      aud: "authenticated",
      firebase_uid: firebaseUid,
      phone: phone_number,
    })
      .setProtectedHeader({ alg: "HS256" })
      .setIssuedAt()
      .setExpirationTime("2h") // Token expires in 2 hours
      .sign(secret);

    return new Response(
      JSON.stringify({
        access_token: jwt,
        firebase_uid: firebaseUid,
        phone_number: phone_number,
      }),
      {
        headers: { "Content-Type": "application/json", 'Access-Control-Allow-Origin': '*' },
      },
    );
  } catch (error: any) {
    console.error("Error:", error.message);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json", 'Access-Control-Allow-Origin': '*' },
    });
  }
});
