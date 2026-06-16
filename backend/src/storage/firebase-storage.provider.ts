import { Injectable, Logger } from '@nestjs/common';
import { StorageProvider } from './storage.provider';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseStorageProvider implements StorageProvider {
  private readonly logger = new Logger(FirebaseStorageProvider.name);

  async uploadFile(path: string, fileBuffer: Buffer, mimeType: string): Promise<string> {
    const bucket = admin.storage().bucket();
    const file = bucket.file(path);

    await file.save(fileBuffer, {
      metadata: { contentType: mimeType },
      public: true, // Make public
    });

    // Return public URL
    return `https://storage.googleapis.com/${bucket.name}/${path}`;
  }

  async deleteFile(pathOrUrl: string): Promise<void> {
    try {
      const bucket = admin.storage().bucket();
      // If it's a URL, extract the path
      let filePath = pathOrUrl;
      if (pathOrUrl.startsWith('http')) {
        const urlParts = new URL(pathOrUrl);
        filePath = decodeURIComponent(urlParts.pathname.replace(`/${bucket.name}/`, ''));
      }
      
      await bucket.file(filePath).delete();
    } catch (e) {
      this.logger.error(`Failed to delete file ${pathOrUrl}: ${e.message}`);
    }
  }

  async replaceFile(oldPathOrUrl: string | null | undefined, newPath: string, fileBuffer: Buffer, mimeType: string): Promise<string> {
    if (oldPathOrUrl) {
      await this.deleteFile(oldPathOrUrl);
    }
    return this.uploadFile(newPath, fileBuffer, mimeType);
  }

  getPublicUrl(path: string): string {
    const bucket = admin.storage().bucket();
    return `https://storage.googleapis.com/${bucket.name}/${path}`;
  }

  async checkHealth(): Promise<void> {
    const bucket = admin.storage().bucket();
    const [exists] = await bucket.exists();
    if (!exists) {
      throw new Error(`Firebase storage health check failed: bucket does not exist`);
    }
  }
}
