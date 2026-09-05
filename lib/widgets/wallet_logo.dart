import 'package:flutter/material.dart';

class WalletLogoWidget extends StatelessWidget {
  final String name;
  final String fallbackIcon;
  final double size;

  const WalletLogoWidget({
    super.key,
    required this.name,
    this.fallbackIcon = '👛',
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final lowerName = name.trim().toLowerCase();

    // 1. GCash Logo Badge (Matching reference image: bright blue circle with white G)
    if (lowerName.contains('gcash')) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFF007DFF),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.52,
                  fontFamily: 'sans-serif',
                ),
              ),
              Icon(
                Icons.wifi,
                size: size * 0.28,
                color: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    // 2. BPI Logo Badge (Matching reference image: red rounded rect with BPI text)
    if (lowerName.contains('bpi')) {
      return Container(
        width: size * 1.2,
        height: size * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFFB71C1C),
          borderRadius: BorderRadius.circular(size * 0.2),
        ),
        child: Center(
          child: Text(
            'BPI',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.4,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );
    }

    // 3. Wise Logo Badge (Matching reference image: bright lime green with Wise symbol)
    if (lowerName.contains('wise')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF8EDE27),
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
        child: Center(
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(
              Icons.flash_on_rounded,
              size: size * 0.65,
              color: const Color(0xFF163300),
            ),
          ),
        ),
      );
    }

    // 4. Maya Logo Badge
    if (lowerName.contains('maya')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF00D632),
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
        child: Center(
          child: Text(
            'm',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.6,
            ),
          ),
        ),
      );
    }

    // 5. BDO Logo Badge
    if (lowerName.contains('bdo')) {
      return Container(
        width: size * 1.2,
        height: size * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFF0B3C5D),
          borderRadius: BorderRadius.circular(size * 0.2),
          border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        ),
        child: Center(
          child: Text(
            'BDO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.38,
            ),
          ),
        ),
      );
    }

    // 6. GoTyme Logo Badge
    if (lowerName.contains('gotyme')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF00B4D8),
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
        child: Center(
          child: Icon(
            Icons.diamond_outlined,
            size: size * 0.6,
            color: Colors.white,
          ),
        ),
      );
    }

    // 7. SeaBank Logo Badge
    if (lowerName.contains('seabank')) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFF57C00),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'S',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.55,
            ),
          ),
        ),
      );
    }

    // 8. PayPal Logo Badge
    if (lowerName.contains('paypal')) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFF003087),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            'P',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: size * 0.55,
            ),
          ),
        ),
      );
    }

    // Fallback: Emoji Icon
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      child: Text(
        fallbackIcon,
        style: TextStyle(fontSize: size * 0.55),
      ),
    );
  }
}
