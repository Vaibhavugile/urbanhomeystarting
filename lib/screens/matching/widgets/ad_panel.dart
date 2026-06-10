import 'package:flutter/material.dart';
import 'package:mytennat/screens/ad_page.dart';

class AdPanel extends StatelessWidget {
  const AdPanel({super.key});

  Widget _buildAdBanner(
    String title,
    String imageUrl,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          debugPrint('Ad Banner Tapped: $title');
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 100,
                errorBuilder:
                    (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Advertisements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        _buildAdBanner(
          'Ad 1: Exclusive Deals!',
          'https://via.placeholder.com/300x150/FF0000/FFFFFF?text=Ad+1',
        ),

        const SizedBox(height: 16),

        _buildAdBanner(
          'Ad 2: Find Your Dream Flat!',
          'https://firebasestorage.googleapis.com/v0/b/renting-wala-27d06.appspot.com/o/products%2F4444%2FIMG-20250516-WA0065.jpg?alt=media&token=edb3308a-cd11-4d39-a1a1-5026188fe1d6',
        ),

        const SizedBox(height: 16),

        _buildAdBanner(
          'Ad 3: Premium Features!',
          'https://via.placeholder.com/300x150/0000FF/FFFFFF?text=Ad+3',
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdPage(),
              ),
            );
          },
          child: const Text(
            'View All Ads',
          ),
        ),
      ],
    ),
  );
}
}