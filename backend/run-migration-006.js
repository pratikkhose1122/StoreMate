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
  const sqlPath = path.join(__dirname, 'src', 'database', 'migrations', '006_add_product_brand_size.sql');
  const sql = fs.readFileSync(sqlPath, 'utf8');
  await client.query(sql);
  console.log('Migration 006_add_product_brand_size run successfully');
  await client.end();
}
run().catch(console.error);
