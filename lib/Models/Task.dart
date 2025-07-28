enum TaskStatus { pending, pickedUp, inProgress, completed, all }

class Task {
  final String taskName;
  final String taskCode; // Unique code for the task
  final String fromLocation; // From where
  final String toLocation; // To where
  final String itemDescription; // What to deliver
  final int itemCount; // Number of items to deliver
  final DateTime startTime; // Start time
  final DateTime deadline; // Deadline to complete the task
  final TaskStatus status; // Status enum
  final String ownerId; // Who posted the task
  final String? confirmationPhoto; // URL or path to a completion photo
  final String? confirmationSign; // URL or path to a signature image

  // can
  Task({
    required this.taskName,
    required this.taskCode,
    required this.fromLocation,
    required this.toLocation,
    required this.itemDescription,
    required this.itemCount,
    required this.startTime,
    required this.deadline,
    required this.status,
    required this.ownerId,
    this.confirmationPhoto,
    this.confirmationSign,
  });

  // Optional: JSON serialization if using Firebase
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskName: json['taskName'],
      taskCode: json['taskCode'],
      fromLocation: json['fromLocation'],
      toLocation: json['toLocation'],
      itemDescription: json['itemDescription'],
      itemCount: json['itemCount'],
      startTime: DateTime.parse(json['startTime']),
      deadline: DateTime.parse(json['deadline']),
      status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
      ownerId: json['ownerId'],
      confirmationPhoto: json['confirmationPhoto'],
      confirmationSign: json['confirmationSign'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taslName': taskName,
      'taskCode': taskCode,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'itemDescription': itemDescription,
      'itemCount': itemCount,
      'startTime': startTime.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'status': status.name,
      'ownerId': ownerId,
      'confirmationPhoto': confirmationPhoto,
      'confirmationSign': confirmationSign,
    };
  }
}