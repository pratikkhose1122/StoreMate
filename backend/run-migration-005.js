const { Client } = require('pg');
const fs = require('fs');

async function runMigration() {
  const client = new Client({
    user: 'storemate',
    password: 'storemate_dev_2024',
    host: 'localhost',
    port: 5432,
    database: 'storemate_db',
  });

  await client.connect();
  const sql = fs.readFileSync('src/migrations/005_shop_settings.sql', 'utf8');
  await client.query(sql);
  console.log('Migration 005_shop_settings executed successfully');
  await client.end();
}

runMigration().catch(console.error);
