export interface User {
  id: string;
  email: string;
  username: string;
}

export interface AuthResponse {
  access_token: string;
  user: User;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  username: string;
  password: string;
}

export interface ApiErrorResponse {
  statusCode: number;
  message: string | string[];
  timestamp: string;
  path: string;
}
