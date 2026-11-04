import 'package:MatchIn/features/settings/presentation/models/team_member_model.dart';

abstract final class TeamCreditsData {
  TeamCreditsData._();

  static const List<TeamMemberModel> members = [
    TeamMemberModel(
      name: 'Ahmed Eltantawi',
      arabicName: 'أحمد الطنطاوي',
      linkedInUrl: 'https://www.linkedin.com/in/ahmedeltantawi7/',
      facebookUrl: 'https://m.facebook.com/profile.php?id=61588928911743',
    ),
    TeamMemberModel(
      name: 'Ali Hassan',
      arabicName: 'علي حسن',
      linkedInUrl: 'https://www.linkedin.com/in/ali-hassan-031365378/',
    ),
    TeamMemberModel(
      name: 'Amira Abdelsalam Sultan',
      arabicName: 'أميرة عبد السلام سلطان',
      linkedInUrl: 'https://www.linkedin.com/in/amira-abdelsalam-sultan/',
      facebookUrl: 'https://m.facebook.com/EngAmiraSultan/',
    ),
    TeamMemberModel(
      name: 'Ahmed Elzaher',
      arabicName: 'أحمد الظاهر',
      linkedInUrl: 'https://www.linkedin.com/in/ahmed-elzaher13/',
    ),
  ];

  static const List<TeamMemberModel> supervisors = [
    TeamMemberModel(
      name: 'Heba Abdelhamid',
      arabicName: 'هبة عبد الحميد',
      linkedInUrl: 'https://www.linkedin.com/in/heba-abdelhamid-35b373293/',
    ),
    TeamMemberModel(
      name: 'Ebrahim Elkbbany',
      arabicName: 'إبراهيم القباني',
      linkedInUrl: 'https://www.linkedin.com/in/ebrahim-elkbbany-4b2374213/',
    ),
  ];
}
