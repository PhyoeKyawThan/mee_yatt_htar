import 'dart:io';

String calculatePensionRemaining(String? dob) {
  // 1. Define the Retirement Date (62nd Birthday)
  // We add 62 years to the birth year. Dart handles potential leap year
  // edge cases (like Feb 29th) gracefully.
  final parts = dob!.split('/');
  if (parts.length < 3) return 'Invalid date';

  int day = int.parse(parts[0]);
  int month = int.parse(parts[1]);
  int year = int.parse(parts[2].length == 2 ? '20${parts[2]}' : parts[2]);

  final birthDate = DateTime(year, month, day);
  final retirementYear = birthDate.year + 62;
  final retirementDate = DateTime(
    retirementYear,
    birthDate.month,
    birthDate.day,
  );

  final now = DateTime.now();

  // 2. Check if Retirement Date has passed
  if (retirementDate.isBefore(now)) {
    return 'Pension date has passed. (Retired on ${retirementDate.year}/${retirementDate.month}/${retirementDate.day})';
  }

  // 3. Calculate Difference in Years, Months, and Days

  // --- Start by calculating Years ---
  int years = retirementDate.year - now.year;
  int months = retirementDate.month - now.month;
  int days = retirementDate.day - now.day;

  // --- Adjust Months and Years ---
  // If the current month is after the retirement month, we decrement the year
  // and add 12 months.
  if (months < 0) {
    years--;
    months += 12;
  }

  // --- Adjust Days and Months ---
  // If the current day is after the retirement day, we decrement the month
  // and add the number of days in the *previous* month.
  if (days < 0) {
    months--;

    // Get the last day of the *previous* month relative to the current date.
    // Setting the day to 0 gives you the last day of the preceding month.
    final lastDayOfPreviousMonth = DateTime(now.year, now.month, 0).day;
    days += lastDayOfPreviousMonth;

    // Handle the final adjustment for months and years if months went negative
    if (months < 0) {
      years--;
      months += 12;
    }
  }

  // Final check: If years somehow ended up negative (shouldn't happen
  // after the initial `isBefore` check), set remaining time to 0.
  if (years < 0) {
    return 'Pension date has passed.';
  }

  // 4. Format and Return Result
  return '$years years, $months months, and $days days';
}

Future<bool> isImageExists(String imagePath) async {
  final file = File(imagePath);
  if (!await file.exists()) {
    return false;
  }
  return true;
}
