# WhatsApp AI Dashboard Platform

A Flutter web application for monitoring and analyzing WhatsApp AI agent conversations in real-time. This multi-tenant platform allows businesses to connect their Supabase instances and visualize KPIs, chat conversations, and analytics.

## Features

- **Real-time Analytics**: Track KPIs, message volume, and performance metrics
- **WhatsApp-style Chat View**: View conversations exactly as they appear in WhatsApp
- **Order Link Tracking**: Monitor when order links are sent to customers
- **Human Handover Detection**: Track when conversations are escalated to human agents
- **Product Insights**: Discover top products customers ask about
- **Multi-tenant Support**: Manage multiple organizations with separate Supabase connections
- **Real-time Updates**: Live updates using Supabase Realtime subscriptions

## Setup

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- A central Supabase project for authentication and tenant connection storage
- Client Supabase instances (one per organization) with the following tables:
  - `n8n_chat_histories` (session_id, message jsonb, time)
  - `Products 01_duplicate` or `products` (Name field)

### Installation (local development)

1. **Clone the repository:**
```bash
git clone <repository-url>
cd aplle
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Set up environment variables:**
   
   Copy the example environment file and fill in your credentials:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your central Supabase credentials:
   ```env
   SUPABASE_URL=https://your-central-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```
   
   > **Important**: The `.env` file is **not** committed to git. Never commit your actual credentials.

4. **Set up the database:**
   
   Before running the app, ensure your central Supabase database is set up:
   - Run the migration script `supabase_migrations.sql` in your Supabase SQL Editor
   - See `DATABASE_SETUP.md` for detailed instructions
   - This creates the required tables: `organizations`, `profiles`, `organization_members`, `tenant_connections`

5. **Run the application:**
   
   **Option A: Using the provided script (Recommended)**
   ```bash
   ./scripts/run_web_with_env.sh
   ```
   This script automatically loads credentials from your `.env` file and passes them via `--dart-define` flags.
   
   **Option B: Manual command**
   ```bash
   flutter run -d chrome \
     --dart-define=SUPABASE_URL=your-url \
     --dart-define=SUPABASE_ANON_KEY=your-key
   ```
   
   **Option C: VS Code Debugger**
   - Use the "Flutter Web (Debug)" configuration in VS Code
   - It automatically uses credentials from your `.env` file via the pre-configured task
   
   The app will be available at `http://localhost:8080`

6. **Connect a tenant Supabase (after first login):**
   - Sign up or log in to create your account
   - Go to Settings page
   - Add your tenant Supabase URL and Anon Key
   - The tenant Supabase should have the `n8n_chat_histories` table with chat data

### Configuration in production

For production deployments, you should **not** commit any real Supabase credentials to the repo or to built artifacts:

- `SUPABASE_URL` and `SUPABASE_ANON_KEY` are read at runtime by `lib/core/config/supabase_config.dart`.
- The app supports two methods (in priority order):
  1. `--dart-define` flags (recommended for production)
  2. `.env` file via `flutter_dotenv` (works for local development)

