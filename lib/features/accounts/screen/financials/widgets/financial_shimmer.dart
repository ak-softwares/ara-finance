import 'package:ara_finance/common/widgets/shimmers/shimmer_effect.dart';
import 'package:flutter/material.dart';

class FinancialShimmer extends StatelessWidget {

  const FinancialShimmer({super.key, this.itemCount = 3});

  final int itemCount;
  @override
  Widget build(BuildContext context) {

    return ListView.builder(
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final theme = Theme.of(context);
          final isEven = index % 2 == 0;
          return ListTile(
          tileColor: isEven ? theme.colorScheme.surface : Colors.transparent,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Row(
            children: [
              Icon(Icons.add, size: 22, color: Colors.blue,),
              const SizedBox(width: 10),
              ShimmerEffect(width: 100, height: 14)
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerEffect(width: 50, height: 14),
              const SizedBox(width: 16),
              SizedBox(
                width: 40,
                child: ShimmerEffect(width: 50, height: 14)
              ),
            ],
          ),
        );
      }
    );
  }
}
