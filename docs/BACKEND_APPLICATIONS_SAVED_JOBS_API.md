# Backend API Reference — Applications & Saved Jobs

> **Purpose:**  
> This document is the source of truth for the backend integration of **Applications, Easy Apply, Saved Jobs, Applied Jobs, and Job Save/Unsave functionality**.
>
> AI agents MUST read this file before modifying any code related to these features.

---

# 1. Base Configuration

## Base URL

```text
https://skillmatch.iptvdemo.serv5group.com
```

## Authentication

All endpoints in this document require the existing JWT authentication mechanism unless explicitly stated otherwise.

The application MUST use the existing authentication/token infrastructure.

Do NOT create a new authentication mechanism.

---

# 2. Common Headers

Requests may use:

```http
Authorization: Bearer <JWT>
Accept: application/json
Accept-Language: en
Content-Type: application/json
```

Supported language values:

```text
en
ar
```

The backend also documents:

```text
en-US → en
ar-EG → ar
anything else → English
```

The existing application networking/interceptor layer should handle authentication and localization where possible.

Do not manually duplicate these headers in every request if the existing networking architecture already provides them.

---

# 3. API Response Conventions

Some application endpoints use JSON:API-style responses.

Example:

```json
{
  "data": {
    "id": "1",
    "type": "applications",
    "attributes": {
      "status": "applied"
    }
  }
}
```

Collection responses may contain:

```json
{
  "data": [],
  "links": {},
  "meta": {}
}
```

Do not assume every endpoint has the same response envelope.

Always follow the response contract documented for the specific endpoint.

---

# 4. Applications

## 4.1 List My Applications

```http
GET /api/applications
```

### Authentication

JWT required.

Candidates receive only their own applications.

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `status` | string | Optional exact machine status |
| `search` | string | Optional substring search by job title |

The backend uses a fixed page size of:

```text
10
```

### Example

```http
GET /api/applications
```

or:

```http
GET /api/applications?status=applied&search=flutter
```

### Response

```json
{
  "data": [
    {
      "id": "1",
      "type": "applications",
      "attributes": {
        "status": "applied",
        "cover_letter": "I am excited to apply.",
        "applied_at": "2026-09-01T10:00:00Z"
      }
    }
  ]
}
```

### Important

The application list may not contain every job/company field shown by the UI.

If the Applied Jobs UI requires additional job information, inspect the actual backend response and existing domain models before inventing fields.

---

# 5. Get Application Details

```http
GET /api/applications/{application}
```

Example:

```http
GET /api/applications/1
```

### Description

Returns a single application.

The backend loads:

- Job
- Company
- Status history
- Candidate user

### Response

```json
{
  "data": {
    "id": "1",
    "type": "applications",
    "attributes": {
      "status": "applied",
      "cover_letter": "string",
      "applied_at": "2026-10-01T08:53:37.307Z",
      "created_at": "2026-10-01T08:53:37.307Z",
      "updated_at": "2026-10-01T08:53:37.307Z"
    }
  }
}
```

---

# 6. Apply to a Job

```http
POST /api/applications
```

## Request

```json
{
  "job_id": 7,
  "cover_letter": "I am excited to apply for this role."
}
```

## Successful Response

HTTP:

```text
201 Created
```

Body:

```json
{
  "status": "success",
  "message": "Application submitted successfully.",
  "data": {
    "id": "1",
    "type": "applications",
    "attributes": {
      "status": "applied",
      "cover_letter": "I am excited to apply for this role."
    }
  }
}
```

---

# 7. Apply Errors

## 401 — Unauthenticated

```json
{
  "message": "Unauthenticated."
}
```

---

## 403 — Candidate Profile Required

```json
{
  "status": "error",
  "message": "string",
  "errors": {
    "additionalProp1": [
      "string"
    ]
  }
}
```

The user must have a candidate profile.

The UI should present an appropriate localized message/action.

---

## 422 — Already Applied

Example:

```json
{
  "message": "You have already applied to this job.",
  "errors": {
    "job_id": [
      "You have already applied to this job."
    ]
  }
}
```

The application MUST NOT create duplicate applications.

The UI should transition to the already-applied state.

---

# 8. Easy Apply

The application should provide an **Easy Apply** experience from Job Details.

Expected flow:

