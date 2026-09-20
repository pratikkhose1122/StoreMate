const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function run() {
  const client = new Client({
    host: 'localhost',
    port: 5432,
    user: 'storemate',
    password: 'storemate_dev_2024',
    database: 'storemate_db',
  });
  await client.connect();
  const sqlPath = path.join(__dirname, 'src', 'migrations', '007_rpc_process_sale.sql');
  const sql = fs.readFileSync(sqlPath, 'utf8');
  await client.query(sql);
  console.log('Migration 007_rpc_process_sale run successfully');
  await client.end();
}
run().catch(console.error);
