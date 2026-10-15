import 'dart:typed_data';

import 'package:MatchIn/core/cache/cache_key.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source_impl.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_upload_receipt_model.dart';
import 'package:MatchIn/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNetwork extends Fake implements NetworkInfo {
  bool online = true;

  @override
  Future<bool> get isConnected async => online;
}

class _FakeProfileRemote extends Fake implements ProfileRemoteDataSource {
  CandidateProfileModel? profileToReturn;
  CvUploadReceiptModel? receiptToReturn;
  int uploadCalls = 0;

  @override
  Future<CandidateProfileModel> getCandidateProfile() async {
    return profileToReturn!;
  }

  @override
  Future<CvUploadReceiptModel?> uploadCv(CvUploadInput input) async {
    uploadCalls++;
    return receiptToReturn;
  }
}

CandidateProfileModel _profile({List<Map<String, dynamic>>? cvDocs}) {
  final json = <String, dynamic>{
    'profile_exists': true,
    'user': const {
      'id': 7,
      'name': 'Layla Hassan',
      'email': 'layla@example.com',
      'role': 'candidate',
      'is_active': true,
    },
    'profile': const {'id': 1, 'job_title': 'Backend Developer'},
  };
  final docs = cvDocs;
  if (docs != null) {
    json['cvDocuments'] = docs;
  }
  return CandidateProfileModel.fromJson(json);
}

Map<String, dynamic> _cvDoc({required int id, required String name}) => {
  'id': id,
  'file_name': name,
  'is_current': true,
  'status': 'completed',
};

CvUploadInput _input([String name = 'my-cv.pdf']) => CvUploadInput(
  fileName: name,
  extension: 'pdf',
  sizeBytes: 4,
  bytes: Uint8List.fromList([1, 2, 3, 4]),
);

