import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_scanner/shared/constants.dart';

class CustomButton extends StatelessWidget {
  final String innerText;
  final void Function()? onPressed;
  final double borderRadius;
  final Widget? suffixIcon;

  const CustomButton({
    super.key,
    required this.innerText,
    required this.onPressed,
    this.borderRadius = 26,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  Text(
                    innerText,
                    style: TextStyle(color: Colors.white, fontSize: 20.sp),
                  ),
                  if (suffixIcon != null)
                    ...[
                      SizedBox(width: 10.w,),
                      suffixIcon!
                    ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
