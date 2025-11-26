# Database Setup Guide

This guide will help you set up the central Supabase database with all required tables.

## Prerequisites

- A Supabase project (create one at [supabase.com](https://supabase.com) if you don't have one)
- Access to your Supabase project's SQL Editor

## Steps to Set Up the Database

### 1. Open Supabase SQL Editor

1. Log in to your Supabase project dashboard
2. Navigate to the **SQL Editor** from the left sidebar
3. Click **New Query** to create a new SQL query

### 2. Run the Migration Script

1. Open the `supabase_migrations.sql` file in this repository
2. Copy the entire contents of the file
3. Paste it into the Supabase SQL Editor
4. Click **Run** (or press `Ctrl+Enter` / `Cmd+Enter`)

The script will:
- Create all required tables (`organizations`, `profiles`, `organization_members`, `tenant_connections`)
- Set up indexes for better performance
- Enable Row Level Security (RLS) on all tables
- Create RLS policies to secure your data
- Set up triggers for automatic timestamp updates
- Create a trigger to automatically create user profiles on signup

### 3. Verify the Setup

After running the migration, verify that the tables were created:

1. Go to **Table Editor** in your Supabase dashboard
2. You should see the following tables:
   - `organizations`
   - `profiles`
   - `organization_members`
   - `tenant_connections`

### 4. Test the Setup

You can test the setup by:

1. **Creating a test user** through your Flutter app's signup flow
2. **Verifying** that:
   - A profile is automatically created in the `profiles` table
   - An organization is created in the `organizations` table
   - The user is added as an owner in the `organization_members` table

## Database Schema Overview

### `organizations`
Stores organization information.
- `id` (UUID, Primary Key)
- `name` (Text)
- `created_at` (Timestamp)

### `profiles`
Extends Supabase auth.users with additional user information.
- `user_id` (UUID, Primary Key, References auth.users)
- `display_name` (Text)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

### `organization_members`
Links users to organizations with roles (many-to-many relationship).
- `org_id` (UUID, References organizations)
- `user_id` (UUID, References auth.users)
- `role` (Text: 'owner', 'admin', or 'member')
- `created_at` (Timestamp)
- Primary Key: (`org_id`, `user_id`)

### `tenant_connections`
Stores Supabase connection details for each organization's client database.
- `org_id` (UUID, Primary Key, References organizations)
- `supabase_url` (Text)
- `supabase_anon_key` (Text)
- `created_by` (UUID, References auth.users)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

## Security Features

The migration script includes:

- **Row Level Security (RLS)**: Enabled on all tables
- **RLS Policies**: 
  - Users can only view/modify data for organizations they belong to
  - Only owners/admins can manage members and tenant connections
  - Users can only modify their own profiles
- **Automatic Profile Creation**: When a user signs up, a profile is automatically created
- **Automatic Timestamps**: `updated_at` fields are automatically updated on record changes

## Troubleshooting

### Error: "relation already exists"
If you see this error, it means some tables already exist. You can either:
- Drop the existing tables and re-run the migration, or
- Modify the migration script to use `CREATE TABLE IF NOT EXISTS` (already included)

### Error: "permission denied"
Make sure you're running the SQL as a database administrator or with sufficient privileges.

### RLS Policies Not Working
If RLS policies seem too restrictive, you can temporarily disable RLS for testing:
```sql
ALTER TABLE organizations DISABLE ROW LEVEL SECURITY;
-- (repeat for other tables)
```
**Note**: Re-enable RLS before deploying to production!

## Next Steps

After setting up the database:

1. Update your `.env` file with your Supabase credentials (for local development only – do **not** commit this file):
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

2. For local development, run your Flutter application:
   ```bash
   flutter run -d chrome
   ```

3. For production builds (for example, when deploying to a static host), inject the Supabase credentials via `--dart-define` instead of `.env`:

   ```bash
   flutter build web \
     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
   ```

4. Test the signup flow to verify everything works correctly in both development and production environments.

