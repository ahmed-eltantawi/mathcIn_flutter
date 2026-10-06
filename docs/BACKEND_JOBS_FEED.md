# Backend Jobs Feed API

## Overview

This document describes the backend API used to retrieve the authenticated user's job feed.

The endpoint supports:

- Job feed pagination
- Search
- Sorting
- Company filtering
- Job type filtering
- Work mode filtering
- Employment type filtering
- Experience level filtering
- Location filtering
- Source filtering
- Application method filtering
- Verified company filtering
- Required skills filtering
- Preferred skills filtering

The endpoint returns only active, non-expired jobs belonging to active companies.

---

# Endpoint

```http
GET /api/jobs
```

### Base URL

```text
https://skillmatch.iptvdemo.serv5group.com
```

### Full URL

```text
https://skillmatch.iptvdemo.serv5group.com/api/jobs
```

---

# Authentication

Authentication is required.

```text
JWT + Active User
```

The endpoint is available for authenticated users with any allowed role.

The JWT should be sent using the application's existing authentication/networking implementation.

**Do not hard-code authentication tokens.**

---

# Headers

## Accept-Language

```http
Accept-Language: en
```

Supported locale behavior:

| Header | Response Locale |
|---|---|
| `en-US` | English |
| `en` | English |
| `ar-EG` | Arabic |
| `ar` | Arabic |
| Any other value | English fallback |

This affects **human-readable messages only**.

The response data itself should not be manually transformed based on this header.

Use the application's existing localization/networking implementation.

---

# Query Parameters

All filters are optional unless otherwise specified.

## Pagination

### page

```text
page=1
```

- Type: `integer`
- Minimum: `1`
- Default: `1`

### per_page

```text
per_page=15
```

- Type: `integer`
- Minimum: `1`
- Maximum: `100`
- Default: `15`

Example:

```http
GET /api/jobs?page=1&per_page=15
```

---

# Search

## search

```text
search=flutter
```

- Type: `string`
- Maximum length: `255`
- Optional

Used to search the job feed.

Example:

```http
GET /api/jobs?search=flutter
```

---

# Sorting

## sort

Optional sorting parameter.

```text
sort=relevance
```

### Important behavior

`sort=relevance` only applies when a search query is provided.

If there is **no search query**, the backend uses **newest first** ordering.

Example:

```http
GET /api/jobs?search=flutter&sort=relevance
```

Do not assume `relevance` sorting works without `search`.

---

# Job Filters

## company_id

```text
company_id=12
```

- Type: `integer`

Filters jobs belonging to a specific company.

---

## job_type

```text
job_type=job
```

- Type: `string`

Filters by job type.

---

## work_mode

```text
work_mode=remote
```

- Type: `string`

Filters by work mode.

---

## employment_type

```text
employment_type=full_time
```

- Type: `string`

Filters by employment type.

---

## experience_level

```text
experience_level=junior
```

- Type: `string`

Filters by experience level.

---

# Location Filters

## country

```text
country=Egypt
```

- Type: `string`

---

## state

```text
state=Dakahlia
```

- Type: `string`

---

## city

```text
city=Mansoura
```

- Type: `string`

Location filters can be combined.

Example:

```http
GET /api/jobs?country=Egypt&state=Dakahlia&city=Mansoura
```

---

# Additional Filters

## source

```text
source=linkedin
```

- Type: `string`

Filters jobs by their source.

---

## application_method

```text
application_method=internal
```

- Type: `string`

Filters by application method.

---

## is_verified_company

```text
is_verified_company=true
```

- Type: `boolean`

Filters jobs based on whether the company is verified.

---

# Skill Filters

## required_skill_ids

Array of integer skill IDs.

Example:

```text
required_skill_ids[]=1
required_skill_ids[]=5
required_skill_ids[]=10
```

Used to filter jobs based on required skills.

---

## preferred_skill_ids

Array of integer skill IDs.

Example:

```text
preferred_skill_ids[]=2
preferred_skill_ids[]=8
```

Used to filter jobs based on preferred skills.

---

# Example Requests

## Basic Job Feed

```http
GET /api/jobs?page=1&per_page=15
```

---

## Search

```http
GET /api/jobs?search=flutter&page=1&per_page=15
```

---

## Search + Relevance

```http
GET /api/jobs?search=flutter&sort=relevance&page=1&per_page=15
```

---

## Multiple Filters

```http
GET /api/jobs?search=flutter&work_mode=remote&employment_type=full_time&experience_level=junior&page=1&per_page=15
```

---

## Location Filtering

