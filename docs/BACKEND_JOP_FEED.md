# Jobs API — Job Feed

## Overview

**Endpoint:** `GET /api/jobs`

**Purpose:** Fetch the authenticated user's job feed with pagination, search, sorting, and filters.

### Authentication

- **JWT required**
- User must be **active**
- Available to **any authenticated role**
- Only returns:
  - Active jobs
  - Non-expired jobs
  - Jobs belonging to active companies

### Base URL

```text
https://skillmatch.iptvdemo.serv5group.com
```

---

# Endpoint

```http
GET /api/jobs
```

Example:

```http
GET /api/jobs?page=1&per_page=15
```

---

# Headers

| Header | Required | Example | Description |
|---|---|---|---|
| `Authorization` | Yes | `Bearer <JWT>` | Authentication token |
| `Accept-Language` | No | `en` | Response message locale |
| `Accept` | No | `application/json` | Expected response format |

### Accept-Language

Supported locales:

```text
en-US → en
ar-EG → ar
anything else → en
```

This affects **human-readable messages only**, not the job data itself.

---

# Query Parameters

## Pagination

### `page`

```text
Type: integer
Default: 1
Minimum: 1
```

Example:

```http
?page=1
```

### `per_page`

```text
Type: integer
Default: 15
Minimum: 1
Maximum: 100
```

Example:

```http
?per_page=30
```

---

# Search & Sorting

## `search`

```text
Type: string
Maximum length: 255
Optional
```

Search jobs using a text query.

Example:

```http
?search=flutter
```

## `sort`

```text
Type: string
Optional
```

Important behavior:

- `sort=relevance` only applies when `search` is provided.
- Without a search query, jobs are sorted by **newest first**.

Example:

```http
?search=flutter&sort=relevance
```

---

# Job Filters

All filters are optional.

| Parameter | Type | Description |
|---|---|---|
| `company_id` | integer | Filter by company |
| `job_type` | string | Filter by job type |
| `work_mode` | string | Filter by work mode |
| `employment_type` | string | Filter by employment type |
| `experience_level` | string | Filter by experience level |
| `country` | string | Filter by country |
| `state` | string | Filter by state |
| `city` | string | Filter by city |
| `source` | string | Filter by job source |
| `application_method` | string | Filter by application method |
| `is_verified_company` | boolean | Filter verified companies |
| `required_skill_ids` | integer[] | Filter by required skill IDs |
| `preferred_skill_ids` | integer[] | Filter by preferred skill IDs |

### Example

```http
GET /api/jobs?work_mode=remote&experience_level=junior
```

### Multiple Skill IDs

```http
GET /api/jobs?required_skill_ids[]=1&required_skill_ids[]=5&required_skill_ids[]=10
```

---

# Complete Example Request

```http
GET /api/jobs?page=1&per_page=15&search=flutter&sort=relevance&work_mode=remote&experience_level=junior&is_verified_company=true
```

Headers:

```http
Authorization: Bearer <JWT>
Accept: application/json
Accept-Language: en
```

---

# 200 — Success

Response:

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
      "published_at": "2026-10-01T17:00:28.820Z",
      "expires_at": "2026-10-01T17:00:28.820Z",
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

# Response Models

## Job

```text
Job
├── id: integer
├── title: string
├── job_type: string
├── work_mode: string
├── employment_type: string
├── experience_level: string
├── country: string
├── state: string
├── city: string
├── min_years_experience: integer
├── max_years_experience: integer
├── source: string
├── application_method: string
├── published_at: datetime
├── expires_at: datetime
├── is_active: boolean
├── company: Company
├── required_skills: List<Skill>
├── preferred_skills: List<Skill>
├── is_expired: boolean
└── is_saved: boolean
```

## Company

```text
Company
├── id: integer
├── name: string
├── logo_url: string
├── is_verified: boolean
└── is_active: boolean
```

## Skill

```text
Skill
├── id: integer
├── name: string
├── importance: integer
└── required_level: string
```

---

# Pagination

The API uses standard pagination.

