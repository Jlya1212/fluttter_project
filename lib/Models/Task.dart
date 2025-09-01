enum TaskStatus { pending, pickedUp, inProgress, completed, all }

enum TaskSort { startTimeAsc, startTimeDesc }

class Task {
  final String taskName;
  final String taskCode;
  final String fromLocation;
  final String toLocation;
  final String itemDescription;
  final int itemCount;
  final DateTime startTime;
  final DateTime deadline;
  final TaskStatus status;
  final String ownerId;

  // Confirmation fields
  final String? confirmationPhoto;
  final String? confirmationSign;
  final DateTime? completionTime; // New field for completion timestamp

  // Details fields
  final String? customerName;
  final String? partDetails;
  final String? destinationAddress;
  final int? estimatedDurationMinutes;
  final String? specialInstructions;
  final String? deliveryNotes;


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
    this.completionTime, // Add to constructor
    this.customerName,
    this.partDetails,
    this.destinationAddress,
    this.estimatedDurationMinutes,
    this.specialInstructions,
    this.deliveryNotes,
  });

  // Since we are not using a real backend, fromJson/toJson are not strictly
  // necessary to update, but it's good practice.
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
      completionTime: json['completionTime'] != null ? DateTime.parse(json['completionTime']) : null,
      customerName: json['customerName'],
      partDetails: json['partDetails'],
      destinationAddress: json['destinationAddress'],
      estimatedDurationMinutes: json['estimatedDurationMinutes'],
      specialInstructions: json['specialInstructions'],
      deliveryNotes: json['deliveryNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
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
      'completionTime': completionTime?.toIso8601String(),
      'customerName': customerName,
      'partDetails': partDetails,
      'destinationAddress': destinationAddress,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'specialInstructions': specialInstructions,
      'deliveryNotes': deliveryNotes,
    };
  }
}

