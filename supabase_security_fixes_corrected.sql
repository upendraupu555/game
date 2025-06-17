-- ============================================================================
-- SUPABASE SECURITY FIXES (CORRECTED)
-- Fix security issues with SECURITY DEFINER views and functions
-- Fixed parameter ordering issues for PostgreSQL compatibility
-- ============================================================================

-- Fix 1: Remove SECURITY DEFINER from user_active_ad_removals view
-- and add proper RLS policies instead
DROP VIEW IF EXISTS user_active_ad_removals;

CREATE OR REPLACE VIEW user_active_ad_removals AS
SELECT 
    user_id,
    transaction_id,
    amount,
    currency,
    purchase_date,
    status
FROM user_purchases 
WHERE product_type = 'ad_removal' 
AND status = 'completed'
AND (
    auth.uid() = user_id  -- Users can only see their own ad removals
    OR auth.role() = 'service_role'  -- Service role can see all
);

-- Grant access to the view
GRANT SELECT ON user_active_ad_removals TO authenticated;

-- Fix 2: Remove SECURITY DEFINER from recent_leaderboard_entries view
-- and add proper RLS policies instead
DROP VIEW IF EXISTS recent_leaderboard_entries;

CREATE OR REPLACE VIEW recent_leaderboard_entries AS
SELECT
    le.id,
    le.score,
    le.game_mode,
    le.game_duration_seconds,
    le.board_snapshot,
    le.custom_base_number,
    le.time_limit,
    le.date_played,
    ROW_NUMBER() OVER (ORDER BY le.score DESC) as score_rank
FROM leaderboard_entries le
WHERE (
    -- Users can see their own entries
    (le.user_id IS NOT NULL AND auth.uid() = le.user_id)
    -- Or entries from their guest sessions (if they have the guest_id)
    OR (le.guest_id IS NOT NULL)
    -- Service role can see all
    OR auth.role() = 'service_role'
)
ORDER BY le.date_played DESC;

-- Grant access to the view
GRANT SELECT ON recent_leaderboard_entries TO authenticated;

-- Fix 3: Remove SECURITY DEFINER from user_statistics_summary view
-- and add proper RLS policies instead
DROP VIEW IF EXISTS user_statistics_summary;

CREATE OR REPLACE VIEW user_statistics_summary AS
SELECT
    us.id,
    us.user_id,
    us.guest_id,
    us.games_played,
    us.games_won,
    us.best_score,
    us.total_score,
    us.total_play_time_seconds,
    us.last_played,
    us.highest_tile_value,
    us.total_2048_achievements,
    ROUND((us.games_won::DECIMAL / NULLIF(us.games_played, 0)) * 100, 2) as win_rate_percentage,
    ROUND(us.total_score::DECIMAL / NULLIF(us.games_played, 0), 2) as average_score
FROM user_statistics us
WHERE (
    -- Users can see their own statistics
    (us.user_id IS NOT NULL AND auth.uid() = us.user_id)
    -- Or statistics from their guest sessions (if they have the guest_id)
    OR (us.guest_id IS NOT NULL)
    -- Service role can see all
    OR auth.role() = 'service_role'
);

-- Grant access to the view
GRANT SELECT ON user_statistics_summary TO authenticated;

-- Fix 4: Update functions to remove unnecessary SECURITY DEFINER
-- Keep SECURITY DEFINER only where absolutely necessary for functionality

-- Update has_active_ad_removal function - Remove SECURITY DEFINER
CREATE OR REPLACE FUNCTION has_active_ad_removal(user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_purchases 
        WHERE user_id = user_uuid 
        AND product_type = 'ad_removal' 
        AND status = 'completed'
        AND auth.uid() = user_uuid  -- Ensure user can only check their own status
    );
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

-- Drop existing function first to avoid conflicts
DROP FUNCTION IF EXISTS get_user_ad_removal_status(UUID);

