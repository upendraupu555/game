-- Supabase Database Schema for 2048 Game Ad Removal System
-- This file contains the SQL commands to create the necessary tables and indexes
-- for the ad removal functionality with Razorpay payment integration

-- Create user_purchases table for storing purchase information
CREATE TABLE IF NOT EXISTS user_purchases (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_type VARCHAR(50) NOT NULL DEFAULT 'ad_removal',
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(255) NOT NULL UNIQUE,
    amount INTEGER NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    purchased_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_user_purchases_user_id ON user_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_user_purchases_product_type ON user_purchases(product_type);
CREATE INDEX IF NOT EXISTS idx_user_purchases_status ON user_purchases(status);
CREATE INDEX IF NOT EXISTS idx_user_purchases_transaction_id ON user_purchases(transaction_id);
CREATE INDEX IF NOT EXISTS idx_user_purchases_user_product_status ON user_purchases(user_id, product_type, status);

-- Create composite index for the most common query (user ad removal status)
CREATE INDEX IF NOT EXISTS idx_user_purchases_ad_removal_active 
ON user_purchases(user_id, product_type, status) 
WHERE product_type = 'ad_removal' AND status = 'completed';

-- Add constraints
ALTER TABLE user_purchases 
ADD CONSTRAINT chk_user_purchases_status 
CHECK (status IN ('completed', 'pending', 'failed', 'refunded'));

ALTER TABLE user_purchases 
ADD CONSTRAINT chk_user_purchases_product_type 
CHECK (product_type IN ('ad_removal'));

ALTER TABLE user_purchases 
ADD CONSTRAINT chk_user_purchases_amount 
CHECK (amount > 0);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_user_purchases_updated_at 
    BEFORE UPDATE ON user_purchases 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE user_purchases ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can only see their own purchases
CREATE POLICY "Users can view their own purchases" ON user_purchases
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own purchases
CREATE POLICY "Users can insert their own purchases" ON user_purchases
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own purchases (for status changes)
CREATE POLICY "Users can update their own purchases" ON user_purchases
    FOR UPDATE USING (auth.uid() = user_id);

-- Create a view for active ad removal purchases
CREATE OR REPLACE VIEW user_active_ad_removals AS
SELECT 
    user_id,
    transaction_id,
    amount,
    currency,
    purchased_at,
    created_at
FROM user_purchases 
WHERE product_type = 'ad_removal' 
AND status = 'completed';

-- Grant access to the view
GRANT SELECT ON user_active_ad_removals TO authenticated;

-- Create function to check if user has active ad removal
CREATE OR REPLACE FUNCTION has_active_ad_removal(user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM user_purchases 
        WHERE user_id = user_uuid 
        AND product_type = 'ad_removal' 
        AND status = 'completed'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION has_active_ad_removal(UUID) TO authenticated;

-- Create function to get user's ad removal status with details
CREATE OR REPLACE FUNCTION get_user_ad_removal_status(user_uuid UUID)
RETURNS TABLE (
    has_ad_removal BOOLEAN,
    purchase_date TIMESTAMPTZ,
    transaction_id VARCHAR(255),
    amount INTEGER,
    currency VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TRUE as has_ad_removal,
        p.purchased_at as purchase_date,
        p.transaction_id,
        p.amount,
        p.currency
    FROM user_purchases p
    WHERE p.user_id = user_uuid 
    AND p.product_type = 'ad_removal' 
    AND p.status = 'completed'
    ORDER BY p.purchased_at DESC
    LIMIT 1;
    
    -- If no results, return false
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL::TIMESTAMPTZ, NULL::VARCHAR(255), NULL::INTEGER, NULL::VARCHAR(10);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION get_user_ad_removal_status(UUID) TO authenticated;

-- Insert sample data for testing (optional - remove in production)
-- This is commented out by default
/*
INSERT INTO user_purchases (
    user_id, 
    product_type, 
    status, 
    transaction_id, 
    amount, 
    currency, 
    purchased_at,
    metadata
) VALUES (
    '00000000-0000-0000-0000-000000000000', -- Replace with actual user ID for testing
    'ad_removal',
    'completed',
    'test_transaction_001',
    10000, -- ₹100 in paise
    'INR',
    NOW(),
    '{"test": true, "razorpay_payment_id": "test_payment_001"}'::jsonb
);
*/

-- Create indexes for performance optimization
CREATE INDEX IF NOT EXISTS idx_user_purchases_created_at ON user_purchases(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_purchases_purchased_at ON user_purchases(purchased_at DESC);

-- Add comments for documentation
COMMENT ON TABLE user_purchases IS 'Stores user purchase information for in-app purchases including ad removal';
COMMENT ON COLUMN user_purchases.user_id IS 'Reference to the user who made the purchase';
COMMENT ON COLUMN user_purchases.product_type IS 'Type of product purchased (currently only ad_removal)';
COMMENT ON COLUMN user_purchases.status IS 'Purchase status: completed, pending, failed, or refunded';
COMMENT ON COLUMN user_purchases.transaction_id IS 'Unique transaction ID from payment gateway (Razorpay)';
COMMENT ON COLUMN user_purchases.amount IS 'Purchase amount in smallest currency unit (paise for INR)';
COMMENT ON COLUMN user_purchases.currency IS 'Currency code (ISO 4217)';
COMMENT ON COLUMN user_purchases.purchased_at IS 'Timestamp when purchase was completed';
COMMENT ON COLUMN user_purchases.metadata IS 'Additional purchase metadata (payment gateway details, etc.)';

-- Performance monitoring query (for debugging)
-- SELECT * FROM pg_stat_user_indexes WHERE relname = 'user_purchases';

-- ============================================================================
-- LEADERBOARD AND STATISTICS TABLES
-- ============================================================================

-- Create leaderboard_entries table for storing game completion data
CREATE TABLE IF NOT EXISTS leaderboard_entries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    guest_id VARCHAR(16), -- For guest users (16-digit UUID)
    score INTEGER NOT NULL,
    game_mode VARCHAR(50) NOT NULL,
    game_duration_seconds INTEGER NOT NULL,
    board_snapshot JSONB NOT NULL,
    custom_base_number INTEGER,
    time_limit INTEGER,
    date_played TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Ensure either user_id or guest_id is provided
    CONSTRAINT chk_leaderboard_user_or_guest CHECK (
        (user_id IS NOT NULL AND guest_id IS NULL) OR
        (user_id IS NULL AND guest_id IS NOT NULL)
    )
);

-- Create user_statistics table for comprehensive game statistics
CREATE TABLE IF NOT EXISTS user_statistics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    guest_id VARCHAR(16), -- For guest users (16-digit UUID)

    -- Basic statistics
    games_played INTEGER NOT NULL DEFAULT 0,
    games_won INTEGER NOT NULL DEFAULT 0,
    best_score INTEGER NOT NULL DEFAULT 0,
    total_score BIGINT NOT NULL DEFAULT 0,
    total_play_time_seconds BIGINT NOT NULL DEFAULT 0,
    last_played TIMESTAMPTZ,

    -- Game mode performance (stored as JSONB for flexibility)
    game_mode_stats JSONB NOT NULL DEFAULT '{}'::jsonb,
    game_mode_wins JSONB NOT NULL DEFAULT '{}'::jsonb,
    game_mode_best_scores JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Powerup statistics
    powerup_usage_count JSONB NOT NULL DEFAULT '{}'::jsonb,
    powerup_success_count JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Tile achievements
    highest_tile_value INTEGER NOT NULL DEFAULT 0,
    total_2048_achievements INTEGER NOT NULL DEFAULT 0,
    tile_value_achievements JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Recent performance (last 10 games)
    recent_games JSONB NOT NULL DEFAULT '[]'::jsonb,

    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Ensure either user_id or guest_id is provided
    CONSTRAINT chk_statistics_user_or_guest CHECK (
        (user_id IS NOT NULL AND guest_id IS NULL) OR
        (user_id IS NULL AND guest_id IS NOT NULL)
    ),

    -- Ensure unique statistics per user/guest
    CONSTRAINT uq_statistics_user UNIQUE (user_id),
    CONSTRAINT uq_statistics_guest UNIQUE (guest_id)
);

-- Create sync_status table for tracking synchronization state
CREATE TABLE IF NOT EXISTS sync_status (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    guest_id VARCHAR(16), -- For guest users
    table_name VARCHAR(50) NOT NULL,
    last_sync_at TIMESTAMPTZ,
    sync_version INTEGER NOT NULL DEFAULT 1,
    is_dirty BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Ensure either user_id or guest_id is provided
    CONSTRAINT chk_sync_user_or_guest CHECK (
        (user_id IS NOT NULL AND guest_id IS NULL) OR
        (user_id IS NULL AND guest_id IS NOT NULL)
    ),

    -- Unique sync status per user/guest per table
    CONSTRAINT uq_sync_status_user_table UNIQUE (user_id, table_name),
    CONSTRAINT uq_sync_status_guest_table UNIQUE (guest_id, table_name)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Leaderboard entries indexes
CREATE INDEX IF NOT EXISTS idx_leaderboard_entries_user_id ON leaderboard_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_leaderboard_entries_guest_id ON leaderboard_entries(guest_id);
CREATE INDEX IF NOT EXISTS idx_leaderboard_entries_score ON leaderboard_entries(score DESC);
CREATE INDEX IF NOT EXISTS idx_leaderboard_entries_game_mode ON leaderboard_entries(game_mode);
CREATE INDEX IF NOT EXISTS idx_leaderboard_entries_date_played ON leaderboard_entries(date_played DESC);
CREATE INDEX IF NOT EXISTS idx_leaderboard_entries_user_score ON leaderboard_entries(user_id, score DESC);
CREATE INDEX IF NOT EXISTS idx_leaderboard_entries_guest_score ON leaderboard_entries(guest_id, score DESC);
CREATE INDEX IF NOT EXISTS idx_leaderboard_entries_mode_score ON leaderboard_entries(game_mode, score DESC);

-- User statistics indexes
CREATE INDEX IF NOT EXISTS idx_user_statistics_user_id ON user_statistics(user_id);
CREATE INDEX IF NOT EXISTS idx_user_statistics_guest_id ON user_statistics(guest_id);
CREATE INDEX IF NOT EXISTS idx_user_statistics_last_played ON user_statistics(last_played DESC);

-- Sync status indexes
CREATE INDEX IF NOT EXISTS idx_sync_status_user_id ON sync_status(user_id);
CREATE INDEX IF NOT EXISTS idx_sync_status_guest_id ON sync_status(guest_id);
CREATE INDEX IF NOT EXISTS idx_sync_status_table_name ON sync_status(table_name);
CREATE INDEX IF NOT EXISTS idx_sync_status_is_dirty ON sync_status(is_dirty) WHERE is_dirty = TRUE;
CREATE INDEX IF NOT EXISTS idx_sync_status_last_sync ON sync_status(last_sync_at DESC);

-- ============================================================================
-- CONSTRAINTS AND VALIDATIONS
-- ============================================================================

-- Leaderboard entries constraints
ALTER TABLE leaderboard_entries
ADD CONSTRAINT chk_leaderboard_score CHECK (score >= 0);

ALTER TABLE leaderboard_entries
ADD CONSTRAINT chk_leaderboard_game_mode
CHECK (game_mode IN ('Classic', 'Time Attack', 'Scenic Mode', 'Custom'));

ALTER TABLE leaderboard_entries
ADD CONSTRAINT chk_leaderboard_duration CHECK (game_duration_seconds > 0);

ALTER TABLE leaderboard_entries
ADD CONSTRAINT chk_leaderboard_guest_id_format
CHECK (guest_id IS NULL OR LENGTH(guest_id) = 16);

-- User statistics constraints
ALTER TABLE user_statistics
ADD CONSTRAINT chk_statistics_games_played CHECK (games_played >= 0);

ALTER TABLE user_statistics
ADD CONSTRAINT chk_statistics_games_won CHECK (games_won >= 0 AND games_won <= games_played);

ALTER TABLE user_statistics
ADD CONSTRAINT chk_statistics_scores CHECK (best_score >= 0 AND total_score >= 0);

ALTER TABLE user_statistics
ADD CONSTRAINT chk_statistics_play_time CHECK (total_play_time_seconds >= 0);

ALTER TABLE user_statistics
ADD CONSTRAINT chk_statistics_tile_value CHECK (highest_tile_value >= 0);

ALTER TABLE user_statistics
ADD CONSTRAINT chk_statistics_2048_achievements CHECK (total_2048_achievements >= 0);

ALTER TABLE user_statistics
ADD CONSTRAINT chk_statistics_guest_id_format
CHECK (guest_id IS NULL OR LENGTH(guest_id) = 16);

-- Sync status constraints
ALTER TABLE sync_status
ADD CONSTRAINT chk_sync_table_name
CHECK (table_name IN ('leaderboard_entries', 'user_statistics'));

ALTER TABLE sync_status
ADD CONSTRAINT chk_sync_version CHECK (sync_version > 0);

ALTER TABLE sync_status
ADD CONSTRAINT chk_sync_guest_id_format
CHECK (guest_id IS NULL OR LENGTH(guest_id) = 16);

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- ============================================================================

-- Create triggers for leaderboard_entries
CREATE TRIGGER update_leaderboard_entries_updated_at
    BEFORE UPDATE ON leaderboard_entries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create triggers for user_statistics
CREATE TRIGGER update_user_statistics_updated_at
    BEFORE UPDATE ON user_statistics
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create triggers for sync_status
CREATE TRIGGER update_sync_status_updated_at
    BEFORE UPDATE ON sync_status
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE leaderboard_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_status ENABLE ROW LEVEL SECURITY;

-- Leaderboard entries policies
-- Users can view all leaderboard entries (for global leaderboard)
CREATE POLICY "Anyone can view leaderboard entries" ON leaderboard_entries
    FOR SELECT USING (TRUE);

-- Users can insert their own entries
CREATE POLICY "Users can insert their own leaderboard entries" ON leaderboard_entries
    FOR INSERT WITH CHECK (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id) OR
        (auth.uid() IS NULL AND guest_id IS NOT NULL)
    );

-- Users can update their own entries
CREATE POLICY "Users can update their own leaderboard entries" ON leaderboard_entries
    FOR UPDATE USING (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id) OR
        (auth.uid() IS NULL AND guest_id IS NOT NULL)
    );

-- Users can delete their own entries
CREATE POLICY "Users can delete their own leaderboard entries" ON leaderboard_entries
    FOR DELETE USING (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id) OR
        (auth.uid() IS NULL AND guest_id IS NOT NULL)
    );

