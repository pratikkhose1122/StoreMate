import { Module } from '@nestjs/common';
import { SupabaseStorageProvider } from './supabase-storage.provider';
import { FirebaseStorageProvider } from './firebase-storage.provider';

@Module({
  providers: [
    {
      provide: 'StorageProvider',
      useClass: SupabaseStorageProvider, // Switched to Supabase
    },
    FirebaseStorageProvider, // Keep as an optional provider if needed
  ],
  exports: ['StorageProvider'],
})
export class StorageModule {}
