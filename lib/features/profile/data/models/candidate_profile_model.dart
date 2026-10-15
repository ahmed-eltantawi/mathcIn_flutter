import 'package:MatchIn/features/profile/data/models/candidate_profile_details_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_project_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_skill_model.dart';
import 'package:MatchIn/features/profile/data/models/career_preference_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_document_model.dart';
import 'package:MatchIn/features/profile/data/models/education_model.dart';
import 'package:MatchIn/features/profile/data/models/experience_model.dart';
import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
import 'package:MatchIn/features/profile/data/models/profile_user_model.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';

class CandidateProfileModel extends CandidateProfileEntity {
  const CandidateProfileModel({
    required super.profileExists,
    required ProfileUserModel super.user,
    CandidateProfileDetailsModel? super.profile,
    super.skills,
    super.projects,
    CareerPreferenceModel? super.careerPreferences,
    super.education,
    super.experience,
    CvDocumentModel? super.cvDocument,
  });

  factory CandidateProfileModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid candidate profile: missing user');
    }
    final profileJson = json['profile'];
    if (profileJson != null && profileJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid candidate profile: invalid profile');
    }
    final profile = profileJson == null
        ? null
        : CandidateProfileDetailsModel.fromJson(
            profileJson as Map<String, dynamic>,
          );
    final profileMap = profileJson is Map<String, dynamic> ? profileJson : null;

    return CandidateProfileModel(
      profileExists: json['profile_exists'] as bool? ?? false,
      user: ProfileUserModel.fromJson(userJson),
      profile: profile,
      skills: _skillList(
        _relationValue(json, profileMap, 'candidateSkills', const [
          'candidateSkills',
          'skills',
        ]),
      ),
      projects: _projectList(
        _relationValue(json, profileMap, 'projects', const ['projects']),
      ),
      careerPreferences: _careerPreferences(
        _relationValue(json, profileMap, 'careerPreference', const [
          'careerPreference',
          'career_preferences',
        ]),
      ),
      education: _educationList(
        _relationValue(json, profileMap, 'educations', const [
          'educations',
          'education',
        ]),
      ),
      experience: _experienceList(
        _relationValue(json, profileMap, 'experiences', const [
          'experiences',
          'experience',
        ]),
      ),
      cvDocument: _currentCvDocument(json, profileMap),
    );
  }

  /// Returns a copy with [document] as the selected current CV.
  ///
  /// Every other relation is preserved untouched, so reconciling a
  /// just-uploaded or pending CV never drops profile data. Used by
  /// the repository when the backend profile read lags behind a
  /// successful upload or holds an offline pending file.
  CandidateProfileModel copyWithCvDocument(CvDocumentModel? document) {
    // --- The constructor requires model types, so these casts always
    // --- succeed for instances built through it or `fromJson`. ---
    return CandidateProfileModel(
      profileExists: profileExists,
      user: user as ProfileUserModel,
      profile: profile as CandidateProfileDetailsModel?,
      skills: skills,
      projects: projects,
      careerPreferences: careerPreferences as CareerPreferenceModel?,
      education: education,
      experience: experience,
      cvDocument: document,
    );
  }

  /// Relation keys that mark a nested `profile` object as authoritative.
  static const _nestedRelationKeys = {
    'educations',
    'experiences',
    'projects',
    'candidateSkills',
    'careerPreference',
    'cvDocuments',
    'cv_documents',
  };

  static bool _hasNestedRelations(Map<String, dynamic> profileJson) {
    return profileJson.keys.any(_nestedRelationKeys.contains);
  }

  /// Resolves one relation value without mixing stale top-level data
  /// into an authoritative nested `profile` response:
  ///
  /// - Nested profile WITH relation keys → nested value only
  ///   (authoritative, even when null/absent for this relation).
  /// - Nested profile WITHOUT relation keys → legacy top-level
  ///   fallback (older cached data with a details-only profile).
  /// - Explicit `profile: null` → null (never resurrects stale
  ///   relations through legacy fallback).
  /// - Absent `profile` key → legacy top-level fallback.
  static dynamic _relationValue(
    Map<String, dynamic> json,
    Map<String, dynamic>? profileJson,
    String nestedKey,
    List<String> legacyKeys,
  ) {
    if (profileJson != null) {
      if (_hasNestedRelations(profileJson)) return profileJson[nestedKey];
      for (final key in legacyKeys) {
        if (json.containsKey(key)) return json[key];
      }
      return null;
    }
    if (json.containsKey('profile')) return null;
    for (final key in legacyKeys) {
      if (json.containsKey(key)) return json[key];
    }
    return null;
  }

  /// Skips items whose required id is missing or invalid instead of
  /// fabricating an id, so malformed siblings never corrupt valid
  /// records and valid records never render with a fake identity.
  static bool _hasValidId(Map<String, dynamic> item) {
    return JsonParsing.parseId(item['id']) != null;
  }

  static List<CandidateSkillModel> _skillList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    final result = <CandidateSkillModel>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        if (!_hasValidId(item)) continue;
        try {
          result.add(CandidateSkillModel.fromJson(item));
        } catch (_) {
          continue;
        }
      }
    }
    return result;
  }

  static List<CandidateProjectModel> _projectList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    final result = <CandidateProjectModel>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        if (!_hasValidId(item)) continue;
        try {
          result.add(CandidateProjectModel.fromJson(item));
        } catch (_) {
          continue;
        }
      }
    }
    return result;
  }

  static CareerPreferenceModel? _careerPreferences(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is! Map<String, dynamic>) {
      return null;
    }
    try {
      return CareerPreferenceModel.fromJson(value);
    } catch (_) {
      return null;
    }
  }

  static List<EducationModel> _educationList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    final result = <EducationModel>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        if (!_hasValidId(item)) continue;
        try {
          result.add(EducationModel.fromJson(item));
        } catch (_) {
          continue;
        }
      }
    }
    return result;
  }

  static List<ExperienceModel> _experienceList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    final result = <ExperienceModel>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        if (!_hasValidId(item)) continue;
        try {
          result.add(ExperienceModel.fromJson(item));
        } catch (_) {
          continue;
        }
      }
    }
    return result;
  }

  /// Selects the current CV using `is_current == true`.
  /// Never selects an arbitrary document: when no entry is flagged
  /// current, the result is null (empty CV state).
  ///
  /// Source priority mirrors [_relationValue]: a nested `profile`
  /// object carrying relation keys is authoritative — an explicit
  /// null/empty `cvDocuments` list there never falls back to legacy
  /// documents. Otherwise the legacy top-level list/singular payload
  /// applies (older cached data), except when `profile` is explicitly
  /// null, which yields no relations at all.
  static CvDocumentModel? _currentCvDocument(
    Map<String, dynamic> json,
    Map<String, dynamic>? profileJson,
  ) {
    if (profileJson != null) {
      if (_hasNestedRelations(profileJson)) {
        final list = profileJson['cvDocuments'] ?? profileJson['cv_documents'];
        if (list is! List) return null;
        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;
          // Skip identity-less entries so a malformed sibling never
          // shadows the valid current document.
          if (JsonParsing.parseId(item['id']) == null) continue;
          try {
            final document = CvDocumentModel.fromJson(item);
            if (document.isCurrent == true) return document;
          } catch (_) {
            continue;
          }
        }
        return null;
      }
      return _legacyCvDocument(json);
    }
    if (json.containsKey('profile')) return null;
    return _legacyCvDocument(json);
  }

  /// Legacy top-level CV payloads (older cached data). Key presence
  /// (not value) decides authority: when either list key exists — even
  /// with a null, empty, or malformed value — the list is authoritative
  /// and the legacy fallback is skipped. The legacy singular
  /// `cv_document` payload applies only when both list keys are absent.
  static CvDocumentModel? _legacyCvDocument(Map<String, dynamic> json) {
    if (json.containsKey('cvDocuments') || json.containsKey('cv_documents')) {
      final list = json['cvDocuments'] ?? json['cv_documents'];
      if (list is! List) return null;
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        if (JsonParsing.parseId(item['id']) == null) continue;
        try {
          final document = CvDocumentModel.fromJson(item);
          if (document.isCurrent == true) return document;
        } catch (_) {
          continue;
        }
      }
      return null;
    }
    return _cvDocument(json['cv_document']);
  }

  static CvDocumentModel? _cvDocument(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is! Map<String, dynamic>) {
      return null;
    }
    try {
      return CvDocumentModel.fromJson(value);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_exists': profileExists,
      'user': ProfileUserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        isActive: user.isActive,
        phone: user.phone,
        avatar: user.avatar,
      ).toJson(),
      'profile': profile == null
          ? null
          : {
              ...CandidateProfileDetailsModel(
                id: profile!.id,
                dateOfBirth: profile!.dateOfBirth,
                gender: profile!.gender,
                jobTitle: profile!.jobTitle,
                country: profile!.country,
                state: profile!.state,
                city: profile!.city,
                githubUrl: profile!.githubUrl,
                linkedinUrl: profile!.linkedinUrl,
                militaryStatus: profile!.militaryStatus,
                professionalSummary: profile!.professionalSummary,
              ).toJson(),
              'educations': education.map((item) {
                if (item is EducationModel) {
                  return item.toJson();
                }
                return {
                  'id': item.id,
                  'degree': item.degree,
                  'institution': item.institution,
                  'start_date': item.startDate,
                  'end_date': item.endDate,
                  'grade': item.grade,
                };
              }).toList(),
              'experiences': experience.map((item) {
                if (item is ExperienceModel) {
                  return item.toJson();
                }
                return {
                  'id': item.id,
                  'job_title': item.jobTitle,
                  'company_name': item.companyName,
                  'employment_type': item.employmentType,
                  'country': item.country,
                  'city': item.city,
                  'description': item.description,
                  'technologies': item.technologies,
                  'start_date': item.startDate,
                  'end_date': item.endDate,
                  'is_current': item.isCurrent,
                };
              }).toList(),
              'projects': projects.map((project) {
                if (project is CandidateProjectModel) {
                  return project.toJson();
                }
                return {
                  'id': project.id,
                  'name': project.name,
                  'description': project.description,
                  'technologies': project.technologies,
                  'project_url': project.projectUrl,
                  'github_url': project.githubUrl,
                  'source': project.source,
                  'start_date': project.startDate,
                  'end_date': project.endDate,
                };
              }).toList(),
              'candidateSkills': skills.map((skill) {
                if (skill is CandidateSkillModel) {
                  return skill.toJson();
                }
                return {
                  'id': skill.id,
                  'skill_id': skill.skillId,
                  'source': skill.source,
                  'proficiency_level': skill.proficiencyLevel,
                  'skill': {'id': skill.skillId, 'name': skill.name},
                };
              }).toList(),
              'careerPreference': careerPreferences == null
                  ? null
                  : (careerPreferences is CareerPreferenceModel
                        ? (careerPreferences as CareerPreferenceModel).toJson()
                        : {
                            'id': careerPreferences!.id,
                            'target_role': careerPreferences!.targetRole,
                            'job_type': careerPreferences!.jobType,
                            'work_mode': careerPreferences!.workMode,
                            'preferred_country':
                                careerPreferences!.preferredCountry,
                            'preferred_city': careerPreferences!.preferredCity,
                            'experience_level':
                                careerPreferences!.experienceLevel,
                            'career_goal': careerPreferences!.careerGoal,
                            'open_to_relocation':
                                careerPreferences!.openToRelocation,
                            'target_roles': careerPreferences!.targetRoles,
                            'preferred_industries':
                                careerPreferences!.preferredIndustries,
                          }),
              // The entity holds exactly the selected current document,
              // so it round-trips as current. The flag is normalized
              // here to preserve the selection invariant through cache.
              'cvDocuments': cvDocument == null
                  ? []
                  : [
                      if (cvDocument is CvDocumentModel)
                        {
                          ...(cvDocument as CvDocumentModel).toJson(),
                          'is_current': true,
                        }
                      else
                        {
                          'id': cvDocument!.id,
                          'file_name': cvDocument!.fileName,
                          'original_filename': cvDocument!.originalFilename,
                          'file_url': cvDocument!.fileUrl,
                          'status': CvDocumentModel.statusToJson(
                            cvDocument!.status,
                          ),
                          'version': cvDocument!.version,
                          'is_current': true,
                          'processed_at': cvDocument!.processedAt,
                          'updated_at': cvDocument!.updatedAt,
                          'failure_reason': cvDocument!.failureReason,
                        },
                    ],
            },
    };
  }
}
