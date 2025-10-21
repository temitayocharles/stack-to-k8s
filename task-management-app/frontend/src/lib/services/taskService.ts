import { apiService } from './api';
import type { Task } from '../stores/data';

export interface TaskResponse {
  tasks: Task[];
  count: number;
}

export interface TaskCreateRequest {
  title: string;
  description?: string;
  status: 'todo' | 'in_progress' | 'done';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  assignee_id?: string;
  project_id: string;
  tags?: string[];
  due_date?: string;
  created_by: string;
}

export interface TaskUpdateRequest extends Partial<TaskCreateRequest> {
  id: string;
}

class TaskService {
  async getTasks(filters?: {
    project_id?: string;
    status?: string;
    assignee_id?: string;
  }): Promise<TaskResponse> {
    const params = new URLSearchParams();
    
    if (filters?.project_id) params.append('project_id', filters.project_id);
    if (filters?.status) params.append('status', filters.status);
    if (filters?.assignee_id) params.append('assignee_id', filters.assignee_id);
    
    const query = params.toString();
    const endpoint = query ? `/tasks?${query}` : '/tasks';
    
    return apiService.get<TaskResponse>(endpoint);
  }

  async getTask(id: string): Promise<Task> {
    return apiService.get<Task>(`/tasks/${id}`);
  }

  async createTask(task: TaskCreateRequest): Promise<Task> {
    return apiService.post<Task>('/tasks', task);
  }

  async updateTask(id: string, updates: Partial<TaskCreateRequest>): Promise<Task> {
    return apiService.put<Task>(`/tasks/${id}`, updates);
  }

  async deleteTask(id: string): Promise<void> {
    return apiService.delete<void>(`/tasks/${id}`);
  }

  async getTaskComments(taskId: string): Promise<{ comments: any[]; count: number }> {
    return apiService.get(`/tasks/${taskId}/comments`);
  }

  async addComment(taskId: string, comment: { content: string; user_id: string }): Promise<any> {
    return apiService.post(`/tasks/${taskId}/comments`, comment);
  }

  async getDashboardStats(): Promise<{
    total_tasks: number;
    total_users: number;
    total_projects: number;
    task_breakdown: Record<string, number>;
    priority_breakdown: Record<string, number>;
  }> {
    return apiService.get('/dashboard/stats');
  }
}

export const taskService = new TaskService();
