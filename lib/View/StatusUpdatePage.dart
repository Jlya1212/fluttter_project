import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// -------------------
/// MODEL
/// -------------------
class DeliveryItem {
  final String name;
  final String code;
  final String car;
  final String location;
  final String customer;
  String status; // mutable status
  DateTime? lastUpdated;

  DeliveryItem({
    required this.name,
    required this.code,
    required this.car,
    required this.location,
    required this.customer,
    this.status = "Pending",
    this.lastUpdated,
  });
}

/// -------------------
/// VIEWMODEL
/// -------------------
class DeliveryViewModel {
  // For now, mock data
  List<DeliveryItem> getDeliveryItems() {
    return [
      DeliveryItem(
          name: "Brake Pads Set",
          code: "BP-HON-001",
          car: "2019 Honda Civic",
          location: "AutoFix - Bay 3",
          customer: "Mike Rodriguez"),

      DeliveryItem(
          name: "Oil Filter",
          code: "OF-HON-002",
          car: "2018 Honda Civic",
          location: "AutoFix - Bay 1",
          customer: "Sara Lee"),
    ];
  }

  // All possible statuses
  List<String> statuses = ["Pending", "Picked Up", "En Route", "Delivered"];
}

/// -------------------
/// VIEW
/// -------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = DeliveryViewModel();
    final items = viewModel.getDeliveryItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Items'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return DeliveryItemCard(
              item: items[index],
              statuses: viewModel.statuses,
            );
          },
        ),
      ),
    );
  }
}

/// -------------------
/// DELIVERY ITEM CARD (STATEFUL FOR STATUS)
/// -------------------
class DeliveryItemCard extends StatefulWidget {
  final DeliveryItem item;
  final List<String> statuses;

  const DeliveryItemCard({super.key, required this.item, required this.statuses});

  @override
  State<DeliveryItemCard> createState() => _DeliveryItemCardState();
}

class _DeliveryItemCardState extends State<DeliveryItemCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // refresh UI every 1 minute
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {}); // rebuild -> refreshes "Updated ..." text
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimeAgo(DateTime? time) {
    if (time == null) return "Never updated";
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} mins ago";
    return "${diff.inHours} hrs ago";
  }
  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name & current status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.item.status,
                      style: TextStyle(
                        color: widget.item.status == "Pending" ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.item.lastUpdated != null)
                      Text(
                        "Updated ${_formatTimeAgo(widget.item.lastUpdated)}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text("${widget.item.code}\n${widget.item.car}"),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(widget.item.location),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(widget.item.customer),
              ],
            ),
            const SizedBox(height: 12),
            const Text("Update Status:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Status buttons: 2 per row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.statuses.map((status) {
                bool isSelected = widget.item.status == status;
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 80) / 2, // 2 per row
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.item.status = status;
                        widget.item.lastUpdated = DateTime.now(); // save update time
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: isSelected ? Colors.orange : Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? Colors.orange : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility),
                label: const Text("View Full Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