```text
Job Details
     ↓
Apply / Easy Apply
     ↓
Review Application
     ↓
Optional Cover Letter
     ↓
Submit
     ↓
Application Created
     ↓
Applied State
```

## Requirements

Easy Apply should:

- Be quick and simple.
- Reuse existing candidate information.
- Allow the user to add/edit a cover letter.
- Prevent duplicate submissions.
- Show loading state.
- Handle validation errors.
- Handle `403` candidate-profile errors.
- Handle `422` already-applied errors.
- Show localized success/error messages.
- Update Job Details immediately after success.
- Update Applied Jobs data/cache immediately after success.

If the user has already applied:

```text
Applied
```

should replace:

```text
Apply
```

Do not allow repeated application submissions.

---

# 9. Application Status

```http
PATCH /api/applications/{application}/status
```

Example:

```http
PATCH /api/applications/1/status
```

## Request

```json
{
  "status": "in_review",
  "notes": "Moving to review."
}
```

---

# 10. Allowed Status Transitions

The backend allows these transitions:

```text
applied
 ├── in_review
 ├── withdrawn
 └── rejected

in_review
 ├── interview
 ├── rejected
 ├── offer
 └── withdrawn

interview
 ├── offer
 ├── rejected
 └── withdrawn

offer
 └── withdrawn
```

Do NOT assume arbitrary status transitions are valid.

---

# 11. Successful Status Update

HTTP:

```text
200 OK
```

Response:

```json
{
  "status": "success",
  "message": "Application status updated successfully.",
  "data": {
    "id": "1",
    "type": "applications",
    "attributes": {
      "status": "in_review"
    }
  }
}
```

---

# 12. Invalid Status Transition

HTTP:

```text
422 Unprocessable Entity
```

Example:

```json
{
  "message": "Invalid status transition.",
  "errors": {
    "status": [
      "Invalid status transition."
    ]
  }
}
```

The backend is the final source of truth.

The application may validate transitions locally for better UX, but must still handle the backend `422`.

---

# 13. Withdraw Application

```http
POST /api/applications/{application}/withdraw
```

Example:

```http
POST /api/applications/1/withdraw
```

No request body.

---

# 14. Successful Withdrawal

HTTP:

```text
200 OK
```

Response:

```json
{
  "status": "success",
  "message": "Application withdrawn successfully.",
  "data": {
    "id": "1",
    "type": "applications",
    "attributes": {
      "status": "withdrawn"
    }
  }
}
```

---

# 15. Withdrawal Rules

The backend may reject withdrawal when the application is already:

```text
rejected
withdrawn
```

Such cases return:

```text
422
```

The UI must handle this gracefully.

---

# 16. Saved Jobs

Saved Jobs consist of three API operations:

```text
Save
Unsave
List Saved Jobs
```

---

# 17. Save a Job

```http
POST /api/jobs/{jobPost}/save
```

Example:

```http
POST /api/jobs/7/save
```

Requires:

- JWT
- Active candidate account

---

# 18. Successful Save

First save:

```text
201 Created
```

Response:

```json
{
  "message": "Job saved successfully.",
  "data": {
    "job_id": 7,
    "is_saved": true
  }
}
```

---

# 19. Save Idempotency

Saving an already-saved job is allowed.

The endpoint is idempotent.

Second save:

```text
200 OK
```

Response has the same logical result:

```json
{
  "message": "...",
  "data": {
    "job_id": 7,
    "is_saved": true
  }
}
```

The application should not treat this as an error.

---

# 20. Unsave a Job

```http
DELETE /api/jobs/{jobPost}/save
```

Example:

```http
DELETE /api/jobs/7/save
```

---

# 21. Successful Unsave

```json
{
  "message": "Job removed from saved jobs.",
  "data": {
    "job_id": 7,
    "is_saved": false
  }
}
```

HTTP:

```text
200 OK
```

Unsaving a job that was not saved still returns `200`.

---

# 22. Saved Jobs Errors

### 401

```json
{
  "message": "Unauthenticated."
}
```

### 403

Possible reasons:

- Inactive account
- Wrong role
- User is not an active candidate

Example:

```json
{
  "message": "Your account is inactive."
}
```

### 404

Job not found.

---

# 23. List Saved Jobs

```http
GET /api/saved-jobs
```

### Query Parameters

| Parameter | Type | Default | Constraints |
|---|---|---:|---|
| `page` | integer | 1 | minimum 1 |
| `per_page` | integer | 15 | 1–100 |

