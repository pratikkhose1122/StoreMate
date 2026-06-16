import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export const getDatabaseConfig = (
  configService: ConfigService,
): TypeOrmModuleOptions => {
  const isProduction = configService.get<string>('NODE_ENV') === 'production';
  const url = configService.get<string>('DATABASE_URL');

  const commonOptions = {
    entities: [__dirname + '/../**/*.entity{.ts,.js}'],
    synchronize: configService.get<string>('DB_SYNC') === 'true',
    logging: configService.get<string>('NODE_ENV') !== 'production',
    // Enable SSL in production (required by Supabase connection pooler for SNI)
    ssl: isProduction ? { rejectUnauthorized: false } : undefined,
    extra: {
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000,
    },
  };

  if (url) {
    return {
      type: 'postgres',
      url,
      ...commonOptions,
    };
  }

  return {
    type: 'postgres',
    host: configService.get<string>('DB_HOST', 'localhost'),
    port: configService.get<number>('DB_PORT', 5432),
    username: configService.get<string>('DB_USERNAME', 'storemate'),
    password: configService.get<string>('DB_PASSWORD', 'storemate_dev_2024'),
    database: configService.get<string>('DB_DATABASE', 'storemate_db'),
    ...commonOptions,
  };
};
