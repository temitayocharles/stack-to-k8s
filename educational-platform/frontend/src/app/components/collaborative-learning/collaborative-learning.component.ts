import { Component, OnInit } from '@angular/core';

interface CollaborativeLearningSession {
  id: number;
  sessionName: string;
  courseId: number;
  chapterId: number;
  hostUserId: number;
  maxParticipants: number;
  scheduledStartTime: string;
  scheduledEndTime: string;
  actualStartTime?: string;
  actualEndTime?: string;
  sessionType: string;
  description: string;
  meetingLink: string;
  status: 'SCHEDULED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';
  createdAt: string;
}

interface SessionParticipant {
  id: number;
  session: CollaborativeLearningSession;
  userId: number;
  joinedAt: string;
  leftAt?: string;
  role: string;
  attendanceDurationMinutes?: number;
  contributionScore: number;
}

interface SessionAnalytics {
  sessionId: number;
  totalParticipants: number;
  averageAttendanceDuration: number;
  averageContributionScore: number;
  participationTimeline: { [key: string]: number };
}

@Component({
  selector: 'app-collaborative-learning',
  template: `
    <div class="collaborative-learning">
      <div class="header">
        <h1>
          <i class="fas fa-users"></i>
          Collaborative Learning Hub
        </h1>
        <div class="header-actions">
          <button (click)="openCreateSessionModal()" class="create-session-btn">
            <i class="fas fa-plus"></i>
            Create Study Session
          </button>
          <button (click)="refreshSessions()" class="refresh-btn">
            <i class="fas fa-sync-alt"></i>
            Refresh
          </button>
        </div>
      </div>

      <!-- Search and Filter -->
      <div class="search-section">
        <div class="search-controls">
          <input 
            type="text" 
            [(ngModel)]="searchQuery" 
            (input)="searchSessions()"
            placeholder="Search study sessions..." 
            class="search-input">
          
          <select [(ngModel)]="filterType" (change)="filterSessions()" class="filter-select">
            <option value="">All Session Types</option>
            <option value="STUDY_GROUP">Study Groups</option>
            <option value="Q_AND_A">Q&A Sessions</option>
            <option value="PROJECT_COLLABORATION">Project Collaboration</option>
            <option value="PEER_REVIEW">Peer Review</option>
          </select>

          <select [(ngModel)]="filterCourse" (change)="filterSessions()" class="filter-select">
            <option value="">All Courses</option>
            <option value="1">JavaScript Fundamentals</option>
            <option value="2">React Development</option>
            <option value="3">Node.js Backend</option>
            <option value="4">Python Programming</option>
          </select>
        </div>
      </div>

      <!-- Active Sessions -->
      <div class="active-sessions-section" *ngIf="activeSessions.length > 0">
        <h2>
          <i class="fas fa-play-circle"></i>
          Live Sessions
        </h2>
        <div class="sessions-grid">
          <div *ngFor="let session of activeSessions" class="session-card active">
            <div class="session-header">
              <h3>{{session.sessionName}}</h3>
              <div class="session-status live">
                <i class="fas fa-circle"></i>
                LIVE
              </div>
            </div>
            <div class="session-details">
              <div class="session-info">
                <span class="session-type">{{session.sessionType.replace('_', ' ')}}</span>
                <span class="session-participants">
                  <i class="fas fa-users"></i>
                  {{getParticipantCount(session.id)}}/{{session.maxParticipants}}
                </span>
              </div>
              <p class="session-description">{{session.description}}</p>
              <div class="session-meta">
                <span class="host">Host: User {{session.hostUserId}}</span>
                <span class="course">Course {{session.courseId}}</span>
              </div>
            </div>
            <div class="session-actions">
              <button (click)="joinSession(session.id)" class="join-btn primary">
                <i class="fas fa-video"></i>
                Join Session
              </button>
              <button (click)="viewSessionDetails(session.id)" class="details-btn">
                <i class="fas fa-info-circle"></i>
                Details
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Upcoming Sessions -->
      <div class="upcoming-sessions-section">
        <h2>
          <i class="fas fa-calendar-alt"></i>
          Upcoming Study Sessions
        </h2>
        
        <!-- Recommended Sessions -->
        <div class="recommended-section" *ngIf="recommendedSessions.length > 0">
          <h3>
            <i class="fas fa-magic"></i>
            Recommended for You
          </h3>
          <div class="sessions-grid">
            <div *ngFor="let session of recommendedSessions" class="session-card recommended">
              <div class="recommendation-badge">
                <i class="fas fa-star"></i>
                Recommended
              </div>
              <div class="session-header">
                <h3>{{session.sessionName}}</h3>
                <div class="session-status scheduled">
                  {{session.scheduledStartTime | date:'short'}}
                </div>
              </div>
              <div class="session-details">
                <div class="session-info">
                  <span class="session-type">{{session.sessionType.replace('_', ' ')}}</span>
                  <span class="session-participants">
                    <i class="fas fa-users"></i>
                    {{getParticipantCount(session.id)}}/{{session.maxParticipants}}
                  </span>
                </div>
                <p class="session-description">{{session.description}}</p>
                <div class="session-meta">
                  <span class="host">Host: User {{session.hostUserId}}</span>
                  <span class="course">Course {{session.courseId}}</span>
                </div>
                <div class="time-info">
                  <span class="start-time">
                    <i class="fas fa-clock"></i>
                    {{session.scheduledStartTime | date:'short'}}
                  </span>
                  <span class="duration">
                    Duration: {{getSessionDuration(session)}}
                  </span>
                </div>
              </div>
              <div class="session-actions">
                <button (click)="joinSession(session.id)" class="join-btn">
                  <i class="fas fa-calendar-plus"></i>
                  Join Session
                </button>
                <button (click)="addToCalendar(session)" class="calendar-btn">
                  <i class="fas fa-calendar"></i>
                  Add to Calendar
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- All Sessions -->
        <div class="all-sessions-section">
          <div class="sessions-grid">
            <div *ngFor="let session of filteredSessions" class="session-card">
              <div class="session-header">
                <h3>{{session.sessionName}}</h3>
                <div class="session-status" [ngClass]="session.status.toLowerCase()">
                  {{session.status.replace('_', ' ')}}
                </div>
              </div>
              <div class="session-details">
                <div class="session-info">
                  <span class="session-type">{{session.sessionType.replace('_', ' ')}}</span>
                  <span class="session-participants">
                    <i class="fas fa-users"></i>
                    {{getParticipantCount(session.id)}}/{{session.maxParticipants}}
                  </span>
                </div>
                <p class="session-description">{{session.description}}</p>
                <div class="session-meta">
                  <span class="host">Host: User {{session.hostUserId}}</span>
                  <span class="course">Course {{session.courseId}}</span>
                </div>
                <div class="time-info">
                  <span class="start-time">
                    <i class="fas fa-clock"></i>
                    {{session.scheduledStartTime | date:'short'}}
                  </span>
                  <span class="duration">
                    Duration: {{getSessionDuration(session)}}
                  </span>
                </div>
              </div>
              <div class="session-actions">
                <button 
                  *ngIf="session.status === 'SCHEDULED'"
                  (click)="joinSession(session.id)" 
                  class="join-btn">
                  <i class="fas fa-calendar-plus"></i>
                  Join Session
                </button>
                <button 
                  *ngIf="session.status === 'IN_PROGRESS'"
                  (click)="joinSession(session.id)" 
                  class="join-btn primary">
                  <i class="fas fa-video"></i>
                  Join Now
                </button>
                <button (click)="viewSessionDetails(session.id)" class="details-btn">
                  <i class="fas fa-info-circle"></i>
                  Details
                </button>
                <button 
                  *ngIf="isSessionHost(session)"
                  (click)="manageSession(session.id)" 
                  class="manage-btn">
                  <i class="fas fa-cog"></i>
                  Manage
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- My Sessions -->
      <div class="my-sessions-section">
        <h2>
          <i class="fas fa-user-circle"></i>
          My Study Sessions
        </h2>
        <div class="my-sessions-tabs">
          <button 
            [class.active]="mySessionsTab === 'joined'"
            (click)="mySessionsTab = 'joined'"
            class="tab-btn">
            Joined Sessions
          </button>
          <button 
            [class.active]="mySessionsTab === 'hosted'"
            (click)="mySessionsTab = 'hosted'"
            class="tab-btn">
            Hosted Sessions
          </button>
          <button 
            [class.active]="mySessionsTab === 'history'"
            (click)="mySessionsTab = 'history'"
            class="tab-btn">
            Session History
          </button>
        </div>

        <div class="my-sessions-content">
          <div *ngIf="mySessionsTab === 'joined'" class="sessions-list">
            <div *ngFor="let session of getJoinedSessions()" class="session-item">
              <div class="session-info">
                <h4>{{session.sessionName}}</h4>
                <p>{{session.description}}</p>
                <div class="session-details-inline">
                  <span>{{session.scheduledStartTime | date:'short'}}</span>
                  <span class="status" [ngClass]="session.status.toLowerCase()">
                    {{session.status}}
                  </span>
                </div>
              </div>
              <div class="session-actions-inline">
                <button (click)="viewSessionDetails(session.id)" class="btn-small">
                  View Details
                </button>
                <button 
                  *ngIf="session.status === 'SCHEDULED'"
                  (click)="leaveSession(session.id)" 
                  class="btn-small danger">
                  Leave
                </button>
              </div>
            </div>
          </div>

          <div *ngIf="mySessionsTab === 'hosted'" class="sessions-list">
            <div *ngFor="let session of getHostedSessions()" class="session-item">
              <div class="session-info">
                <h4>{{session.sessionName}}</h4>
                <p>{{session.description}}</p>
                <div class="session-details-inline">
                  <span>{{session.scheduledStartTime | date:'short'}}</span>
                  <span>{{getParticipantCount(session.id)}} participants</span>
                  <span class="status" [ngClass]="session.status.toLowerCase()">
                    {{session.status}}
                  </span>
                </div>
              </div>
              <div class="session-actions-inline">
                <button (click)="manageSession(session.id)" class="btn-small">
                  Manage
                </button>
                <button (click)="viewAnalytics(session.id)" class="btn-small">
                  Analytics
                </button>
                <button 
                  *ngIf="session.status === 'SCHEDULED'"
                  (click)="cancelSession(session.id)" 
                  class="btn-small danger">
                  Cancel
                </button>
              </div>
            </div>
          </div>

          <div *ngIf="mySessionsTab === 'history'" class="sessions-list">
            <div *ngFor="let session of getCompletedSessions()" class="session-item">
              <div class="session-info">
                <h4>{{session.sessionName}}</h4>
                <p>{{session.description}}</p>
                <div class="session-details-inline">
                  <span>{{session.actualStartTime | date:'short'}}</span>
                  <span>Duration: {{getActualDuration(session)}}</span>
                  <span class="contribution-score">
                    Contribution: {{getMyContributionScore(session.id)}}%
                  </span>
                </div>
              </div>
              <div class="session-actions-inline">
                <button (click)="viewSessionSummary(session.id)" class="btn-small">
                  View Summary
                </button>
                <button (click)="provideFeedback(session.id)" class="btn-small">
                  Feedback
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Session Analytics Dashboard -->
      <div class="analytics-section" *ngIf="showAnalytics">
        <h2>
          <i class="fas fa-chart-line"></i>
          Collaboration Analytics
        </h2>
        <div class="analytics-cards">
          <div class="analytics-card">
            <h3>Total Sessions</h3>
            <div class="metric">{{getAnalyticsData().totalSessions}}</div>
            <div class="metric-label">This month</div>
          </div>
          <div class="analytics-card">
            <h3>Avg. Participation</h3>
            <div class="metric">{{getAnalyticsData().avgParticipation}}</div>
            <div class="metric-label">participants per session</div>
          </div>
          <div class="analytics-card">
            <h3>Contribution Score</h3>
            <div class="metric">{{getAnalyticsData().avgContribution}}%</div>
            <div class="metric-label">average contribution</div>
          </div>
          <div class="analytics-card">
            <h3>Attendance Rate</h3>
            <div class="metric">{{getAnalyticsData().attendanceRate}}%</div>
            <div class="metric-label">session attendance</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create Session Modal -->
    <div class="modal-overlay" *ngIf="showCreateModal" (click)="closeCreateSessionModal()">
      <div class="modal-content" (click)="$event.stopPropagation()">
        <div class="modal-header">
          <h2>Create Study Session</h2>
          <button (click)="closeCreateSessionModal()" class="close-btn">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <form (ngSubmit)="createSession()" class="create-session-form">
            <div class="form-group">
              <label>Session Name</label>
              <input 
                type="text" 
                [(ngModel)]="newSession.sessionName" 
                name="sessionName"
                required 
                class="form-control">
            </div>

            <div class="form-group">
              <label>Description</label>
              <textarea 
                [(ngModel)]="newSession.description" 
                name="description"
                rows="3" 
                class="form-control">
              </textarea>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Session Type</label>
                <select [(ngModel)]="newSession.sessionType" name="sessionType" class="form-control">
                  <option value="STUDY_GROUP">Study Group</option>
                  <option value="Q_AND_A">Q&A Session</option>
                  <option value="PROJECT_COLLABORATION">Project Collaboration</option>
                  <option value="PEER_REVIEW">Peer Review</option>
                </select>
              </div>

              <div class="form-group">
                <label>Course</label>
                <select [(ngModel)]="newSession.courseId" name="courseId" class="form-control">
                  <option value="1">JavaScript Fundamentals</option>
                  <option value="2">React Development</option>
                  <option value="3">Node.js Backend</option>
                  <option value="4">Python Programming</option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Start Date & Time</label>
                <input 
                  type="datetime-local" 
                  [(ngModel)]="newSession.scheduledStartTime" 
                  name="startTime"
                  required 
                  class="form-control">
              </div>

              <div class="form-group">
                <label>End Date & Time</label>
                <input 
                  type="datetime-local" 
                  [(ngModel)]="newSession.scheduledEndTime" 
                  name="endTime"
                  required 
                  class="form-control">
              </div>
            </div>

            <div class="form-group">
              <label>Max Participants</label>
              <input 
                type="number" 
                [(ngModel)]="newSession.maxParticipants" 
                name="maxParticipants"
                min="2" 
                max="50" 
                required 
                class="form-control">
            </div>

            <div class="form-actions">
              <button type="button" (click)="closeCreateSessionModal()" class="btn-cancel">
                Cancel
              </button>
              <button type="submit" class="btn-create">
                <i class="fas fa-plus"></i>
                Create Session
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .collaborative-learning {
      padding: 20px;
      max-width: 1400px;
      margin: 0 auto;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
    }

    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 30px;
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(10px);
      padding: 25px;
      border-radius: 15px;
      border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .header h1 {
      color: white;
      font-size: 2.5rem;
      font-weight: 700;
      margin: 0;
      text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
    }

    .header h1 i {
      margin-right: 15px;
      color: #64ffda;
    }

    .header-actions {
      display: flex;
      gap: 15px;
    }

    .create-session-btn {
      padding: 12px 24px;
      background: #64ffda;
      color: #1a1a1a;
      border: none;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
      font-size: 1rem;
    }

    .create-session-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 16px rgba(100, 255, 218, 0.3);
    }

    .refresh-btn {
      padding: 12px 20px;
      background: rgba(255, 255, 255, 0.2);
      color: white;
      border: 1px solid rgba(255, 255, 255, 0.3);
      border-radius: 8px;
      cursor: pointer;
      transition: background 0.3s;
    }

    .refresh-btn:hover {
      background: rgba(255, 255, 255, 0.3);
    }

    .search-section {
      background: rgba(255, 255, 255, 0.95);
      padding: 25px;
      border-radius: 15px;
      margin-bottom: 30px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    }

    .search-controls {
      display: flex;
      gap: 15px;
      align-items: center;
      flex-wrap: wrap;
    }

    .search-input {
      flex: 1;
      min-width: 300px;
      padding: 12px 16px;
      border: 2px solid #e9ecef;
      border-radius: 8px;
      font-size: 1rem;
      background: white;
    }

    .search-input:focus {
      outline: none;
      border-color: #667eea;
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    .filter-select {
      padding: 12px 16px;
      border: 2px solid #e9ecef;
      border-radius: 8px;
      background: white;
      cursor: pointer;
      min-width: 180px;
    }

    .filter-select:focus {
      outline: none;
      border-color: #667eea;
    }

    .active-sessions-section,
    .upcoming-sessions-section,
    .my-sessions-section,
    .analytics-section {
      background: rgba(255, 255, 255, 0.95);
      padding: 30px;
      border-radius: 15px;
      margin-bottom: 30px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    }

    .active-sessions-section h2,
    .upcoming-sessions-section h2,
    .my-sessions-section h2,
    .analytics-section h2 {
      color: #2c3e50;
      margin-bottom: 25px;
      font-size: 1.8rem;
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .recommended-section {
      margin-bottom: 30px;
    }

    .recommended-section h3 {
      color: #e67e22;
      margin-bottom: 20px;
      font-size: 1.4rem;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .sessions-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
      gap: 20px;
    }

    .session-card {
      background: white;
      border-radius: 12px;
      padding: 25px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      border: 2px solid transparent;
      transition: all 0.3s;
      position: relative;
    }

    .session-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
      border-color: #667eea;
    }

    .session-card.active {
      border-color: #27ae60;
      background: linear-gradient(135deg, #d5f4e6 0%, #ffffff 100%);
    }

    .session-card.recommended {
      border-color: #e67e22;
      background: linear-gradient(135deg, #fdeaa7 0%, #ffffff 100%);
    }

    .recommendation-badge {
      position: absolute;
      top: -10px;
      right: 15px;
      background: #e67e22;
      color: white;
      padding: 6px 12px;
      border-radius: 12px;
      font-size: 0.8rem;
      font-weight: 600;
    }

    .session-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 15px;
    }

    .session-header h3 {
      color: #2c3e50;
      margin: 0;
      font-size: 1.3rem;
      line-height: 1.3;
    }

    .session-status {
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 0.8rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .session-status.live {
      background: #27ae60;
      color: white;
      animation: pulse 2s infinite;
    }

    .session-status.scheduled {
      background: #3498db;
      color: white;
    }

    .session-status.completed {
      background: #95a5a6;
      color: white;
    }

    .session-status.cancelled {
      background: #e74c3c;
      color: white;
    }

    @keyframes pulse {
      0% { opacity: 1; }
      50% { opacity: 0.7; }
      100% { opacity: 1; }
    }

    .session-details {
      margin-bottom: 20px;
    }

    .session-info {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 12px;
    }

    .session-type {
      background: #ecf0f1;
      padding: 4px 8px;
      border-radius: 6px;
      font-size: 0.85rem;
      font-weight: 500;
      color: #2c3e50;
    }

    .session-participants {
      color: #7f8c8d;
      font-size: 0.9rem;
      display: flex;
      align-items: center;
      gap: 5px;
    }

    .session-description {
      color: #7f8c8d;
      line-height: 1.5;
      margin: 10px 0;
    }

    .session-meta {
      display: flex;
      gap: 15px;
      font-size: 0.85rem;
      color: #95a5a6;
      margin-bottom: 10px;
    }

    .time-info {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 0.9rem;
      color: #2c3e50;
      background: #f8f9fa;
      padding: 8px 12px;
      border-radius: 6px;
    }

    .session-actions {
      display: flex;
      gap: 10px;
    }

    .join-btn {
      flex: 1;
      padding: 12px;
      border: none;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
      background: #667eea;
      color: white;
    }

    .join-btn.primary {
      background: #27ae60;
    }

    .join-btn:hover {
      transform: translateY(-2px);
    }

    .details-btn,
    .calendar-btn,
    .manage-btn {
      padding: 12px;
      border: 2px solid #667eea;
      background: transparent;
      color: #667eea;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.3s;
      font-weight: 500;
    }

    .details-btn:hover,
    .calendar-btn:hover,
    .manage-btn:hover {
      background: #667eea;
      color: white;
    }

    .my-sessions-tabs {
      display: flex;
      gap: 2px;
      margin-bottom: 25px;
      background: #ecf0f1;
      padding: 4px;
      border-radius: 8px;
    }

    .tab-btn {
      flex: 1;
      padding: 12px 20px;
      border: none;
      background: transparent;
      color: #7f8c8d;
      cursor: pointer;
      border-radius: 6px;
      font-weight: 500;
      transition: all 0.3s;
    }

    .tab-btn.active {
      background: white;
      color: #2c3e50;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .sessions-list {
      display: flex;
      flex-direction: column;
      gap: 15px;
    }

    .session-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 20px;
      background: #f8f9fa;
      border-radius: 8px;
      border-left: 4px solid #667eea;
    }

    .session-info h4 {
      margin: 0 0 8px 0;
      color: #2c3e50;
    }

    .session-info p {
      margin: 0 0 8px 0;
      color: #7f8c8d;
      font-size: 0.9rem;
    }

    .session-details-inline {
      display: flex;
      gap: 15px;
      font-size: 0.85rem;
      color: #95a5a6;
    }

    .session-actions-inline {
      display: flex;
      gap: 10px;
    }

    .btn-small {
      padding: 8px 16px;
      border: 1px solid #e9ecef;
      background: white;
      color: #667eea;
      border-radius: 6px;
      cursor: pointer;
      font-size: 0.85rem;
      font-weight: 500;
      transition: all 0.3s;
    }

    .btn-small:hover {
      background: #667eea;
      color: white;
    }

    .btn-small.danger {
      color: #e74c3c;
      border-color: #e74c3c;
    }

    .btn-small.danger:hover {
      background: #e74c3c;
      color: white;
    }

    .contribution-score {
      background: #d5f4e6;
      color: #27ae60;
      padding: 4px 8px;
      border-radius: 6px;
      font-weight: 600;
    }

    .analytics-cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 20px;
    }

    .analytics-card {
      background: white;
      padding: 25px;
      border-radius: 12px;
      text-align: center;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      border-left: 4px solid #667eea;
    }

    .analytics-card h3 {
      color: #2c3e50;
      margin: 0 0 15px 0;
      font-size: 1.1rem;
    }

    .metric {
      font-size: 3rem;
      font-weight: 700;
      color: #667eea;
      margin-bottom: 5px;
    }

    .metric-label {
      color: #7f8c8d;
      font-size: 0.9rem;
    }

    /* Modal Styles */
    .modal-overlay {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1000;
      backdrop-filter: blur(4px);
    }

    .modal-content {
      background: white;
      border-radius: 15px;
      width: 90%;
      max-width: 600px;
      max-height: 90vh;
      overflow-y: auto;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    }

    .modal-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 25px 30px;
      border-bottom: 1px solid #e9ecef;
    }

    .modal-header h2 {
      margin: 0;
      color: #2c3e50;
    }

    .close-btn {
      background: none;
      border: none;
      font-size: 1.5rem;
      color: #95a5a6;
      cursor: pointer;
      padding: 5px;
      border-radius: 50%;
      transition: all 0.3s;
    }

    .close-btn:hover {
      background: #ecf0f1;
      color: #2c3e50;
    }

    .modal-body {
      padding: 30px;
    }

    .create-session-form {
      display: flex;
      flex-direction: column;
      gap: 20px;
    }

    .form-group {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .form-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
    }

    .form-group label {
      font-weight: 600;
      color: #2c3e50;
    }

    .form-control {
      padding: 12px;
      border: 2px solid #e9ecef;
      border-radius: 8px;
      font-size: 1rem;
      transition: border-color 0.3s;
    }

    .form-control:focus {
      outline: none;
      border-color: #667eea;
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    .form-actions {
      display: flex;
      justify-content: flex-end;
      gap: 15px;
      margin-top: 20px;
      padding-top: 20px;
      border-top: 1px solid #e9ecef;
    }

    .btn-cancel {
      padding: 12px 24px;
      border: 2px solid #95a5a6;
      background: transparent;
      color: #95a5a6;
      border-radius: 8px;
      cursor: pointer;
      font-weight: 600;
      transition: all 0.3s;
    }

    .btn-cancel:hover {
      background: #95a5a6;
      color: white;
    }

    .btn-create {
      padding: 12px 24px;
      background: #27ae60;
      color: white;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      font-weight: 600;
      transition: all 0.3s;
    }

    .btn-create:hover {
      background: #229954;
      transform: translateY(-2px);
    }

    @media (max-width: 768px) {
      .collaborative-learning {
        padding: 15px;
      }

      .header {
        flex-direction: column;
        gap: 15px;
        text-align: center;
      }

      .header h1 {
        font-size: 2rem;
      }

      .search-controls {
        flex-direction: column;
        align-items: stretch;
      }

      .search-input {
        min-width: auto;
      }

      .sessions-grid {
        grid-template-columns: 1fr;
      }

      .session-actions {
        flex-direction: column;
      }

      .session-item {
        flex-direction: column;
        align-items: stretch;
        gap: 15px;
      }

      .session-actions-inline {
        justify-content: center;
      }

      .analytics-cards {
        grid-template-columns: 1fr;
      }

      .form-row {
        grid-template-columns: 1fr;
      }

      .form-actions {
        flex-direction: column;
      }

      .my-sessions-tabs {
        flex-direction: column;
      }
    }
  `]
})
export class CollaborativeLearningComponent implements OnInit {
  currentUserId: number = 1; // Current logged-in user
  