-- Update get_user_ad_removal_status function - Remove SECURITY DEFINER
CREATE OR REPLACE FUNCTION get_user_ad_removal_status(user_uuid UUID)
RETURNS TABLE(
    has_removal BOOLEAN,
    purchase_date TIMESTAMPTZ,
    transaction_id VARCHAR(255),
    amount INTEGER,
    currency VARCHAR(10)
) AS $$
BEGIN
    -- Ensure user can only check their own status
    IF auth.uid() != user_uuid AND auth.role() != 'service_role' THEN
        RAISE EXCEPTION 'Access denied: You can only check your own ad removal status';
    END IF;

    RETURN QUERY
    SELECT 
        TRUE as has_removal,
        up.purchase_date,
        up.transaction_id,
        up.amount,
        up.currency
    FROM user_purchases up
    WHERE up.user_id = user_uuid 
    AND up.product_type = 'ad_removal' 
    AND up.status = 'completed'
    ORDER BY up.purchase_date DESC
    LIMIT 1;

    -- If no results, return false
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL::TIMESTAMPTZ, NULL::VARCHAR(255), NULL::INTEGER, NULL::VARCHAR(10);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

-- Update migrate_guest_data_to_user function - Keep SECURITY DEFINER for data migration
-- This function needs elevated privileges to update data across users
CREATE OR REPLACE FUNCTION migrate_guest_data_to_user(
    p_guest_id VARCHAR(16),
    p_user_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Only allow authenticated users to migrate their own data
    IF auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Access denied: You can only migrate data to your own account';
    END IF;

    -- Migrate leaderboard entries
    UPDATE leaderboard_entries 
    SET user_id = p_user_id, guest_id = NULL, updated_at = NOW()
    WHERE guest_id = p_guest_id;

    -- Migrate user statistics
    UPDATE user_statistics 
    SET user_id = p_user_id, guest_id = NULL, updated_at = NOW()
    WHERE guest_id = p_guest_id;

    -- Migrate sync status
    UPDATE sync_status 
    SET user_id = p_user_id, guest_id = NULL, updated_at = NOW()
    WHERE guest_id = p_guest_id;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;  -- Keep SECURITY DEFINER for data migration

-- Drop existing function first to avoid conflicts
DROP FUNCTION IF EXISTS get_user_leaderboard(UUID, VARCHAR(16), VARCHAR(50), INTEGER, INTEGER);

-- Update get_user_leaderboard function - Remove SECURITY DEFINER
-- Fixed parameter ordering: required parameters first, then optional ones
CREATE OR REPLACE FUNCTION get_user_leaderboard(
    p_user_id UUID DEFAULT NULL,
    p_guest_id VARCHAR(16) DEFAULT NULL,
    p_game_mode VARCHAR(50) DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id UUID,
    score INTEGER,
    game_mode VARCHAR(50),
    game_duration_seconds INTEGER,
    date_played TIMESTAMPTZ,
    score_rank BIGINT
) AS $$
BEGIN
    -- Ensure user can only access their own data
    IF p_user_id IS NOT NULL AND auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Access denied: You can only access your own leaderboard data';
    END IF;

    RETURN QUERY
    SELECT 
        le.id,
        le.score,
        le.game_mode,
        le.game_duration_seconds,
        le.date_played,
        ROW_NUMBER() OVER (ORDER BY le.score DESC) as score_rank
    FROM leaderboard_entries le
    WHERE (p_user_id IS NOT NULL AND le.user_id = p_user_id)
       OR (p_guest_id IS NOT NULL AND le.guest_id = p_guest_id)
       OR (p_user_id IS NULL AND p_guest_id IS NULL)
    AND (p_game_mode IS NULL OR le.game_mode = p_game_mode)
    ORDER BY le.score DESC, le.date_played DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

-- Drop existing function first to avoid conflicts
DROP FUNCTION IF EXISTS get_global_leaderboard(VARCHAR(50), INTEGER, INTEGER);

-- Update get_global_leaderboard function - Remove SECURITY DEFINER
CREATE OR REPLACE FUNCTION get_global_leaderboard(
    p_game_mode VARCHAR(50) DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id UUID,
    score INTEGER,
    game_mode VARCHAR(50),
    game_duration_seconds INTEGER,
    date_played TIMESTAMPTZ,
    score_rank BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        le.id,
        le.score,
        le.game_mode,
        le.game_duration_seconds,
        le.date_played,
        ROW_NUMBER() OVER (ORDER BY le.score DESC) as score_rank
    FROM leaderboard_entries le
    WHERE (p_game_mode IS NULL OR le.game_mode = p_game_mode)
    ORDER BY le.score DESC, le.date_played DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

-- Drop existing function first to avoid conflicts
DROP FUNCTION IF EXISTS add_leaderboard_entry(UUID, VARCHAR(16), INTEGER, VARCHAR(50), INTEGER, JSONB, INTEGER, INTEGER);

-- Update add_leaderboard_entry function - Remove SECURITY DEFINER
-- Fixed parameter ordering: required parameters first, then optional ones
CREATE OR REPLACE FUNCTION add_leaderboard_entry(
    p_score INTEGER,
    p_game_mode VARCHAR(50),
    p_game_duration_seconds INTEGER,
    p_user_id UUID DEFAULT NULL,
    p_guest_id VARCHAR(16) DEFAULT NULL,
    p_board_snapshot JSONB DEFAULT '{}',
    p_custom_base_number INTEGER DEFAULT NULL,
    p_time_limit INTEGER DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    entry_id UUID;
BEGIN
    -- Ensure user can only add entries for themselves
    IF p_user_id IS NOT NULL AND auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Access denied: You can only add leaderboard entries for yourself';
    END IF;

    INSERT INTO leaderboard_entries (
        user_id, guest_id, score, game_mode, game_duration_seconds,
        board_snapshot, custom_base_number, time_limit, date_played, created_at, updated_at
    ) VALUES (
        p_user_id, p_guest_id, p_score, p_game_mode, p_game_duration_seconds,
        p_board_snapshot, p_custom_base_number, p_time_limit, NOW(), NOW(), NOW()
    ) RETURNING id INTO entry_id;

    RETURN entry_id;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

-- Drop existing function first to avoid conflicts
DROP FUNCTION IF EXISTS initialize_user_statistics(UUID, VARCHAR(16));

-- Update initialize_user_statistics function - Remove SECURITY DEFINER
CREATE OR REPLACE FUNCTION initialize_user_statistics(
    p_user_id UUID DEFAULT NULL,
    p_guest_id VARCHAR(16) DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    stats_id UUID;
BEGIN
    -- Ensure user can only initialize statistics for themselves
    IF p_user_id IS NOT NULL AND auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Access denied: You can only initialize statistics for yourself';
    END IF;

    -- Check if statistics already exist
    SELECT id INTO stats_id FROM user_statistics
    WHERE (p_user_id IS NOT NULL AND user_id = p_user_id)
       OR (p_guest_id IS NOT NULL AND guest_id = p_guest_id);

    -- If not found, create new statistics
    IF stats_id IS NULL THEN
        INSERT INTO user_statistics (
            user_id, guest_id, games_played, games_won, best_score, total_score,
            total_play_time_seconds, last_played, created_at, updated_at
        ) VALUES (
            p_user_id, p_guest_id, 0, 0, 0, 0, 0, NOW(), NOW(), NOW()
        ) RETURNING id INTO stats_id;
    END IF;

    RETURN stats_id;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Query to verify the fixes
SELECT
    schemaname,
    viewname,
    definition
FROM pg_views
WHERE viewname IN ('user_active_ad_removals', 'recent_leaderboard_entries', 'user_statistics_summary');

-- Query to check function security settings
SELECT
    proname as function_name,
    prosecdef as is_security_definer
FROM pg_proc
WHERE proname IN (
    'has_active_ad_removal',
    'get_user_ad_removal_status',
    'migrate_guest_data_to_user',
    'get_user_leaderboard',
    'get_global_leaderboard',
    'add_leaderboard_entry',
    'initialize_user_statistics'
);
