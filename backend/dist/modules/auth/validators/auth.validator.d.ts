import { z } from 'zod';
export declare const loginSchema: z.ZodObject<{
    username: z.ZodString;
    password: z.ZodString;
}, z.core.$strip>;
export type LoginSchema = z.infer<typeof loginSchema>;
//# sourceMappingURL=auth.validator.d.ts.map