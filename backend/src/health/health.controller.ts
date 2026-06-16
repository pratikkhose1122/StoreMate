import { Controller, Get, Inject } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { StorageProvider } from '../storage/storage.provider';

@Controller('health')
export class HealthController {
  constructor(
    private readonly dataSource: DataSource,
    @Inject('StorageProvider') private readonly storageProvider: StorageProvider,
  ) {}

  @Get()
  ping() {
    return { status: 'ok', timestamp: new Date().toISOString() };
  }

  @Get('database')
  async checkDatabase() {
    try {
      await this.dataSource.query('SELECT 1');
      return { status: 'ok', message: 'Database connection successful' };
    } catch (e) {
      return { status: 'error', message: 'Database connection failed', details: e.message };
    }
  }

  @Get('storage')
  async checkStorage() {
    try {
      await this.storageProvider.checkHealth();
      return { status: 'ok', message: 'Storage connection successful' };
    } catch (e) {
      return { status: 'error', message: 'Storage connection failed', details: e.message };
    }
  }
}
