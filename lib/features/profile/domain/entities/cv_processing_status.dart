/// Backend-documented CV processing states plus a safe fallback.
///
/// The string-to-enum mapping is applied inside the Data Layer
/// (`CvDocumentModel`): `uploaded`/`processing` → [analyzing],
/// `completed` → [analyzed], `failed` → [failed].
/// Anything else maps to [unknown], which renders without a status
/// badge. An HTTP upload failure is reported separately through
/// `CvUploadFailure` and must not be confused with analysis status.
/// Presentation resolves labels through `S`
/// (`analyzing`, `analyzed`, `failed`) and must never
/// depend on raw backend machine strings.
enum CvProcessingStatus { analyzing, analyzed, failed, unknown }
