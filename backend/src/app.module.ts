import { Module, OnModuleInit, Logger } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ShopsModule } from './shops/shops.module';
import { getDatabaseConfig } from './config/database.config';
import { initializeFirebase } from './config/firebase.config';

import { CategoriesModule } from './categories/categories.module';
import { ProductsModule } from './products/products.module';
import { InventoryModule } from './inventory/inventory.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { CustomersModule } from './customers/customers.module';
import { SalesModule } from './sales/sales.module';
import { ReportsModule } from './reports/reports.module';
import { StorageModule } from './storage/storage.module';
import { ActivityLogsModule } from './activity-logs/activity-logs.module';
import { StaffModule } from './staff/staff.module';
import { HealthModule } from './health/health.module';
import { AppController } from './app.controller';

@Module({
  imports: [
    // Global config module — makes ConfigService available everywhere
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // TypeORM database connection
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) =>
        getDatabaseConfig(configService),
    }),

    // Feature modules
    AuthModule,
    UsersModule,
    ShopsModule,
    CategoriesModule,
    ProductsModule,
    InventoryModule,
    DashboardModule,
    CustomersModule,
    SalesModule,
    ReportsModule,
    StorageModule,
    ActivityLogsModule,
    StaffModule,
    HealthModule,
  ],
  controllers: [AppController],
})
export class AppModule implements OnModuleInit {
  private readonly logger = new Logger(AppModule.name);

  constructor(private readonly configService: ConfigService) {}

  onModuleInit(): void {
    // Initialize Firebase Admin SDK on app startup
    const firebaseProjectId =
      this.configService.get<string>('FIREBASE_PROJECT_ID') || '';
    initializeFirebase(firebaseProjectId);
    this.logger.log('StoreMate API modules initialized');
  }
}
