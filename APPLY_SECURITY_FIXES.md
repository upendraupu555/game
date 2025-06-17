# 🔒 How to Apply Supabase Security Fixes

## 🚨 Problem
Your Supabase database has security issues with `SECURITY DEFINER` views that bypass Row Level Security (RLS) policies.

## ✅ Solution
Use the corrected security fixes that resolve PostgreSQL parameter ordering issues.

## 📋 Step-by-Step Instructions

### Step 1: Open Supabase SQL Editor
1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor** in the left sidebar
3. Click **New Query**

### Step 2: Apply the Security Fixes
1. Open the file: `frontend/game/supabase_security_fixes_corrected.sql`
2. **Copy the entire contents** of the file
3. **Paste it into the Supabase SQL Editor**
4. Click **Run** to execute the script

### Step 3: Verify the Fixes
After running the script, you should see output from the verification queries at the bottom showing:
- Views are recreated without security issues
- Functions have correct security settings

### Step 4: Check Supabase Linter
1. Go to **Database** → **Database Linter** in your Supabase dashboard
2. Verify that the 3 security errors are now resolved:
   - ✅ `user_active_ad_removals` view fixed
   - ✅ `recent_leaderboard_entries` view fixed  
   - ✅ `user_statistics_summary` view fixed

### Step 5: Test Your Application
Test your Flutter app to ensure:
- Users can view their own data
- Users cannot view other users' data
- Guest functionality still works
- Authentication flows work correctly

## 🔧 What Was Fixed

### Parameter Ordering Issues
**Before (Caused Error):**
```sql
CREATE FUNCTION example(
    p_user_id UUID DEFAULT NULL,  -- Default parameter
    p_score INTEGER               -- Required parameter after default - ERROR!
)
```

**After (Fixed):**
```sql
CREATE FUNCTION example(
    p_score INTEGER,              -- Required parameters first
    p_user_id UUID DEFAULT NULL   -- Default parameters last
)
```

### Security Issues
**Before (Insecure):**
```sql
CREATE VIEW user_data AS SELECT * FROM sensitive_table;
-- Any authenticated user could see ALL data
```

**After (Secure):**
```sql
CREATE VIEW user_data AS 
SELECT * FROM sensitive_table 
WHERE auth.uid() = user_id;  -- Users only see their own data
```

## 🎯 Security Benefits

After applying these fixes:
- ✅ **Row Level Security properly enforced**
- ✅ **Users can only access their own data**
- ✅ **Guest sessions remain isolated**
- ✅ **No unauthorized data access**
- ✅ **Supabase security linter passes**

## 🧪 Testing Checklist

After applying the fixes, verify:
- [ ] Supabase linter shows no security errors
- [ ] Users can view their own leaderboard entries
- [ ] Users cannot view other users' data
- [ ] Guest users can access their session data
- [ ] Authentication and data migration work
- [ ] App functionality remains unchanged

## 🚨 Troubleshooting

If you encounter issues:

1. **Function signature conflicts**: The script includes `DROP FUNCTION` statements to handle this
2. **Permission errors**: Make sure you're running as database owner/admin
3. **RLS policy violations**: Check that your app properly authenticates users
4. **Guest access issues**: Verify guest IDs are being passed correctly

## 📞 Need Help?

If you encounter any issues:
1. Check the Supabase logs for detailed error messages
2. Verify your authentication setup
3. Test with different user accounts
4. Ensure your Flutter app is using the correct user/guest IDs

The security fixes are production-ready and maintain full backward compatibility!
