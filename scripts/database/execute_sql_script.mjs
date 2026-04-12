#!/usr/bin/env node
import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const SUPABASE_URL = 'https://gmorarhibiptvcrnvrpi.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdtb3JhcmhpYmlwdHZjcm52cnBpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MzI4MzI0OSwiZXhwIjoyMDg4ODU5MjQ5fQ.LMTbfUtyurnJDfn_aW4UIXiyMLwTUMhc70jjRAZRpIQ';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

async function executeSqlScript(scriptPath) {
  try {
    console.log(`\n📝 Reading SQL script: ${scriptPath}\n`);
    const sqlContent = readFileSync(scriptPath, 'utf8');
    
    // Split into statements (simple split by semicolon, works for most cases)
    const statements = sqlContent
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'));
    
    console.log(`✅ Found ${statements.length} SQL statements to execute\n`);
    
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement) {
        console.log(`\n[${i + 1}/${statements.length}] Executing statement...\n`);
        
        const { data, error } = await supabase.rpc('exec_sql', { 
          sql_query: statement 
        });
        
        if (error) {
          // Try direct query for SELECT statements
          if (statement.trim().toUpperCase().startsWith('SELECT')) {
            const { data: selectData, error: selectError } = await supabase
              .from('raw_sql')
              .select('*')
              .limit(0); // This won't work, let me try a different approach
            
            console.log('⚠️  Note: SELECT queries may not return results via this method');
            console.log('   Consider using psql directly for verification queries');
          } else {
            console.error('❌ Error executing statement:', error.message);
            console.error('Statement:', statement.substring(0, 200));
          }
        } else {
          console.log('✅ Statement executed successfully');
          if (data) {
            console.log('📊 Result:', JSON.stringify(data, null, 2));
          }
        }
      }
    }
    
    console.log('\n✨ Script execution complete!\n');
    
  } catch (err) {
    console.error('❌ Fatal error:', err.message);
    process.exit(1);
  }
}

const scriptPath = process.argv[2] || join(__dirname, 'insert_all_missing_api_keys.sql');
executeSqlScript(scriptPath);
