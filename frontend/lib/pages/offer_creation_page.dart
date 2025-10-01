import 'package:flutter/material.dart';

class OfferCreationPage extends StatelessWidget {
  final String targetItemId;
  final String targetItemName;

  const OfferCreationPage({
    super.key, 
    required this.targetItemId, 
    required this.targetItemName
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Make an Offer for $targetItemName')),
      body: Center(
        child: Column(
          children: [
            // List/Grid of user's own items for them to select
            const Text('Select one of your items to offer:'),
            // ... Your list building logic here ...
            
            ElevatedButton(
              onPressed: () {
                // CONCEPTUAL: Replace this with the actual item the user selected
                final selectedItemData = {'id': 'user_item_123', 'name': 'My Cool Hat'};
                
                // CRITICAL: Use Navigator.pop to return the selected data to HomePage
                Navigator.of(context).pop(selectedItemData);
              },
              child: const Text('Confirm Offer'),
            ),
            ElevatedButton(
              onPressed: () {
                // Pop with null if the user cancels
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}