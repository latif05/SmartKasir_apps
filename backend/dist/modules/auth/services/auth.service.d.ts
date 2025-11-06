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
export declare class AuthService {
    private readonly userRepository;
    constructor(userRepository?: UserRepository);
    login(input: LoginInput): Promise<LoginResult>;
    private toSafeUser;
}
//# sourceMappingURL=auth.service.d.ts.map