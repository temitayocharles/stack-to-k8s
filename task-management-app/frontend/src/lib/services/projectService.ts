import { apiService } from './api';
import type { Project } from '../stores/data';

export interface ProjectResponse {
  projects: Project[];
  count: number;
}

export interface ProjectCreateRequest {
  name: string;
  description?: string;
  owner_id: string;
  team_members?: string[];
}

class ProjectService {
  async getProjects(): Promise<ProjectResponse> {
    return apiService.get<ProjectResponse>('/projects');
  }

  async getProject(id: string): Promise<Project> {
    return apiService.get<Project>(`/projects/${id}`);
  }

  async createProject(project: ProjectCreateRequest): Promise<Project> {
    return apiService.post<Project>('/projects', project);
  }

  async updateProject(id: string, updates: Partial<ProjectCreateRequest>): Promise<Project> {
    return apiService.put<Project>(`/projects/${id}`, updates);
  }

  async getProjectTasks(projectId: string): Promise<{
    tasks: any[];
    count: number;
    project_id: string;
  }> {
    return apiService.get(`/projects/${projectId}/tasks`);
  }
}

export const projectService = new ProjectService();
