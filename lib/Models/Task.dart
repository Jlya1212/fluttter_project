import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

enum TaskStatus { pending, pickedUp, inProgress, completed, all }
enum TaskSort { startTimeAsc, startTimeDesc }

class Task {
  final String taskName;
  final String taskCode;
  Uint8List? mechanicSignature;
  Uint8List? deliverySignature;
  final String fromLocation;
  final String toLocation;
  final String itemDescription;
  final int itemCount;
  final DateTime startTime;
  final DateTime deadline;
  final TaskStatus status;
  final String ownerId;
  final String? photoBase64;
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
    this.mechanicSignature,
    this.deliverySignature,
    this.completionTime,
    this.customerName,
    this.partDetails,
    this.destinationAddress,
    this.estimatedDurationMinutes,
    this.specialInstructions,
    this.deliveryNotes,
    this.photoBase64,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskName: json['taskName'] ?? '',
      taskCode: json['taskCode'] ?? '',
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      itemDescription: json['itemDescription'] ?? '',
      itemCount: json['itemCount'] ?? 0,

      // Safely convert Firestore Timestamps
      startTime: json['startTime'] != null
          ? (json['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      deadline: json['deadline'] != null
          ? (json['deadline'] as Timestamp).toDate()
          : DateTime.now(),


      // Convert status string → enum
      status: TaskStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),

      ownerId: json['ownerId'] ?? '',

      mechanicSignature: json['mechanicSignature'] != null
          ? (json['mechanicSignature'] is Blob
          ? (json['mechanicSignature'] as Blob).bytes
          : null)
          : null,

      deliverySignature: json['deliverySignature'] != null
          ? (json['deliverySignature'] is Blob
          ? (json['deliverySignature'] as Blob).bytes
          : null)
          : null,


      // ✅ Strings
      customerName: json['customerName'] as String?,
      partDetails: json['partDetails'] as String?,
      destinationAddress: json['destinationAddress'] as String?,
      specialInstructions: json['specialInstructions'] as String?,
      deliveryNotes: json['deliveryNotes'] as String?,
      photoBase64: json['photoBase64'] as String?,

      // ✅ Numbers (force to int)
      estimatedDurationMinutes: json['estimatedDurationMinutes'] != null
          ? (json['estimatedDurationMinutes'] as num).toInt()
          : null,

      // ✅ Photo and completion time
      completionTime: json['completionTime'] != null
          ? (json['completionTime'] as Timestamp).toDate()
          : null,
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
      'mechanicSignature':
      mechanicSignature != null ? Blob(mechanicSignature!) : null,
      'deliverySignature':
      deliverySignature != null ? Blob(deliverySignature!) : null,
      'completionTime': completionTime != null ? Timestamp.fromDate(completionTime!) : null,
      'customerName': customerName,
      'partDetails': partDetails,
      'destinationAddress': destinationAddress,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'specialInstructions': specialInstructions,
      'deliveryNotes': deliveryNotes,
      'photoBase64': photoBase64,
    };
  }
}