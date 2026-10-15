import 'package:MatchIn/features/profile/data/models/cv_upload_receipt_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CvUploadReceiptModel.tryParseReceipt', () {
    test('parses a complete upload receipt', () {
      final receipt = CvUploadReceiptModel.tryParseReceipt({
        'message': 'CV uploaded successfully.',
        'data': {'id': 2, 'version': 2, 'status': 'processing'},
      });

      expect(receipt, isNotNull);
      expect(receipt!.id, 2);
      expect(receipt.version, 2);
      expect(receipt.status, 'processing');
    });

    test('returns null when data is missing', () {
      expect(CvUploadReceiptModel.tryParseReceipt({'message': 'ok'}), isNull);
    });

    test('returns null when id is missing or invalid', () {
      expect(
        CvUploadReceiptModel.tryParseReceipt({
          'data': {'version': 1},
        }),
        isNull,
      );
      expect(
        CvUploadReceiptModel.tryParseReceipt({
          'data': {'id': 0},
        }),
        isNull,
      );
      expect(
        CvUploadReceiptModel.tryParseReceipt({
          'data': {'id': 'not-a-number'},
        }),
        isNull,
      );
      expect(
        CvUploadReceiptModel.tryParseReceipt({
          'data': {'id': '0'},
        }),
        isNull,
      );
    });

    test('parses the current JSON:API-style 201 response', () {
      final receipt = CvUploadReceiptModel.tryParseReceipt({
        'status': 'success',
        'message': 'CV uploaded successfully.',
        'data': {
          'id': '10',
          'type': 'cvDocuments',
          'attributes': {
            'original_filename': 'cv.pdf',
            'mime_type': 'application/pdf',
            'file_size': 123456,
            'version': 2,
            'is_current': true,
            'status': 'uploaded',
          },
        },
      });

      expect(receipt, isNotNull);
      expect(receipt!.id, 10);
      expect(receipt.version, 2);
      expect(receipt.status, 'uploaded');
    });

    test('accepts numeric ids and string versions', () {
      final receipt = CvUploadReceiptModel.tryParseReceipt({
        'data': {
          'id': 10,
          'attributes': {'version': '3', 'status': 'processing'},
        },
      });

      expect(receipt, isNotNull);
      expect(receipt!.id, 10);
      expect(receipt.version, 3);
      expect(receipt.status, 'processing');
    });

    test('attributes override top-level version and status', () {
      final receipt = CvUploadReceiptModel.tryParseReceipt({
        'data': {
          'id': '11',
          'version': 1,
          'status': 'processing',
          'attributes': {'version': 2, 'status': 'uploaded'},
        },
      });

      expect(receipt, isNotNull);
      expect(receipt!.id, 11);
      expect(receipt.version, 2);
      expect(receipt.status, 'uploaded');
    });

    test('returns null for non-map responses', () {
      expect(CvUploadReceiptModel.tryParseReceipt(null), isNull);
      expect(CvUploadReceiptModel.tryParseReceipt('ok'), isNull);
    });
  });
}
