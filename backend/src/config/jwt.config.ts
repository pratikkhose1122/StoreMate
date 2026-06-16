import { ConfigService } from '@nestjs/config';
import { JwtModuleOptions } from '@nestjs/jwt';

export const getJwtConfig = (
  configService: ConfigService,
): JwtModuleOptions => ({
  secret: configService.get<string>('JWT_SECRET'),
  signOptions: {
    expiresIn: configService.get<string>('JWT_EXPIRATION', '24h'),
    issuer: 'storemate-api',
    algorithm: 'HS256',
  },
  verifyOptions: {
    issuer: 'storemate-api',
    algorithms: ['HS256'],
  },
});
