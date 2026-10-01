class JobLinksModel {
  const JobLinksModel({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory JobLinksModel.fromJson(Map<String, dynamic> json) {
    return JobLinksModel(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }

  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  Map<String, dynamic> toJson() {
    return {
      'first': first,
      'last': last,
      'prev': prev,
      'next': next,
    };
  }
}
