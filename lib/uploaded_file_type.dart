enum UploadedFileType { image, pdf, audio, video, other }

UploadedFileType detectUploadedFileType(String fileName) {
  final lowerFileName = fileName.toLowerCase();

  if (lowerFileName.endsWith('.jpg') ||
      lowerFileName.endsWith('.jpeg') ||
      lowerFileName.endsWith('.png') ||
      lowerFileName.endsWith('.gif') ||
      lowerFileName.endsWith('.bmp') ||
      lowerFileName.endsWith('.webp')) {
    return UploadedFileType.image;
  }

  if (lowerFileName.endsWith('.pdf')) {
    return UploadedFileType.pdf;
  }

  if (lowerFileName.endsWith('.mp3') ||
      lowerFileName.endsWith('.wav') ||
      lowerFileName.endsWith('.m4a') ||
      lowerFileName.endsWith('.aac') ||
      lowerFileName.endsWith('.ogg')) {
    return UploadedFileType.audio;
  }

  if (lowerFileName.endsWith('.mp4') ||
      lowerFileName.endsWith('.mov') ||
      lowerFileName.endsWith('.avi') ||
      lowerFileName.endsWith('.mkv')) {
    return UploadedFileType.video;
  }

  return UploadedFileType.other;
}
