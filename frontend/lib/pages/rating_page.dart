import 'package:flutter/material.dart';


// Separated Star Rating Widget for reusability and cleaner code
class StarRatingWidget extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final Color selectedStarColor;
  final Color unselectedStarColor;

  const StarRatingWidget({
    super.key,
    this.rating = 0,
    required this.onRatingChanged,
    this.selectedStarColor = const Color(0xFF5B7C6E), // Darker green for selected stars
    this.unselectedStarColor = const Color(0xFFAABFAD), // Lighter green for unselected stars
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            onRatingChanged(index + 1);
          },
          icon: Icon(
            index < rating ? Icons.star_rounded : Icons.star_border_rounded, // Use rounded stars
            color: index < rating ? selectedStarColor : unselectedStarColor,
            size: 48, // Slightly larger stars
          ),
          splashRadius: 28, // Larger splash effect
        );
      }),
    );
  }
}

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 0; // Variable to hold the current star rating

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4EF), // A softer, light green-ish background
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B7C6E), // A rich, deep green for the app bar
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Rate Your Experience', // More engaging title
          style: TextStyle(
            fontWeight: FontWeight.w600, // Medium bold
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28), // Rounded close icon
          onPressed: () {
            // Add logic to close the page, e.g., Navigator.of(context).pop();  logic ตอนกดปิด
         
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0), // More vertical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image (using a placeholder for now, ideally an actual image)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFCAD7C8), // Light grey-green background for profile
                border: Border.all(color: const Color(0xFF5B7C6E), width: 3), // Accent border
              ),
              child: const Icon(
                Icons.person_rounded, // Rounded person icon
                size: 60,
                color: Color(0xFF5B7C6E), // Dark green icon
              ),
            ),
            const SizedBox(height: 16),

            // User Name
            const Text(
              'Sherlock Mority',
              style: TextStyle(
                fontSize: 26, // Slightly larger
                fontWeight: FontWeight.w700, // Heavier bold
                color: Color(0xFF3B4A3D), // Very dark green/almost black
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // "How was your experience?" Text
            const Text(
              'How was your experience?',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w500, // Slightly lighter bold
                color: Color(0xFF5B7C6E), // Matching green color
              ),
            ),
            const SizedBox(height: 30),

            // Star Rating Section using the separated widget
            StarRatingWidget(
              rating: _rating,
              onRatingChanged: (newRating) {
                setState(() {
                  _rating = newRating;
                });
              },
              selectedStarColor: const Color(0xFFF7B12C), // Gold color for selected stars
              unselectedStarColor: const Color(0xFFD3D3D3), // Light grey for unselected stars
            ),
            const SizedBox(height: 40),

            // Comment Text Field with a subtle card-like appearance
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4), // subtle shadow
                  ),
                ],
              ),
              child: TextField(
                maxLines: 5, // Allow more lines for comment
                decoration: InputDecoration(
                  hintText: 'Share your thoughts with us...', // More inviting hint text
                  hintStyle: const TextStyle(color: Color(0xFFAABFAD), fontSize: 16),
                  contentPadding: const EdgeInsets.all(20.0), // More padding inside text field
                  border: InputBorder.none, // Remove default border
                ),
                style: const TextStyle(color: Color(0xFF3B4A3D), fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),

            // Submit Button with modern styling
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add your submission logic here
                  print('Submitted rating: $_rating');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7C6E), // Dark green button
                  padding: const EdgeInsets.symmetric(vertical: 18), // Taller button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // More rounded corners
                  ),
                  elevation: 5, // Add some shadow to the button
                  shadowColor: const Color(0xFF5B7C6E).withOpacity(0.4),
                ),
                child: const Text(
                  'Submit Rating', // More descriptive button text
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600, // Medium bold
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}