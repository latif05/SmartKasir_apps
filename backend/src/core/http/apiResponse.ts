export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  errors?: unknown;
}

export const successResponse = <T>(
  data?: T,
  message = 'OK',
): ApiResponse<T> => {
  const response: ApiResponse<T> = {
    success: true,
    message,
  };

  if (typeof data !== 'undefined') {
    response.data = data;
  }

  return response;
};

export const errorResponse = (
  message: string,
  errors?: unknown,
): ApiResponse<never> => {
  const response: ApiResponse<never> = {
    success: false,
    message,
  };

  if (typeof errors !== 'undefined') {
    response.errors = errors;
  }

  return response;
};
