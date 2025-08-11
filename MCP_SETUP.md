# MCP Server Setup Guide

## ✅ Supabase MCP Server Status
- **Installation**: ✅ Installed successfully
- **Configuration**: ✅ Configured in `.cursor/mcp.json`
- **Connection**: ✅ Verified working
- **Project Reference**: `etufhqdrucqwqkrzctsq`

## 🔧 Current Configuration

The Supabase MCP server is configured to:
- Connect to your Supabase project (`etufhqdrucqwqkrzctsq`)
- Run in **read-only mode** for safety
- Use the access token from environment variables

## 🛡️ Security Setup

### Files Protected by .gitignore:
- `.cursor/mcp.json` - Contains sensitive tokens
- `*.env` files - Environment variables
- `*.key`, `*.pem`, `*.p12` - Certificate files

### Template Available:
- `.cursor/mcp.json.template` - Safe template without tokens

## 🚀 How to Use

### In Cursor/IDE:
1. The MCP server will automatically connect when Cursor starts
2. You can now query your Supabase database directly from Cursor
3. Use natural language to interact with your database

### Example Queries:
- "Show me all users in the database"
- "What tables exist in my Supabase project?"
- "Get the latest car bookings"
- "Show me the schema for the cars table"

## 🔍 Verification

### Test Connection:
```bash
# Set environment variable
$env:SUPABASE_ACCESS_TOKEN="your_token_here"

# Test the connection
npx @supabase/mcp-server-supabase --read-only --project-ref=etufhqdrucqwqkrzctsq
```

### Check Installation:
```bash
npm list -g @supabase/mcp-server-supabase
```

## 📊 Available Database Tables
Based on your Flutter app, you should have access to:
- `users` - User profiles and authentication
- `cars` - Vehicle listings and details
- `bookings` - Rental bookings and reservations
- `payments` - Payment transactions
- `reviews` - User reviews and ratings
- `locations` - Pickup/dropoff locations
- `favorites` - User favorite cars/lists

## 🔄 Updating Tokens

When you need to update your Supabase access token:
1. Go to Supabase Dashboard → Settings → Access Tokens
2. Revoke the old token
3. Generate a new token
4. Update `.cursor/mcp.json` with the new token
5. Restart Cursor

## 🆘 Troubleshooting

### Common Issues:
1. **Connection Failed**: Check your access token is valid
2. **Permission Denied**: Ensure token has read permissions
3. **Server Not Found**: Reinstall with `npm install -g @supabase/mcp-server-supabase`

### Debug Commands:
```bash
# Check if package is installed
npm list -g @supabase/mcp-server-supabase

# Test with environment variable
$env:SUPABASE_ACCESS_TOKEN="your_token"; npx @supabase/mcp-server-supabase --read-only --project-ref=etufhqdrucqwqkrzctsq
```

## ✨ Next Steps

Your Supabase MCP server is ready! You can now:
1. Query your database directly from Cursor
2. Analyze your app's data
3. Debug database issues
4. Explore your schema
5. Generate reports

The setup is complete and secure! 🎉