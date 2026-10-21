import 'package:MatchIn/features/profile/domain/entities/cv_file_download_entity.dart';

/// Data-layer binary CV payload. See [CvFileDownloadEntity].
class CvFileDownload extends CvFileDownloadEntity {
  const CvFileDownload({required super.bytes, super.fileName, super.mimeType});
}
