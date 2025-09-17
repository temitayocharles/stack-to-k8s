import { apiService } from './api';
import type { User } from '../stores/data';

export interface UserResponse {
  users: User[];
  count: number;
}

export interface UserCreateRequest {
  username: string;
  email: string;
  full_name: string;
  role: 'admin' | 'manager' | 'user';
  avatar?: string;
}

class UserService {
  async getUsers(): Promise<UserResponse> {
    return apiService.get<UserResponse>('/users');
  }

  async getUser(id: string): Promise<User> {
    return apiService.get<User>(`/users/${id}`);
  }

  async createUser(user: UserCreateRequest): Promise<User> {
    return apiService.post<User>('/users', user);
  }

  async updateUser(id: string, updates: Partial<UserCreateRequest>): Promise<User> {
    return apiService.put<User>(`/users/${id}`, updates);
  }
}

export const userService = new UserService();
