import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_scanner/shared/constants.dart';

class CustomButton extends StatelessWidget {
  final String innerText;
  final void Function()? onPressed;
  final bool havePrefix;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.innerText,
    required this.onPressed,
    this.havePrefix = false,
    this.borderRadius = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw - 35.w,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (havePrefix)
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                  Text(
                    innerText,
                    style: TextStyle(color: Colors.white, fontSize: 20.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
