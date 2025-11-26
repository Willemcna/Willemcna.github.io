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

1. Clone the repository:
```bash
git clone <repository-url>
cd aplle
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create a `.env` file in the root directory (this file is **not** committed to git):
```env
SUPABASE_URL=https://your-central-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

4. Run the application for local development:
```bash
flutter run -d chrome
```

### Configuration in production

For production deployments, you should **not** commit any real Supabase credentials to the repo or to built artifacts:

- `SUPABASE_URL` and `SUPABASE_ANON_KEY` are read at runtime by `lib/core/config/supabase_config.dart`.
- In local development they come from your `.env` file (via `flutter_dotenv`).
- In production you should inject them using Flutter’s `--dart-define` flags (for example in your CI/CD pipeline or hosting provider):

```bash
flutter build web \
  --dart-define=SUPABASE_URL=https://your-central-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

The built `build/` directory is ignored by git, so production builds are created per deployment environment and not tracked in this repository.

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
4. **View Chats**: Browse conversations in WhatsApp-style interface on the Chats page
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
