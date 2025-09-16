import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fluttter_project/Models/Task.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Common/FieldHandler.dart';
import '../ViewModel/TaskController.dart';

class DeliveryTimePromptPage extends StatefulWidget {
  final String taskCode;

  const DeliveryTimePromptPage({
    Key? key,
    required this.taskCode, required onDeliveryTimeSelected,
  }) : super(key: key);

  @override
  State<DeliveryTimePromptPage> createState() => _DeliveryTimePromptPageState();
}

class _DeliveryTimePromptPageState extends State<DeliveryTimePromptPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDeliveryTime;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Delivery Time'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Code: ${widget.taskCode}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please select the preferred delivery time for this task.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Delivery Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              DateTimeField(
                format: _dateFormat,
                decoration: InputDecoration(
                  labelText: 'Select Date & Time',
                  hintText: 'Choose delivery date and time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.schedule, color: Colors.blue[600]),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onShowPicker: (context, currentValue) async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                    initialDate: currentValue ?? DateTime.now().add(Duration(hours: 1)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        currentValue ?? DateTime.now().add(Duration(hours: 1)),
                      ),
                    );
                    return DateTimeField.combine(date, time);
                  } else {
                    return currentValue;
                  }
                },
                onChanged: (DateTime? value) {
                  setState(() {
                    _selectedDeliveryTime = value;
                  });
                },
                validator: (DateTime? value) {
                  return FieldHandler.validateDeliveryTime(value);
                },
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.grey[700],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedDeliveryTime != null
                          ? () => _confirmDeliveryTime(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeliveryTime(BuildContext context) async {
    if (_formKey.currentState!.validate() && _selectedDeliveryTime != null) {
      final controller = context.read<TaskController>();


      await controller.updateTaskStatus(widget.taskCode, TaskStatus.inProgress);
      await controller.updateTaskDeliveryTime(widget.taskCode, _selectedDeliveryTime!);

      Navigator.of(context).pop();
    }
  }
}