Example:

```http
GET /api/saved-jobs?page=1&per_page=15
```

---

# 24. Saved Jobs Response

```json
{
  "data": [
    {
      "id": 0,
      "title": "string",
      "job_type": "job",
      "work_mode": "string",
      "employment_type": "string",
      "experience_level": "string",
      "country": "string",
      "state": "string",
      "city": "string",
      "min_years_experience": 0,
      "max_years_experience": 0,
      "source": "string",
      "application_method": "internal",
      "published_at": "2026-10-01T08:57:32.127Z",
      "expires_at": "2026-10-01T08:57:32.127Z",
      "is_active": true,
      "company": {
        "id": 0,
        "name": "string",
        "logo_url": "string",
        "is_verified": true,
        "is_active": true
      },
      "required_skills": [
        {
          "id": 0,
          "name": "string",
          "importance": 0,
          "required_level": "string"
        }
      ],
      "preferred_skills": [
        {
          "id": 0,
          "name": "string",
          "importance": 0,
          "required_level": "string"
        }
      ],
      "is_expired": true,
      "is_saved": true
    }
  ],
  "links": {
    "first": "string",
    "last": "string",
    "prev": "string",
    "next": "string"
  },
  "meta": {
    "current_page": 0,
    "from": 0,
    "last_page": 0,
    "per_page": 0,
    "to": 0,
    "total": 0
  }
}
```

---

# 25. Saved Jobs UI Rules

The Saved Jobs page MUST:

- Use the backend saved-jobs endpoint.
- Support pagination.
- Display cached results offline.
- Support refresh.
- Support save/unsave.
- Immediately remove an item from the list after successful unsave.
- Update `is_saved` in related cached Job data.
- Handle loading state.
- Handle empty state.
- Handle error state.
- Handle offline state.

---

# 26. Applied Jobs Page

The application contains a dedicated:

```text
Applied Jobs
```

page.

It MUST NOT be merged with Saved Jobs.

Data source:

```http
GET /api/applications
```

The Applied Jobs page should provide:

- Application list
- Application status
- Applied date
- Search
- Status filtering
- Loading state
- Empty state
- Error state
- Offline cached data
- Refresh
- Navigation to Application Details

---

# 27. Synchronization Rules

The application must keep related screens synchronized.

## Save

After:

```text
POST /api/jobs/{id}/save
```

update:

```text
Job Feed
Job Details
Saved Jobs
Local Cache
```

with:

```text
is_saved = true
```

---

## Unsave

After:

```text
DELETE /api/jobs/{id}/save
```

update:

```text
Job Feed
Job Details
Saved Jobs
Local Cache
```

with:

```text
is_saved = false
```

and remove the job from the Saved Jobs list.

---

## Apply

After:

```text
POST /api/applications
```

update:

```text
Job Details
Applied Jobs
Application cache
Local cache
```

The Job Details page should immediately display:

```text
Applied
```

instead of:

```text
Apply
```

---

## Withdraw

After:

```text
POST /api/applications/{id}/withdraw
```

update:

```text
Application Details
Applied Jobs
Application cache
```

Status becomes:

```text
withdrawn
```

---

## Status Update

After:

```text
PATCH /api/applications/{id}/status
```

update:

```text
Application Details
Applied Jobs
Application cache
```

with the new status.

---

# 28. Offline-First Requirements

The application follows an **offline-first** architecture.

For read operations:

```text
UI
 ↓
Cubit
 ↓
UseCase
 ↓
Repository
 ↓
Local Data Source
 ↓
Display cached data
 ↓
Remote Data Source
 ↓
Refresh cache
 ↓
Update UI
```

When offline:

```text
UI
 ↓
Cubit
 ↓
UseCase
 ↓
Repository
 ↓
Local Cache
 ↓
Cached Data
```

Previously loaded data should remain available when possible.

---

# 29. Cache Requirements

Cache relevant data for:

```text
Jobs
Saved Jobs
Applications
Application Details
```

Cache implementation MUST follow the project's existing local-storage/cache architecture.

Do NOT introduce a new storage framework without a strong reason.

---

# 30. Mutation Synchronization

For successful mutations:

```text
Save
Unsave
Apply
Withdraw
Status Update
```

update the local cache/state where possible.

Example:

