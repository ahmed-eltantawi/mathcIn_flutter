# SkillMatch API Reference

Official source: [SkillMatch API 1.0.0](https://iptvdemo.serv5group.com/api/docs)
OpenAPI file: [`openapi.json`](openapi.json)
Snapshot date: 2026-10-28 (UTC)

This is the downloaded API contract. Before changing a request or response mapping, check the matching operation and schema here; do not infer field names from app models.

Documented paths: **120**
Documented operations: **159**

| Method | Path | Tag | Summary |
|---|---|---|---|
| GET | `/admin/ai-review-items` | Admin | List AI items requiring human-in-the-loop review |
| GET | `/admin/ai-review-items/{aiReviewItem}` | Admin | Get AI review item details |
| POST | `/admin/ai-review-items/{aiReviewItem}/approve` | Admin | Approve AI review item |
| POST | `/admin/ai-review-items/{aiReviewItem}/correct` | Admin | Submit human correction for AI review item |
| POST | `/admin/ai-review-items/{aiReviewItem}/reject` | Admin | Reject AI review item |
| GET | `/admin/ai-review/{id}` | Admin | Retrieve single AI review item details |
| POST | `/admin/ai-review/{id}/approve` | Admin | Approve the AI-extracted item into the canonical database |
| PATCH | `/admin/ai-review/{id}/correct` | Admin | Correct malformed job/CV tags or taxonomy mappings with administrative audit logs |
| POST | `/admin/ai-review/{id}/correct` | Admin | Correct malformed job/CV tags or taxonomy mappings (POST alias) |
| POST | `/admin/ai-review/{id}/reject` | Admin | Reject AI review item |
| GET | `/admin/ai-review/queue` | Admin | Retrieve low-confidence CV/job extractions or ambiguous skill mappings flagged for human review |
| GET | `/admin/audit-logs` | Admin | Query system audit trails |
| GET | `/admin/companies` | Admin | List companies (Admin view) |
| POST | `/admin/companies` | Admin | Create new company record |
| GET | `/admin/companies/{company}` | Admin | Get company details with job count |
| PATCH | `/admin/companies/{company}` | Admin | Update company profile |
| POST | `/admin/companies/{sourceCompany}/merge` | Admin | Merge source company into target company |
| GET | `/admin/dashboard` | Admin | Get admin dashboard overview metrics |
| GET | `/admin/ingestion-runs` | Admin | List all global crawler ingestion runs across sources |
| GET | `/admin/job-matches` | Admin | Inspect computed match records across platform |
| GET | `/admin/job-sources` | Admin | List configured external job crawler sources |
| POST | `/admin/job-sources` | Admin | Register new job crawler source |
| DELETE | `/admin/job-sources/{jobSource}` | Admin | Delete or archive job source |
| GET | `/admin/job-sources/{jobSource}` | Admin | Get single job crawler source details |
| PATCH | `/admin/job-sources/{jobSource}` | Admin | Update job source configuration |
| GET | `/admin/job-sources/{jobSource}/raw-jobs` | Admin | List raw jobs ingested from specific job source |
| GET | `/admin/job-sources/{jobSource}/raw-jobs/{rawJob}` | Admin | Get raw job details under specific job source |
| POST | `/admin/job-sources/{jobSource}/run` | Admin | Trigger manual ingestion run for job source |
| GET | `/admin/job-sources/{jobSource}/runs` | Admin | List ingestion runs for specific job source |
| POST | `/admin/jobs` | Admin | Create official job posting (Admin only) |
| GET | `/admin/jobs/{jobPost}` | Admin | Get job details (Admin view) |
| PATCH | `/admin/jobs/{jobPost}` | Admin | Update job post attributes, requirements, or status |
| POST | `/admin/moderation/merge-duplicates` | Admin | Merge duplicate job or company listings and record audit trails |
| POST | `/admin/notifications` | Admin | Broadcast system notification (Alias endpoint) |
| POST | `/admin/notifications/compose` | Admin | Broadcast system notification to targeted users or roles |
| GET | `/admin/raw-jobs` | Admin | List all global raw scraped jobs |
| GET | `/admin/raw-jobs/{rawJob}` | Admin | Get single raw job details and raw payload |
| POST | `/admin/skills` | Admin | Create new skill in taxonomy (Admin only) |
| PATCH | `/admin/skills/{id}` | Admin | Update taxonomy skill (Admin only) |
| GET | `/admin/skills/{id}/aliases` | Admin | List aliases for a skill |
| POST | `/admin/skills/{id}/aliases` | Admin | Add alias for skill |
| DELETE | `/admin/skills/{id}/aliases/{aliasId}` | Admin | Delete skill alias |
| PATCH | `/admin/skills/{id}/aliases/{aliasId}` | Admin | Update skill alias |
| POST | `/admin/skills/{sourceSkillId}/merge` | Admin | Merge duplicate skill into canonical skill (Admin only) |
| GET | `/admin/sources` | Admin | List all approved job aggregation sources and their health status |
| POST | `/admin/sources` | Admin | Register a new approved job source |
| DELETE | `/admin/sources/{id}` | Admin | Delete or archive job source |
| GET | `/admin/sources/{id}` | Admin | Get single job source details |
| PATCH | `/admin/sources/{id}` | Admin | Enable/disable a source or update its metadata |
| PUT | `/admin/sources/{id}` | Admin | Update job source metadata |
| POST | `/admin/sources/{id}/trigger` | Admin | Manually trigger a collection/scraping run for a specific source |
| GET | `/admin/statistics` | Admin | Get platform aggregate statistics and analytics |
| GET | `/admin/stats` | Admin | Provide summary usage and operations metrics |
| GET | `/admin/taxonomy/skills` | Admin | List canonical skills, categories, and aliases |
| POST | `/admin/taxonomy/skills` | Admin | Create a new canonical skill or alias |
| DELETE | `/admin/taxonomy/skills/{id}` | Admin | Deactivate or remove an incorrect taxonomy entry |
| PATCH | `/admin/taxonomy/skills/{id}` | Admin | Update skill details or map aliases |
| GET | `/admin/users` | Admin | List registered platform users |
| GET | `/admin/users/{user}` | Admin | Get user details and account status (Admin view) |
| PATCH | `/admin/users/{user}/role` | Admin | Change user role (Super Admin only) |
| PATCH | `/admin/users/{user}/status` | Admin | Update user account status (Suspend or activate) |
| GET | `/application-strategy` | Application Strategy | List candidate application strategy assessments history |
| GET | `/application-strategy/{strategy}` | Application Strategy | Get single application strategy assessment |
| POST | `/application-strategy/assess` | Application Strategy | Generate AI application strategy report for a target job |
| GET | `/applications` | Applications | List applications (Candidate sees own, Admin sees all) |
| POST | `/applications` | Applications | Submit new job application |
| GET | `/applications/{application}` | Applications | Get application details |
| PATCH | `/applications/{application}/notes` | Applications | Candidate updates personal application notes |
| PATCH | `/applications/{application}/status` | Applications | Update application status (Admin only) |
| POST | `/applications/{application}/withdraw` | Applications | Candidate self-withdraws application |
| POST | `/auth/forgot-password` | Auth | Request password reset OTP |
| POST | `/auth/forgot-password/verify-otp` | Auth | Verify password reset OTP |
| POST | `/auth/login` | Auth | User login |
| POST | `/auth/logout` | Auth | Log out and invalidate token session |
| GET | `/auth/me` | Auth | Get current authenticated user profile |
| POST | `/auth/refresh` | Auth | Refresh JWT session tokens |
| POST | `/auth/register` | Auth | Register a new candidate account |
| POST | `/auth/resend-email-otp` | Auth | Resend email verification OTP |
| POST | `/auth/reset-password` | Auth | Reset account password |
| POST | `/auth/verify-email-otp` | Auth | Verify email address using 6-digit OTP |
| GET | `/candidate/career-preferences` | Candidate Profile | Get candidate career preferences |
| PATCH | `/candidate/career-preferences` | Candidate Profile | Update career preferences |
| GET | `/candidate/cv-improvements` | Candidate Profile | List candidate CV improvement analysis history |
| POST | `/candidate/cv-improvements/analyze` | Candidate Profile | Run AI CV improvement analysis |
| GET | `/candidate/cv-improvements/latest` | Candidate Profile | Get latest CV improvement analysis |
| GET | `/candidate/educations` | Candidate Profile | List candidate education records |
| POST | `/candidate/educations` | Candidate Profile | Add education record |
| DELETE | `/candidate/educations/{id}` | Candidate Profile | Delete education record |
| GET | `/candidate/educations/{id}` | Candidate Profile | Get single education record |
| PATCH | `/candidate/educations/{id}` | Candidate Profile | Update education record |
| GET | `/candidate/experiences` | Candidate Profile | List candidate work experience records |
| POST | `/candidate/experiences` | Candidate Profile | Add work experience record |
| DELETE | `/candidate/experiences/{id}` | Candidate Profile | Delete work experience record |
| GET | `/candidate/experiences/{id}` | Candidate Profile | Get single work experience record |
| PATCH | `/candidate/experiences/{id}` | Candidate Profile | Update work experience record |
| GET | `/candidate/profile` | Candidate Profile | Get full candidate profile |
| PATCH | `/candidate/profile` | Candidate Profile | Update candidate profile |
| DELETE | `/candidate/profile/avatar` | Candidate Profile | Delete candidate avatar photo |
| POST | `/candidate/profile/avatar` | Candidate Profile | Upload or update candidate avatar photo |
| GET | `/candidate/projects` | Candidate Profile | List candidate project records |
| POST | `/candidate/projects` | Candidate Profile | Add project portfolio item |
| DELETE | `/candidate/projects/{id}` | Candidate Profile | Delete project record |
| GET | `/candidate/projects/{id}` | Candidate Profile | Get single project record |
| PATCH | `/candidate/projects/{id}` | Candidate Profile | Update project record |
| GET | `/candidate/recommended-jobs` | Candidate Profile | Get personalized recommended jobs for candidate |
| GET | `/candidate/skill-gaps` | Candidate Profile | Analyze candidate skill gaps against target jobs |
| GET | `/candidate/skills` | Candidate Profile | List candidate skills |
| POST | `/candidate/skills` | Candidate Profile | Add skill to candidate profile |
| DELETE | `/candidate/skills/{id}` | Candidate Profile | Remove skill from candidate profile |
| GET | `/candidate/xp` | Candidate Profile | Get candidate roadmap achievement XP status and levels |
| PATCH | `/candidate/xp` | Candidate Profile | Add XP for user roadmap achievements |
| GET | `/cv` | CV | Stream and preview candidate's latest CV file |
| POST | `/cv/extractions/{extraction}/verify` | CV | Confirm or adjust extracted CV data into candidate profile |
| GET | `/cv/file` | CV | Return candidate's latest CV file for any format (PDF, DOCX, etc.) |
| POST | `/cv/file` | CV | Upload raw candidate CV file without AI extraction |
| GET | `/cv/file/{cvDocument}` | CV | Return specific candidate CV file by ID for any format (PDF, DOCX, etc.) |
| GET | `/cv/history` | CV | Get uploaded CV documents history |
| GET | `/cv/preview` | CV | Stream and preview candidate's latest uploaded CV document inline |
| GET | `/cv/preview/{cvDocument}` | CV | Stream and preview specific candidate CV document inline |
| POST | `/cv/retry/{cvDocument}` | CV | Retry failed CV extraction |
| GET | `/cv/status/{cvDocument}` | CV | Poll CV processing and extraction status |
| POST | `/cv/upload` | CV | Upload CV file (PDF or DOCX) |
| GET | `/health` | Health | System health and operational readiness check |
| GET | `/interview-prep/sessions` | Interview Prep | List candidate interview prep sessions |
| POST | `/interview-prep/sessions` | Interview Prep | Start interactive AI mock interview session |
| GET | `/interview-prep/sessions/{session}` | Interview Prep | Get interview session details, questions, and evaluations |
| POST | `/interview-prep/sessions/{session}/evaluate` | Interview Prep | Submit candidate answer and receive AI rubric critique |
| GET | `/jobs` | Jobs | Browse and filter active job postings feed |
| GET | `/jobs/{jobPost}` | Jobs | Get single job post details |
| GET | `/jobs/{jobPost}/match` | Jobs | Get explainable match breakdown for specific job |
| POST | `/jobs/{jobPost}/match/recalculate` | Jobs | Force re-calculate match score for job |
| DELETE | `/jobs/{jobPost}/save` | Jobs | Un-bookmark job post |
| POST | `/jobs/{jobPost}/save` | Jobs | Bookmark job post |
| GET | `/jobs/recommendations` | Jobs | Get AI recommended jobs for candidate |
| GET | `/jobs/saved` | Jobs | List candidate bookmarked jobs |
| GET | `/mentor/context-preview` | Mentor | Preview candidate context bundle passed to AI Mentor |
| GET | `/mentor/conversations` | Mentor | List candidate AI mentor conversations |
| POST | `/mentor/conversations` | Mentor | Start new AI mentor conversation session |
| DELETE | `/mentor/conversations/{conversation}` | Mentor | Delete mentor conversation |
| GET | `/mentor/conversations/{conversation}` | Mentor | Get mentor conversation details and full message history |
| PATCH | `/mentor/conversations/{conversation}` | Mentor | Update conversation title or archive state |
| POST | `/mentor/conversations/{conversation}/messages` | Mentor | Send message to AI mentor and receive contextual reply |
| GET | `/notifications` | Notifications | List user notifications |
| PATCH | `/notifications/{notification}/read` | Notifications | Mark single notification as read |
| PATCH | `/notifications/read-all` | Notifications | Mark all user notifications as read |
| GET | `/notifications/unread-count` | Notifications | Get unread notifications badge counter |
| PATCH | `/roadmap-tasks/{roadmapTask}/complete` | Roadmaps | Mark roadmap task as completed (Flat route variant) |
| GET | `/roadmaps` | Roadmaps | List candidate roadmaps |
| POST | `/roadmaps` | Roadmaps | Generate personalized career learning roadmap |
| GET | `/roadmaps/{roadmap}` | Roadmaps | Get roadmap details with milestone stages and task hierarchy |
| POST | `/roadmaps/{roadmap}/refresh` | Roadmaps | Dynamically refresh roadmap based on progress or market changes |
| GET | `/roadmaps/{roadmap}/xp` | Roadmaps | Get specific roadmap XP metrics, tasks completion, and history |
| PATCH | `/roadmaps/{roadmap}/xp` | Roadmaps | Add XP for specific roadmap progress |
| PATCH | `/roadmaps/tasks/{roadmapTask}/complete` | Roadmaps | Mark roadmap task as completed |
| GET | `/roadmaps/xp` | Roadmaps | Get candidate roadmap XP summary, levels, and achievements |
| PATCH | `/roadmaps/xp` | Roadmaps | Add XP for user to achieve roadmap goals |
| GET | `/saved-jobs` | Jobs | List candidate bookmarked jobs (Alternative endpoint) |
| DELETE | `/saved-jobs/{jobPost}` | Jobs | Remove job bookmark (Alternative endpoint) |
| GET | `/skills/search` | Skills | Autocomplete search skills taxonomy |

## Avatar contract

- Upload or replace: `POST /candidate/profile/avatar`
- Content type: `multipart/form-data`
- File field: `avatar` (JPEG or PNG)
- Delete: `DELETE /candidate/profile/avatar`
- The upload response wraps the updated profile in `data`.

The avatar controls are in the Edit Profile screen. Selecting a file previews it; confirming sends it to the documented upload route. A dismissed picker returns `null`; picker/platform failures are now surfaced in the UI rather than silently treated as cancellation.
