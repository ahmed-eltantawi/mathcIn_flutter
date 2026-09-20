// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `No internet connection`
  String get noInternetConnection {
    return Intl.message(
      'No internet connection',
      name: 'noInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection and try again`
  String get pleaseCheckYourInternetConnection {
    return Intl.message(
      'Please check your internet connection and try again',
      name: 'pleaseCheckYourInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get tryAgain {
    return Intl.message('Try Again', name: 'tryAgain', desc: '', args: []);
  }

  /// `Chat Bot`
  String get chatBot {
    return Intl.message('Chat Bot', name: 'chatBot', desc: '', args: []);
  }

  /// `RoadMap`
  String get roadMap {
    return Intl.message('RoadMap', name: 'roadMap', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Saved Jobs`
  String get savedJobs {
    return Intl.message('Saved Jobs', name: 'savedJobs', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `My Career Roadmap`
  String get myCareerRoadmap {
    return Intl.message(
      'My Career Roadmap',
      name: 'myCareerRoadmap',
      desc: '',
      args: [],
    );
  }

  /// `Track your progress and build essential skills`
  String get roadmapSubtitle {
    return Intl.message(
      'Track your progress and build essential skills',
      name: 'roadmapSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `LEARNING TASKS`
  String get learningTasks {
    return Intl.message(
      'LEARNING TASKS',
      name: 'learningTasks',
      desc: '',
      args: [],
    );
  }

  /// `Skill Completed`
  String get skillCompleted {
    return Intl.message(
      'Skill Completed',
      name: 'skillCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Skill In Progress`
  String get skillInProgress {
    return Intl.message(
      'Skill In Progress',
      name: 'skillInProgress',
      desc: '',
      args: [],
    );
  }

  /// `No learning tasks defined for this skill yet.`
  String get noLearningTasks {
    return Intl.message(
      'No learning tasks defined for this skill yet.',
      name: 'noLearningTasks',
      desc: '',
      args: [],
    );
  }

  /// `Tasks completed`
  String get tasksCompleted {
    return Intl.message(
      'Tasks completed',
      name: 'tasksCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Turn your CV into opportunities`
  String get turnCvIntoOpportunities {
    return Intl.message(
      'Turn your CV into opportunities',
      name: 'turnCvIntoOpportunities',
      desc: '',
      args: [],
    );
  }

  /// `See why a job fits you, what you’re missing, and what to do next.`
  String get turnCvIntoOpportunitiesDesc {
    return Intl.message(
      'See why a job fits you, what you’re missing, and what to do next.',
      name: 'turnCvIntoOpportunitiesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Get an explainable match`
  String get getExplainableMatch {
    return Intl.message(
      'Get an explainable match',
      name: 'getExplainableMatch',
      desc: '',
      args: [],
    );
  }

  /// `Not just a score — strengths, gaps, and clear next actions.`
  String get getExplainableMatchDesc {
    return Intl.message(
      'Not just a score — strengths, gaps, and clear next actions.',
      name: 'getExplainableMatchDesc',
      desc: '',
      args: [],
    );
  }

  /// `Setup your career profile`
  String get setupCareerProfile {
    return Intl.message(
      'Setup your career profile',
      name: 'setupCareerProfile',
      desc: '',
      args: [],
    );
  }

  /// `Tell us about your skills and goals to get better recommendations.`
  String get setupCareerProfileDesc {
    return Intl.message(
      'Tell us about your skills and goals to get better recommendations.',
      name: 'setupCareerProfileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Upload your CV for instant AI parsing`
  String get onboardingBullet1 {
    return Intl.message(
      'Upload your CV for instant AI parsing',
      name: 'onboardingBullet1',
      desc: '',
      args: [],
    );
  }

  /// `Select target roles and skills`
  String get onboardingBullet2 {
    return Intl.message(
      'Select target roles and skills',
      name: 'onboardingBullet2',
      desc: '',
      args: [],
    );
  }

  /// `Get matched with high-fit opportunities`
  String get onboardingBullet3 {
    return Intl.message(
      'Get matched with high-fit opportunities',
      name: 'onboardingBullet3',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message('Start', name: 'start', desc: '', args: []);
  }

  /// `Get Started`
  String get getStarted {
    return Intl.message('Get Started', name: 'getStarted', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `Not now`
  String get notNow {
    return Intl.message('Not now', name: 'notNow', desc: '', args: []);
  }

  /// `Enter verification code`
  String get enterVerificationCode {
    return Intl.message(
      'Enter verification code',
      name: 'enterVerificationCode',
      desc: '',
      args: [],
    );
  }

  /// `We sent a 6-digit code to your email.`
  String get sentCodeToEmail {
    return Intl.message(
      'We sent a 6-digit code to your email.',
      name: 'sentCodeToEmail',
      desc: '',
      args: [],
    );
  }

  /// `VERIFICATION CODE`
  String get verificationCodeLabel {
    return Intl.message(
      'VERIFICATION CODE',
      name: 'verificationCodeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message('Verify', name: 'verify', desc: '', args: []);
  }

  /// `Resend code in`
  String get resendCodeIn {
    return Intl.message(
      'Resend code in',
      name: 'resendCodeIn',
      desc: '',
      args: [],
    );
  }

  /// `Resend Code`
  String get resendCode {
    return Intl.message('Resend Code', name: 'resendCode', desc: '', args: []);
  }

  /// `Use a different email`
  String get useDifferentEmail {
    return Intl.message(
      'Use a different email',
      name: 'useDifferentEmail',
      desc: '',
      args: [],
    );
  }

  /// `Invalid verification code`
  String get invalidVerificationCode {
    return Intl.message(
      'Invalid verification code',
      name: 'invalidVerificationCode',
      desc: '',
      args: [],
    );
  }

  /// `s`
  String get secondsSuffix {
    return Intl.message('s', name: 'secondsSuffix', desc: '', args: []);
  }

  /// `Create a new password`
  String get createNewPassword {
    return Intl.message(
      'Create a new password',
      name: 'createNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Choose a strong password you haven’t used before.`
  String get chooseStrongPassword {
    return Intl.message(
      'Choose a strong password you haven’t used before.',
      name: 'chooseStrongPassword',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get newPassword {
    return Intl.message(
      'New password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm new password`
  String get confirmNewPassword {
    return Intl.message(
      'Confirm new password',
      name: 'confirmNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Use at least 8 characters.`
  String get passwordLengthHint {
    return Intl.message(
      'Use at least 8 characters.',
      name: 'passwordLengthHint',
      desc: '',
      args: [],
    );
  }

  /// `Password requirements`
  String get passwordRequirements {
    return Intl.message(
      'Password requirements',
      name: 'passwordRequirements',
      desc: '',
      args: [],
    );
  }

  /// `At least 8 characters`
  String get reqMin8Chars {
    return Intl.message(
      'At least 8 characters',
      name: 'reqMin8Chars',
      desc: '',
      args: [],
    );
  }

  /// `At least one number`
  String get reqAtLeastOneNumber {
    return Intl.message(
      'At least one number',
      name: 'reqAtLeastOneNumber',
      desc: '',
      args: [],
    );
  }

  /// `At least one special character`
  String get reqAtLeastOneSpecial {
    return Intl.message(
      'At least one special character',
      name: 'reqAtLeastOneSpecial',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Reset password`
  String get resetPassword {
    return Intl.message(
      'Reset password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Back to login`
  String get backToLogin {
    return Intl.message(
      'Back to login',
      name: 'backToLogin',
      desc: '',
      args: [],
    );
  }

  /// `Password changed successfully`
  String get passwordChangedSuccessfully {
    return Intl.message(
      'Password changed successfully',
      name: 'passwordChangedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Your password has been changed successfully. You can now log in with your new password.`
  String get passwordChangedSuccessDesc {
    return Intl.message(
      'Your password has been changed successfully. You can now log in with your new password.',
      name: 'passwordChangedSuccessDesc',
      desc: '',
      args: [],
    );
  }

  /// `Hello, {name} 👋`
  String greetingUser(String name) {
    return Intl.message(
      'Hello, $name 👋',
      name: 'greetingUser',
      desc: 'Greeting message displayed on the home screen',
      args: [name],
    );
  }

  /// `Ready to find your next opportunity?`
  String get readyToFindYourNextOpportunity {
    return Intl.message(
      'Ready to find your next opportunity?',
      name: 'readyToFindYourNextOpportunity',
      desc: '',
      args: [],
    );
  }

  /// `Search jobs, companies, or skills`
  String get searchJobs {
    return Intl.message(
      'Search jobs, companies, or skills',
      name: 'searchJobs',
      desc: '',
      args: [],
    );
  }

  /// `We found jobs that match your profile`
  String get jobsMatchYourProfile {
    return Intl.message(
      'We found jobs that match your profile',
      name: 'jobsMatchYourProfile',
      desc: '',
      args: [],
    );
  }

  /// `Explore opportunities based on your skills and career preferences.`
  String get jobsMatchDescription {
    return Intl.message(
      'Explore opportunities based on your skills and career preferences.',
      name: 'jobsMatchDescription',
      desc: '',
      args: [],
    );
  }

  /// `View Matches`
  String get viewMatches {
    return Intl.message(
      'View Matches',
      name: 'viewMatches',
      desc: '',
      args: [],
    );
  }

  /// `Recommended for you`
  String get recommendedForYou {
    return Intl.message(
      'Recommended for you',
      name: 'recommendedForYou',
      desc: '',
      args: [],
    );
  }

  /// `See all`
  String get seeAll {
    return Intl.message('See all', name: 'seeAll', desc: '', args: []);
  }

  /// `Apply Now`
  String get applyNow {
    return Intl.message('Apply Now', name: 'applyNow', desc: '', args: []);
  }

  /// `No jobs found`
  String get noJobsFound {
    return Intl.message(
      'No jobs found',
      name: 'noJobsFound',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Strong Match`
  String get strongMatch {
    return Intl.message(
      'Strong Match',
      name: 'strongMatch',
      desc: '',
      args: [],
    );
  }

  /// `Good Match`
  String get goodMatch {
    return Intl.message('Good Match', name: 'goodMatch', desc: '', args: []);
  }

  /// `matches`
  String get matches {
    return Intl.message('matches', name: 'matches', desc: '', args: []);
  }

  /// `Match`
  String get match {
    return Intl.message('Match', name: 'match', desc: '', args: []);
  }

  /// `Search Jobs`
  String get searchJobsTitle {
    return Intl.message(
      'Search Jobs',
      name: 'searchJobsTitle',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Remote`
  String get remote {
    return Intl.message('Remote', name: 'remote', desc: '', args: []);
  }

  /// `Internship`
  String get internship {
    return Intl.message('Internship', name: 'internship', desc: '', args: []);
  }

  /// `Full-time`
  String get fullTime {
    return Intl.message('Full-time', name: 'fullTime', desc: '', args: []);
  }

  /// `Entry Level`
  String get entryLevel {
    return Intl.message('Entry Level', name: 'entryLevel', desc: '', args: []);
  }

  /// `opportunities`
  String get opportunities {
    return Intl.message(
      'opportunities',
      name: 'opportunities',
      desc: '',
      args: [],
    );
  }

  /// `Most relevant`
  String get mostRelevant {
    return Intl.message(
      'Most relevant',
      name: 'mostRelevant',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Mark all read`
  String get markAllRead {
    return Intl.message(
      'Mark all read',
      name: 'markAllRead',
      desc: '',
      args: [],
    );
  }

  /// `Jobs`
  String get jobs {
    return Intl.message('Jobs', name: 'jobs', desc: '', args: []);
  }

  /// `Applications`
  String get applications {
    return Intl.message(
      'Applications',
      name: 'applications',
      desc: '',
      args: [],
    );
  }

  /// `Roadmap`
  String get roadmap {
    return Intl.message('Roadmap', name: 'roadmap', desc: '', args: []);
  }

  /// `CV`
  String get cv {
    return Intl.message('CV', name: 'cv', desc: '', args: []);
  }

  /// `TODAY`
  String get today {
    return Intl.message('TODAY', name: 'today', desc: '', args: []);
  }

  /// `YESTERDAY`
  String get yesterday {
    return Intl.message('YESTERDAY', name: 'yesterday', desc: '', args: []);
  }

  /// `New jobs match your profile`
  String get newJobsMatchProfile {
    return Intl.message(
      'New jobs match your profile',
      name: 'newJobsMatchProfile',
      desc: '',
      args: [],
    );
  }

  /// `We found 8 Flutter opportunities based on your skills.`
  String get flutterOpportunities {
    return Intl.message(
      'We found 8 Flutter opportunities based on your skills.',
      name: 'flutterOpportunities',
      desc: '',
      args: [],
    );
  }

  /// `10 min ago`
  String get tenMinutesAgo {
    return Intl.message(
      '10 min ago',
      name: 'tenMinutesAgo',
      desc: '',
      args: [],
    );
  }

  /// `View Jobs`
  String get viewJobs {
    return Intl.message('View Jobs', name: 'viewJobs', desc: '', args: []);
  }

  /// `Your roadmap has been updated`
  String get roadmapUpdated {
    return Intl.message(
      'Your roadmap has been updated',
      name: 'roadmapUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Testing is now one of your highest-priority skills.`
  String get testingPrioritySkill {
    return Intl.message(
      'Testing is now one of your highest-priority skills.',
      name: 'testingPrioritySkill',
      desc: '',
      args: [],
    );
  }

  /// `2 hrs ago`
  String get twoHoursAgo {
    return Intl.message('2 hrs ago', name: 'twoHoursAgo', desc: '', args: []);
  }

  /// `View Roadmap`
  String get viewRoadmap {
    return Intl.message(
      'View Roadmap',
      name: 'viewRoadmap',
      desc: '',
      args: [],
    );
  }

  /// `CV analysis completed`
  String get cvAnalysisCompleted {
    return Intl.message(
      'CV analysis completed',
      name: 'cvAnalysisCompleted',
      desc: '',
      args: [],
    );
  }

  /// `We extracted 12 skills and updated your career profile.`
  String get cvAnalysisDescription {
    return Intl.message(
      'We extracted 12 skills and updated your career profile.',
      name: 'cvAnalysisDescription',
      desc: '',
      args: [],
    );
  }

  /// `4 hrs ago`
  String get fourHoursAgo {
    return Intl.message('4 hrs ago', name: 'fourHoursAgo', desc: '', args: []);
  }

  /// `Review CV`
  String get reviewCv {
    return Intl.message('Review CV', name: 'reviewCv', desc: '', args: []);
  }

  /// `Application status updated`
  String get applicationStatusUpdated {
    return Intl.message(
      'Application status updated',
      name: 'applicationStatusUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Your TechNova application is now In Review.`
  String get applicationStatusDescription {
    return Intl.message(
      'Your TechNova application is now In Review.',
      name: 'applicationStatusDescription',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday • 3:45 PM`
  String get yesterdayTime {
    return Intl.message(
      'Yesterday • 3:45 PM',
      name: 'yesterdayTime',
      desc: '',
      args: [],
    );
  }

  /// `View Application`
  String get viewApplication {
    return Intl.message(
      'View Application',
      name: 'viewApplication',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `ACCOUNT`
  String get account {
    return Intl.message('ACCOUNT', name: 'account', desc: '', args: []);
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `PREFERENCES`
  String get preferences {
    return Intl.message('PREFERENCES', name: 'preferences', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `PRIVACY & SUPPORT`
  String get privacyAndSupport {
    return Intl.message(
      'PRIVACY & SUPPORT',
      name: 'privacyAndSupport',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Contact Us`
  String get contactUs {
    return Intl.message('Contact Us', name: 'contactUs', desc: '', args: []);
  }

  /// `Follow Us`
  String get followUs {
    return Intl.message('Follow Us', name: 'followUs', desc: '', args: []);
  }

  /// `Log Out`
  String get logOut {
    return Intl.message('Log Out', name: 'logOut', desc: '', args: []);
  }

  /// `© 2025 SkillMatch. All rights reserved.`
  String get copyright {
    return Intl.message(
      '© 2025 SkillMatch. All rights reserved.',
      name: 'copyright',
      desc: '',
      args: [],
    );
  }

  /// `Job Details`
  String get jobDetails {
    return Intl.message('Job Details', name: 'jobDetails', desc: '', args: []);
  }

  /// `Junior Flutter Developer`
  String get juniorFlutterDeveloper {
    return Intl.message(
      'Junior Flutter Developer',
      name: 'juniorFlutterDeveloper',
      desc: '',
      args: [],
    );
  }

  /// `Cairo`
  String get cairo {
    return Intl.message('Cairo', name: 'cairo', desc: '', args: []);
  }

  /// `0–2 years`
  String get zeroToTwoYears {
    return Intl.message(
      '0–2 years',
      name: 'zeroToTwoYears',
      desc: '',
      args: [],
    );
  }

  /// `Hybrid`
  String get hybrid {
    return Intl.message('Hybrid', name: 'hybrid', desc: '', args: []);
  }

  /// `Posted 2 days ago`
  String get postedTwoDaysAgo {
    return Intl.message(
      'Posted 2 days ago',
      name: 'postedTwoDaysAgo',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get source {
    return Intl.message('Source', name: 'source', desc: '', args: []);
  }

  /// `Application status`
  String get applicationStatus {
    return Intl.message(
      'Application status',
      name: 'applicationStatus',
      desc: '',
      args: [],
    );
  }

  /// `Applied`
  String get applied {
    return Intl.message('Applied', name: 'applied', desc: '', args: []);
  }

  /// `2 days ago`
  String get twoDaysAgo {
    return Intl.message('2 days ago', name: 'twoDaysAgo', desc: '', args: []);
  }

  /// `View timeline`
  String get viewTimeline {
    return Intl.message(
      'View timeline',
      name: 'viewTimeline',
      desc: '',
      args: [],
    );
  }

  /// `Your Match`
  String get yourMatch {
    return Intl.message('Your Match', name: 'yourMatch', desc: '', args: []);
  }

  /// `You match 7 of 9 important requirements.`
  String get matchSevenOfNine {
    return Intl.message(
      'You match 7 of 9 important requirements.',
      name: 'matchSevenOfNine',
      desc: '',
      args: [],
    );
  }

  /// `You’re a good fit for this role. Your Flutter and API experience match the core requirements, but testing and CI/CD are important gaps.`
  String get matchExplanation {
    return Intl.message(
      'You’re a good fit for this role. Your Flutter and API experience match the core requirements, but testing and CI/CD are important gaps.',
      name: 'matchExplanation',
      desc: '',
      args: [],
    );
  }

  /// `What you already match`
  String get whatYouAlreadyMatch {
    return Intl.message(
      'What you already match',
      name: 'whatYouAlreadyMatch',
      desc: '',
      args: [],
    );
  }

  /// `From your CV`
  String get fromYourCv {
    return Intl.message('From your CV', name: 'fromYourCv', desc: '', args: []);
  }

  /// `Found in your CV and projects`
  String get foundInCvAndProjects {
    return Intl.message(
      'Found in your CV and projects',
      name: 'foundInCvAndProjects',
      desc: '',
      args: [],
    );
  }

  /// `Used in 2 projects`
  String get usedInTwoProjects {
    return Intl.message(
      'Used in 2 projects',
      name: 'usedInTwoProjects',
      desc: '',
      args: [],
    );
  }

  /// `Found in your skills`
  String get foundInYourSkills {
    return Intl.message(
      'Found in your skills',
      name: 'foundInYourSkills',
      desc: '',
      args: [],
    );
  }

  /// `Experience with Bloc`
  String get experienceWithBloc {
    return Intl.message(
      'Experience with Bloc',
      name: 'experienceWithBloc',
      desc: '',
      args: [],
    );
  }

  /// `Skills to improve`
  String get skillsToImprove {
    return Intl.message(
      'Skills to improve',
      name: 'skillsToImprove',
      desc: '',
      args: [],
    );
  }

  /// `Required for this role`
  String get requiredForThisRole {
    return Intl.message(
      'Required for this role',
      name: 'requiredForThisRole',
      desc: '',
      args: [],
    );
  }

  /// `Mentioned in job requirements`
  String get mentionedInJobRequirements {
    return Intl.message(
      'Mentioned in job requirements',
      name: 'mentionedInJobRequirements',
      desc: '',
      args: [],
    );
  }

  /// `Helpful advantage`
  String get helpfulAdvantage {
    return Intl.message(
      'Helpful advantage',
      name: 'helpfulAdvantage',
      desc: '',
      args: [],
    );
  }

  /// `High priority`
  String get highPriority {
    return Intl.message(
      'High priority',
      name: 'highPriority',
      desc: '',
      args: [],
    );
  }

  /// `Nice to have`
  String get niceToHave {
    return Intl.message('Nice to have', name: 'niceToHave', desc: '', args: []);
  }

  /// `Job requirements`
  String get jobRequirements {
    return Intl.message(
      'Job requirements',
      name: 'jobRequirements',
      desc: '',
      args: [],
    );
  }

  /// `Required skills`
  String get requiredSkills {
    return Intl.message(
      'Required skills',
      name: 'requiredSkills',
      desc: '',
      args: [],
    );
  }

  /// `Preferred`
  String get preferred {
    return Intl.message('Preferred', name: 'preferred', desc: '', args: []);
  }

  /// `Experience`
  String get experience {
    return Intl.message('Experience', name: 'experience', desc: '', args: []);
  }

  /// `Education`
  String get education {
    return Intl.message('Education', name: 'education', desc: '', args: []);
  }

  /// `CS or related`
  String get csOrRelated {
    return Intl.message(
      'CS or related',
      name: 'csOrRelated',
      desc: '',
      args: [],
    );
  }

  /// `View full job description`
  String get viewFullJobDescription {
    return Intl.message(
      'View full job description',
      name: 'viewFullJobDescription',
      desc: '',
      args: [],
    );
  }

  /// `Want to improve your match?`
  String get wantToImproveYourMatch {
    return Intl.message(
      'Want to improve your match?',
      name: 'wantToImproveYourMatch',
      desc: '',
      args: [],
    );
  }

  /// `Focus on 2 high-priority skills`
  String get focusOnTwoHighPrioritySkills {
    return Intl.message(
      'Focus on 2 high-priority skills',
      name: 'focusOnTwoHighPrioritySkills',
      desc: '',
      args: [],
    );
  }

  /// `Build a personalized roadmap to work on Testing and CI/CD and become a stronger candidate for this role.`
  String get roadmapMatchDescription {
    return Intl.message(
      'Build a personalized roadmap to work on Testing and CI/CD and become a stronger candidate for this role.',
      name: 'roadmapMatchDescription',
      desc: '',
      args: [],
    );
  }

  /// `Build My Roadmap`
  String get buildMyRoadmap {
    return Intl.message(
      'Build My Roadmap',
      name: 'buildMyRoadmap',
      desc: '',
      args: [],
    );
  }

  /// `Your roadmap will be based on this job and your current skills.`
  String get roadmapBasedOnJob {
    return Intl.message(
      'Your roadmap will be based on this job and your current skills.',
      name: 'roadmapBasedOnJob',
      desc: '',
      args: [],
    );
  }

  /// `Already submitted`
  String get alreadySubmitted {
    return Intl.message(
      'Already submitted',
      name: 'alreadySubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Application`
  String get application {
    return Intl.message('Application', name: 'application', desc: '', args: []);
  }

  /// `Apply for Role`
  String get applyForRole {
    return Intl.message(
      'Apply for Role',
      name: 'applyForRole',
      desc: '',
      args: [],
    );
  }

  /// `of`
  String get stepOf {
    return Intl.message('of', name: 'stepOf', desc: '', args: []);
  }

  /// `Your Information`
  String get yourInformation {
    return Intl.message(
      'Your Information',
      name: 'yourInformation',
      desc: '',
      args: [],
    );
  }

  /// `Review your information before continuing.`
  String get reviewInformationBeforeContinuing {
    return Intl.message(
      'Review your information before continuing.',
      name: 'reviewInformationBeforeContinuing',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get fullName {
    return Intl.message('Full Name', name: 'fullName', desc: '', args: []);
  }

  /// `Email Address`
  String get emailAddress {
    return Intl.message(
      'Email Address',
      name: 'emailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `CV / Résumé`
  String get cvResume {
    return Intl.message('CV / Résumé', name: 'cvResume', desc: '', args: []);
  }

  /// `Updated 5 days ago`
  String get updatedFiveDaysAgo {
    return Intl.message(
      'Updated 5 days ago',
      name: 'updatedFiveDaysAgo',
      desc: '',
      args: [],
    );
  }

  /// `Ready`
  String get ready {
    return Intl.message('Ready', name: 'ready', desc: '', args: []);
  }

  /// `View`
  String get view {
    return Intl.message('View', name: 'view', desc: '', args: []);
  }

  /// `Change`
  String get change {
    return Intl.message('Change', name: 'change', desc: '', args: []);
  }

  /// `Cover Note`
  String get coverNote {
    return Intl.message('Cover Note', name: 'coverNote', desc: '', args: []);
  }

  /// `Optional`
  String get optional {
    return Intl.message('Optional', name: 'optional', desc: '', args: []);
  }

  /// `Add a short message about why you’re interested in this role.`
  String get coverNoteHint {
    return Intl.message(
      'Add a short message about why you’re interested in this role.',
      name: 'coverNoteHint',
      desc: '',
      args: [],
    );
  }

  /// `characters`
  String get characters {
    return Intl.message('characters', name: 'characters', desc: '', args: []);
  }

  /// `Continue`
  String get continueText {
    return Intl.message('Continue', name: 'continueText', desc: '', args: []);
  }

  /// `Next: Application questions`
  String get nextApplicationQuestions {
    return Intl.message(
      'Next: Application questions',
      name: 'nextApplicationQuestions',
      desc: '',
      args: [],
    );
  }

  /// `0–2 yrs exp`
  String get zeroToTwoYearsExp {
    return Intl.message(
      '0–2 yrs exp',
      name: 'zeroToTwoYearsExp',
      desc: '',
      args: [],
    );
  }

  /// `Application Questions`
  String get applicationQuestions {
    return Intl.message(
      'Application Questions',
      name: 'applicationQuestions',
      desc: '',
      args: [],
    );
  }

  /// `A few more questions`
  String get aFewMoreQuestions {
    return Intl.message(
      'A few more questions',
      name: 'aFewMoreQuestions',
      desc: '',
      args: [],
    );
  }

  /// `Answer the employer’s questions to continue your application.`
  String get answerEmployerQuestions {
    return Intl.message(
      'Answer the employer’s questions to continue your application.',
      name: 'answerEmployerQuestions',
      desc: '',
      args: [],
    );
  }

  /// `Why are you interested in this role? *`
  String get whyInterestedRequired {
    return Intl.message(
      'Why are you interested in this role? *',
      name: 'whyInterestedRequired',
      desc: '',
      args: [],
    );
  }

  /// `Describe what excites you about TechNova and this position...`
  String get whyInterestedHint {
    return Intl.message(
      'Describe what excites you about TechNova and this position...',
      name: 'whyInterestedHint',
      desc: '',
      args: [],
    );
  }

  /// `What is your expected monthly salary?`
  String get expectedMonthlySalary {
    return Intl.message(
      'What is your expected monthly salary?',
      name: 'expectedMonthlySalary',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 24,000`
  String get salaryHint {
    return Intl.message('e.g. 24,000', name: 'salaryHint', desc: '', args: []);
  }

  /// `Enter your expected gross monthly salary.`
  String get salaryHelper {
    return Intl.message(
      'Enter your expected gross monthly salary.',
      name: 'salaryHelper',
      desc: '',
      args: [],
    );
  }

  /// `Which work mode do you prefer?`
  String get preferredWorkMode {
    return Intl.message(
      'Which work mode do you prefer?',
      name: 'preferredWorkMode',
      desc: '',
      args: [],
    );
  }

  /// `Popular`
  String get popular {
    return Intl.message('Popular', name: 'popular', desc: '', args: []);
  }

  /// `On-site`
  String get onSite {
    return Intl.message('On-site', name: 'onSite', desc: '', args: []);
  }

  /// `Which technologies have you worked with?`
  String get technologiesWorkedWith {
    return Intl.message(
      'Which technologies have you worked with?',
      name: 'technologiesWorkedWith',
      desc: '',
      args: [],
    );
  }

  /// `Supporting Document (Optional)`
  String get supportingDocumentOptional {
    return Intl.message(
      'Supporting Document (Optional)',
      name: 'supportingDocumentOptional',
      desc: '',
      args: [],
    );
  }

  /// `Upload File`
  String get uploadFile {
    return Intl.message('Upload File', name: 'uploadFile', desc: '', args: []);
  }

  /// `PDF or DOCX • Max 5 MB`
  String get uploadFileHint {
    return Intl.message(
      'PDF or DOCX • Max 5 MB',
      name: 'uploadFileHint',
      desc: '',
      args: [],
    );
  }

  /// `Portfolio or Project Link (Optional)`
  String get portfolioOrProjectLink {
    return Intl.message(
      'Portfolio or Project Link (Optional)',
      name: 'portfolioOrProjectLink',
      desc: '',
      args: [],
    );
  }

  /// `https://github.com/username or portfolio`
  String get portfolioLinkHint {
    return Intl.message(
      'https://github.com/username or portfolio',
      name: 'portfolioLinkHint',
      desc: '',
      args: [],
    );
  }

  /// `Review Application`
  String get reviewApplication {
    return Intl.message(
      'Review Application',
      name: 'reviewApplication',
      desc: '',
      args: [],
    );
  }

  /// `You will review all details before final submission.`
  String get reviewBeforeSubmission {
    return Intl.message(
      'You will review all details before final submission.',
      name: 'reviewBeforeSubmission',
      desc: '',
      args: [],
    );
  }

  /// `Applying for`
  String get applyingFor {
    return Intl.message(
      'Applying for',
      name: 'applyingFor',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Review before submitting`
  String get reviewBeforeSubmitting {
    return Intl.message(
      'Review before submitting',
      name: 'reviewBeforeSubmitting',
      desc: '',
      args: [],
    );
  }

  /// `Make sure your information is correct. You can go back and edit anything before submitting.`
  String get reviewBeforeSubmittingDescription {
    return Intl.message(
      'Make sure your information is correct. You can go back and edit anything before submitting.',
      name: 'reviewBeforeSubmittingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Step 3 of 3`
  String get stepThreeOfThree {
    return Intl.message(
      'Step 3 of 3',
      name: 'stepThreeOfThree',
      desc: '',
      args: [],
    );
  }

  /// `Final Confirmation`
  String get finalConfirmation {
    return Intl.message(
      'Final Confirmation',
      name: 'finalConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `No cover note added`
  String get noCoverNoteAdded {
    return Intl.message(
      'No cover note added',
      name: 'noCoverNoteAdded',
      desc: '',
      args: [],
    );
  }

  /// `Preferred work mode`
  String get preferredWorkModeLabel {
    return Intl.message(
      'Preferred work mode',
      name: 'preferredWorkModeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Expected salary`
  String get expectedSalary {
    return Intl.message(
      'Expected salary',
      name: 'expectedSalary',
      desc: '',
      args: [],
    );
  }

  /// `Technologies`
  String get technologies {
    return Intl.message(
      'Technologies',
      name: 'technologies',
      desc: '',
      args: [],
    );
  }

  /// `By submitting, you confirm that the information provided is accurate and complies with our community guidelines.`
  String get submissionConfirmationNotice {
    return Intl.message(
      'By submitting, you confirm that the information provided is accurate and complies with our community guidelines.',
      name: 'submissionConfirmationNotice',
      desc: '',
      args: [],
    );
  }

  /// `Submit Application`
  String get submitApplication {
    return Intl.message(
      'Submit Application',
      name: 'submitApplication',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `STEP 4 OF 4 • CONFIRMATION`
  String get stepFourConfirmation {
    return Intl.message(
      'STEP 4 OF 4 • CONFIRMATION',
      name: 'stepFourConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Application submitted!`
  String get applicationSubmitted {
    return Intl.message(
      'Application submitted!',
      name: 'applicationSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Your application for`
  String get yourApplicationFor {
    return Intl.message(
      'Your application for',
      name: 'yourApplicationFor',
      desc: '',
      args: [],
    );
  }

  /// `at`
  String get at {
    return Intl.message('at', name: 'at', desc: '', args: []);
  }

  /// `has been submitted successfully.`
  String get submittedSuccessfully {
    return Intl.message(
      'has been submitted successfully.',
      name: 'submittedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Timeline`
  String get timeline {
    return Intl.message('Timeline', name: 'timeline', desc: '', args: []);
  }

  /// `Submitted just now`
  String get submittedJustNow {
    return Intl.message(
      'Submitted just now',
      name: 'submittedJustNow',
      desc: '',
      args: [],
    );
  }

  /// `Recruiter review`
  String get recruiterReview {
    return Intl.message(
      'Recruiter review',
      name: 'recruiterReview',
      desc: '',
      args: [],
    );
  }

  /// `Within 3 business days`
  String get withinThreeBusinessDays {
    return Intl.message(
      'Within 3 business days',
      name: 'withinThreeBusinessDays',
      desc: '',
      args: [],
    );
  }

  /// `Track Application`
  String get trackApplication {
    return Intl.message(
      'Track Application',
      name: 'trackApplication',
      desc: '',
      args: [],
    );
  }

  /// `Back to Jobs`
  String get backToJobs {
    return Intl.message('Back to Jobs', name: 'backToJobs', desc: '', args: []);
  }

  /// `Tracking Application`
  String get trackingApplication {
    return Intl.message(
      'Tracking Application',
      name: 'trackingApplication',
      desc: '',
      args: [],
    );
  }

  /// `View Job`
  String get viewJob {
    return Intl.message('View Job', name: 'viewJob', desc: '', args: []);
  }

  /// `CURRENT STATUS`
  String get currentStatus {
    return Intl.message(
      'CURRENT STATUS',
      name: 'currentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Submitted today at 10:32 AM`
  String get submittedTodayTime {
    return Intl.message(
      'Submitted today at 10:32 AM',
      name: 'submittedTodayTime',
      desc: '',
      args: [],
    );
  }

  /// `Application Timeline`
  String get applicationTimeline {
    return Intl.message(
      'Application Timeline',
      name: 'applicationTimeline',
      desc: '',
      args: [],
    );
  }

  /// `Today • 10:32 AM`
  String get todayAtTime {
    return Intl.message(
      'Today • 10:32 AM',
      name: 'todayAtTime',
      desc: '',
      args: [],
    );
  }

  /// `In Review`
  String get inReview {
    return Intl.message('In Review', name: 'inReview', desc: '', args: []);
  }

  /// `Pending employer screening`
  String get pendingEmployerScreening {
    return Intl.message(
      'Pending employer screening',
      name: 'pendingEmployerScreening',
      desc: '',
      args: [],
    );
  }

  /// `Interview`
  String get interview {
    return Intl.message('Interview', name: 'interview', desc: '', args: []);
  }

  /// `Technical & culture fit stage`
  String get technicalCultureFitStage {
    return Intl.message(
      'Technical & culture fit stage',
      name: 'technicalCultureFitStage',
      desc: '',
      args: [],
    );
  }

  /// `Offer`
  String get offer {
    return Intl.message('Offer', name: 'offer', desc: '', args: []);
  }

  /// `Final decision and onboarding`
  String get finalDecisionAndOnboarding {
    return Intl.message(
      'Final decision and onboarding',
      name: 'finalDecisionAndOnboarding',
      desc: '',
      args: [],
    );
  }

  /// `Keep your tracker updated when you hear back from the employer.`
  String get keepTrackerUpdated {
    return Intl.message(
      'Keep your tracker updated when you hear back from the employer.',
      name: 'keepTrackerUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Update Status`
  String get updateStatus {
    return Intl.message(
      'Update Status',
      name: 'updateStatus',
      desc: '',
      args: [],
    );
  }

  /// `Application Details`
  String get applicationDetails {
    return Intl.message(
      'Application Details',
      name: 'applicationDetails',
      desc: '',
      args: [],
    );
  }

  /// `Application method`
  String get applicationMethod {
    return Intl.message(
      'Application method',
      name: 'applicationMethod',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message('Notes', name: 'notes', desc: '', args: []);
  }

  /// `Edit Note`
  String get editNote {
    return Intl.message('Edit Note', name: 'editNote', desc: '', args: []);
  }

  /// `Waiting for a response from the recruiter.`
  String get waitingForRecruiterResponse {
    return Intl.message(
      'Waiting for a response from the recruiter.',
      name: 'waitingForRecruiterResponse',
      desc: '',
      args: [],
    );
  }

  /// `Need help with next steps?`
  String get needHelpWithNextSteps {
    return Intl.message(
      'Need help with next steps?',
      name: 'needHelpWithNextSteps',
      desc: '',
      args: [],
    );
  }

  /// `Ask your Career Mentor what to focus on while you wait.`
  String get askCareerMentorDescription {
    return Intl.message(
      'Ask your Career Mentor what to focus on while you wait.',
      name: 'askCareerMentorDescription',
      desc: '',
      args: [],
    );
  }

  /// `Ask Chat Bot`
  String get askChatBot {
    return Intl.message('Ask Chat Bot', name: 'askChatBot', desc: '', args: []);
  }

  /// `Withdraw Application`
  String get withdrawApplication {
    return Intl.message(
      'Withdraw Application',
      name: 'withdrawApplication',
      desc: '',
      args: [],
    );
  }

  /// `Upload your CV`
  String get uploadYourCv {
    return Intl.message(
      'Upload your CV',
      name: 'uploadYourCv',
      desc: '',
      args: [],
    );
  }

  /// `PDF or DOCX • Max 5 MB`
  String get cvUploadRequirements {
    return Intl.message(
      'PDF or DOCX • Max 5 MB',
      name: 'cvUploadRequirements',
      desc: '',
      args: [],
    );
  }

  /// `Choose File`
  String get chooseFile {
    return Intl.message('Choose File', name: 'chooseFile', desc: '', args: []);
  }

  /// `No file selected`
  String get noFileSelected {
    return Intl.message(
      'No file selected',
      name: 'noFileSelected',
      desc: '',
      args: [],
    );
  }

  /// `View CV`
  String get viewCv {
    return Intl.message('View CV', name: 'viewCv', desc: '', args: []);
  }

  /// `Replace CV`
  String get replaceCv {
    return Intl.message('Replace CV', name: 'replaceCv', desc: '', args: []);
  }

  /// `Uploaded`
  String get uploaded {
    return Intl.message('Uploaded', name: 'uploaded', desc: '', args: []);
  }

  /// `Analyzing`
  String get analyzing {
    return Intl.message('Analyzing', name: 'analyzing', desc: '', args: []);
  }

  /// `Analyzed`
  String get analyzed {
    return Intl.message('Analyzed', name: 'analyzed', desc: '', args: []);
  }

  /// `Failed`
  String get failed {
    return Intl.message('Failed', name: 'failed', desc: '', args: []);
  }

  /// `Updated just now`
  String get updatedJustNow {
    return Intl.message(
      'Updated just now',
      name: 'updatedJustNow',
      desc: '',
      args: [],
    );
  }

  /// `Good`
  String get good {
    return Intl.message('Good', name: 'good', desc: '', args: []);
  }

  /// `AI Assistant`
  String get aiAssistant {
    return Intl.message(
      'AI Assistant',
      name: 'aiAssistant',
      desc: '',
      args: [],
    );
  }

  /// `New Chat`
  String get newChat {
    return Intl.message('New Chat', name: 'newChat', desc: '', args: []);
  }

  /// `Ask anything...`
  String get askAnything {
    return Intl.message(
      'Ask anything...',
      name: 'askAnything',
      desc: '',
      args: [],
    );
  }

  /// `Chat History`
  String get chatHistory {
    return Intl.message(
      'Chat History',
      name: 'chatHistory',
      desc: '',
      args: [],
    );
  }

  /// `How can I help you today?`
  String get howCanIHelpYouToday {
    return Intl.message(
      'How can I help you today?',
      name: 'howCanIHelpYouToday',
      desc: '',
      args: [],
    );
  }

  /// `No conversations yet`
  String get noConversationsYet {
    return Intl.message(
      'No conversations yet',
      name: 'noConversationsYet',
      desc: '',
      args: [],
    );
  }

  /// `Start your first conversation below`
  String get startFirstConversation {
    return Intl.message(
      'Start your first conversation below',
      name: 'startFirstConversation',
      desc: '',
      args: [],
    );
  }

  /// `Older`
  String get older {
    return Intl.message('Older', name: 'older', desc: '', args: []);
  }

  /// `Failed to send message. Please try again.`
  String get failedToSendMessage {
    return Intl.message(
      'Failed to send message. Please try again.',
      name: 'failedToSendMessage',
      desc: '',
      args: [],
    );
  }

  /// `AI is thinking...`
  String get aiIsTyping {
    return Intl.message(
      'AI is thinking...',
      name: 'aiIsTyping',
      desc: '',
      args: [],
    );
  }

  /// `Explain Flutter BLoC pattern`
  String get chatSuggestion1 {
    return Intl.message(
      'Explain Flutter BLoC pattern',
      name: 'chatSuggestion1',
      desc: '',
      args: [],
    );
  }

  /// `Help me prepare for an interview`
  String get chatSuggestion2 {
    return Intl.message(
      'Help me prepare for an interview',
      name: 'chatSuggestion2',
      desc: '',
      args: [],
    );
  }

  /// `Review my career roadmap`
  String get chatSuggestion3 {
    return Intl.message(
      'Review my career roadmap',
      name: 'chatSuggestion3',
      desc: '',
      args: [],
    );
  }

  /// `What skills should I learn next?`
  String get chatSuggestion4 {
    return Intl.message(
      'What skills should I learn next?',
      name: 'chatSuggestion4',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get copiedToClipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'copiedToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Suggested Questions`
  String get suggestedQuestions {
    return Intl.message(
      'Suggested Questions',
      name: 'suggestedQuestions',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to clear all chats? This action cannot be undone.`
  String get confirmClearAllChats {
    return Intl.message(
      'Are you sure you want to clear all chats? This action cannot be undone.',
      name: 'confirmClearAllChats',
      desc: '',
      args: [],
    );
  }

  /// `Clear All Chats`
  String get clearAllChats {
    return Intl.message(
      'Clear All Chats',
      name: 'clearAllChats',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Clear`
  String get clear {
    return Intl.message('Clear', name: 'clear', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Are you sure you want to delete this chat? This action cannot be undone.`
  String get confirmDeleteChat {
    return Intl.message(
      'Are you sure you want to delete this chat? This action cannot be undone.',
      name: 'confirmDeleteChat',
      desc: '',
      args: [],
    );
  }

  /// `Delete Chat`
  String get deleteChat {
    return Intl.message('Delete Chat', name: 'deleteChat', desc: '', args: []);
  }

  /// `Previous 7 days`
  String get previous7Days {
    return Intl.message(
      'Previous 7 days',
      name: 'previous7Days',
      desc: '',
      args: [],
    );
  }

  /// `Verifying…`
  String get otpVerifying {
    return Intl.message('Verifying…', name: 'otpVerifying', desc: '', args: []);
  }

  /// `That code didn't match. Check the message and try again.`
  String get otpCodeDidNotMatch {
    return Intl.message(
      'That code didn\'t match. Check the message and try again.',
      name: 'otpCodeDidNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Enter your email address`
  String get emailHint {
    return Intl.message(
      'Enter your email address',
      name: 'emailHint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Enter your password`
  String get passwordHint {
    return Intl.message(
      'Enter your password',
      name: 'passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Keep me signed in`
  String get keepMeSignedIn {
    return Intl.message(
      'Keep me signed in',
      name: 'keepMeSignedIn',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get or {
    return Intl.message('or', name: 'or', desc: '', args: []);
  }

  /// `Continue with Google`
  String get registerWithGoogle {
    return Intl.message(
      'Continue with Google',
      name: 'registerWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `New here?`
  String get newHere {
    return Intl.message('New here?', name: 'newHere', desc: '', args: []);
  }

  /// `Already have an account?`
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Enter your phone number`
  String get phoneHint {
    return Intl.message(
      'Enter your phone number',
      name: 'phoneHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Re-enter your password`
  String get confirmPasswordHint {
    return Intl.message(
      'Re-enter your password',
      name: 'confirmPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Terms & Conditions`
  String get termsAndConditions {
    return Intl.message(
      'Terms & Conditions',
      name: 'termsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `Complete Registration`
  String get completeRegistration {
    return Intl.message(
      'Complete Registration',
      name: 'completeRegistration',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back!`
  String get welcomeBack {
    return Intl.message(
      'Welcome Back!',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Your smart career discovery platform`
  String get smartCareerDiscoveryPlatform {
    return Intl.message(
      'Your smart career discovery platform',
      name: 'smartCareerDiscoveryPlatform',
      desc: '',
      args: [],
    );
  }

  /// `Candidate Profile`
  String get candidateProfile {
    return Intl.message(
      'Candidate Profile',
      name: 'candidateProfile',
      desc: '',
      args: [],
    );
  }

  /// `Listening...`
  String get listening {
    return Intl.message('Listening...', name: 'listening', desc: '', args: []);
  }

  /// `Speech recognition unavailable`
  String get speechUnavailable {
    return Intl.message(
      'Speech recognition unavailable',
      name: 'speechUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Microphone permission denied`
  String get micPermissionDenied {
    return Intl.message(
      'Microphone permission denied',
      name: 'micPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Speech recognition error`
  String get speechError {
    return Intl.message(
      'Speech recognition error',
      name: 'speechError',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Regenerate`
  String get regenerate {
    return Intl.message('Regenerate', name: 'regenerate', desc: '', args: []);
  }

  /// `New messages`
  String get newMessages {
    return Intl.message(
      'New messages',
      name: 'newMessages',
      desc: '',
      args: [],
    );
  }

  /// `Delete all conversations?`
  String get deleteAllConversations {
    return Intl.message(
      'Delete all conversations?',
      name: 'deleteAllConversations',
      desc: '',
      args: [],
    );
  }

  /// `This action can't be undone.`
  String get undoWarning {
    return Intl.message(
      'This action can\'t be undone.',
      name: 'undoWarning',
      desc: '',
      args: [],
    );
  }

  /// `Ask me anything about your career, jobs, interviews, or professional growth.`
  String get chatEmptySubtitle {
    return Intl.message(
      'Ask me anything about your career, jobs, interviews, or professional growth.',
      name: 'chatEmptySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get listeningDone {
    return Intl.message('Done', name: 'listeningDone', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