```text
Save Job #7

Remote:
is_saved = true

Local:
is_saved = true

Job Feed:
is_saved = true

Saved Jobs:
Job #7 exists
```

The user should not have to manually refresh every screen.

---

# 31. Error Handling

The following HTTP statuses are important:

| Status | Meaning |
|---:|---|
| 200 | Successful request |
| 201 | Resource/action successfully created |
| 401 | Unauthenticated |
| 403 | Authenticated but not allowed |
| 404 | Resource not found |
| 422 | Validation/business-rule failure |

The app MUST use the existing project Failure/Error architecture.

Do not create feature-specific ad-hoc error handling if an existing global mechanism exists.

---

# 32. Localization

Backend messages depend on:

```http
Accept-Language
```

The application supports:

```text
English
Arabic
```

New UI messages must use the existing localization system.

Do NOT hardcode user-facing strings inside:

- Cubits
- Repositories
- Widgets
- Data sources

unless the existing architecture explicitly requires it.

---

# 33. Architecture Rules

Follow the existing Clean Architecture:

```text
Presentation
     ↓
Domain
     ↓
Data
     ↓
Core / Network
```

Expected dependency flow:

```text
Widget
  ↓
Cubit
  ↓
UseCase
  ↓
Repository
  ↓
RemoteDataSource / LocalDataSource
  ↓
ApiConsumer
```

Never:

```text
Widget → Dio
Widget → API
Cubit → Dio
Cubit → DataSource
```

---

# 34. DTO / Entity Separation

Backend response models belong to the Data layer.

Use:

```text
DTO
 ↓
Mapper
 ↓
Domain Entity
 ↓
Presentation
```

Do not expose backend-specific DTOs directly to UI code.

JSON:API-specific structures should remain in the Data layer.

---

# 35. Source of Truth

The backend is the final source of truth for:

- Application status
- Application ownership
- Duplicate applications
- Allowed status transitions
- Job existence
- Save state

Local validation can improve UX but must not replace backend validation.

---

# 36. Agent Instructions

Before modifying these features, the AI agent MUST:

1. Read `GEMENI.md`.
2. Read this file.
3. Inspect existing architecture.
4. Find existing networking abstractions.
5. Find existing local storage/cache implementation.
6. Find existing Job Feed and Job Details implementations.
7. Find existing Saved Jobs and Applied Jobs screens.
8. Reuse existing patterns.
9. Avoid duplicate architecture.
10. Implement incrementally.
11. Run `flutter analyze`.
12. Run existing tests.
13. Fix regressions before finishing.

---

# 37. Important Restrictions

Do NOT:

- Create another Dio instance.
- Create another API client.
- Bypass `ApiConsumer`.
- Put API calls inside widgets.
- Put API calls directly inside Cubits.
- Create duplicate networking utilities.
- Create duplicate pagination utilities.
- Create duplicate authentication logic.
- Hardcode JWT tokens.
- Hardcode API responses.
- Ignore offline-first requirements.
- Ignore localization.
- Ignore `GEMENI.md`.
- Rebuild existing UI unnecessarily.
- Merge Saved Jobs and Applied Jobs into one page.

---

# 38. Feature Relationship

The features are connected as follows:

```text
                    ┌──────────────┐
                    │   Job Feed   │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              │                         │
           Save Job                  Job Details
              │                         │
              ▼                         ▼
       ┌─────────────┐             Easy Apply
       │ Saved Jobs  │                 │
       └─────────────┘                 ▼
                                ┌──────────────┐
                                │ Applied Jobs │
                                └──────┬───────┘
                                       │
                                       ▼
                              Application Details
                                       │
                         ┌─────────────┴─────────────┐
                         │                           │
                      Withdraw                 Status Update
```

---

# 39. Final Integration Goal

The final application should provide a consistent flow:

```text
Browse Jobs
    ↓
Save Job
    ↓
Saved Jobs

Browse Jobs
    ↓
Job Details
    ↓
Easy Apply
    ↓
Application Submitted
    ↓
Applied Jobs
    ↓
Application Details
    ↓
Track Status / Withdraw
```

All of the above must work with:

```text
JWT Authentication
Clean Architecture
Existing Networking Layer
Existing DI
Existing State Management
Existing Localization
Offline-First Caching
Existing GEMENI.md Rules
```

This document should be treated as the **backend contract/reference** for these features.