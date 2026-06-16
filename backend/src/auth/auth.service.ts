import {
  Injectable,
  UnauthorizedException,
  Logger,
  InternalServerErrorException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { LoginDto } from './dto/login.dto';
import { verifyFirebaseToken } from '../config/firebase.config';
import { User } from '../users/entities/user.entity';
import { JwtPayload } from './decorators/current-user.decorator';

export interface LoginResponse {
  accessToken: string;
  user: {
    id: string;
    mobileNumber: string;
    role: string;
    shopId: string | null;
    lastLoginAt: Date | null;
  };
  shop: {
    id: string;
    shopCode: string;
    name: string;
    businessType: string;
  } | null;
  onboardingRequired: boolean;
}

export interface ProfileResponse {
  user: {
    id: string;
    mobileNumber: string;
    role: string;
    shopId: string | null;
    lastLoginAt: Date | null;
    createdAt: Date;
  };
  shop: {
    id: string;
    shopCode: string;
    name: string;
    ownerName: string;
    mobileNumber: string | null;
    email: string | null;
    address: string | null;
    businessType: string;
    subscriptionStatus: string;
    createdAt: Date;
  } | null;
  onboardingRequired: boolean;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly jwtService: JwtService,
    private readonly usersService: UsersService,
  ) {}

  /**
   * Authenticate a user via Firebase token.
   *
   * Flow:
   * 1. Verify Firebase ID token
   * 2. Check if user exists in database
   * 3. If new user → create record, mark onboarding_required
   * 4. If existing user without shop → mark onboarding_required
   * 5. If existing user with shop → return full data
   * 6. Generate and return JWT
   */
  async login(loginDto: LoginDto): Promise<LoginResponse> {
    // Step 1: Verify Firebase token
    let decodedToken;
    try {
      decodedToken = await verifyFirebaseToken(loginDto.firebaseToken);
    } catch (error) {
      this.logger.warn(
        `Firebase token verification failed: ${(error as Error).message}`,
      );
      throw new UnauthorizedException('Invalid or expired Firebase token');
    }

    const firebaseUid = decodedToken.uid;
    const phoneNumber = decodedToken.phone_number;

    if (!phoneNumber) {
      throw new UnauthorizedException(
        'Firebase token does not contain a phone number',
      );
    }

    // Normalize phone number: remove +91 prefix if present
    const normalizedPhone = phoneNumber.replace(/^\+91/, '');

    // Step 2: Find user by firebaseUid
    let user = await this.usersService.findByFirebaseUid(firebaseUid);

    if (!user) {
      // Step 2.5: Check if user was invited by mobile number
      user = await this.usersService.findByMobileNumber(normalizedPhone);
      
      if (user) {
        // Was invited. Check if inactive
        if (!user.isActive) {
          throw new UnauthorizedException('Your account has been deactivated.');
        }
        
        // Accept invite and update firebaseUid
        await this.usersService.acceptInvite(user.id, firebaseUid);
        // Reload user with shop relation
        user = await this.usersService.findByFirebaseUid(firebaseUid);
        this.logger.log(`User ${normalizedPhone} accepted staff invitation.`);
      } else {
        // Step 3: New user — create record
        this.logger.log(`New user login: ${normalizedPhone}`);
        user = await this.usersService.create({
          firebaseUid,
          mobileNumber: normalizedPhone,
        });
        // Reload with shop relation
        user = await this.usersService.findByFirebaseUid(firebaseUid);
      }

      if (!user) {
        throw new InternalServerErrorException('Failed to retrieve user');
      }
    } else {
      // User found. Check if inactive
      if (!user.isActive) {
        throw new UnauthorizedException('Your account has been deactivated.');
      }
      
      // Step 4: Existing user — update last login
      await this.usersService.updateLastLogin(user.id);
      user.lastLoginAt = new Date();
    }

    // Step 5: Generate JWT
    const accessToken = this.generateJwt(user);
    const onboardingRequired = !user.shopId;

    return {
      accessToken,
      user: {
        id: user.id,
        mobileNumber: user.mobileNumber,
        role: user.role,
        shopId: user.shopId,
        lastLoginAt: user.lastLoginAt,
      },
      shop: user.shop
        ? {
            id: user.shop.id,
            shopCode: user.shop.shopCode,
            name: user.shop.name,
            businessType: user.shop.businessType,
          }
        : null,
      onboardingRequired,
    };
  }

  /**
   * Get the authenticated user's profile with shop information.
   */
  async getProfile(userId: string): Promise<ProfileResponse> {
    const user = await this.usersService.findByIdWithShop(userId);

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return {
      user: {
        id: user.id,
        mobileNumber: user.mobileNumber,
        role: user.role,
        shopId: user.shopId,
        lastLoginAt: user.lastLoginAt,
        createdAt: user.createdAt,
      },
      shop: user.shop
        ? {
            id: user.shop.id,
            shopCode: user.shop.shopCode,
            name: user.shop.name,
            ownerName: user.shop.ownerName,
            mobileNumber: user.shop.mobileNumber,
            email: user.shop.email,
            address: user.shop.address,
            businessType: user.shop.businessType,
            subscriptionStatus: user.shop.subscriptionStatus,
            createdAt: user.shop.createdAt,
          }
        : null,
      onboardingRequired: !user.shopId,
    };
  }

  /**
   * Generate a JWT for the given user.
   * Includes shop_id in the payload for multi-tenant authorization.
   */
  generateJwt(user: User): string {
    const payload: Omit<JwtPayload, 'iat' | 'exp'> = {
      sub: user.id,
      firebaseUid: user.firebaseUid,
      shopId: user.shopId,
      role: user.role,
    };

    return this.jwtService.sign(payload);
  }
}
