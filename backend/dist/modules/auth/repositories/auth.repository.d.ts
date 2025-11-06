import type { User } from '../models/user';
export declare class AuthRepository {
    constructor();
    findByUsername(username: string): Promise<User | null>;
    private mapRowToUser;
}
//# sourceMappingURL=auth.repository.d.ts.map