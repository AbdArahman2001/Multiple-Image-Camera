import 'dart:io';
import 'dart:typed_data';

class MediaModel {
  MediaModel.blob(this.file, this.filePath, this.blobImage);
  File file;
  String filePath;
  Uint8List blobImage;
}
