String normalizeJobCategory(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return 'Intelligence Engineering';
  }

  final lowered = raw.toLowerCase();

  if (lowered == 'teknik' ||
      lowered == 'engineering' ||
      lowered == 'intelligence engineering' ||
      lowered.contains('engineer')) {
    return 'Intelligence Engineering';
  }

  if (lowered == 'kreasi' ||
      lowered == 'creation' ||
      lowered == 'intelligence creation' ||
      lowered.contains('creat')) {
    return 'Intelligence Creation';
  }

  if (lowered == 'implementasi' ||
      lowered == 'implementation' ||
      lowered.contains('implement')) {
    return 'Implementation';
  }

  return raw;
}

String mapJobCategoryToApi(String? value) {
  final normalized = normalizeJobCategory(value);
  switch (normalized) {
    case 'Intelligence Creation':
      return 'kreasi';
    case 'Implementation':
      return 'implementasi';
    case 'Intelligence Engineering':
    default:
      return 'teknik';
  }
}
