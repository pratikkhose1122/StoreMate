const { Client } = require('pg');
const fs = require('fs');

async function run() {
  const client = new Client({
    host: 'localhost',
    port: 5432,
    user: 'storemate',
    password: 'storemate_dev_2024',
    database: 'storemate_db',
  });
  await client.connect();
  const sql = fs.readFileSync('src/migrations/006_multi_user.sql', 'utf8');
  await client.query(sql);
  console.log('Migration 006 run successfully');
  await client.end();
}
run().catch(console.error);
