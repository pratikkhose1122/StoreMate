const { Client } = require('pg');
async function run() {
  const client = new Client({
    host: 'localhost',
    port: 5432,
    user: 'storemate',
    password: 'storemate_dev_2024',
    database: 'storemate_db',
  });
  await client.connect();
  
  // Reload schema cache
  await client.query("NOTIFY pgrst, 'reload schema';");
  console.log('Schema cache reloaded via NOTIFY!');
  
  // As a fallback, sometimes restarting supabase works, but let's try just NOTIFY first.
  
  await client.end();
}
run().catch(console.error);
