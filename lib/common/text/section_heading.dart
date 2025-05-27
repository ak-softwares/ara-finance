
import 'package:flutter/material.dart';

import '../../utils/constants/sizes.dart';
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    this.seeActionButton = false,
    required this.title,
    this.buttonTitle = 'View all',
    this.onPressed,
    this.verticalPadding = true,
  });

  final bool seeActionButton, verticalPadding;
  final String title, buttonTitle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    List<String> titleParts = title.split(',');

    return Container(
      padding: verticalPadding ? const EdgeInsets.symmetric(vertical: AppSizes.sm) : const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              maxLines: 1, // Limit the RichText to one line
              overflow: TextOverflow.ellipsis, // Overflow handling
              text: TextSpan(
                children: [
                  TextSpan(
                    text: titleParts[0],
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (titleParts.length > 1) // Check if there's more than one part after splitting
                    TextSpan(
                      text: titleParts[1],
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ),
          if(seeActionButton)
            InkWell(
                onTap: onPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(buttonTitle, style: Theme.of(context).textTheme.bodySmall!,),
                    const Icon(Icons.arrow_right, size: 25, color: Colors.blue),
                  ],
                )
            )
        ],
      ),
    );

  }
}

class Heading extends StatelessWidget {
  const Heading({super.key, required this.title, this.paddingLeft = 0});

  final String title;
  final double paddingLeft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: paddingLeft),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}