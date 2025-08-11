-- Add car use type enum and column (backward-compatible)
-- Enum: car_use_type = ('daily','business','event')

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type WHERE typname = 'car_use_type'
  ) THEN
    CREATE TYPE car_use_type AS ENUM ('daily','business','event');
  END IF;
END$$;

-- Add column to cars if missing
ALTER TABLE public.cars
  ADD COLUMN IF NOT EXISTS use_type car_use_type NOT NULL DEFAULT 'daily';

-- Backfill any nulls (in case of older rows before NOT NULL applied)
UPDATE public.cars SET use_type = 'daily' WHERE use_type IS NULL;

-- Optional: index for filter performance
CREATE INDEX IF NOT EXISTS idx_cars_use_type ON public.cars (use_type);


