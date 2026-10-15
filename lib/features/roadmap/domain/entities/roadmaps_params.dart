import 'package:equatable/equatable.dart';

class RoadmapsParams extends Equatable {
  const RoadmapsParams({this.page = 1, this.perPage = 15});

  final int page;
  final int perPage;

  Map<String, dynamic> toJson() {
    return {'page': page, 'per_page': perPage};
  }

  @override
  List<Object?> get props => [page, perPage];
}
