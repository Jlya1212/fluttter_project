import 'dart:async';
import 'Repository.dart';
import '../Models/Task.dart';
import '../common/Result.dart';
import '../Models/User.dart';

class MockUpRepository implements Repository {

  final List<Task> _tasks = [

    Task(
        taskName: 'Brake Pads Set',
        taskCode: 'BP-HON-001',
        fromLocation: 'Warehouse A - Bay 3',
        toLocation: 'AutoFix Workshop - Bay 3',
        itemDescription: '2019 Honda Civic',
        itemCount: 2,
        startTime: DateTime(2025, 9, 1, 8, 30),
        deadline: DateTime(2025, 9, 1, 9, 0),
        status: TaskStatus.pending,
        ownerId: 'Mike Rodriguez',
        customerName: 'John Smith',
        partDetails: 'Ceramic brake pads, front axle only - Premium grade',
        destinationAddress: '123 Main St, Downtown, NY 10001',
        estimatedDurationMinutes: 30,
        specialInstructions: 'Handle with care. Ceramic brake pads require special handling.',
        deliveryNotes: 'Contact mechanic Mike Rodriguez upon arrival at Bay 3'
    ),
    // Task 2
    Task(
        taskName: 'Battery Replacement',
        taskCode: 'T001',
        fromLocation: 'Proton Service Center, Shah Alam',
        toLocation: 'Customer Address, Subang Jaya',
        itemDescription: 'Amaron Car Battery DIN55',
        itemCount: 1,
        startTime: DateTime(2025, 9, 1, 10, 0),
        deadline: DateTime(2025, 9, 1, 11, 0),
        status: TaskStatus.inProgress,
        ownerId: 'user001',
        customerName: 'Alice Tan',
        partDetails: 'High-performance, zero-maintenance Amaron battery.',
        destinationAddress: '88, Jalan SS 15/4d, Ss 15, 47500 Subang Jaya, Selangor',
        estimatedDurationMinutes: 45,
        specialInstructions: 'Customer will pay upon delivery. Cash only.',
        deliveryNotes: 'Call customer 10 minutes before arrival.'
    ),
    // Task 3
    Task(
        taskName: 'Engine Oil Change',
        taskCode: 'T002',
        fromLocation: 'Shell Workshop, Petaling Jaya',
        toLocation: 'MRT Station, Taman Tun Dr Ismail',
        itemDescription: 'Shell Helix Ultra 5W-40 Engine Oil (4L)',
        itemCount: 1,
        startTime: DateTime(2025, 9, 1, 11, 30),
        deadline: DateTime(2025, 9, 1, 12, 15),
        status: TaskStatus.pending,
        ownerId: 'user002',
        customerName: 'David Chen',
        partDetails: 'Fully synthetic motor oil for high-performance engines.',
        destinationAddress: 'Taman Tun Dr Ismail MRT Station, Platform 1 Entrance A',
        estimatedDurationMinutes: 25,
        specialInstructions: 'Urgent delivery. Customer is waiting at the location.',
        deliveryNotes: 'Meet customer at the main entrance of the MRT station.'
    ),
    // Task 4
    Task(
        taskName: 'Tyre Replacement',
        taskCode: 'TSK002',
        fromLocation: 'Spare Parts Center, Kota Damansara',
        toLocation: 'Honda Service Center, Cheras',
        itemDescription: '2019 Honda Civic Tyre (Michelin Primacy 4)',
        itemCount: 4,
        startTime: DateTime(2025, 9, 1, 14, 0),
        deadline: DateTime(2025, 9, 1, 15, 30),
        status: TaskStatus.inProgress,
        ownerId: 'Mike Rodriguez',
        customerName: 'Service Center Stock',
        partDetails: 'Set of 4 Michelin Primacy 4 tyres, size 215/55R17.',
        destinationAddress: 'Lot 22, Jalan Cheras, 56100 Kuala Lumpur',
        estimatedDurationMinutes: 60,
        specialInstructions: 'Store tyres in a cool, dry place away from direct sunlight.',
        deliveryNotes: 'Deliver to the service bay manager, Mr. Wong.'
    ),
    // Task 5
    Task(
        taskName: 'Transmission Fluid Delivery',
        taskCode: 'TSK003',
        fromLocation: 'Total Service Station, Kajang',
        toLocation: 'Client Garage, Serdang',
        itemDescription: 'Toyota ATF Transmission Fluid (1L)',
        itemCount: 4,
        startTime: DateTime(2025, 9, 1, 16, 0),
        deadline: DateTime(2025, 9, 1, 16, 45),
        status: TaskStatus.completed,
        ownerId: 'Sarah Johnson',
        customerName: 'Bob\'s Garage',
        partDetails: '4 bottles of genuine Toyota Automatic Transmission Fluid.',
        destinationAddress: '12, Jalan 2/5, Taman Serdang Perdana, 43300 Seri Kembangan, Selangor',
        estimatedDurationMinutes: 35,
        specialInstructions: 'Fragile items, do not stack heavy objects on top.',
        deliveryNotes: 'Leave the package at the reception if Bob is unavailable.'
    ),
    // Task 6
    Task(
        taskName: 'Oil Filter Replacement',
        taskCode: 'TSK004',
        fromLocation: 'Ban Lee Heng Auto Parts, Pudu KL',
        toLocation: 'Quick Fix Garage, Setapak',
        itemDescription: 'Bosch Oil Filter Set',
        itemCount: 6,
        startTime: DateTime(2025, 9, 2, 9, 0),
        deadline: DateTime(2025, 9, 2, 10, 0),
        status: TaskStatus.completed,
        ownerId: 'Tom Wilson',
        customerName: 'Quick Fix Auto',
        partDetails: 'Bulk order of 6 Bosch oil filters, model P3314.',
        destinationAddress: '5, Jalan Genting Kelang, Setapak, 53300 Kuala Lumpur',
        estimatedDurationMinutes: 40,
        specialInstructions: 'Check package seal before delivery.',
        deliveryNotes: 'Obtain signature from the garage foreman upon delivery.'
    ),
    // Task 7
    Task(
        taskName: 'Tyre Delivery',
        taskCode: 'TSK005',
        fromLocation: 'Central Auto Depot, Klang',
        toLocation: 'Ford Dealership, Jalan Ampang',
        itemDescription: '2018 Ford F-150 Tyre Set (Goodyear Wrangler)',
        itemCount: 4,
        startTime: DateTime(2025, 9, 2, 11, 0),
        deadline: DateTime(2025, 9, 2, 12, 30),
        status: TaskStatus.inProgress,
        ownerId: 'Lisa Chen',
        customerName: 'Ford Ampang',
        partDetails: 'All-terrain Goodyear Wrangler tyres for Ford F-150.',
        destinationAddress: '34, Jalan Ampang, 50450 Kuala Lumpur',
        estimatedDurationMinutes: 75,
        specialInstructions: 'These are heavy. Use a trolley for transport.',
        deliveryNotes: 'Deliver to the parts department at the back of the dealership.'
    ),
  ];

  final List<User> _users = [
    User(
      id: 'user001',
      username: 'JohnDoe',
      email: 'johndoe',
      phone: '012-3456789',
      password: 'password123',
    ),
    User(
      id: 'user002',
      username: 'JaneSmith',
      email: 'janesmith@example.com',
      phone: '012-9876543',
      password: 'password456',
    ),
  ];
  // This method filters tasks by their status
  @override
  Future<Result<List<Task>>> getTasksByStatus(TaskStatus status) async {
    try {
      if (status == TaskStatus.all) {
        return Result.success(_tasks);
      } else {
        final filtered = _tasks.where((task) => task.status == status).toList();
        return Result.success(filtered);
      }
    } catch (e) {
      return Result.failure('Failed to fetch tasks: ${e.toString()}');
    }
  }

  @override
  Future<Result<User>> getUserByEmail(String email) async {
    try {
      final User user = _users.firstWhere((user) => user.email == email);
      return Result.success(user);
    } catch (e) {
      return Result.failure('User not found');
    }
  }


}

