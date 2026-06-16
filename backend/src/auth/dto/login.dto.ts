import { IsNotEmpty, IsString } from 'class-validator';

export class LoginDto {
  @IsNotEmpty({ message: 'Firebase token is required' })
  @IsString()
  firebaseToken: string;
}
