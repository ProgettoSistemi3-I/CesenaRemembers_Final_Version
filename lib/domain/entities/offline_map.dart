class OfflineMapProgress {
  const OfflineMapProgress({
    required this.downloaded,
    required this.total,
    required this.status,
  });

  final int downloaded;
  final int total;
  final OfflineMapStatus status;

  double get ratio => total == 0 ? 0 : downloaded / total;
}

enum OfflineMapStatus { idle, downloading, completed, failed }