void main() {
  late SharedPreferencesHelper helper;
  late ProfileLocalDataSource local;
  late _FakeProfileRemote remote;
  late _FakeNetwork network;
  late ProfileRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    helper = SharedPreferencesHelper(preferences: prefs);
    local = ProfileLocalDataSourceImpl(sharedPreferencesHelper: helper);
    remote = _FakeProfileRemote();
    network = _FakeNetwork();
    repository = ProfileRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: network,
    );
    await helper.saveData(key: CacheKey.id, value: 7);
  });

  group('CV offline-first sync', () {
    test('offline upload stores pending and reports offline', () async {
      network.online = false;

      final result = await repository.uploadCv(_input());
      expect(result.isLeft(), isTrue);

      final pending = await repository.getPendingCvUpload();
      expect(
        pending.fold((_) => null, (value) => value?.fileName),
        'my-cv.pdf',
      );

      final localFile = await repository.getLocalCvFile();
      expect(localFile.fold((_) => null, (file) => file?.bytes), isNotNull);
      expect(remote.uploadCalls, 0);
    });

    test('successful upload resolves the CV even when GET lags', () async {
      remote.receiptToReturn = const CvUploadReceiptModel(
        id: 2,
        version: 2,
        status: 'processing',
      );

      final upload = await repository.uploadCv(_input());
      expect(upload.isRight(), isTrue);

      // Backend read still has no CV: the marker fills the gap.
      remote.profileToReturn = _profile();
      final profile = await repository.getCandidateProfile();
      final document = profile.fold((_) => null, (value) => value.cvDocument);
      expect(document, isNotNull);
      expect(document!.fileName, 'my-cv.pdf');

      // Restart: the cached read still resolves the uploaded CV.
      final cached = await repository.getCachedCandidateProfile();
      expect(
        cached.fold((_) => null, (value) => value?.cvDocument?.fileName),
        'my-cv.pdf',
      );
    });

    test('marker clears once the backend serves the uploaded CV', () async {
      remote.receiptToReturn = const CvUploadReceiptModel(
        id: 2,
        version: 2,
        status: 'processing',
      );
      await repository.uploadCv(_input());

      remote.profileToReturn = _profile(
        cvDocs: [_cvDoc(id: 2, name: 'server-cv.pdf')],
      );
      final profile = await repository.getCandidateProfile();
      expect(
        profile.fold((_) => null, (value) => value.cvDocument?.fileName),
        'server-cv.pdf',
      );
      expect(await local.getUploadedCvMarker(), isNull);
    });

    test('stale backend CV does not wipe a newer upload', () async {
      remote.receiptToReturn = const CvUploadReceiptModel(id: 9);
      await repository.uploadCv(_input('new-cv.pdf'));

      remote.profileToReturn = _profile(
        cvDocs: [_cvDoc(id: 1, name: 'old-cv.pdf')],
      );
      final profile = await repository.getCandidateProfile();
      expect(
        profile.fold((_) => null, (value) => value.cvDocument?.fileName),
        'new-cv.pdf',
      );
      expect(await local.getUploadedCvMarker(), isNotNull);
    });

    test('pending offline file wins over a stale remote CV', () async {
      remote.profileToReturn = _profile(
        cvDocs: [_cvDoc(id: 1, name: 'old-cv.pdf')],
      );
      await repository.getCandidateProfile();

      network.online = false;
      await repository.uploadCv(_input('offline-cv.pdf'));

      final profile = await repository.getCandidateProfile();
      expect(
        profile.fold((_) => null, (value) => value.cvDocument?.fileName),
        'offline-cv.pdf',
      );
    });

    test('retryPending uploads the stored file and clears it', () async {
      network.online = false;
      await repository.uploadCv(_input());
      network.online = true;
      remote.receiptToReturn = const CvUploadReceiptModel(id: 3);

      final retry = await repository.retryPendingCvUpload();
      expect(retry.isRight(), isTrue);
      expect(remote.uploadCalls, 1);

      final pending = await repository.getPendingCvUpload();
      expect(pending.fold((_) => 'x', (value) => value), isNull);
    });

    test('retryPending without stored file reports cache failure', () async {
      final retry = await repository.retryPendingCvUpload();
      expect(retry.isLeft(), isTrue);
      expect(
        retry.fold((failure) => failure, (_) => null),
        isA<CacheFailure>(),
      );
    });

    test('CV records are isolated per authenticated user', () async {
      network.online = false;
      await repository.uploadCv(_input());

      await helper.saveData(key: CacheKey.id, value: 9);
      final otherPending = await repository.getPendingCvUpload();
      expect(otherPending.fold((_) => 'x', (value) => value), isNull);
      final otherFile = await repository.getLocalCvFile();
      expect(otherFile.fold((_) => 'x', (value) => value), isNull);

      await helper.saveData(key: CacheKey.id, value: 7);
      final ownPending = await repository.getPendingCvUpload();
      expect(
        ownPending.fold((_) => null, (value) => value?.fileName),
        'my-cv.pdf',
      );
    });

    test('failed replacement keeps the previously uploaded CV', () async {
      remote.receiptToReturn = const CvUploadReceiptModel(id: 2);
      await repository.uploadCv(_input('first-cv.pdf'));

      remote.profileToReturn = _profile(
        cvDocs: [_cvDoc(id: 2, name: 'first-cv.pdf')],
      );
      final profile = await repository.getCandidateProfile();
      expect(
        profile.fold((_) => null, (value) => value.cvDocument?.fileName),
        'first-cv.pdf',
      );
    });

    test('receipt-less replacement keeps the new name until the backend catches up', () async {
      remote.receiptToReturn = null;
      await repository.uploadCv(_input('new-cv.pdf'));

      // Backend still serves the older document: the newer local
      // intent wins instead of being discarded.
      remote.profileToReturn = _profile(
        cvDocs: [_cvDoc(id: 1, name: 'old-cv.pdf')],
      );
      final lagging = await repository.getCandidateProfile();
      expect(
        lagging.fold((_) => null, (value) => value.cvDocument?.fileName),
        'new-cv.pdf',
      );

      // Once the backend serves the uploaded filename, the marker
      // clears and the served document is used.
      remote.profileToReturn = _profile(
        cvDocs: [_cvDoc(id: 1, name: 'new-cv.pdf')],
      );
      final caughtUp = await repository.getCandidateProfile();
      expect(
        caughtUp.fold((_) => null, (value) => value.cvDocument?.fileName),
        'new-cv.pdf',
      );
      expect(await local.getUploadedCvMarker(), isNull);
    });
  });
}
