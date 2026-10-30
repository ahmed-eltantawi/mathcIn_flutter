import 'package:equatable/equatable.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';

class JobFilterParams extends Equatable {
  const JobFilterParams({
    this.search,
    this.sort,
    this.companyId,
    this.jobType,
    this.workMode,
    this.employmentType,
    this.experienceLevel,
    this.country,
    this.state,
    this.city,
    this.source,
    this.applicationMethod,
    this.isVerifiedCompany,
    this.requiredSkillIds,
    this.preferredSkillIds,
    this.page = 1,
    this.perPage = 15,
  });

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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (search != null && search!.trim().isNotEmpty) {
      map['q'] = search!.trim();
    }
    if (employmentType != null && employmentType!.isNotEmpty) {
      map[ApiKey.employmentType] = employmentType;
    }
    if (experienceLevel != null && experienceLevel!.isNotEmpty) {
      map[ApiKey.experienceLevel] = experienceLevel;
    }
    final locationParts = [
      country,
      state,
      city,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
    if (locationParts.isNotEmpty) map['location'] = locationParts.join(', ');
    if (workMode != null && workMode!.isNotEmpty) {
      map['is_remote'] = workMode!.toLowerCase().contains('remote');
    }
    // The deployed contract does not define sort, company, source,
    // verification, or skill-id filters; don't send undocumented keys.
    map[ApiKey.page] = page;
    map[ApiKey.perPage] = perPage;
    return map;
  }

  String toCacheKey() {
    final buffer = StringBuffer('default');
    if (search != null && search!.trim().isNotEmpty) {
      buffer.write('_search_${search!.trim().toLowerCase()}');
    }
    if (sort != null && sort!.isNotEmpty) {
      buffer.write('_sort_${sort!}');
    }
    if (jobType != null && jobType!.isNotEmpty) {
      buffer.write('_jt_${jobType!}');
    }
    if (workMode != null && workMode!.isNotEmpty) {
      buffer.write('_wm_${workMode!}');
    }
    if (employmentType != null && employmentType!.isNotEmpty) {
      buffer.write('_et_${employmentType!}');
    }
    if (experienceLevel != null && experienceLevel!.isNotEmpty) {
      buffer.write('_el_${experienceLevel!}');
    }
    if (country != null && country!.isNotEmpty) {
      buffer.write('_co_${country!}');
    }
    if (state != null && state!.isNotEmpty) {
      buffer.write('_st_${state!}');
    }
    if (city != null && city!.isNotEmpty) {
      buffer.write('_ci_${city!}');
    }
    if (source != null && source!.isNotEmpty) {
      buffer.write('_so_${source!}');
    }
    if (applicationMethod != null && applicationMethod!.isNotEmpty) {
      buffer.write('_am_${applicationMethod!}');
    }
    if (isVerifiedCompany != null) {
      buffer.write('_vc_$isVerifiedCompany');
    }
    if (requiredSkillIds != null && requiredSkillIds!.isNotEmpty) {
      buffer.write('_rs_${requiredSkillIds!.join(',')}');
    }
    if (preferredSkillIds != null && preferredSkillIds!.isNotEmpty) {
      buffer.write('_ps_${preferredSkillIds!.join(',')}');
    }
    if (companyId != null) {
      buffer.write('_cid_$companyId');
    }
    if (page > 1) {
      buffer.write('_p_$page');
    }
    return buffer.toString();
  }

  JobFilterParams copyWith({
    String? search,
    String? sort,
    int? companyId,
    String? jobType,
    String? workMode,
    String? employmentType,
    String? experienceLevel,
    String? country,
    String? state,
    String? city,
    String? source,
    String? applicationMethod,
    bool? isVerifiedCompany,
    List<int>? requiredSkillIds,
    List<int>? preferredSkillIds,
    int? page,
    int? perPage,
  }) {
    return JobFilterParams(
      search: search ?? this.search,
      sort: sort ?? this.sort,
      companyId: companyId ?? this.companyId,
      jobType: jobType ?? this.jobType,
      workMode: workMode ?? this.workMode,
      employmentType: employmentType ?? this.employmentType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      source: source ?? this.source,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      isVerifiedCompany: isVerifiedCompany ?? this.isVerifiedCompany,
      requiredSkillIds: requiredSkillIds ?? this.requiredSkillIds,
      preferredSkillIds: preferredSkillIds ?? this.preferredSkillIds,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  @override
  List<Object?> get props => [
    search,
    sort,
    companyId,
    jobType,
    workMode,
    employmentType,
    experienceLevel,
    country,
    state,
    city,
    source,
    applicationMethod,
    isVerifiedCompany,
    requiredSkillIds,
    preferredSkillIds,
    page,
    perPage,
  ];
}
