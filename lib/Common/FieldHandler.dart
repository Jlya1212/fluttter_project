class FieldHandler {
  static String? validateDeliveryTime(DateTime? deliveryTime) {
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

    return null; // Valid
  }

  static bool isValidDeliveryTime(DateTime? deliveryTime) {
    return validateDeliveryTime(deliveryTime) == null;
  }
}
