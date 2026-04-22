#!/usr/bin/env node
import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { config } from 'dotenv';

// Load environment variables from .env file
config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Database connection using Supabase client (like other working scripts)
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

// Validate environment variables
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('❌ Missing required environment variables:');
  console.error('   SUPABASE_URL: ', SUPABASE_URL ? '✅ Set' : '❌ Missing');
  console.error('   SUPABASE_SERVICE_ROLE_KEY: ', SUPABASE_SERVICE_ROLE_KEY ? '✅ Set' : '❌ Missing');
  console.error('\nPlease ensure .env file contains the correct Supabase credentials.');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function executeSqlScript(scriptPath) {
  try {
    console.log(`\n📝 Reading SQL script: ${scriptPath}\n`);
    const sqlContent = readFileSync(scriptPath, 'utf8');

    // For Supabase, we need to execute the entire script as one statement
    // since exec_sql RPC function doesn't exist, we'll try a different approach
    console.log('🔄 Executing SQL script via Supabase...');

    // Try to execute the entire SQL content at once
    const { data, error } = await supabase.rpc('exec_sql', {
      sql: sqlContent
    });

    if (error) {
      console.error('❌ Error executing SQL script:', error);
      console.error('This might be because the exec_sql RPC function is not available.');
      console.error('Please execute the SQL manually in the Supabase dashboard or use a different approach.');
      return false;
    }

    console.log('✅ SQL script executed successfully');
    console.log('📊 Result:', data);
    return true;

  } catch (err) {
    console.error('❌ Fatal error:', err.message);
    console.error('\n💡 Suggestion: The exec_sql RPC function may not be available in your Supabase instance.');
    console.error('   Try executing the SQL directly in the Supabase SQL Editor instead.');
    process.exit(1);
  }
}

const scriptPath = process.argv[2] || join(__dirname, 'insert_all_missing_api_keys.sql');
executeSqlScript(scriptPath);
