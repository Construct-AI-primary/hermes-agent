#!/usr/bin/env node
import pkg from 'pg';
const { Client } = pkg;
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const client = new Client({
  connectionString: 'postgresql://postgres.gmorarhibiptvcrnvrpi:bmdPWI7wQ172Ch1m@aws-1-eu-west-1.pooler.supabase.com:6543/postgres',
  ssl: {
    rejectUnauthorized: false
  }
});

async function executeSqlScript(scriptPath) {
  try {
    await client.connect();
    console.log(`\n📝 Reading SQL script: ${scriptPath}\n`);
    const sqlContent = readFileSync(scriptPath, 'utf8');

    // Split into statements (simple split by semicolon, works for most cases)
    const statements = sqlContent
      .split(';')
      .map(s => {
        // Remove leading comments and whitespace
        let cleaned = s.trim();
        while (cleaned.startsWith('--')) {
          const lines = cleaned.split('\n');
          // Remove the first line if it starts with --
          if (lines[0].trim().startsWith('--')) {
            lines.shift();
            cleaned = lines.join('\n').trim();
          } else {
            break;
          }
        }
        return cleaned;
      })
      .filter(s => s.length > 0);

    console.log(`✅ Found ${statements.length} SQL statements to execute\n`);

    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement) {
        console.log(`\n[${i + 1}/${statements.length}] Executing statement...\n`);
        console.log(`SQL: ${statement.substring(0, 100)}...`);

        try {
          const result = await client.query(statement);

          if (statement.trim().toUpperCase().startsWith('SELECT')) {
            console.log('📊 Query results:');
            console.log(`   Rows returned: ${result.rows.length}`);
            if (result.rows.length > 0 && result.rows.length <= 10) {
              console.table(result.rows);
            } else if (result.rows.length > 10) {
              console.log('   (Too many rows to display - showing first row)');
              console.table([result.rows[0]]);
            }
          } else {
            console.log(`✅ Statement executed successfully (${result.rowCount || 0} rows affected)`);
          }
        } catch (err) {
          console.error('❌ Error executing statement:', err.message);
          console.error('Statement:', statement.substring(0, 200));
          // Continue with next statement instead of exiting
        }
      }
    }

    console.log('\n✨ Script execution complete!\n');

  } catch (err) {
    console.error('❌ Fatal error:', err.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

const scriptPath = process.argv[2] || join(__dirname, 'insert_all_missing_api_keys.sql');
executeSqlScript(scriptPath);
