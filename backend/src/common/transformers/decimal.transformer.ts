import { ValueTransformer } from 'typeorm';

/**
 * TypeORM returns DECIMAL/NUMERIC types as strings to prevent precision loss.
 * This transformer safely converts them to numbers for our NestJS DTOs/Entities.
 */
export class DecimalColumnTransformer implements ValueTransformer {
  /**
   * Called when writing to the database
   */
  to(data: number | null): number | null {
    return data;
  }

  /**
   * Called when reading from the database
   */
  from(data: string | null): number | null {
    if (data === null || data === undefined) {
      return null;
    }
    const res = parseFloat(data);
    return isNaN(res) ? null : res;
  }
}
