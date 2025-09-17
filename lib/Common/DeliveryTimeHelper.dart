import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModel/TaskController.dart';

class DeliveryTimeHelper {
  static Future<void> showDeliveryTimePrompt(
      BuildContext context,
      String taskCode, {
        bool isEditMode = false,
        DateTime? initialDeliveryTime,
      }) async {
    final taskController = Provider.of<TaskController>(context, listen: false);

    final result = await Navigator.of(context, rootNavigator: true).pushNamed(
      '/delivery-time-prompt',
      arguments: {
        'taskCode': taskCode,
        'isEditMode': isEditMode,
        'initialDeliveryTime': initialDeliveryTime,
        'onDeliveryTimeSelected': (DateTime deliveryTime) async {
          await taskController.updateTaskDeliveryTime(taskCode, deliveryTime);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditMode ? 'Delivery time updated successfully!' : 'Delivery time set successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
      },
    );
  }
}
