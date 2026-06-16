import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export const getDatabaseConfig = (
  configService: ConfigService,
): TypeOrmModuleOptions => ({
  type: 'postgres',
  host: configService.get<string>('DB_HOST', 'localhost'),
  port: configService.get<number>('DB_PORT', 5432),
  username: configService.get<string>('DB_USERNAME', 'storemate'),
  password: configService.get<string>('DB_PASSWORD', 'storemate_dev_2024'),
  database: configService.get<string>('DB_DATABASE', 'storemate_db'),
  entities: [__dirname + '/../**/*.entity{.ts,.js}'],
  synchronize: configService.get<string>('DB_SYNC') === 'true',
  logging: configService.get<string>('NODE_ENV') !== 'production',
  // Connection pool settings for production
  extra: {
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
  },
});
