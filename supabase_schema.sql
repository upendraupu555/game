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
