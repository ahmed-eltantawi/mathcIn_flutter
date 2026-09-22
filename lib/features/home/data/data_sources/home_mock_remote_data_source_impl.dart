import 'package:MatchIn/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';

// TODO: استبدال الكلاس ده بـ HomeRemoteDataSourceImpl حقيقي يستخدم ApiConsumer
// لما تجهز endpoints الباك إند (نفس نمط Auth/Chatbot/Jobs الحاليين)
class HomeMockRemoteDataSourceImpl
    implements HomeRemoteDataSource {
  @override
  Future<HomeDashboardEntity> getHomeDashboard() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return const HomeDashboardEntity(
      userName: 'Ahmed',
      matchesCount: 12,
    );
  }
}
