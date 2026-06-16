export interface StorageProvider {
  /**
   * Uploads a file and returns its public URL
   */
  uploadFile(path: string, fileBuffer: Buffer, mimeType: string): Promise<string>;
  
  /**
   * Deletes a file by its path or URL
   */
  deleteFile(pathOrUrl: string): Promise<void>;

  /**
   * Replaces an existing file with a new one
   */
  replaceFile(oldPathOrUrl: string | null | undefined, newPath: string, fileBuffer: Buffer, mimeType: string): Promise<string>;

  /**
   * Gets the public URL for a file path
   */
  getPublicUrl(path: string): string;

  /**
   * Checks the health of the storage service
   */
  checkHealth(): Promise<void>;
}
