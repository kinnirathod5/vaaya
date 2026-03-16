import 'package:flutter/material.dart';

// 🔥 Humara apna CustomNetworkImage use karenge
import 'custom_network_image.dart';

class PremiumAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final bool isOnline;

  const PremiumAvatar({
    super.key,
    required this.imageUrl,
    this.size = 50, // Default size 50 rakhi hai
    this.isOnline = false, // Default offline rahega
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🖼️ Main Profile Photo
        CustomNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          borderRadius: size / 2, // Hamesha perfect circle banayega
        ),

        // 🟢 Online Green Dot (Sirf tab dikhega jab isOnline true hoga)
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              // Size ke hisaab se dot automatically chhota/bada hoga
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}