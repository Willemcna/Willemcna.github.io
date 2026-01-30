-- org_webhooks: store webhook URLs per organization (Settings -> Webhook credentials)
-- Run this in your central Supabase SQL Editor.

-- Table
CREATE TABLE IF NOT EXISTS org_webhooks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  webhook_key TEXT NOT NULL,
  webhook_url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(org_id, webhook_key)
);

CREATE INDEX IF NOT EXISTS idx_org_webhooks_org_id ON org_webhooks(org_id);

-- RLS
ALTER TABLE org_webhooks ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (for idempotency)
DROP POLICY IF EXISTS "Users can view webhooks of their organizations" ON org_webhooks;
DROP POLICY IF EXISTS "Owners and admins can create webhooks" ON org_webhooks;
DROP POLICY IF EXISTS "Owners and admins can update webhooks" ON org_webhooks;
DROP POLICY IF EXISTS "Owners and admins can delete webhooks" ON org_webhooks;

-- Users can view webhooks for organizations they belong to
CREATE POLICY "Users can view webhooks of their organizations"
  ON org_webhooks FOR SELECT
  USING (
    org_id IN (
      SELECT org_id FROM organization_members
      WHERE user_id = auth.uid()
    )
  );

-- Owners and admins can insert webhooks
CREATE POLICY "Owners and admins can create webhooks"
  ON org_webhooks FOR INSERT
  WITH CHECK (
    org_id IN (
      SELECT org_id FROM organization_members
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
    )
  );

-- Owners and admins can update webhooks
CREATE POLICY "Owners and admins can update webhooks"
  ON org_webhooks FOR UPDATE
  USING (
    org_id IN (
      SELECT org_id FROM organization_members
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
    )
  );

-- Owners and admins can delete webhooks
CREATE POLICY "Owners and admins can delete webhooks"
  ON org_webhooks FOR DELETE
  USING (
    org_id IN (
      SELECT org_id FROM organization_members
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
    )
  );

-- Function to update updated_at (include in case main migration not run)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists (for idempotency)
DROP TRIGGER IF EXISTS update_org_webhooks_updated_at ON org_webhooks;

-- Auto-update updated_at
CREATE TRIGGER update_org_webhooks_updated_at
  BEFORE UPDATE ON org_webhooks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
