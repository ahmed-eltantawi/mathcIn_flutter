import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
  });

  final String? labelText;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;


  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;
  late FocusNode _focusNode;
  bool _hasLostFocusOnce = false; // المتغير ده اللي هيتحكم في ظهور الإيرور

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode();

    // هنا بنراقب اليوزر، أول ما يسيب الحقل بنشغل الفاليديشن
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _hasLostFocusOnce = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(widget.labelText!),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          // الفاليديشن اللحظي مش هيشتغل غير بعد ما اليوزر يسيب الحقل لأول مرة
          autovalidateMode: _hasLostFocusOnce
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}
