import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
import { StorageProvider } from './storage.provider';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { ConfigService } from '@nestjs/config';
import * as WebSocket from 'ws';

@Injectable()
export class SupabaseStorageProvider implements StorageProvider {
  private readonly logger = new Logger(SupabaseStorageProvider.name);
  private readonly supabase: SupabaseClient;

  constructor(private readonly configService: ConfigService) {
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseKey = this.configService.get<string>('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseKey) {
      throw new Error('SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be defined');
    }

    this.supabase = createClient(supabaseUrl, supabaseKey, {
      auth: {
        persistSession: false,
      },
      global: {
        // @ts-ignore
        WebSocket: WebSocket,
      },
    });
  }

  /**
   * Upload a file to a specific bucket based on path
   */
  async uploadFile(path: string, fileBuffer: Buffer, mimeType: string): Promise<string> {
    const bucket = this.getBucketFromPath(path);
    const filePath = this.getFilePathFromPath(path);

    const { data, error } = await this.supabase.storage
      .from(bucket)
      .upload(filePath, fileBuffer, {
        contentType: mimeType,
        upsert: true,
      });

    if (error) {
      this.logger.error(`Failed to upload file to Supabase: ${error.message}`);
      throw new InternalServerErrorException('Failed to upload file');
    }

    return this.getPublicUrl(path);
  }

  /**
   * Delete a file from a bucket based on path or URL
   */
  async deleteFile(pathOrUrl: string): Promise<void> {
    try {
      const { bucket, filePath } = this.extractBucketAndPath(pathOrUrl);
      
      const { error } = await this.supabase.storage
        .from(bucket)
        .remove([filePath]);

      if (error) {
        this.logger.error(`Failed to delete file from Supabase: ${error.message}`);
      }
    } catch (e) {
      this.logger.error(`Error processing file deletion for ${pathOrUrl}: ${e.message}`);
    }
  }

  /**
   * Replace an existing file with a new one
   */
  async replaceFile(oldPathOrUrl: string | null | undefined, newPath: string, fileBuffer: Buffer, mimeType: string): Promise<string> {
    if (oldPathOrUrl) {
      await this.deleteFile(oldPathOrUrl);
    }
    return this.uploadFile(newPath, fileBuffer, mimeType);
  }

  /**
   * Get the public URL for a file
   */
  getPublicUrl(path: string): string {
    const bucket = this.getBucketFromPath(path);
    const filePath = this.getFilePathFromPath(path);
    
    const { data } = this.supabase.storage
      .from(bucket)
      .getPublicUrl(filePath);
      
    return data.publicUrl;
  }

  /**
   * Checks the health of the Supabase storage service
   */
  async checkHealth(): Promise<void> {
    const { error } = await this.supabase.storage.listBuckets();
    if (error) {
      throw new Error(`Supabase storage health check failed: ${error.message}`);
    }
  }

  /**
   * Helper to determine bucket name based on path prefix
   * Path format expected: "bucket-name/folder/filename.ext"
   */
  private getBucketFromPath(path: string): string {
    const parts = path.split('/');
    return parts[0];
  }

  /**
   * Helper to get the actual path within the bucket
   */
  private getFilePathFromPath(path: string): string {
    const parts = path.split('/');
    // Return everything after the bucket name
    return parts.slice(1).join('/');
  }

  /**
   * Helper to parse a public URL back into bucket and file path
   */
  private extractBucketAndPath(pathOrUrl: string): { bucket: string, filePath: string } {
    if (pathOrUrl.startsWith('http')) {
      // Supabase public URLs typically look like:
      // https://[project].supabase.co/storage/v1/object/public/[bucket]/[filePath]
      const url = new URL(pathOrUrl);
      const pathParts = url.pathname.split('/');
      
      // Find the 'public' segment
      const publicIndex = pathParts.indexOf('public');
      if (publicIndex !== -1 && pathParts.length > publicIndex + 2) {
        const bucket = pathParts[publicIndex + 1];
        const filePath = pathParts.slice(publicIndex + 2).join('/');
        return { bucket, filePath: decodeURIComponent(filePath) };
      }
      throw new Error('Invalid Supabase public URL format');
    } else {
      return {
        bucket: this.getBucketFromPath(pathOrUrl),
        filePath: this.getFilePathFromPath(pathOrUrl)
      };
    }
  }
}
