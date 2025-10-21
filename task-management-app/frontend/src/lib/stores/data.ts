import { writable } from 'svelte/store';

export interface User {
  id: string;
  username: string;
  email: string;
  full_name: string;
  role: 'admin' | 'manager' | 'user';
  avatar?: string;
  is_active: boolean;
  created_at: string;
}

export interface Task {
  id: string;
  title: string;
  description: string;
  status: 'todo' | 'in_progress' | 'done';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  assignee_id?: string;
  project_id: string;
  tags: string[];
  due_date?: string;
  created_by: string;
  created_at: string;
  updated_at: string;
}

export interface Project {
  id: string;
  name: string;
  description: string;
  status: 'active' | 'completed' | 'archived';
  owner_id: string;
  team_members: string[];
  created_at: string;
  updated_at: string;
}

export interface Comment {
  id: string;
  task_id: string;
  user_id: string;
  content: string;
  created_at: string;
}

// Data stores
export const tasksStore = writable<Task[]>([]);
export const projectsStore = writable<Project[]>([]);
export const usersStore = writable<User[]>([]);
export const commentsStore = writable<Comment[]>([]);

// UI stores
export const selectedTaskStore = writable<Task | null>(null);
export const selectedProjectStore = writable<Project | null>(null);
export const loadingStore = writable<boolean>(false);

// Filter stores
export const taskFilterStore = writable<{
  status?: string;
  priority?: string;
  assignee_id?: string;
  project_id?: string;
}>({});
