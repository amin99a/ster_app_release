-- Host documents table and RLS policies (backward-compatible)
-- Guards: additive only; no breaking schema changes

-- Create table if not exists
CREATE TABLE IF NOT EXISTS public.host_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  type text NOT NULL, -- id_front | id_back | license | ownership | selfie_optional
  storage_path text NOT NULL,
  verified boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.host_documents ENABLE ROW LEVEL SECURITY;

-- Policies: owner can insert/select own; admins can select/update for verification
DROP POLICY IF EXISTS "host_documents_insert_owner" ON public.host_documents;
CREATE POLICY "host_documents_insert_owner"
ON public.host_documents
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "host_documents_select_owner_or_admin" ON public.host_documents;
CREATE POLICY "host_documents_select_owner_or_admin"
ON public.host_documents
FOR SELECT
USING (
  user_id = auth.uid()
  OR EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
  )
);

DROP POLICY IF EXISTS "host_documents_update_admin_only" ON public.host_documents;
CREATE POLICY "host_documents_update_admin_only"
ON public.host_documents
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
  )
);


