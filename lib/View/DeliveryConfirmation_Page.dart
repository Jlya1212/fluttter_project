import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../Models/Task.dart';

class DeliveryConfirmationPage extends StatefulWidget {
  final Task task;
  const DeliveryConfirmationPage({Key? key, required this.task}) : super(key: key);

  @override
  _DeliveryConfirmationPageState createState() => _DeliveryConfirmationPageState();
}

class _DeliveryConfirmationPageState extends State<DeliveryConfirmationPage> {
  bool _isSignatureCompleted = false;
  bool _isPhotoCompleted = false;
  bool _isFinalized = false;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final ImagePicker _picker = ImagePicker();
  File? _photoFile;

  void _completeAndReturn() {
    if (!_isFinalized) return; // Guard clause

    // Return a map with all confirmation details
    Navigator.of(context).pop({
      'status': TaskStatus.completed,
      'signature': 'Mechanic Signature Captured\nSigned by: ${widget.task.ownerId}',
      'photoUrl': _photoFile?.path,
      'completionTime': DateTime.now(),
    });
  }

  void _showSignatureDialog() {
    _signatureController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text(
          'Digital Signature',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please have the mechanic sign below to confirm receipt.',
                style: TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.grey[200]!,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _signatureController.clear();
              setState(() => _isSignatureCompleted = false);
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (_signatureController.isNotEmpty) {
                final data = await _signatureController.toPngBytes();
                if (data != null) {
                  setState(() => _isSignatureCompleted = true);
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
                  child: Image.file(_photoFile!, fit: BoxFit.cover),
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
                setState(() {
                  _photoFile = File(pickedFile.path);
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
    if (_isSignatureCompleted && _isPhotoCompleted) {
      setState(() {
        _isFinalized = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete signature and photo steps first.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentStep = 1;
    if (_isSignatureCompleted) currentStep = 2;
    if (_isPhotoCompleted) currentStep = 3;
    if (_isFinalized) currentStep = 4;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(null), // Always pop null on back press
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
          if (currentStep <= 3)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Chip(
                label: Text(
                  'Step $currentStep of 3',
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
          onPressed: _isFinalized ? _completeAndReturn : null,
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
        ],
      ),
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
            title: 'Digital Signature',
            subtitle: 'Get mechanic confirmation',
            isCompleted: _isSignatureCompleted,
            onTap: _showSignatureDialog,
          ),
          const SizedBox(height: 12),
          _stepItem(
            stepNumber: 2,
            title: 'Photo Confirmation',
            subtitle: 'Document delivered parts',
            isCompleted: _isPhotoCompleted,
            onTap: _showPhotoDialog,
            isEnabled: _isSignatureCompleted,
          ),
          const SizedBox(height: 12),
          _stepItem(
            stepNumber: 3,
            title: 'Completion',
            subtitle: 'Finalize delivery record',
            isCompleted: _isFinalized,
            onTap: _finalizeDelivery,
            isEnabled: _isSignatureCompleted && _isPhotoCompleted,
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
    if(stepNumber == 3) buttonText = 'Finalize';


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

