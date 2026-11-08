# still — Your Second Mind

A personal visual archive PWA built with Vite, Supabase, and optional OpenAI tagging/search.

## Upload the application

Upload the contents of the `mindspace-pwa` folder from `still-pwa-source.zip` into the repository root (not the containing folder). Do not upload `.env` or API keys.

## Deploy

1. Import this repository at https://vercel.com/new.
2. Use Vite, build command `npm run build`, output `dist`.
3. Configure Supabase and the Vercel environment variables `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.
4. Run `supabase/migrations/001_init.sql` in Supabase SQL Editor and deploy the `ai-enrich` Edge Function with its server-side `OPENAI_API_KEY` secret.

Without Supabase variables the app operates in local-only demo mode, with no cloud sync or AI.
