import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { CategoriesService } from '../categories/categories.service';
import { ProductsService } from '../products/products.service';
import { CustomersService } from '../customers/customers.service';
import { ShopsService } from '../shops/shops.service';
import { SalesService } from '../sales/sales.service';
import { DataSource } from 'typeorm';

async function bootstrap() {
  console.log('Starting demo data seed...');
  const app = await NestFactory.createApplicationContext(AppModule);
  
  const shopsService = app.get(ShopsService);
  const categoriesService = app.get(CategoriesService);
  const productsService = app.get(ProductsService);
  const customersService = app.get(CustomersService);
  const salesService = app.get(SalesService);
  const dataSource = app.get(DataSource);

  // Get the first shop
  const shops = await dataSource.query('SELECT id FROM shops LIMIT 1');
  if (shops.length === 0) {
    console.log('No shops found! Please register a shop first via the app.');
    await app.close();
    return;
  }
  
  const shopId = shops[0].id;
  console.log(`Seeding data for shop: ${shopId}`);

  // 1. Create Categories
  const categoriesToCreate = [
    { name: 'Electronics', description: 'Gadgets and devices' },
    { name: 'Accessories', description: 'Computer accessories' },
    { name: 'Office Supplies', description: 'Stationery and office items' },
    { name: 'Furniture', description: 'Office furniture' },
    { name: 'Beverages', description: 'Drinks and snacks' },
  ];

  const categories = [];
  for (const cat of categoriesToCreate) {
    categories.push(await categoriesService.create(cat, shopId));
  }
  console.log('Created 5 categories.');

  // 2. Create Products
  const productsToCreate = [];
  for (let i = 1; i <= 50; i++) {
    const catIndex = i % 5;
    productsToCreate.push({
      name: `Demo Product ${i}`,
      sku: `SKU-${1000 + i}`,
      barcode: `89012345${1000 + i}`,
      description: `Description for demo product ${i}`,
      purchasePrice: 100 + (i * 10),
      sellingPrice: 150 + (i * 15),
      quantity: 50 + (i * 2),
      unitType: 'PCS',
      lowStockThreshold: 10,
      categoryId: categories[catIndex].id,
    });
  }

  const products = [];
  for (const prod of productsToCreate) {
    products.push(await productsService.create(prod, shopId));
  }
  console.log('Created 50 products.');

  // 3. Create Customers
  const customersToCreate = [];
  for (let i = 1; i <= 20; i++) {
    customersToCreate.push({
      name: `Customer ${i}`,
      mobileNumber: `98765432${i.toString().padStart(2, '0')}`,
      email: `customer${i}@example.com`,
      address: `${i} Main St, City`,
    });
  }

  const customers = [];
  for (const cust of customersToCreate) {
    customers.push(await customersService.create(shopId, cust));
  }
  console.log('Created 20 customers.');

  // 4. Create Sales (Invoices)
  for (let i = 1; i <= 30; i++) {
    const custIndex = i % 20;
    const prod1 = products[(i * 2) % 50];
    const prod2 = products[(i * 3) % 50];
    
    await salesService.checkout(shopId, {
      customerId: customers[custIndex].id,
      items: [
        { productId: prod1.id, quantity: 1, unitPrice: prod1.sellingPrice, taxPercentage: 0 },
        { productId: prod2.id, quantity: 2, unitPrice: prod2.sellingPrice, taxPercentage: 0 }
      ],
      totalAmount: prod1.sellingPrice + (prod2.sellingPrice * 2),
      discountAmount: 10,
      taxAmount: 0,
      netAmount: prod1.sellingPrice + (prod2.sellingPrice * 2) - 10,
      payments: [
        { paymentMethod: i % 3 === 0 ? 'card' : 'cash', amount: prod1.sellingPrice + (prod2.sellingPrice * 2) - 10 }
      ],
    }, { id: 'demo-user-id', email: 'demo@example.com' });
  }
  console.log('Created 30 sales.');

  console.log('Demo data seed complete!');
  await app.close();
}

bootstrap();
