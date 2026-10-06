# Notifications API Documentation

This document describes the backend APIs for the Candidate Notifications feature.

The AI agent must read and follow this document before implementing or integrating the Notifications feature.

---

## 1. General Rules

### Authentication

All endpoints require:

- JWT authentication
- An active Candidate account

The API only allows candidates to access their own notifications.

### Authorization

If the authenticated user:

- Has an invalid/missing JWT → `401`
- Is inactive or has the wrong role → `403`

### Localization

All endpoints support the `Accept-Language` header.

Supported values:

- `en`
- `en-US`
- `ar`
- `ar-EG`

Default:

```text
en

Behavior:
- en-US → English
- en → English
- ar-EG → Arabic
- ar → Arabic
- Unsupported values → fallback to English
Localization affects human-readable API messages only. Do not hardcode localized backend messages in the Flutter application.

2. List Notifications
Endpoint
GET /api/notifications

Description
Returns the authenticated candidate's notifications.
Notifications are returned newest first.
The endpoint supports:
- Pagination
- Filtering unread notifications only
Query Parameters
Parameter	Type	Required	Default	Description
unread_only	boolean	No	—	Return only unread notifications
page	integer	No	1	Page number
per_page	integer	No	15	Number of notifications per page
Accept-Language	header	No	en	Response message locale


Pagination constraints
page >= 1
1 <= per_page <= 100

Example:
GET /api/notifications?page=1&per_page=15

Unread only:
GET /api/notifications?unread_only=true

Combined:
GET /api/notifications?unread_only=true&page=1&per_page=20

Success Response
HTTP 200
Example:
{
  "data": [
    {
      "id": 1,
      "type": "job_match",
      "title": "New matching job",
      "message": "A new job matches your profile.",
      "read_at": null,
      "is_read": false
    }
  ]
}

Notification Fields
Field	Type	Description
id	integer	Notification ID
type	string	Notification type
title	string	Notification title
message	string	Notification message
read_at	nullable string	Timestamp when notification was read
is_read	boolean	Whether notification has been read


The backend may provide additional fields depending on the endpoint/version. Do not assume fields that are not provided by the API.

3. Get Unread Notifications Count
Endpoint
GET /api/notifications/unread-count

Description
Returns the number of unread notifications for the authenticated candidate.
Success Response
HTTP 200
{
  "data": {
    "count": 3
  }
}

Response Fields
Field	Type	Description
count	integer	Number of unread notifications


4. Mark All Notifications as Read
Endpoint
PATCH /api/notifications/read-all

Description
Marks all notifications belonging to the authenticated candidate as read.
The response contains the number of notifications that were updated.
Success Response
HTTP 200
{
  "data": {
    "updated_count": 3
  }
}

Response Fields
Field	Type	Description
updated_count	integer	Number of notifications changed to read


5. Mark One Notification as Read
Endpoint
PATCH /api/notifications/{notification}/read

Path Parameters
Parameter	Type	Required	Description
notification	integer	Yes	Notification ID


Example:
PATCH /api/notifications/15/read

Description
Marks a single notification as read.
The notification ID is scoped to the authenticated candidate.
A candidate cannot mark another candidate's notification as read.
Success Response
HTTP 200
{
  "data": {
    "id": 15,
    "type": "job_match",
    "title": "New matching job",
    "message": "A new job matches your profile.",
    "data": {},
    "read_at": "2026-10-06T07:20:27.400Z",
    "created_at": "2026-10-06T07:20:27.400Z",
    "is_read": true
  }
}

Response Fields
Field	Type	Description
id	integer	Notification ID
type	string	Notification type
title	string	Notification title
message	string	Notification message
data	object	Additional notification data
read_at	nullable string	Read timestamp
created_at	string	Notification creation timestamp
is_read	boolean	Read status


6. Error Responses
401 — Unauthenticated
Returned when the JWT is missing or invalid.
{
  "message": "Unauthenticated."
}

The application should handle this through the existing authentication/error handling mechanism.
Do not duplicate authentication logic inside the Notifications feature.
403 — Forbidden
Returned when the authenticated user is not allowed to access the endpoint.
Possible reasons:
- Account is inactive
- User has the wrong role
Example:
{
  "message": "Your account is inactive."
}

404 — Notification Not Found
Used by:
PATCH /api/notifications/{notification}/read

Returned when:
- Notification does not exist
- Notification does not belong to the authenticated candidate
Example:
{
  "message": "Unauthenticated."
}

Treat this as a backend response. Do not expose hardcoded backend messages in the UI.

422 — Validation Error
Example:
{
  "message": "The email field is required. (and 1 more error)",
  "errors": {
    "email": [
      "The email field is required."
    ]
  }
}

Use the application's existing API validation/error handling mechanism.
Do not create duplicated validation handling specifically for Notifications unless required by the existing architecture.
7. API Summary
Method	Endpoint	Purpose
GET	/api/notifications	Get paginated notifications
GET	/api/notifications/unread-count	Get unread notification count
PATCH	/api/notifications/read-all	Mark all notifications as read
PATCH	/api/notifications/{notification}/read	Mark one notification as read


8. Flutter Integration Requirements
When integrating these endpoints into the Flutter application:
Architecture
Follow the existing project architecture strictly.
Use:
Presentation
    ↓
Domain
    ↓
Data
    ↓
Remote / Local Data Sources

Follow Clean Architecture and SOLID principles.
Use a UseCase for each business operation where this matches the existing project architecture.
Recommended operations:
GetNotificationsUseCase
GetUnreadNotificationsCountUseCase
MarkNotificationAsReadUseCase
MarkAllNotificationsAsReadUseCase

Do not put API calls directly inside Cubits/Widgets.
9. Data Layer
Follow the existing networking implementation.
Use the project's existing:
- ApiConsumer
- DioConsumer
- DI / GetIt
- API constants
- Failure handling
- Network exceptions
- Response parsing patterns
Do NOT create a second networking implementation.
Do NOT create a new Dio instance if the project already provides one through dependency injection.
10. Data Sources
Keep remote data sources separated from each other when appropriate.
For example:
notifications/
├── data/
│   ├── datasources/
│   │   ├── notifications_remote_data_source.dart
│   │   └── notifications_remote_data_source_impl.dart
│   │
│   ├── models/
│   │   └── notification_model.dart
│   │
│   └── repositories/
│       └── notifications_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── notification_entity.dart
│   │
│   ├── repositories/
│   │   └── notifications_repository.dart
│   │
│   └── usecases/
│       ├── get_notifications_use_case.dart
│       ├── get_unread_notifications_count_use_case.dart
│       ├── mark_notification_as_read_use_case.dart
│       └── mark_all_notifications_as_read_use_case.dart
│
└── presentation/
    ├── cubit/
    ├── pages/
    └── widgets/

Adapt the structure to the existing project structure instead of blindly creating duplicate folders.
11. Models and Entities
Create a proper Notification model/entity based on the API response.
Do not use Map<String, dynamic> throughout the application.
Use proper:
NotificationModel
NotificationEntity

The model should handle nullable fields such as:
read_at

The data field from the mark-single-read endpoint should also be handled safely because it may contain additional dynamic notification data.
12. Pagination
The notifications endpoint is paginated.
The implementation must support pagination according to the existing project pagination pattern.
Default:
page = 1
per_page = 15

Maximum:
per_page = 100

Do not hardcode pagination behavior inside widgets.
Pagination logic should belong to the appropriate presentation/domain/data layer based on the existing architecture.
13. Read Status
The application should rely on:
is_read

and:
read_at

from the API.
Do not calculate read status using UI assumptions.
For example:
is_read == false

means the notification is unread.
After successfully marking a notification as read, update the UI using the API response/state management mechanism.
14. Unread Count
The unread count endpoint should be treated as a separate API operation:
GET /api/notifications/unread-count

Do not calculate the unread count by assuming that the currently loaded notifications represent all notifications.
The backend is the source of truth for the unread count.
15. Mark All as Read
Use:
PATCH /api/notifications/read-all

Do not send one request per notification.
After a successful response:
{
  "data": {
    "updated_count": 3
  }
}

Update the local/presentation state accordingly.
The unread count should become 0 when the operation successfully marks all notifications as read.
16. Localization Rules
Do not hardcode English or Arabic UI strings in Dart code.
Use the project's existing localization system.
Examples of UI strings that should be localized:
Notifications
No notifications
No unread notifications
Mark all as read
Notification read
Something went wrong
Retry

For API requests, use the project's existing localization/locale mechanism to provide:
Accept-Language

Do not manually duplicate locale conversion logic if the project already has a centralized implementation.
17. Hardcoded Values
DO NOT hardcode:
- API URLs
- Notification IDs
- Notification messages
- User-specific notification data
- Unread count
- Notification titles
- Notification types
- Authentication tokens
- Localized API messages
API values must come from the backend.
Use the existing API constants/configuration system.
18. State Management
Use the project's existing state-management approach.
If the feature uses Cubit/BLoC, keep:
- Loading
- Success
- Error
- Empty
- Pagination/loading-more
- Read/update states
properly separated.
Do not put business logic inside widgets.
Widgets should be responsible primarily for presentation and user interaction.
19. Important Backend Rules
The backend is the source of truth.
The agent must NOT assume:
- Notification types that are not documented
- Notification data structure beyond what the API returns
- Fixed notification counts
- Fixed notification titles/messages
- Notification ordering other than the documented newest-first behavior
- That all notifications fit on the first page
The implementation must remain flexible for future notification types.
20. Implementation Checklist
Before considering the integration complete, verify:
- [ ] GET /api/notifications integrated
- [ ] Pagination implemented
- [ ] unread_only filter supported
- [ ] GET /api/notifications/unread-count integrated
- [ ] PATCH /api/notifications/read-all integrated
- [ ] PATCH /api/notifications/{notification}/read integrated
- [ ] JWT authentication uses the existing auth mechanism
- [ ] Accept-Language is handled
- [ ] Models/entities created properly
- [ ] Repository abstraction implemented
- [ ] UseCases implemented
- [ ] Cubit/BLoC handles states correctly
- [ ] Loading state implemented
- [ ] Empty state implemented
- [ ] Error state implemented
- [ ] Pagination loading state implemented
- [ ] Read/unread state updates correctly
- [ ] Unread count updates correctly
- [ ] Localization used instead of hardcoded strings
- [ ] No hardcoded API data
- [ ] Existing networking layer reused
- [ ] Existing DI/GetIt setup reused
- [ ] Existing error/failure handling reused
- [ ] Existing project rules followed
- [ ] No unnecessary duplicate code
- [ ] No API calls directly from widgets