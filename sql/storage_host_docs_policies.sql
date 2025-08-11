-- Storage bucket and RLS for host documents

-- Ensure bucket exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('host-docs', 'host-docs', false)
ON CONFLICT (id) DO NOTHING;

-- Drop existing policies for a clean slate
DROP POLICY IF EXISTS "host_docs_insert_owner" ON storage.objects;
DROP POLICY IF EXISTS "host_docs_select_owner" ON storage.objects;
DROP POLICY IF EXISTS "host_docs_update_owner" ON storage.objects;
DROP POLICY IF EXISTS "host_docs_delete_owner" ON storage.objects;

-- Owner-only access by folder convention: name like 'userId/...' so first folder equals auth.uid()
CREATE POLICY "host_docs_insert_owner" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'host-docs' AND
  (auth.uid()::text = (storage.foldername(name))[1])
);

CREATE POLICY "host_docs_select_owner" ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'host-docs' AND
  (auth.uid()::text = (storage.foldername(name))[1]
   OR EXISTS (
     SELECT 1 FROM public.user_profiles up
     WHERE up.id = auth.uid() AND up.role = 'admin'
   ))
);

CREATE POLICY "host_docs_update_owner" ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'host-docs' AND
  (auth.uid()::text = (storage.foldername(name))[1])
)
WITH CHECK (
  bucket_id = 'host-docs' AND
  (auth.uid()::text = (storage.foldername(name))[1])
);

CREATE POLICY "host_docs_delete_owner" ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'host-docs' AND
  (auth.uid()::text = (storage.foldername(name))[1]
   OR EXISTS (
     SELECT 1 FROM public.user_profiles up
     WHERE up.id = auth.uid() AND up.role = 'admin'
   ))
);


