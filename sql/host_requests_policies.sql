-- RLS policies for public.host_requests
-- Guards: keep scope minimal; do not weaken other policies

-- Ensure RLS enabled
ALTER TABLE public.host_requests ENABLE ROW LEVEL SECURITY;

-- Backward-compatible column for rejection reason
ALTER TABLE public.host_requests
ADD COLUMN IF NOT EXISTS rejection_reason text;

-- INSERT: allow authenticated users to insert their own request
DROP POLICY IF EXISTS "host_requests_insert_own" ON public.host_requests;
CREATE POLICY "host_requests_insert_own"
ON public.host_requests
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- SELECT: owner and admins can read
DROP POLICY IF EXISTS "host_requests_select_owner_or_admin" ON public.host_requests;
CREATE POLICY "host_requests_select_owner_or_admin"
ON public.host_requests
FOR SELECT
USING (
  user_id = auth.uid()
  OR EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
  )
);

-- UPDATE: admins only (for review actions)
DROP POLICY IF EXISTS "host_requests_update_admin_only" ON public.host_requests;
CREATE POLICY "host_requests_update_admin_only"
ON public.host_requests
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

-- Remove permissive update policy, if present, to ensure only admins can update
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'host_requests' AND polname = 'Users can update their own host requests'
  ) THEN
    EXECUTE 'DROP POLICY "Users can update their own host requests" ON public.host_requests';
  END IF;
END $$;


