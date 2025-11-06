export interface ApiResponse<T> {
    success: boolean;
    message?: string;
    data?: T;
    errors?: unknown;
}
export declare const successResponse: <T>(data?: T, message?: string) => ApiResponse<T>;
export declare const errorResponse: (message: string, errors?: unknown) => ApiResponse<never>;
//# sourceMappingURL=apiResponse.d.ts.map