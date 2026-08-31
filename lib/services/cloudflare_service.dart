/// Dedicated media service managing CDN streaming URLs via Cloudflare R2 & Cloudflare Stream.
/// Bypasses heavy Firebase Storage egress costs and provides zero-egress audio/video streaming.
class CloudflareService {
  static const String _r2CdnBaseUrl = 'https://cdn.rukiyahealing.com';
  static const String _streamCdnBaseUrl = 'https://cloudflare-stream.com';

  /// Generates zero-egress CDN URL for Ruqyah audio files hosted on Cloudflare R2.
  static String getAudioStreamUrl(String audioFileName) {
    if (audioFileName.startsWith('http://') ||
        audioFileName.startsWith('https://')) {
      return audioFileName;
    }
    final cleanPath = audioFileName.startsWith('/')
        ? audioFileName.substring(1)
        : audioFileName;
    return '$_r2CdnBaseUrl/audio/$cleanPath';
  }

  /// Generates adaptive bitrate video streaming URL for course lectures hosted on Cloudflare Stream.
  static String getVideoStreamUrl(String videoStreamId) {
    if (videoStreamId.startsWith('http://') ||
        videoStreamId.startsWith('https://')) {
      return videoStreamId;
    }
    final cleanId = videoStreamId.startsWith('/')
        ? videoStreamId.substring(1)
        : videoStreamId;
    return '$_streamCdnBaseUrl/$cleanId/manifest/video.m3u8';
  }

  /// Generates CDN URL for medical session images or public assets.
  static String getAssetUrl(String assetPath) {
    if (assetPath.startsWith('http://') || assetPath.startsWith('https://')) {
      return assetPath;
    }
    final cleanPath =
        assetPath.startsWith('/') ? assetPath.substring(1) : assetPath;
    return '$_r2CdnBaseUrl/$cleanPath';
  }
}
