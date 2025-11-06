import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

import { HttpError } from '../../../core/http/httpError';
import { env } from '../../../config/env';
import type { User } from '../../users/models/user';
import { UserRepository } from '../../users/repositories/user.repository';

export interface LoginInput {
  username: string;
  password: string;
}

export interface LoginResult {
  token: string;
  user: Pick<User, 'id' | 'username' | 'displayName' | 'role'>;
}

export class AuthService {
  constructor(private readonly userRepository = new UserRepository()) {}

  async login(input: LoginInput): Promise<LoginResult> {
    const user = await this.userRepository.findByUsername(input.username);
    if (!user) {
      throw new HttpError(401, 'Username atau kata sandi tidak valid');
    }

    const passwordMatches = await bcrypt.compare(
      input.password,
      user.passwordHash,
    );
    if (!passwordMatches) {
      throw new HttpError(401, 'Username atau kata sandi tidak valid');
    }

    const token = jwt.sign(
      { sub: user.id, role: user.role },
      env.jwtSecret,
      { expiresIn: '12h' },
    );

    return {
      token,
      user: this.toSafeUser(user),
    };
  }

  private toSafeUser(user: User): LoginResult['user'] {
    return {
      id: user.id,
      username: user.username,
      displayName: user.displayName,
      role: user.role,
    };
  }
}
