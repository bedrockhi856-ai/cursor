/// Returns 75% of the input years, rounded to the nearest integer
int getRegainableYears(double years) {
  return (years * 0.75).round();
}

/// Formats seconds into MM:SS format
String formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}
