class FieldHandler {
  static String? validateDeliveryTime(DateTime? deliveryTime, {DateTime? requiredDeadline}) {
    if (deliveryTime == null) {
      return 'Delivery time is required';
    }

    final now = DateTime.now();
    if (deliveryTime.isBefore(now)) {
      return 'Delivery time cannot be in the past';
    }

    // Check if delivery time is more than 1 year in the future (reasonable limit)
    final oneYearFromNow = now.add(Duration(days: 365));
    if (deliveryTime.isAfter(oneYearFromNow)) {
      return 'Delivery time cannot be more than 1 year in the future';
    }

    // Additional optional check: must be on/before the required deadline
    if (requiredDeadline != null) {
      // Use isAfter with a small tolerance to handle timezone/precision issues
      final tolerance = Duration(minutes: 1);
      if (deliveryTime.isAfter(requiredDeadline.add(tolerance))) {
        return 'Delivery time cannot be later than the required deadline';
      }
    }

    return null; // Valid
  }

  static bool isValidDeliveryTime(DateTime? deliveryTime, {DateTime? requiredDeadline}) {
    return validateDeliveryTime(deliveryTime, requiredDeadline: requiredDeadline) == null;
  }
}
