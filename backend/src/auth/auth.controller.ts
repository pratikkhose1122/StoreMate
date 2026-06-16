import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { CurrentUser, JwtPayload } from './decorators/current-user.decorator';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * POST /api/v1/auth/login
   *
   * Accepts a Firebase ID token from the Flutter app.
   * Verifies the token, finds or creates the user, and returns a JWT.
   *
   * If the user is new or has no shop, onboardingRequired = true.
   */
  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  /**
   * GET /api/v1/auth/profile
   *
   * Returns the authenticated user's profile and shop information.
   * Used by the Flutter app on splash screen to validate the stored JWT
   * and determine navigation (dashboard vs. shop registration).
   */
  @Get('profile')
  @UseGuards(JwtAuthGuard)
  async getProfile(@CurrentUser() user: JwtPayload) {
    return this.authService.getProfile(user.sub);
  }

  /**
   * POST /api/v1/auth/logout
   *
   * Logout endpoint. Currently stateless (JWT-based), so the client
   * discards the token. This endpoint exists for:
   * 1. Future token blacklisting (when Redis is added)
   * 2. Audit logging
   * 3. API contract consistency
   */
  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async logout(@CurrentUser() user: JwtPayload) {
    return { message: 'Logged out successfully', userId: user.sub };
  }
}
