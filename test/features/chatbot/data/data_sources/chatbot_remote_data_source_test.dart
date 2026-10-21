import 'dart:typed_data';

import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/chatbot/data/data_sources/chatbot_remote_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApiConsumer implements ApiConsumer {
  dynamic getResponse;
  dynamic postResponse;
  dynamic patchResponse;
  dynamic deleteResponse;

  String? lastGetPath;
  String? lastPostPath;
  Object? lastPostData;
  String? lastPatchPath;
  Object? lastPatchData;
  String? lastDeletePath;

  bool shouldThrowServerException = false;
  bool shouldThrowOfflineException = false;

  void _checkThrow() {
    if (shouldThrowServerException) {
      throw ServerException(
        errorModel: const ErrorModel(
          statusCode: 500,
          errorMessage: 'Internal error',
        ),
      );
    }
    if (shouldThrowOfflineException) {
      throw OfflineException();
    }
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    lastGetPath = path;
    _checkThrow();
    return getResponse;
  }

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    lastPostPath = path;
    lastPostData = data;
    _checkThrow();
    return postResponse;
  }

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    _checkThrow();
    return null;
  }

  @override
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    lastPatchPath = path;
    lastPatchData = data;
    _checkThrow();
    return patchResponse;
  }

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    lastDeletePath = path;
    _checkThrow();
    return deleteResponse;
  }

  @override
  Future<({Uint8List bytes, String? fileName, String? mimeType})> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late _FakeApiConsumer fakeApiConsumer;
  late ChatbotRemoteDataSourceImpl dataSource;

  setUp(() {
    fakeApiConsumer = _FakeApiConsumer();
    dataSource = ChatbotRemoteDataSourceImpl(apiConsumer: fakeApiConsumer);
  });

  group('ChatbotRemoteDataSourceImpl Tests', () {
    test(
      'getConversations parses list of conversations successfully',
      () async {
        fakeApiConsumer.getResponse = {
          'status': 'success',
          'data': [
            {
              'id': 1,
              'title': 'Interview Prep',
              'created_at': '2026-10-14T10:00:00Z',
              'updated_at': '2026-10-14T10:05:00Z',
              'messages': [
                {
                  'id': 10,
                  'sender': 'user',
                  'content': 'Hello',
                  'timestamp': '2026-10-14T10:00:00Z',
                },
              ],
            },
          ],
        };

        final conversations = await dataSource.getConversations();

        expect(fakeApiConsumer.lastGetPath, EndPoint.mentorConversations);
        expect(conversations.length, 1);
        expect(conversations.first.id, '1');
        expect(conversations.first.title, 'Interview Prep');
        expect(conversations.first.messages.length, 1);
      },
    );

    test('getConversationDetails parses conversation with messages', () async {
      fakeApiConsumer.getResponse = {
        'data': {
          'id': 42,
          'title': 'Roadmap Discussion',
          'created_at': '2026-10-14T10:00:00Z',
          'updated_at': '2026-10-14T10:05:00Z',
          'messages': [
            {
              'id': 101,
              'sender': 'assistant',
              'content': 'How can I assist?',
              'timestamp': '2026-10-14T10:00:00Z',
            },
          ],
        },
      };

      final details = await dataSource.getConversationDetails('42');

      expect(
        fakeApiConsumer.lastGetPath,
        EndPoint.mentorConversationDetails('42'),
      );
      expect(details.id, '42');
      expect(details.title, 'Roadmap Discussion');
      expect(details.messages.first.content, 'How can I assist?');
    });

    test(
      'createConversation posts title and message and parses result',
      () async {
        fakeApiConsumer.postResponse = {
          'status': 'success',
          'data': {
            'id': 99,
            'title': 'New Chat',
            'created_at': '2026-10-14T10:00:00Z',
            'updated_at': '2026-10-14T10:00:00Z',
            'user_message': {
              'id': 1,
              'sender': 'user',
              'content': 'Hi mentor',
              'timestamp': '2026-10-14T10:00:00Z',
            },
            'mentor_reply': {
              'id': 2,
              'sender': 'assistant',
              'content': 'Hello candidate!',
              'timestamp': '2026-10-14T10:00:05Z',
              'suggested_actions': [
                {'type': 'suggested_prompt', 'label': 'What is Flutter?'},
              ],
            },
          },
        };

        final result = await dataSource.createConversation(
          title: 'New Chat',
          message: 'Hi mentor',
        );

        expect(fakeApiConsumer.lastPostPath, EndPoint.mentorConversations);
        expect((fakeApiConsumer.lastPostData as Map)['title'], 'New Chat');
        expect((fakeApiConsumer.lastPostData as Map)['message'], 'Hi mentor');
        expect(result.id, '99');
        expect(result.messages.length, 2);
      },
    );

    test('sendMessage sends message payload and parses user_message & mentor_reply', () async {
      fakeApiConsumer.postResponse = {
        'status': 'success',
        'message': 'Message sent successfully.',
        'data': {
          'user_message': {
            'id': 51,
            'sender': 'user',
            'content': 'What is BLoC?',
          },
          'mentor_reply': {
            'id': 52,
            'sender': 'assistant',
            'content': 'BLoC stands for Business Logic Component.',
            'suggested_actions': [
              {'type': 'suggested_prompt', 'label': 'Compare BLoC vs Riverpod'},
            ],
          },
        },
      };

      final response = await dataSource.sendMessage(
        conversationId: '5',
        message: 'What is BLoC?',
      );

      expect(
        fakeApiConsumer.lastPostPath,
        EndPoint.mentorConversationMessages('5'),
      );
      expect(response.userMessage?.content, 'What is BLoC?');
      expect(
        response.mentorReply.content,
        'BLoC stands for Business Logic Component.',
      );
      expect(
        response.mentorReply.suggestedActions.first.label,
        'Compare BLoC vs Riverpod',
      );
    });

    test('updateConversation sends patch request', () async {
      fakeApiConsumer.patchResponse = {'status': 'success'};

      await dataSource.updateConversation(
        conversationId: '10',
        title: 'Renamed Chat',
        isArchived: true,
      );

      expect(
        fakeApiConsumer.lastPatchPath,
        EndPoint.mentorConversationDetails('10'),
      );
      expect((fakeApiConsumer.lastPatchData as Map)['title'], 'Renamed Chat');
      expect((fakeApiConsumer.lastPatchData as Map)['is_archived'], true);
    });

    test('deleteConversation calls delete endpoint', () async {
      fakeApiConsumer.deleteResponse = {'status': 'success'};

      await dataSource.deleteConversation('12');

      expect(
        fakeApiConsumer.lastDeletePath,
        EndPoint.mentorConversationDetails('12'),
      );
    });

    test('getContextPreview gets candidate grounding context', () async {
      fakeApiConsumer.getResponse = {
        'data': {
          'headline': 'Senior Flutter Engineer',
          'verified_skills': ['Dart', 'Flutter'],
        },
      };

      final preview = await dataSource.getContextPreview();

      expect(fakeApiConsumer.lastGetPath, EndPoint.mentorContextPreview);
      expect(preview['headline'], 'Senior Flutter Engineer');
    });

    test('throws ServerException on failure', () async {
      fakeApiConsumer.shouldThrowServerException = true;

      expect(
        () => dataSource.getConversations(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
