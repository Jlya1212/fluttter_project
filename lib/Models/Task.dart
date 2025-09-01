import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String? confirmationPhoto;
  final String? confirmationSign;
  final DateTime? completionTime;
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
    this.completionTime,
    this.customerName,
    this.partDetails,
    this.destinationAddress,
    this.estimatedDurationMinutes,
    this.specialInstructions,
    this.deliveryNotes,
  });

  // Updated fromJson to handle Firestore Timestamps
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskName: json['taskName'] ?? '',
      taskCode: json['taskCode'] ?? '',
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      itemDescription: json['itemDescription'] ?? '',
      itemCount: json['itemCount'] ?? 0,
      // This is the important change: convert Timestamp to DateTime
      startTime: (json['startTime'] as Timestamp).toDate(),
      deadline: (json['deadline'] as Timestamp).toDate(),
      status: TaskStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      ownerId: json['ownerId'] ?? '',
      confirmationPhoto: json['confirmationPhoto'],
      confirmationSign: json['confirmationSign'],
      completionTime: json['completionTime'] != null
          ? (json['completionTime'] as Timestamp).toDate()
          : null,
      customerName: json['customerName'],
      partDetails: json['partDetails'],
      destinationAddress: json['destinationAddress'],
      estimatedDurationMinutes: json['estimatedDurationMinutes'],
      specialInstructions: json['specialInstructions'],
      deliveryNotes: json['deliveryNotes'],
    );
  }

  // toJson should convert DateTime back to Timestamp for saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'taskCode': taskCode,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'itemDescription': itemDescription,
      'itemCount': itemCount,
      'startTime': Timestamp.fromDate(startTime),
      'deadline': Timestamp.fromDate(deadline),
      'status': status.name,
      'ownerId': ownerId,
      'confirmationPhoto': confirmationPhoto,
      'confirmationSign': confirmationSign,
      'completionTime': completionTime != null ? Timestamp.fromDate(completionTime!) : null,
      'customerName': customerName,
      'partDetails': partDetails,
      'destinationAddress': destinationAddress,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'specialInstructions': specialInstructions,
      'deliveryNotes': deliveryNotes,
    };
  }
}