```json
{
  "links": {
    "first": "...",
    "last": "...",
    "prev": null,
    "next": "..."
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 10,
    "per_page": 15,
    "to": 15,
    "total": 150
  }
}
```

### Important

Use the API pagination metadata rather than calculating pagination manually.

Relevant fields:

```text
meta.current_page
meta.last_page
meta.per_page
meta.total
meta.from
meta.to
```

For loading the next page, use:

```text
links.next
```

when available.

---

# 401 — Unauthenticated

Returned when the JWT is missing or invalid.

```json
{
  "message": "Unauthenticated."
}
```

### Client behavior

The app should:

1. Detect authentication failure.
2. Clear/refresh authentication according to the existing auth flow.
3. If the user cannot be authenticated, redirect to the login flow.

Do not treat this as an empty job feed.

---

# 403 — Forbidden

Returned when the user is authenticated but not allowed to access the endpoint.

Example:

```json
{
  "message": "Your account is inactive."
}
```

Possible reasons:

- Account is inactive.
- User does not have the required role.

This is different from `401`.

---

# 422 — Validation Error

Returned when query parameters fail Laravel validation.

Example:

```json
{
  "message": "The email field is required. (and 1 more error)",
  "errors": {
    "email": [
      "The email field is required."
    ]
  }
}
```

The client should preserve the `errors` object so field-specific validation messages can be displayed when appropriate.

---

# 503 — Service Unavailable

The documented test request currently returned:

```http
503 Service Unavailable
```

Response:

```html
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html>
<head>
<title>503 Service Unavailable</title>
</head>
<body>
<h1>Service Unavailable</h1>
<p>
The server is temporarily unable to service your
request due to maintenance downtime or capacity
problems.
</p>
</body>
</html>
```

This indicates a server/infrastructure availability problem, **not an empty job list**.

The API may become available later.

Client behavior:

- Do not parse this as a normal JSON API response.
- Map it to the application's network/server failure.
- Show the existing generic server/network error UI.
- Do not treat it as `200` with an empty list.

---

# Flutter Integration Notes

When implementing this endpoint in Flutter:

## Architecture

Follow the project's existing:

```text
Clean Architecture
+
SOLID
+
Offline First
+
Existing Network Layer
```

Do **not** create a new HTTP/networking implementation if an existing `ApiConsumer`, `DioConsumer`, interceptors, authentication handling, or network datasource already exists.

Reuse the existing network folder and patterns.

---

# Recommended Data Flow

```text
Presentation
    ↓
Jobs Cubit / Bloc
    ↓
Get Jobs UseCase
    ↓
Jobs Repository
    ↓
Jobs Remote DataSource
    ↓
Existing ApiConsumer
    ↓
GET /api/jobs
```

For offline-first behavior:

```text
Jobs Cubit
    ↓
Repository
    ├── Local Data Source
    │      ↓
    │   Cached Jobs
    │
    └── Remote Data Source
           ↓
        GET /api/jobs
```

The repository should remain responsible for deciding whether data comes from local cache or the API.

---

# Important Implementation Rules

### 1. Reuse existing network layer

Use the project's existing:

```text
ApiConsumer
DioConsumer
Dio
Interceptors
Auth/JWT handling
Failure/Error handling
```

Do not introduce another Dio instance or another API client.

### 2. Keep API models separate

Create API response models according to the existing project conventions.

Example conceptual structure:

```text
JobModel
CompanyModel
SkillModel
JobsResponseModel
PaginationMetaModel
PaginationLinksModel
```

Map models to domain entities inside the data layer according to the project's existing architecture.

### 3. Preserve nullable API fields

Do not assume fields such as:

```text
state
city
logo_url
expires_at
links.prev
links.next
```

will always contain non-null values.

Follow the actual API response and existing project null-safety conventions.

### 4. Dates

The API returns ISO-8601 datetime strings:

```text
2026-10-01T17:00:28.820Z
```

Parse them using the project's existing date/time utilities.

Do not manually parse the string with substring/index operations.

