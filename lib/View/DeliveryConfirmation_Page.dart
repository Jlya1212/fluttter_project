import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../Models/Task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // for base64
import 'dart:typed_data';

class DeliveryConfirmationPage extends StatefulWidget {
  final Task task;
  const DeliveryConfirmationPage({Key? key, required this.task}) : super(key: key);

  @override
  _DeliveryConfirmationPageState createState() => _DeliveryConfirmationPageState();
}

class _DeliveryConfirmationPageState extends State<DeliveryConfirmationPage> {
  bool _isMechanicSignatureCompleted = false;
  bool _isDeliverySignatureCompleted = false;
  bool _isPhotoCompleted = false;
  bool _isFinalized = false;
  bool _isLoading = false;
  Uint8List? _photoBytes;

  final SignatureController _mechanicSignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final SignatureController _deliverySignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final ImagePicker _picker = ImagePicker();
  XFile? _photoFile;

  void _completeAndReturn() async {
    if (!_isFinalized) return;

    setState(() {
      _isLoading = true;
    });

    final mechanicSignatureBytes = await _mechanicSignatureController.toPngBytes();
    final deliverySignatureBytes = await _deliverySignatureController.toPngBytes();

    // Encode photo to Base64
    String? base64Photo;
    if (_photoBytes != null) {
      base64Photo = base64Encode(_photoBytes!);
    }


    final deliveryDoc = await FirebaseFirestore.instance
        .collection('deliveries')
        .doc(widget.task.taskCode)
        .get();

    await FirebaseFirestore.instance
        .collection('deliveries')
        .doc(widget.task.taskCode)
        .set({
      'status': TaskStatus.completed.toString(),
      'mechanicSignature': mechanicSignatureBytes != null ? base64Encode(mechanicSignatureBytes) : null,
      'deliverySignature': deliverySignatureBytes != null ? base64Encode(deliverySignatureBytes) : null,
      'photoBase64': base64Photo,
      'completionTime': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Return to previous page with values
    Navigator.of(context).pop({
      'status': TaskStatus.completed,
      'mechanicSignature': mechanicSignatureBytes,
      'deliverySignature': deliverySignatureBytes,
      'photoBase64': base64Photo, // base64 string instead of file path
      'completionTime': DateTime.now(),
    });
  }
  Widget _buildPhotoPreview(String taskCode) {
    if (_photoBytes != null) {
      // Show freshly captured photo without waiting for Firestore
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _photoBytes!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    }

    // Fallback to Firestore if _photoBytes is null
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('deliveries')
          .doc(taskCode)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("No delivery record found");
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final base64Photo = data['photoBase64'];

        if (base64Photo == null) {
          return const Text("No photo uploaded yet");
        }

        try {
          final bytes = base64Decode(base64Photo);
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          );
        } catch (e) {
          return Text("Error loading photo: $e");
        }
      },
    );
  }

  Widget _buildPhotoSection(String taskCode) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('deliveries')
          .doc(taskCode)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        if (!snapshot.data!.exists) return const Text("No delivery record");

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final base64Photo = data['photoBase64'];

        if (base64Photo == null) {
          return const Text("No photo uploaded");
        }

        try {
          final bytes = base64Decode(base64Photo);
          return Image.memory(bytes, fit: BoxFit.cover);
        } catch (e) {
          return Text("Error decoding photo: $e");
        }
      },
    );
  }

  void _showSignatureDialog({required bool isMechanic}) {
    final controller = isMechanic ? _mechanicSignatureController : _deliverySignatureController;
    final title = isMechanic ? 'Mechanic Signature' : 'Delivery Man Signature';

    controller.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please sign below to confirm.',
                style: const TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Signature(
                  controller: controller,
                  backgroundColor: Colors.grey[200]!,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clear();
              setState(() {
                if (isMechanic) {
                  _isMechanicSignatureCompleted = false;
                } else {
                  _isDeliverySignatureCompleted = false;
                }
              });
            },
            child: const Text('Clear', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (controller.isNotEmpty) {
                final data = await controller.toPngBytes();
                if (data != null) {
                  setState(() {
                    if (isMechanic) {
                      _isMechanicSignatureCompleted = true;
                    } else {
                      _isDeliverySignatureCompleted = true;
                    }
                  });
                }
              }
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<String?> _getPhotoBase64() async {
    if (_photoFile == null) return null;
    final bytes = await _photoFile!.readAsBytes();
    return base64Encode(bytes);
  }


  void _showPhotoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text(
          'Photo Confirmation',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Take a photo of the delivered parts at the workshop.',
                style: TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: _photoFile == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No photo selected yet',
                        style: TextStyle(color: Colors.grey)),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_photoFile!.path), fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final pickedFile = await _picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                final bytes = await pickedFile.readAsBytes();
                setState(() {
                  _photoBytes = bytes;
                  _isPhotoCompleted = true;
                });
              }
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
          ),
        ],
      ),
    );
  }


  void _finalizeDelivery() {
    if (_isMechanicSignatureCompleted && _isDeliverySignatureCompleted && _isPhotoCompleted) {
      setState(() {
        _isFinalized = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all steps first.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mechanicSignatureController.dispose();
    _deliverySignatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentStep = 1;

    if (_isMechanicSignatureCompleted) currentStep = 2;
    if (_isDeliverySignatureCompleted) currentStep = 3;
    if (_isPhotoCompleted) currentStep = 4;
    if (_isFinalized) currentStep = 5;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.grey[100],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Confirmation',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '#${widget.task.taskCode}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            actions: [
              if (currentStep <= 4)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Chip(
                    label: Text(
                      'Step $currentStep of 4',
                      style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: Colors.green.shade100,
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 24),
                _buildConfirmationSteps(),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _isFinalized && !_isLoading ? _completeAndReturn : null,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text('Complete & Return to Schedule'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFinalized ? Colors.green.shade600 : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),

        // ✅ Overlay loader
        if (_isLoading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }



  // UI Widgets (unchanged from before, they are correct)
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.green.shade600, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delivery Completed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Delivered at ${DateFormat('M/d/y, hh:mm a').format(DateTime.now())}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Divider(),
            _summaryRow('Part:', widget.task.taskName),
            _summaryRowWithBadge('Quantity:', widget.task.itemCount.toString()),
            _summaryRow('Workshop:', widget.task.toLocation.split(' - ')[0]),
            _summaryRow('Mechanic:', widget.task.ownerId),
            _summaryRow('Customer:', widget.task.customerName ?? 'N/A'),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Delivery Photo:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildPhotoPreview(widget.task.taskCode),


          ]),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _summaryRowWithBadge(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildConfirmationSteps() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirmation Steps',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _stepItem(
            stepNumber: 1,
            title: 'Mechanic Signature',
            subtitle: 'Get mechanic confirmation',
            isCompleted: _isMechanicSignatureCompleted,
            onTap: () => _showSignatureDialog(isMechanic: true),
          ),
          const SizedBox(height: 12),
          _stepItem(
            stepNumber: 2,
            title: 'Delivery Man Signature',
            subtitle: 'Confirm delivery acknowledgement',
            isCompleted: _isDeliverySignatureCompleted,
            onTap: () => _showSignatureDialog(isMechanic: false),
            isEnabled: _isMechanicSignatureCompleted,
          ),
          const SizedBox(height: 12),
          _stepItem(
            stepNumber: 3,
            title: 'Photo Confirmation',
            subtitle: 'Document delivered parts',
            isCompleted: _isPhotoCompleted,
            onTap: _showPhotoDialog,
            isEnabled: _isMechanicSignatureCompleted && _isDeliverySignatureCompleted,
          ),
          const SizedBox(height: 12),
          _stepItem(
            stepNumber: 4,
            title: 'Completion',
            subtitle: 'Finalize delivery record',
            isCompleted: _isFinalized,
            onTap: _finalizeDelivery,
            isEnabled: _isMechanicSignatureCompleted && _isDeliverySignatureCompleted && _isPhotoCompleted,
          ),
        ],
      ),
    );
  }

  Widget _stepItem({
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    Color color = Colors.grey.shade300;
    Color iconColor = Colors.grey.shade600;
    String buttonText = 'Sign';
    if (stepNumber == 3) {
      buttonText = 'Capture';
    } else if (stepNumber == 4) {
      buttonText = 'Finalize';
    }


    if (isEnabled && !isCompleted) {
      color = Colors.orange.shade100;
      iconColor = Colors.orange.shade800;
    } else if (isCompleted) {
      color = Colors.green.shade100;
      iconColor = Colors.green.shade800;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? iconColor : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 2),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                stepNumber.toString(),
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: iconColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: iconColor.withOpacity(0.8), fontSize: 14),
                ),
              ],
            ),
          ),
          if (!isCompleted)
            ElevatedButton(
              onPressed: isEnabled ? onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnabled ? Colors.orange : Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(buttonText),
            ),
        ],
      ),
    );
  }
}