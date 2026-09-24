class SaveJobToggleModel {
  const SaveJobToggleModel({
    required this.jobId,
    required this.isSaved,
  });

  factory SaveJobToggleModel.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return SaveJobToggleModel(
      jobId: (data['job_id'] as num?)?.toInt() ?? (data['id'] as num?)?.toInt() ?? 0,
      isSaved: data['is_saved'] as bool? ?? false,
    );
  }

  final int jobId;
  final bool isSaved;
}