-- User statistics policies
-- Users can view their own statistics
CREATE POLICY "Users can view their own statistics" ON user_statistics
    FOR SELECT USING (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id) OR
        (auth.uid() IS NULL AND guest_id IS NOT NULL)
    );

-- Users can insert their own statistics
CREATE POLICY "Users can insert their own statistics" ON user_statistics
    FOR INSERT WITH CHECK (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id) OR
        (auth.uid() IS NULL AND guest_id IS NOT NULL)
    );

-- Users can update their own statistics
CREATE POLICY "Users can update their own statistics" ON user_statistics
    FOR UPDATE USING (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id) OR
        (auth.uid() IS NULL AND guest_id IS NOT NULL)
    );

-- Sync status policies
-- Users can view their own sync status
CREATE POLICY "Users can view their own sync status" ON sync_status
    FOR SELECT USING (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id) OR
        (auth.uid() IS NULL AND guest_id IS NOT NULL)
    );

-- Users can insert their own sync status
CREATE POLICY "Users can insert their own sync status" ON sync_status
    FOR INSERT WITH CHECK (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id) OR
        (auth.uid() IS NULL AND guest_id IS NOT NULL)
    );

-- Users can update their own sync status
CREATE POLICY "Users can update their own sync status" ON sync_status
    FOR UPDATE USING (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id) OR
        (auth.uid() IS NULL AND guest_id IS NOT NULL)
    );

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Function to migrate guest data to authenticated user
CREATE OR REPLACE FUNCTION migrate_guest_data_to_user(
    p_guest_id VARCHAR(16),
    p_user_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    leaderboard_count INTEGER;
    statistics_count INTEGER;
BEGIN
    -- Migrate leaderboard entries
    UPDATE leaderboard_entries
    SET user_id = p_user_id, guest_id = NULL, updated_at = NOW()
    WHERE guest_id = p_guest_id;

    GET DIAGNOSTICS leaderboard_count = ROW_COUNT;

    -- Migrate user statistics (merge if user already has statistics)
    INSERT INTO user_statistics (
        user_id, games_played, games_won, best_score, total_score,
        total_play_time_seconds, last_played, game_mode_stats,
        game_mode_wins, game_mode_best_scores, powerup_usage_count,
        powerup_success_count, highest_tile_value, total_2048_achievements,
        tile_value_achievements, recent_games
    )
    SELECT
        p_user_id, games_played, games_won, best_score, total_score,
        total_play_time_seconds, last_played, game_mode_stats,
        game_mode_wins, game_mode_best_scores, powerup_usage_count,
        powerup_success_count, highest_tile_value, total_2048_achievements,
        tile_value_achievements, recent_games
    FROM user_statistics
    WHERE guest_id = p_guest_id
    ON CONFLICT (user_id) DO UPDATE SET
        games_played = user_statistics.games_played + EXCLUDED.games_played,
        games_won = user_statistics.games_won + EXCLUDED.games_won,
        best_score = GREATEST(user_statistics.best_score, EXCLUDED.best_score),
        total_score = user_statistics.total_score + EXCLUDED.total_score,
        total_play_time_seconds = user_statistics.total_play_time_seconds + EXCLUDED.total_play_time_seconds,
        last_played = GREATEST(user_statistics.last_played, EXCLUDED.last_played),
        updated_at = NOW();

    -- Delete guest statistics after migration
    DELETE FROM user_statistics WHERE guest_id = p_guest_id;
    GET DIAGNOSTICS statistics_count = ROW_COUNT;

    -- Update sync status
    UPDATE sync_status
    SET user_id = p_user_id, guest_id = NULL, is_dirty = TRUE, updated_at = NOW()
    WHERE guest_id = p_guest_id;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user leaderboard with pagination
CREATE OR REPLACE FUNCTION get_user_leaderboard(
    p_user_id UUID DEFAULT NULL,
    p_guest_id VARCHAR(16) DEFAULT NULL,
    p_game_mode VARCHAR(50) DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    score INTEGER,
    game_mode VARCHAR(50),
    game_duration_seconds INTEGER,
    date_played TIMESTAMPTZ,
    rank BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        le.id,
        le.score,
        le.game_mode,
        le.game_duration_seconds,
        le.date_played,
        ROW_NUMBER() OVER (ORDER BY le.score DESC, le.date_played DESC) as rank
    FROM leaderboard_entries le
    WHERE
        (p_user_id IS NOT NULL AND le.user_id = p_user_id) OR
        (p_guest_id IS NOT NULL AND le.guest_id = p_guest_id) OR
        (p_user_id IS NULL AND p_guest_id IS NULL)
    AND (p_game_mode IS NULL OR le.game_mode = p_game_mode)
    ORDER BY le.score DESC, le.date_played DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get global leaderboard with pagination
CREATE OR REPLACE FUNCTION get_global_leaderboard(
    p_game_mode VARCHAR(50) DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    score INTEGER,
    game_mode VARCHAR(50),
    game_duration_seconds INTEGER,
    date_played TIMESTAMPTZ,
    rank BIGINT,
    is_current_user BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        le.id,
        le.score,
        le.game_mode,
        le.game_duration_seconds,
        le.date_played,
        ROW_NUMBER() OVER (ORDER BY le.score DESC, le.date_played DESC) as rank,
        (le.user_id = auth.uid()) as is_current_user
    FROM leaderboard_entries le
    WHERE (p_game_mode IS NULL OR le.game_mode = p_game_mode)
    ORDER BY le.score DESC, le.date_played DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View for recent leaderboard entries with user context
CREATE OR REPLACE VIEW recent_leaderboard_entries AS
SELECT
    le.id,
    le.score,
    le.game_mode,
    le.game_duration_seconds,
    le.date_played,
    le.user_id,
    le.guest_id,
    (le.user_id = auth.uid()) as is_current_user,
    ROW_NUMBER() OVER (ORDER BY le.date_played DESC) as recency_rank,
    ROW_NUMBER() OVER (ORDER BY le.score DESC) as score_rank
FROM leaderboard_entries le
ORDER BY le.date_played DESC;

-- View for user statistics summary
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
    us.highest_tile_value,
    us.total_2048_achievements,
    us.last_played,
    CASE
        WHEN us.games_played > 0 THEN ROUND((us.games_won::DECIMAL / us.games_played::DECIMAL) * 100, 2)
        ELSE 0
    END as win_percentage,
    CASE
        WHEN us.games_played > 0 THEN ROUND(us.total_score::DECIMAL / us.games_played::DECIMAL, 0)
        ELSE 0
    END as average_score,
    CASE
        WHEN us.games_played > 0 THEN ROUND(us.total_play_time_seconds::DECIMAL / us.games_played::DECIMAL, 0)
        ELSE 0
    END as average_game_duration
FROM user_statistics us;

-- ============================================================================
-- SAMPLE DATA INSERTION FUNCTIONS (FOR TESTING)
-- ============================================================================

-- Function to create sample leaderboard entry
CREATE OR REPLACE FUNCTION create_sample_leaderboard_entry(
    p_user_id UUID DEFAULT NULL,
    p_guest_id VARCHAR(16) DEFAULT NULL,
    p_score INTEGER DEFAULT 2048,
    p_game_mode VARCHAR(50) DEFAULT 'Classic'
)
RETURNS UUID AS $$
DECLARE
    entry_id UUID;
BEGIN
    INSERT INTO leaderboard_entries (
        user_id, guest_id, score, game_mode, game_duration_seconds,
        board_snapshot, date_played
    ) VALUES (
        p_user_id, p_guest_id, p_score, p_game_mode, 300,
        '{"board": [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]}',
        NOW()
    ) RETURNING id INTO entry_id;

    RETURN entry_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to initialize user statistics
CREATE OR REPLACE FUNCTION initialize_user_statistics(
    p_user_id UUID DEFAULT NULL,
    p_guest_id VARCHAR(16) DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    stats_id UUID;
BEGIN
    INSERT INTO user_statistics (
        user_id, guest_id, games_played, games_won, best_score,
        total_score, total_play_time_seconds, game_mode_stats,
        game_mode_wins, game_mode_best_scores, powerup_usage_count,
        powerup_success_count, highest_tile_value, total_2048_achievements,
        tile_value_achievements, recent_games
    ) VALUES (
        p_user_id, p_guest_id, 0, 0, 0, 0, 0,
        '{}'::jsonb, '{}'::jsonb, '{}'::jsonb, '{}'::jsonb,
        '{}'::jsonb, 0, 0, '{}'::jsonb, '[]'::jsonb
    ) RETURNING id INTO stats_id;

    RETURN stats_id;
EXCEPTION
    WHEN unique_violation THEN
        -- Statistics already exist, return existing ID
        SELECT id INTO stats_id FROM user_statistics
        WHERE (p_user_id IS NOT NULL AND user_id = p_user_id)
           OR (p_guest_id IS NOT NULL AND guest_id = p_guest_id);
        RETURN stats_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PERFORMANCE MONITORING QUERIES (FOR DEBUGGING)
-- ============================================================================

-- Query to check table sizes and performance
-- SELECT
--     schemaname,
--     tablename,
--     attname,
--     n_distinct,
--     correlation
-- FROM pg_stats
-- WHERE schemaname = 'public'
--   AND tablename IN ('leaderboard_entries', 'user_statistics', 'sync_status');

-- Query to check index usage
-- SELECT
--     schemaname,
--     tablename,
--     indexname,
--     idx_scan,
--     idx_tup_read,
--     idx_tup_fetch
-- FROM pg_stat_user_indexes
-- WHERE schemaname = 'public'
--   AND tablename IN ('leaderboard_entries', 'user_statistics', 'sync_status');