```http
GET /api/jobs?country=Egypt&state=Dakahlia&city=Mansoura&page=1&per_page=15
```

---

# Successful Response

### HTTP 200

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
      "published_at": "2026-10-05T09:07:56.610Z",
      "expires_at": "2026-10-05T09:07:56.610Z",
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

# Job Object

Each item in `data` represents a job.

| Field | Type | Description |
|---|---|---|
| `id` | integer | Unique job ID |
| `title` | string | Job title |
| `job_type` | string | Job type |
| `work_mode` | string | Work mode |
| `employment_type` | string | Employment type |
| `experience_level` | string | Required experience level |
| `country` | string | Country |
| `state` | string | State/governorate |
| `city` | string | City |
| `min_years_experience` | integer | Minimum years of experience |
| `max_years_experience` | integer | Maximum years of experience |
| `source` | string | Job source |
| `application_method` | string | How the user can apply |
| `published_at` | datetime | Publication date/time |
| `expires_at` | datetime | Expiration date/time |
| `is_active` | boolean | Whether the job is active |
| `is_expired` | boolean | Whether the job is expired |
| `is_saved` | boolean | Whether the current user has saved the job |

---

# Company Object

```json
{
  "id": 0,
  "name": "string",
  "logo_url": "string",
  "is_verified": true,
  "is_active": true
}
```

| Field | Type | Description |
|---|---|---|
| `id` | integer | Company ID |
| `name` | string | Company name |
| `logo_url` | string | Company logo URL |
| `is_verified` | boolean | Whether the company is verified |
| `is_active` | boolean | Whether the company is active |

---

# Skill Object

Required and preferred skills use the following structure:

```json
{
  "id": 0,
  "name": "string",
  "importance": 0,
  "required_level": "string"
}
```

| Field | Type | Description |
|---|---|---|
| `id` | integer | Skill ID |
| `name` | string | Skill name |
| `importance` | integer | Skill importance |
| `required_level` | string | Required skill level |

There are two skill collections:

```text
required_skills
preferred_skills
```

Do not treat preferred skills as required skills.

---

# Pagination Response

Pagination information is available in:

```text
meta
```

Example:

```json
{
  "current_page": 1,
  "from": 1,
  "last_page": 5,
  "per_page": 15,
  "to": 15,
  "total": 75
}
```

### Pagination fields

| Field | Type | Description |
|---|---|---|
| `current_page` | integer | Current page |
| `from` | integer/null | First item number |
| `last_page` | integer | Last available page |
| `per_page` | integer | Number of items per page |
| `to` | integer/null | Last item number on current page |
| `total` | integer | Total number of jobs |

Pagination URLs are also provided through:

```text
links.first
links.last
links.prev
links.next
```

The application should preferably use the pagination metadata rather than manually constructing pagination state from assumptions.

---

# Important Backend Behavior

## Active Jobs Only

The backend is designed to return:

- Active jobs
- Non-expired jobs
- Jobs belonging to active companies

The client should **not duplicate backend filtering logic** unnecessarily.

---

## Current User Saved State

Each job contains:

```text
is_saved
```

This indicates whether the current authenticated user has saved that job.

The UI should use this field to determine the initial saved state.

Do not hard-code saved states.

---

# Error Responses

## 401 — Unauthenticated

Returned when the JWT is missing or invalid.

```json
{
  "message": "Unauthenticated."
}
```

The application should handle this through the existing authentication/error handling mechanism.

Do not implement authentication handling directly inside the UI.

---

## 403 — Forbidden

Returned when the authenticated user is not allowed to access the endpoint, such as an inactive account or wrong role.

Example:

```json
{
  "message": "Your account is inactive."
}
```

---

## 422 — Validation Error

Returned when request parameters fail backend validation.

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

The application should map validation errors through the existing failure/error handling architecture.

Do not expose raw backend errors directly in the UI unless that is already the application's established behavior.

---

## 503 — Service Unavailable

The API may temporarily return:

```text
503 Service Unavailable
```

Example:

```html
<h1>Service Unavailable</h1>
<p>
The server is temporarily unable to service your request
due to maintenance downtime or capacity problems.
Please try again later.
</p>
```

This was observed during API testing and may indicate temporary backend maintenance/capacity issues.

Handle this through the application's standard network failure mechanism.

---

# Flutter Integration Rules

When integrating this endpoint into the Flutter application:

### 1. Follow Clean Architecture

Keep responsibilities separated:

```text
Presentation
    ↓
Domain
    ↓
Data
```

The UI must not call the API directly.