  searchQuery: string = '';
  filterType: string = '';
  filterCourse: string = '';
  
  allSessions: CollaborativeLearningSession[] = [];
  activeSessions: CollaborativeLearningSession[] = [];
  filteredSessions: CollaborativeLearningSession[] = [];
  recommendedSessions: CollaborativeLearningSession[] = [];
  
  mySessionsTab: string = 'joined';
  showAnalytics: boolean = true;
  
  // Create session modal
  showCreateModal: boolean = false;
  newSession: any = {
    sessionName: '',
    description: '',
    sessionType: 'STUDY_GROUP',
    courseId: 1,
    scheduledStartTime: '',
    scheduledEndTime: '',
    maxParticipants: 10
  };

  // Mock data for participants
  sessionParticipants: { [sessionId: number]: SessionParticipant[] } = {};

  ngOnInit() {
    this.loadSessions();
    this.loadRecommendedSessions();
    this.initializeMockData();
  }

  loadSessions() {
    // Mock data for collaborative learning sessions
    this.allSessions = [
      {
        id: 1,
        sessionName: 'JavaScript Fundamentals Study Group',
        courseId: 1,
        chapterId: 1,
        hostUserId: 2,
        maxParticipants: 15,
        scheduledStartTime: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        scheduledEndTime: new Date(Date.now() + 24 * 60 * 60 * 1000 + 2 * 60 * 60 * 1000).toISOString(),
        sessionType: 'STUDY_GROUP',
        description: 'Join us for an interactive study session covering JavaScript basics, variables, functions, and scope.',
        meetingLink: 'https://meet.educational-platform.com/room/js-fundamentals-001',
        status: 'SCHEDULED',
        createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString()
      },
      {
        id: 2,
        sessionName: 'React Hooks Deep Dive',
        courseId: 2,
        chapterId: 5,
        hostUserId: 3,
        maxParticipants: 12,
        scheduledStartTime: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(),
        scheduledEndTime: new Date(Date.now() + 4 * 60 * 60 * 1000).toISOString(),
        sessionType: 'Q_AND_A',
        description: 'Advanced React Hooks discussion with Q&A session. Bring your questions about useState, useEffect, and custom hooks!',
        meetingLink: 'https://meet.educational-platform.com/room/react-hooks-qa-002',
        status: 'IN_PROGRESS',
        createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
        actualStartTime: new Date(Date.now() - 30 * 60 * 1000).toISOString()
      },
      {
        id: 3,
        sessionName: 'Node.js Project Collaboration',
        courseId: 3,
        chapterId: 8,
        hostUserId: 1,
        maxParticipants: 8,
        scheduledStartTime: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(),
        scheduledEndTime: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000 + 3 * 60 * 60 * 1000).toISOString(),
        sessionType: 'PROJECT_COLLABORATION',
        description: 'Collaborative project session building a REST API with Express.js and MongoDB.',
        meetingLink: 'https://meet.educational-platform.com/room/nodejs-project-003',
        status: 'SCHEDULED',
        createdAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString()
      },
      {
        id: 4,
        sessionName: 'Code Review Session',
        courseId: 4,
        chapterId: 3,
        hostUserId: 4,
        maxParticipants: 10,
        scheduledStartTime: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
        scheduledEndTime: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000 + 90 * 60 * 1000).toISOString(),
        actualStartTime: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
        actualEndTime: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000 + 90 * 60 * 1000).toISOString(),
        sessionType: 'PEER_REVIEW',
        description: 'Peer code review session focusing on Python best practices and clean code principles.',
        meetingLink: 'https://meet.educational-platform.com/room/python-review-004',
        status: 'COMPLETED',
        createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString()
      }
    ];

    // Separate active sessions
    this.activeSessions = this.allSessions.filter(session => session.status === 'IN_PROGRESS');
    
    // Initially show all scheduled/upcoming sessions
    this.filteredSessions = this.allSessions.filter(session => 
      session.status === 'SCHEDULED' || session.status === 'IN_PROGRESS'
    );
  }

  loadRecommendedSessions() {
    // Mock recommended sessions based on user's activity
    this.recommendedSessions = this.allSessions.filter(session => 
      session.courseId === 1 || session.courseId === 2
    ).slice(0, 2);
  }

  initializeMockData() {
    // Mock participant data
    this.sessionParticipants = {
      1: [
        { id: 1, session: this.allSessions[0], userId: 1, joinedAt: new Date().toISOString(), role: 'PARTICIPANT', contributionScore: 85 },
        { id: 2, session: this.allSessions[0], userId: 2, joinedAt: new Date().toISOString(), role: 'HOST', contributionScore: 95 },
        { id: 3, session: this.allSessions[0], userId: 5, joinedAt: new Date().toISOString(), role: 'PARTICIPANT', contributionScore: 78 }
      ],
      2: [
        { id: 4, session: this.allSessions[1], userId: 1, joinedAt: new Date().toISOString(), role: 'PARTICIPANT', contributionScore: 92 },
        { id: 5, session: this.allSessions[1], userId: 3, joinedAt: new Date().toISOString(), role: 'HOST', contributionScore: 88 },
        { id: 6, session: this.allSessions[1], userId: 6, joinedAt: new Date().toISOString(), role: 'PARTICIPANT', contributionScore: 83 }
      ],
      3: [
        { id: 7, session: this.allSessions[2], userId: 1, joinedAt: new Date().toISOString(), role: 'HOST', contributionScore: 0 }
      ],
      4: [
        { id: 8, session: this.allSessions[3], userId: 1, joinedAt: new Date().toISOString(), role: 'PARTICIPANT', contributionScore: 89 },
        { id: 9, session: this.allSessions[3], userId: 4, joinedAt: new Date().toISOString(), role: 'HOST', contributionScore: 94 }
      ]
    };
  }

  searchSessions() {
    this.filterSessions();
  }

  filterSessions() {
    let filtered = this.allSessions.filter(session => 
      session.status === 'SCHEDULED' || session.status === 'IN_PROGRESS'
    );

    if (this.searchQuery.trim()) {
      filtered = filtered.filter(session =>
        session.sessionName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        session.description.toLowerCase().includes(this.searchQuery.toLowerCase())
      );
    }

    if (this.filterType) {
      filtered = filtered.filter(session => session.sessionType === this.filterType);
    }

    if (this.filterCourse) {
      filtered = filtered.filter(session => session.courseId.toString() === this.filterCourse);
    }

    this.filteredSessions = filtered;
  }

  refreshSessions() {
    console.log('Refreshing sessions...');
    this.loadSessions();
    this.loadRecommendedSessions();
  }

  openCreateSessionModal() {
    this.showCreateModal = true;
    // Set default start time to 1 hour from now
    const defaultStart = new Date(Date.now() + 60 * 60 * 1000);
    const defaultEnd = new Date(Date.now() + 3 * 60 * 60 * 1000);
    
    this.newSession.scheduledStartTime = defaultStart.toISOString().slice(0, 16);
    this.newSession.scheduledEndTime = defaultEnd.toISOString().slice(0, 16);
  }

  closeCreateSessionModal() {
    this.showCreateModal = false;
    // Reset form
    this.newSession = {
      sessionName: '',
      description: '',
      sessionType: 'STUDY_GROUP',
      courseId: 1,
      scheduledStartTime: '',
      scheduledEndTime: '',
      maxParticipants: 10
    };
  }

  createSession() {
    console.log('Creating session:', this.newSession);
    
    // Create new session object
    const session: CollaborativeLearningSession = {
      id: this.allSessions.length + 1,
      sessionName: this.newSession.sessionName,
      courseId: parseInt(this.newSession.courseId),
      chapterId: 1,
      hostUserId: this.currentUserId,
      maxParticipants: this.newSession.maxParticipants,
      scheduledStartTime: new Date(this.newSession.scheduledStartTime).toISOString(),
      scheduledEndTime: new Date(this.newSession.scheduledEndTime).toISOString(),
      sessionType: this.newSession.sessionType,
      description: this.newSession.description,
      meetingLink: `https://meet.educational-platform.com/room/session-${this.allSessions.length + 1}`,
      status: 'SCHEDULED',
      createdAt: new Date().toISOString()
    };

    // Add to sessions list
    this.allSessions.unshift(session);
    this.filterSessions();
    
    // Close modal
    this.closeCreateSessionModal();
    
    // Show success message (you could implement a toast service)
    alert('Study session created successfully!');
  }

  joinSession(sessionId: number) {
    console.log('Joining session:', sessionId);
    const session = this.allSessions.find(s => s.id === sessionId);
    
    if (session) {
      // Check if user is already a participant
      const participants = this.sessionParticipants[sessionId] || [];
      const isAlreadyParticipant = participants.some(p => p.userId === this.currentUserId);
      
      if (!isAlreadyParticipant) {
        // Add user as participant
        const newParticipant: SessionParticipant = {
          id: Date.now(),
          session: session,
          userId: this.currentUserId,
          joinedAt: new Date().toISOString(),
          role: 'PARTICIPANT',
          contributionScore: 0
        };
        
        if (!this.sessionParticipants[sessionId]) {
          this.sessionParticipants[sessionId] = [];
        }
        this.sessionParticipants[sessionId].push(newParticipant);
      }
      
      // Simulate opening meeting link
      if (session.status === 'IN_PROGRESS') {
        window.open(session.meetingLink, '_blank');
      } else {
        alert(`Session scheduled for ${new Date(session.scheduledStartTime).toLocaleString()}. You'll receive a reminder when it starts!`);
      }
    }
  }

  leaveSession(sessionId: number) {
    console.log('Leaving session:', sessionId);
    
    if (this.sessionParticipants[sessionId]) {
      this.sessionParticipants[sessionId] = this.sessionParticipants[sessionId].filter(
        p => p.userId !== this.currentUserId
      );
    }
    
    alert('Left the study session successfully.');
  }

  viewSessionDetails(sessionId: number) {
    console.log('Viewing session details:', sessionId);
    // Implement session details modal or navigation
  }

  isSessionHost(session: CollaborativeLearningSession): boolean {
    return session.hostUserId === this.currentUserId;
  }

  manageSession(sessionId: number) {
    console.log('Managing session:', sessionId);
    // Implement session management functionality
  }

  cancelSession(sessionId: number) {
    console.log('Cancelling session:', sessionId);
    const session = this.allSessions.find(s => s.id === sessionId);
    if (session && session.hostUserId === this.currentUserId) {
      session.status = 'CANCELLED';
      this.filterSessions();
      alert('Session cancelled successfully. Participants will be notified.');
    }
  }

  addToCalendar(session: CollaborativeLearningSession) {
    console.log('Adding to calendar:', session);
    
    // Create calendar event details
    const startDate = new Date(session.scheduledStartTime);
    const endDate = new Date(session.scheduledEndTime);
    
    const calendarUrl = `https://calendar.google.com/calendar/render?action=TEMPLATE&text=${encodeURIComponent(session.sessionName)}&dates=${startDate.toISOString().replace(/[-:]/g, '').replace(/\.\d{3}/, '')}/${endDate.toISOString().replace(/[-:]/g, '').replace(/\.\d{3}/, '')}&details=${encodeURIComponent(session.description + '\n\nMeeting Link: ' + session.meetingLink)}`;
    
    window.open(calendarUrl, '_blank');
  }

  viewAnalytics(sessionId: number) {
    console.log('Viewing analytics for session:', sessionId);
    // Implement analytics view
  }

  viewSessionSummary(sessionId: number) {
    console.log('Viewing session summary:', sessionId);
    // Implement session summary view
  }

  provideFeedback(sessionId: number) {
    console.log('Providing feedback for session:', sessionId);
    // Implement feedback form
  }

  getParticipantCount(sessionId: number): number {
    return this.sessionParticipants[sessionId]?.length || 0;
  }

  getSessionDuration(session: CollaborativeLearningSession): string {
    const start = new Date(session.scheduledStartTime);
    const end = new Date(session.scheduledEndTime);
    const duration = (end.getTime() - start.getTime()) / (1000 * 60 * 60);
    return `${duration}h`;
  }

  getActualDuration(session: CollaborativeLearningSession): string {
    if (session.actualStartTime && session.actualEndTime) {
      const start = new Date(session.actualStartTime);
      const end = new Date(session.actualEndTime);
      const duration = (end.getTime() - start.getTime()) / (1000 * 60);
      return `${Math.round(duration)}min`;
    }
    return 'N/A';
  }

  getMyContributionScore(sessionId: number): number {
    const participants = this.sessionParticipants[sessionId] || [];
    const myParticipation = participants.find(p => p.userId === this.currentUserId);
    return myParticipation?.contributionScore || 0;
  }

  getJoinedSessions(): CollaborativeLearningSession[] {
    return this.allSessions.filter(session => {
      const participants = this.sessionParticipants[session.id] || [];
      return participants.some(p => p.userId === this.currentUserId && p.role !== 'HOST');
    });
  }

  getHostedSessions(): CollaborativeLearningSession[] {
    return this.allSessions.filter(session => session.hostUserId === this.currentUserId);
  }

  getCompletedSessions(): CollaborativeLearningSession[] {
    return this.allSessions.filter(session => {
      const participants = this.sessionParticipants[session.id] || [];
      return session.status === 'COMPLETED' && 
             participants.some(p => p.userId === this.currentUserId);
    });
  }

  getAnalyticsData() {
    // Mock analytics data
    return {
      totalSessions: 12,
      avgParticipation: 8.5,
      avgContribution: 87,
      attendanceRate: 92
    };
  }
}