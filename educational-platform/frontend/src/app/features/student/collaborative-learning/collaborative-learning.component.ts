import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-collaborative-learning',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="collaborative-learning">
      <h2 class="page-title">👥 Collaborative Learning Hub</h2>
      
      <!-- Active Sessions Overview -->
      <div class="sessions-overview">
        <div class="overview-card">
          <h3>Active Sessions</h3>
          <div class="stat-value">{{ activeSessions.length }}</div>
        </div>
        <div class="overview-card">
          <h3>Your Sessions</h3>
          <div class="stat-value">{{ mySessions.length }}</div>
        </div>
        <div class="overview-card">
          <h3>Total Participants</h3>
          <div class="stat-value">{{ totalParticipants }}</div>
        </div>
        <div class="overview-card">
          <h3>Hours This Week</h3>
          <div class="stat-value">{{ weeklyHours }}</div>
        </div>
      </div>

      <!-- Create Session Button -->
      <div class="action-section">
        <button class="create-session-btn" (click)="showCreateModal = true">
          + Create New Session
        </button>
      </div>

      <!-- Active Sessions List -->
      <div class="sessions-section">
        <h3>🔴 Live Sessions</h3>
        <div class="sessions-grid">
          <div class="session-card live" *ngFor="let session of activeSessions">
            <div class="session-header">
              <h4>{{ session.title }}</h4>
              <span class="live-indicator">LIVE</span>
            </div>
            <p class="session-description">{{ session.description }}</p>
            <div class="session-meta">
              <span class="participants">👥 {{ session.participantCount }} participants</span>
              <span class="duration">⏰ {{ session.duration }} min</span>
              <span class="subject">📚 {{ session.subject }}</span>
            </div>
            <div class="session-actions">
              <button class="join-btn" (click)="joinSession(session.id)">Join Session</button>
              <button class="view-btn" (click)="viewSessionDetails(session.id)">View Details</button>
            </div>
          </div>
        </div>
      </div>

      <!-- My Sessions -->
      <div class="sessions-section">
        <h3>📝 My Sessions</h3>
        <div class="sessions-grid">
          <div class="session-card" 
               *ngFor="let session of mySessions"
               [class.completed]="session.status === 'completed'">
            <div class="session-header">
              <h4>{{ session.title }}</h4>
              <span class="status-badge" [class]="session.status">{{ session.status | uppercase }}</span>
            </div>
            <p class="session-description">{{ session.description }}</p>
            <div class="session-meta">
              <span class="participants">👥 {{ session.participantCount }} participants</span>
              <span class="created">📅 {{ formatDate(session.createdAt) }}</span>
              <span class="rating" *ngIf="session.rating">⭐ {{ session.rating }}/5</span>
            </div>
            <div class="session-actions">
              <button class="manage-btn" 
                      *ngIf="session.status === 'active'"
                      (click)="manageSession(session.id)">
                Manage
              </button>
              <button class="review-btn" 
                      *ngIf="session.status === 'completed'"
                      (click)="reviewSession(session.id)">
                View Results
              </button>
              <button class="edit-btn" 
                      *ngIf="session.status === 'scheduled'"
                      (click)="editSession(session.id)">
                Edit
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Study Groups -->
      <div class="study-groups-section">
        <h3>📖 Study Groups</h3>
        <div class="study-groups-grid">
          <div class="study-group-card" *ngFor="let group of studyGroups">
            <div class="group-header">
              <h4>{{ group.name }}</h4>
              <span class="member-count">{{ group.memberCount }} members</span>
            </div>
            <p class="group-description">{{ group.description }}</p>
            <div class="group-subjects">
              <span class="subject-tag" *ngFor="let subject of group.subjects">{{ subject }}</span>
            </div>
            <div class="group-schedule">
              <span class="schedule-info">📅 {{ group.schedule }}</span>
            </div>
            <div class="group-actions">
              <button class="join-group-btn" 
                      *ngIf="!group.isMember"
                      (click)="joinStudyGroup(group.id)">
                Join Group
              </button>
              <button class="view-group-btn" 
                      *ngIf="group.isMember"
                      (click)="viewStudyGroup(group.id)">
                View Group
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Session Analytics -->
      <div class="analytics-section">
        <h3>📊 Collaboration Analytics</h3>
        <div class="analytics-grid">
          <div class="analytic-card">
            <h4>Weekly Activity</h4>
            <div class="activity-chart">
              <div class="bar-chart">
                <div class="bar" *ngFor="let day of weeklyActivity" 
                     [style.height.%]="day.percentage">
                  <span class="bar-label">{{ day.day }}</span>
                  <span class="bar-value">{{ day.hours }}h</span>
                </div>
              </div>
            </div>
          </div>
          
          <div class="analytic-card">
            <h4>Collaboration Score</h4>
            <div class="score-display">
              <div class="score-circle">
                <span class="score-number">{{ collaborationScore }}</span>
                <span class="score-label">/100</span>
              </div>
              <div class="score-breakdown">
                <div class="score-item">
                  <span class="label">Participation:</span>
                  <span class="value">{{ scoreBreakdown.participation }}/25</span>
                </div>
                <div class="score-item">
                  <span class="label">Knowledge Sharing:</span>
                  <span class="value">{{ scoreBreakdown.sharing }}/25</span>
                </div>
                <div class="score-item">
                  <span class="label">Consistency:</span>
                  <span class="value">{{ scoreBreakdown.consistency }}/25</span>
                </div>
                <div class="score-item">
                  <span class="label">Leadership:</span>
                  <span class="value">{{ scoreBreakdown.leadership }}/25</span>
                </div>
              </div>
            </div>
          </div>
          
          <div class="analytic-card">
            <h4>Recent Achievements</h4>
            <div class="achievements-list">
              <div class="achievement-item" *ngFor="let achievement of recentAchievements">
                <span class="achievement-icon">{{ achievement.icon }}</span>
                <div class="achievement-info">
                  <span class="achievement-title">{{ achievement.title }}</span>
                  <span class="achievement-date">{{ formatDate(achievement.earnedAt) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create Session Modal -->
    <div class="modal-overlay" *ngIf="showCreateModal" (click)="showCreateModal = false">
      <div class="modal-content" (click)="$event.stopPropagation()">
        <h3>Create New Collaborative Session</h3>
        <form (ngSubmit)="createSession()" #sessionForm="ngForm">
          <div class="form-group">
            <label for="sessionTitle">Session Title</label>
            <input type="text" 
                   id="sessionTitle" 
                   [(ngModel)]="newSession.title" 
                   name="title" 
                   required 
                   class="form-control">
          </div>
          
          <div class="form-group">
            <label for="sessionDescription">Description</label>
            <textarea id="sessionDescription" 
                      [(ngModel)]="newSession.description" 
                      name="description" 
                      required 
                      class="form-control"></textarea>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label for="sessionSubject">Subject</label>
              <select id="sessionSubject" 
                      [(ngModel)]="newSession.subject" 
                      name="subject" 
                      required 
                      class="form-control">
                <option value="">Select Subject</option>
                <option value="JavaScript">JavaScript</option>
                <option value="React">React</option>
                <option value="Angular">Angular</option>
                <option value="Node.js">Node.js</option>
                <option value="Database">Database</option>
                <option value="Algorithms">Algorithms</option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="sessionDuration">Duration (minutes)</label>
              <input type="number" 
                     id="sessionDuration" 
                     [(ngModel)]="newSession.duration" 
                     name="duration" 
                     min="15" 
                     max="180" 
                     required 
                     class="form-control">
            </div>
          </div>
          
          <div class="form-group">
            <label for="sessionType">Session Type</label>
            <select id="sessionType" 
                    [(ngModel)]="newSession.type" 
                    name="type" 
                    required 
                    class="form-control">
              <option value="">Select Type</option>
              <option value="study-group">Study Group</option>
              <option value="problem-solving">Problem Solving</option>
              <option value="code-review">Code Review</option>
              <option value="project-collaboration">Project Collaboration</option>
              <option value="q-and-a">Q&A Session</option>
            </select>
          </div>
          
          <div class="modal-actions">
            <button type="button" 
                    class="cancel-btn" 
                    (click)="showCreateModal = false">
              Cancel
            </button>
            <button type="submit" 
                    class="create-btn" 
                    [disabled]="!sessionForm.form.valid">
              Create Session
            </button>
          </div>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .collaborative-learning {
      padding: 20px;
      max-width: 1200px;
      margin: 0 auto;
    }

    .page-title {
      text-align: center;
      color: #2c3e50;
      margin-bottom: 30px;
      font-size: 2.5rem;
    }

    .sessions-overview {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }

    .overview-card {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 20px;
      border-radius: 10px;
      text-align: center;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }

    .overview-card h3 {
      margin: 0 0 10px 0;
      font-size: 1rem;
      opacity: 0.9;
    }

    .stat-value {
      font-size: 2rem;
      font-weight: bold;
    }

    .action-section {
      text-align: center;
      margin-bottom: 30px;
    }

    .create-session-btn {
      background: linear-gradient(135deg, #e74c3c, #c0392b);
      color: white;
      border: none;
      padding: 15px 30px;
      border-radius: 25px;
      font-size: 1.1rem;
      font-weight: bold;
      cursor: pointer;
      transition: all 0.3s;
      box-shadow: 0 4px 15px rgba(231, 76, 60, 0.3);
    }

    .create-session-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(231, 76, 60, 0.4);
    }

    .sessions-section {
      margin-bottom: 40px;
    }

    .sessions-section h3 {
      color: #2c3e50;
      border-bottom: 2px solid #3498db;
      padding-bottom: 10px;
      margin-bottom: 20px;
    }

    .sessions-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
      gap: 20px;
    }

    .session-card {
      background: white;
      border: 1px solid #ecf0f1;
      border-radius: 10px;
      padding: 20px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      transition: all 0.3s;
    }

    .session-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
    }

    .session-card.live {
      border-left: 4px solid #e74c3c;
      animation: pulse 2s infinite;
    }

    .session-card.completed {
      opacity: 0.8;
      background: #f8f9fa;
    }

    @keyframes pulse {
      0% { border-left-color: #e74c3c; }
      50% { border-left-color: #c0392b; }
      100% { border-left-color: #e74c3c; }
    }

    .session-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;
    }

    .session-header h4 {
      margin: 0;
      color: #2c3e50;
    }

    .live-indicator {
      background: #e74c3c;
      color: white;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 0.8rem;
      font-weight: bold;
      animation: blink 1s infinite;
    }

    .status-badge {
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 0.8rem;
      font-weight: bold;
    }

    .status-badge.active {
      background: #2ecc71;
      color: white;
    }

    .status-badge.scheduled {
      background: #f39c12;
      color: white;
    }

    .status-badge.completed {
      background: #95a5a6;
      color: white;
    }

    @keyframes blink {
      0%, 50% { opacity: 1; }
      51%, 100% { opacity: 0.5; }
    }

    .session-description {
      color: #7f8c8d;
      margin-bottom: 15px;
      line-height: 1.4;
    }

    .session-meta {
      display: flex;
      flex-wrap: wrap;
      gap: 15px;
      margin-bottom: 15px;
      font-size: 0.9rem;
      color: #7f8c8d;
    }

    .session-actions {
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
    }

    .join-btn, .view-btn, .manage-btn, .review-btn, .edit-btn {
      padding: 8px 16px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      font-weight: bold;
      transition: all 0.2s;
    }

    .join-btn {
      background: #3498db;
      color: white;
    }

    .join-btn:hover {
      background: #2980b9;
    }

    .view-btn, .manage-btn {
      background: #2ecc71;
      color: white;
    }

    .view-btn:hover, .manage-btn:hover {
      background: #27ae60;
    }

    .review-btn, .edit-btn {
      background: #f39c12;
      color: white;
    }

    .review-btn:hover, .edit-btn:hover {
      background: #e67e22;
    }

    .study-groups-section {
      margin-bottom: 40px;
    }

    .study-groups-section h3 {
      color: #2c3e50;
      border-bottom: 2px solid #9b59b6;
      padding-bottom: 10px;
      margin-bottom: 20px;
    }

    .study-groups-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 20px;
    }

    .study-group-card {
      background: white;
      border: 1px solid #ecf0f1;
      border-radius: 10px;
      padding: 20px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      transition: all 0.3s;
    }

    .study-group-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
    }

    .group-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;
    }

    .group-header h4 {
      margin: 0;
      color: #2c3e50;
    }

    .member-count {
      background: #ecf0f1;
      color: #7f8c8d;
      padding: 4px 8px;
      border-radius: 12px;
      font-size: 0.8rem;
    }

    .group-description {
      color: #7f8c8d;
      margin-bottom: 15px;
      line-height: 1.4;
    }

    .group-subjects {
      margin-bottom: 15px;
    }

    .subject-tag {
      background: #3498db;
      color: white;
      padding: 4px 8px;
      border-radius: 12px;
      font-size: 0.8rem;
      margin-right: 8px;
      margin-bottom: 5px;
      display: inline-block;
    }

    .group-schedule {
      margin-bottom: 15px;
      font-size: 0.9rem;
      color: #7f8c8d;
    }

    .group-actions {
      display: flex;
      gap: 10px;
    }

    .join-group-btn, .view-group-btn {
      padding: 8px 16px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      font-weight: bold;
      transition: all 0.2s;
    }

    .join-group-btn {
      background: #9b59b6;
      color: white;
    }

    .join-group-btn:hover {
      background: #8e44ad;
    }

    .view-group-btn {
      background: #34495e;
      color: white;
    }

    .view-group-btn:hover {
      background: #2c3e50;
    }

    .analytics-section {
      margin-bottom: 40px;
    }

    .analytics-section h3 {
      color: #2c3e50;
      border-bottom: 2px solid #e74c3c;
      padding-bottom: 10px;
      margin-bottom: 20px;
    }

    .analytics-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 20px;
    }

    .analytic-card {
      background: white;
      border: 1px solid #ecf0f1;
      border-radius: 10px;
      padding: 20px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .analytic-card h4 {
      margin-top: 0;
      color: #2c3e50;
      border-bottom: 1px solid #ecf0f1;
      padding-bottom: 10px;
    }

    .bar-chart {
      display: flex;
      align-items: end;
      height: 100px;
      gap: 10px;
      margin-top: 15px;
    }

    .bar {
      flex: 1;
      background: linear-gradient(to top, #3498db, #5dade2);
      border-radius: 4px 4px 0 0;
      position: relative;
      min-height: 20px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      align-items: center;
      color: white;
      font-size: 0.8rem;
      padding: 5px;
    }

    .bar-label {
      position: absolute;
      bottom: -20px;
      color: #7f8c8d;
      font-size: 0.7rem;
    }

    .score-display {
      display: flex;
      align-items: center;
      gap: 20px;
    }

    .score-circle {
      width: 80px;
      height: 80px;
      border: 4px solid #3498db;
      border-radius: 50%;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      position: relative;
    }

    .score-number {
      font-size: 1.5rem;
      font-weight: bold;
      color: #2c3e50;
    }

    .score-label {
      font-size: 0.8rem;
      color: #7f8c8d;
    }

    .score-breakdown {
      flex: 1;
    }

    .score-item {
      display: flex;
      justify-content: space-between;
      margin-bottom: 5px;
      font-size: 0.9rem;
    }

    .score-item .label {
      color: #7f8c8d;
    }

    .score-item .value {
      color: #2c3e50;
      font-weight: bold;
    }

    .achievements-list {
      max-height: 200px;
      overflow-y: auto;
    }

    .achievement-item {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 10px 0;
      border-bottom: 1px solid #ecf0f1;
    }

    .achievement-item:last-child {
      border-bottom: none;
    }

    .achievement-icon {
      font-size: 1.5rem;
    }

    .achievement-info {
      display: flex;
      flex-direction: column;
    }

    .achievement-title {
      font-weight: bold;
      color: #2c3e50;
    }

    .achievement-date {
      font-size: 0.8rem;
      color: #7f8c8d;
    }

    /* Modal Styles */
    .modal-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1000;
    }

    .modal-content {
      background: white;
      border-radius: 10px;
      padding: 30px;
      width: 90%;
      max-width: 500px;
      max-height: 90vh;
      overflow-y: auto;
    }

    .modal-content h3 {
      margin-top: 0;
      color: #2c3e50;
      text-align: center;
      margin-bottom: 20px;
    }

    .form-group {
      margin-bottom: 20px;
    }

    .form-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 15px;
    }

    .form-group label {
      display: block;
      margin-bottom: 5px;
      color: #2c3e50;
      font-weight: bold;
    }

    .form-control {
      width: 100%;
      padding: 10px;
      border: 2px solid #ecf0f1;
      border-radius: 5px;
      font-size: 1rem;
      transition: border-color 0.2s;
    }

    .form-control:focus {
      outline: none;
      border-color: #3498db;
    }

    textarea.form-control {
      resize: vertical;
      min-height: 80px;
    }

    .modal-actions {
      display: flex;
      gap: 10px;
      justify-content: flex-end;
      margin-top: 20px;
    }

    .cancel-btn, .create-btn {
      padding: 10px 20px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      font-weight: bold;
      transition: all 0.2s;
    }

    .cancel-btn {
      background: #95a5a6;
      color: white;
    }

    .cancel-btn:hover {
      background: #7f8c8d;
    }

    .create-btn {
      background: #3498db;
      color: white;
    }

    .create-btn:hover:not(:disabled) {
      background: #2980b9;
    }

    .create-btn:disabled {
      background: #bdc3c7;
      cursor: not-allowed;
    }

    @media (max-width: 768px) {
      .sessions-overview,
      .sessions-grid,
      .study-groups-grid,
      .analytics-grid {
        grid-template-columns: 1fr;
      }
      
      .page-title {
        font-size: 2rem;
      }
      
      .form-row {
        grid-template-columns: 1fr;
      }
      
      .score-display {
        flex-direction: column;
        align-items: center;
      }
      
      .modal-content {
        padding: 20px;
      }
    }
  `]
})
export class CollaborativeLearningComponent implements OnInit {
  showCreateModal = false;
  
  // Mock data for active sessions
  activeSessions = [
    {
      id: 1,
      title: 'JavaScript Fundamentals Study Group',
      description: 'Deep dive into ES6+ features and async programming',
      participantCount: 8,
      duration: 90,
      subject: 'JavaScript',
      status: 'active'
    },
    {
      id: 2,
      title: 'React Hooks Problem Solving',
      description: 'Working through complex state management scenarios',
      participantCount: 5,
      duration: 60,
      subject: 'React',
      status: 'active'
    },
    {
      id: 3,
      title: 'Database Design Workshop',
      description: 'Collaborative database schema design and optimization',
      participantCount: 12,
      duration: 120,
      subject: 'Database',
      status: 'active'
    }
  ];

  // Mock data for user's sessions
  mySessions = [
    {
      id: 4,
      title: 'Node.js API Development',
      description: 'Building RESTful APIs with Express and MongoDB',
      participantCount: 6,
      createdAt: new Date('2024-01-15'),
      status: 'completed',
      rating: 4.5
    },
    {
      id: 5,
      title: 'Angular Components Deep Dive',
      description: 'Advanced component patterns and lifecycle hooks',
      participantCount: 4,
      createdAt: new Date('2024-01-20'),
      status: 'scheduled',
      rating: null
    }
  ];

  // Mock data for study groups
  studyGroups = [
    {
      id: 1,
      name: 'Full Stack Developers Circle',
      description: 'Weekly meetups for full-stack development topics',
      memberCount: 24,
      subjects: ['JavaScript', 'React', 'Node.js', 'Database'],
      schedule: 'Tuesdays 7:00 PM',
      isMember: true
    },
    {
      id: 2,
      name: 'Algorithm Masters',
      description: 'Practice coding challenges and algorithm optimization',
      memberCount: 18,
      subjects: ['Algorithms', 'Data Structures'],
      schedule: 'Saturdays 10:00 AM',
      isMember: false
    },
    {
      id: 3,
      name: 'Frontend UI/UX Collective',
      description: 'Focus on modern frontend frameworks and design patterns',
      memberCount: 15,
      subjects: ['React', 'Angular', 'CSS', 'Design'],
      schedule: 'Wednesdays 6:00 PM',
      isMember: true
    }
  ];

  // Analytics data
  totalParticipants = 45;
  weeklyHours = 12.5;
  collaborationScore = 87;
  
  scoreBreakdown = {
    participation: 22,
    sharing: 20,
    consistency: 23,
    leadership: 22
  };

  weeklyActivity = [
    { day: 'Mon', hours: 2, percentage: 66 },
    { day: 'Tue', hours: 3, percentage: 100 },
    { day: 'Wed', hours: 1.5, percentage: 50 },
    { day: 'Thu', hours: 2.5, percentage: 83 },
    { day: 'Fri', hours: 2, percentage: 66 },
    { day: 'Sat', hours: 1, percentage: 33 },
    { day: 'Sun', hours: 0.5, percentage: 16 }
  ];

  recentAchievements = [
    {
      icon: '🏆',
      title: 'Study Group Leader',
      earnedAt: new Date('2024-01-18')
    },
    {
      icon: '🤝',
      title: 'Collaboration Expert',
      earnedAt: new Date('2024-01-15')
    },
    {
      icon: '📚',
      title: 'Knowledge Sharer',
      earnedAt: new Date('2024-01-12')
    },
    {
      icon: '⭐',
      title: 'Top Contributor',
      earnedAt: new Date('2024-01-10')
    }
  ];

  // New session form data
  newSession = {
    title: '',
    description: '',
    subject: '',
    duration: 60,
    type: ''
  };

  ngOnInit() {
    this.loadCollaborativeData();
  }

  loadCollaborativeData() {
    console.log('Loading collaborative learning data...');
    // Mock API call simulation
    setTimeout(() => {
      console.log('Collaborative data loaded successfully');
    }, 1000);
  }

  joinSession(sessionId: number) {
    console.log('Joining session:', sessionId);
    // Implement session joining logic
  }

  viewSessionDetails(sessionId: number) {
    console.log('Viewing session details:', sessionId);
    // Implement session details view
  }

  manageSession(sessionId: number) {
    console.log('Managing session:', sessionId);
    // Implement session management
  }

  reviewSession(sessionId: number) {
    console.log('Reviewing session:', sessionId);
    // Implement session review
  }

  editSession(sessionId: number) {
    console.log('Editing session:', sessionId);
    // Implement session editing
  }

  joinStudyGroup(groupId: number) {
    console.log('Joining study group:', groupId);
    // Implement study group joining logic
    const group = this.studyGroups.find(g => g.id === groupId);
    if (group) {
      group.isMember = true;
      group.memberCount++;
    }
  }

  viewStudyGroup(groupId: number) {
    console.log('Viewing study group:', groupId);
    // Implement study group view
  }

  createSession() {
    console.log('Creating new session:', this.newSession);
    
    // Add the new session to mySessions
    const newSessionData = {
      id: Date.now(),
      title: this.newSession.title,
      description: this.newSession.description,
      participantCount: 1,
      createdAt: new Date(),
      status: 'scheduled' as const,
      rating: null
    };
    
    this.mySessions.unshift(newSessionData);
    
    // Reset form and close modal
    this.newSession = {
      title: '',
      description: '',
      subject: '',
      duration: 60,
      type: ''
    };
    this.showCreateModal = false;
    
    console.log('Session created successfully');
  }

  formatDate(date: Date): string {
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  }
}