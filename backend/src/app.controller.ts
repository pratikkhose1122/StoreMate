import { Controller, Get } from '@nestjs/common';

@Controller('app')
export class AppController {
  @Get('version')
  getVersion() {
    return {
      latestVersion: '1.0.0',
      minimumVersion: '1.0.0',
    };
  }
}