---

### 2. Use the Existing Networking Layer

Use the project's existing:

- `ApiConsumer`
- `DioConsumer`
- Dio configuration
- Authentication interceptor
- Error handling
- Dependency injection

Do not create a second networking implementation.

Do not duplicate the API client.

---

### 3. No Hard-Coded Job Data

Do not hard-code:

- Job titles
- Company names
- Company logos
- Locations
- Skills
- Saved state
- Job IDs
- Pagination totals
- Search results

All job feed data must come from the API/cache.

---

### 4. DTO / Model Mapping

The API response belongs to the Data layer.

Recommended flow:

```text
API Response
    ↓
JobModel
    ↓
JobEntity
    ↓
UseCase
    ↓
Cubit
    ↓
UI
```

The UI should depend on domain entities rather than raw API response objects.

---

### 5. Repository Pattern

The presentation layer should never communicate directly with the remote data source.

Recommended flow:

```text
JobFeedCubit
      ↓
GetJobsUseCase
      ↓
JobsRepository
      ↓
JobsRemoteDataSource
      ↓
ApiConsumer
      ↓
GET /api/jobs
```

---

### 6. Cubit Responsibility

The Cubit should remain lightweight.

The Cubit should primarily:

1. Receive UI actions.
2. Call the appropriate use case.
3. Handle the returned result.
4. Emit the appropriate state.

Avoid putting:

- API calls
- Filtering algorithms
- JSON parsing
- Repository logic
- Business rules

inside the Cubit.

---

# Search and Filter Integration

The search/filter state should be represented by a dedicated request/filter model rather than passing many unrelated parameters through the presentation layer.

For example:

```text
JobsQuery
```

can contain:

```text
search
sort
companyId
jobType
workMode
employmentType
experienceLevel
country
state
city
source
applicationMethod
isVerifiedCompany
requiredSkillIds
preferredSkillIds
page
perPage
```

The exact class name should follow the project's existing naming conventions and `GEMENI.md` rules.

---

# Pagination Behavior

When implementing pagination:

```text
page = 1
perPage = 15
```

should be the default behavior according to the API contract.

The implementation must respect:

```text
1 <= page
1 <= perPage <= 100
```

Do not request more than:

```text
per_page=100
```

Pagination should be driven by the backend response:

```text
meta.current_page
meta.last_page
meta.total
links.next
```

Do not assume a fixed number of pages.

---

# Offline-First Considerations

If the project follows an offline-first architecture:

```text
UI
 ↓
Cubit
 ↓
UseCase
 ↓
Repository
 ↙       ↘
Local    Remote
```

The repository should determine whether cached data can be used and when the remote API should be requested.

The API response should be mapped and cached using the project's existing local-data architecture.

Do not introduce a new caching mechanism if one already exists in the project.

---

# Important Implementation Notes

1. Do not hard-code API response data.
2. Do not hard-code pagination values beyond the API defaults/constraints.
3. Do not create a new Dio/API client.
4. Reuse the existing networking folder and classes.
5. Reuse the existing authentication mechanism.
6. Follow the project's Clean Architecture structure.
7. Follow SOLID principles.
8. Keep business logic outside the UI.
9. Keep Cubits lightweight.
10. Use UseCases for business operations.
11. Map API Models to Domain Entities.
12. Handle loading, success, empty, and error states.
13. Handle pagination properly.
14. Preserve the backend's `is_saved` value.
15. Do not manually filter active/expired jobs if the backend already guarantees them.
16. Do not assume `sort=relevance` works without `search`.
17. Respect the `per_page` maximum of `100`.
18. Follow all project-specific rules defined in `GEMENI.md`.

---

# Reference Request

Basic request:

```http
GET /api/jobs?page=1&per_page=15
```

With language:

```http
GET /api/jobs?page=1&per_page=15
Accept-Language: en
```

With search and filters:

```http
GET /api/jobs?search=flutter&sort=relevance&work_mode=remote&experience_level=junior&page=1&per_page=15
Accept-Language: en
```

---

# API Contract Summary

```text
Endpoint:
GET /api/jobs

Authentication:
JWT + Active User

Default pagination:
page=1
per_page=15

Maximum per_page:
100

Search:
search

Relevance sorting:
sort=relevance
Only meaningful when search is provided.

Response:
Paginated JSON

Main response fields:
data
links
meta

Job-specific user state:
is_saved

Company information:
company

Skills:
required_skills
preferred_skills
```

This file should be treated as the **source of truth for the Jobs Feed API contract** during frontend integration.