### 5. Pagination

Pagination is server-side.

Do not fetch all jobs and paginate them locally.

Use:

```text
page
per_page
```

and the returned:

```text
meta
links
```

to control pagination.

### 6. Search

Search should be sent to the backend:

```http
?search=flutter
```

Do not implement the primary job search by filtering the already-loaded list locally.

### 7. Filters

Send active filters as query parameters.

Do not send unnecessary empty parameters unless the existing API client convention requires them.

Example:

```http
/api/jobs?work_mode=remote&city=Mansoura
```

instead of:

```http
/api/jobs?work_mode=remote&city=&country=&state=&search=
```

### 8. Sort

`sort=relevance` should only be sent when a search query exists.

Without search, the backend automatically uses newest-first ordering.

---

# Suggested Request Parameters Object

Conceptually:

```dart
class JobsQueryParameters {
  final String? search;
  final String? sort;
  final int? companyId;
  final String? jobType;
  final String? workMode;
  final String? employmentType;
  final String? experienceLevel;
  final String? country;
  final String? state;
  final String? city;
  final String? source;
  final String? applicationMethod;
  final bool? isVerifiedCompany;
  final List<int>? requiredSkillIds;
  final List<int>? preferredSkillIds;
  final int page;
  final int perPage;
}
```

Adapt this to the project's existing naming and parameter conventions rather than introducing a conflicting pattern.

---

# Example API Call

```http
GET /api/jobs?page=1&per_page=15
Authorization: Bearer <JWT>
Accept: application/json
Accept-Language: en
```

With search:

```http
GET /api/jobs?search=flutter&sort=relevance&page=1&per_page=15
```

With filters:

```http
GET /api/jobs?work_mode=remote&employment_type=full_time&experience_level=junior&page=1&per_page=15
```

With skills:

```http
GET /api/jobs?required_skill_ids[]=1&required_skill_ids[]=5&page=1&per_page=15
```

---

# Error Mapping

Recommended mapping to the existing application's failure system:

| HTTP Status | Meaning | Client Handling |
|---|---|---|
| `200` | Success | Parse jobs |
| `401` | Unauthenticated | Auth/session handling |
| `403` | Forbidden/inactive | Show appropriate permission/account message |
| `422` | Validation error | Parse API validation errors |
| `503` | Server unavailable | Show server/network failure |

Do not create feature-specific error handling if the project already has centralized failure handling.

---

# Current API Availability Note

At documentation time, the following request:

```http
GET /api/jobs?page=1&per_page=15
```

returned:

```http
503 Service Unavailable
```

Therefore, the endpoint contract above is based on the provided Swagger specification, while the `503` response confirms that the server may currently be unavailable.

The implementation should still follow the documented `200`, `401`, `403`, and `422` contracts.

---

# Agent Checklist

Before considering the integration complete:

- [ ] Use `GET /api/jobs`.
- [ ] Reuse the existing network layer.
- [ ] Reuse existing JWT/auth handling.
- [ ] Follow Clean Architecture.
- [ ] Follow SOLID.
- [ ] Follow the project's existing `CLAUDE.md` rules.
- [ ] Implement remote data source.
- [ ] Implement repository method.
- [ ] Implement use case.
- [ ] Connect Cubit/Bloc to the use case.
- [ ] Support pagination.
- [ ] Support search.
- [ ] Support sorting.
- [ ] Support all documented filters.
- [ ] Support required skill IDs.
- [ ] Support preferred skill IDs.
- [ ] Parse company information.
- [ ] Parse required/preferred skills.
- [ ] Parse `is_saved`.
- [ ] Parse pagination metadata.
- [ ] Handle `401`.
- [ ] Handle `403`.
- [ ] Handle `422`.
- [ ] Handle `503`.
- [ ] Preserve offline-first behavior.
- [ ] Cache successful job-feed responses according to the existing caching strategy.
- [ ] Do not break existing features.
- [ ] Add/update tests for datasource, repository, use case, and Cubit/Bloc where applicable.