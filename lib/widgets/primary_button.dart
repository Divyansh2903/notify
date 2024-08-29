import 'package:flutter/material.dart';
import 'package:notify/constants/colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    required this.onTap,
    this.height = 55,
    this.width = 200,
    this.bgColor = AppColors.secondaryColor,
    super.key,
  });
  final String text;
  final VoidCallback onTap;
  final double width;
  final double height;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: bgColor,
        ),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            // minFontSize: minValue,
            style: const TextStyle(
                color: AppColors.secondaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