**Production build:**
```bash
flutter build web \
  --dart-define=SUPABASE_URL=https://your-central-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

The built `build/` directory is ignored by git, so production builds are created per deployment environment and not tracked in this repository.

**Note**: For local development, the `.env` file method works, but using `--dart-define` (via the provided script) ensures consistency with production and avoids potential issues with `.env` file loading in web builds.

### Deploy to production

**Option A: Auto-deploy to GitHub Pages (recommended)**  
Push to `main` to build and deploy to GitHub Pages; you can link your GoDaddy custom domain via DNS. See **[DEPLOY_GODADDY.md](DEPLOY_GODADDY.md)** (Option 3) for setup: GitHub Secrets (`SUPABASE_URL`, `SUPABASE_ANON_KEY`), enabling Pages from Actions, and custom domain.

**Option B: Manual upload to GoDaddy**  
1. Put your production Supabase URL and anon key in `.env`.
2. Build and create the upload zip: `./publish.sh`
3. Upload to GoDaddy: use the contents of `build/web/` or the zip `build/aplle-web-deploy.zip`. See **[DEPLOY_GODADDY.md](DEPLOY_GODADDY.md)** for step-by-step instructions.

To update the live site: with GitHub Pages, push to `main`; with manual GoDaddy, run `./publish.sh` again and re-upload.

## Database Schema

### Central Supabase

The following tables are required in your central Supabase project:

- `organizations` - Stores organization information
- `profiles` - User profiles
- `organization_members` - Links users to organizations with roles
- `tenant_connections` - Stores Supabase connection details per organization

### Client Supabase

Each organization's Supabase instance should have:

- `n8n_chat_histories` table with:
  - `id` (integer)
  - `session_id` (varchar) - Phone number/unique identifier
  - `message` (jsonb) - Message content with type ('human' or 'ai') and content
  - `time` (timestamp)

- `Products 01_duplicate` or `products` table with:
  - `Name` (text) - Product name

## Usage

1. **Sign Up**: Create an account (automatically creates an organization)
2. **Connect Supabase**: Go to Settings and add your Supabase URL and Anon Key
3. **View Dashboard**: See KPIs and analytics on the Dashboard page
4. **View Chats**: Browse conversations in WhatsApp-style interface on the Chats page. Each session has a **star toggle** next to the session ID to star/unstar conversations.
5. **Switch Organizations**: Use the organization switcher if you belong to multiple organizations

## Project Structure

```
lib/
├── core/
│   ├── config/          # Supabase configuration
│   ├── models/          # Data models
│   ├── services/        # Business logic services
│   └── utils/           # Utility functions
├── features/
│   ├── auth/            # Authentication pages
│   ├── home/            # Home page
│   └── dashboard/       # Dashboard pages and widgets
└── shared/              # Shared widgets and theme
```

## Key Components

- **Authentication**: Supabase Auth for user management
- **State Management**: Provider pattern for state management
- **Charts**: Syncfusion Flutter Charts for analytics visualization
- **Real-time**: Supabase Realtime for live updates

## Message Format

Messages in `n8n_chat_histories.message` should follow this JSON structure:

```json
{
  "type": "human" | "ai",
  "content": "Message text here",
  "additional_kwargs": {},
  "response_metadata": {}
}
```

## KPI Calculations

- **Time Saved**: (AI messages × 120 seconds) + (switches × 30 seconds)
- **Order Links**: Detected via URL regex in AI messages
- **Handovers**: Detected via phone number regex in AI messages
- **Top Products**: Matched against Products table by name

## Troubleshooting

### App won't start / Supabase initialization errors

- **Check your `.env` file**: Ensure it exists in the project root with `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- **Use the script**: Run `./scripts/run_web_with_env.sh` instead of `flutter run` directly
- **Verify credentials**: Make sure your Supabase URL and Anon Key are correct
- **Check database setup**: Ensure `supabase_migrations.sql` has been run on your central Supabase

### Authentication not working

- Verify your central Supabase has the required tables (see Database Schema section)
- Check that Row Level Security (RLS) policies are set up correctly
- Ensure the `profiles` table trigger is created (auto-creates profiles on signup)

### Tenant connection not working

- Verify the tenant Supabase URL and Anon Key are correct
- Check that the tenant Supabase has the `n8n_chat_histories` table
- Ensure RLS policies on the tenant Supabase allow reads with the provided Anon Key
- Check browser console for CORS errors (Supabase should handle this, but verify)

### Real-time updates not working

- Ensure Supabase Realtime is enabled for the `n8n_chat_histories` table
- In Supabase dashboard: Database → Replication → Enable for `n8n_chat_histories`
- Check browser console for WebSocket connection errors

## Release Checklist

Before you deploy this app to production, make sure you have:

1. **Database set up**:
   - Run `supabase_migrations.sql` in your central Supabase project (see `DATABASE_SETUP.md`).
2. **Environment configured**:
   - Created a `.env` file locally with `SUPABASE_URL` and `SUPABASE_ANON_KEY` for development.
   - Configured your CI/CD or hosting provider to pass these values via `--dart-define` for production builds.
3. **Secrets verified**:
   - Ensured `.env`, `build/`, and generated platform config files are **not** committed to git.
   - Optionally run a secret scanner (e.g. `trufflehog`, `git-secrets`) against the repo.
4. **Build created for target platform**:
   - For web: `flutter build web` with the appropriate `--dart-define` flags.
5. **Smoke tests**:
   - Sign up, create an organization, connect a tenant Supabase, and verify that the dashboard and chat views load correctly.

## License

[Your License Here]
