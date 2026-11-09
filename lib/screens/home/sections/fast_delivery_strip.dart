import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/catalog.dart';
import '../../../widgets/food_card.dart';
import '../../../widgets/section_header.dart';
import '../../actions.dart';

class FastDeliveryStrip extends ConsumerWidget {
  const FastDeliveryStrip({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SectionHeader('Fast delivery · 15 min or less'),
        HStrip(
          height: 206,
          itemCount: products.length,
          itemBuilder: (_, i) => SizedBox(
            width: 140,
            child: FoodCard(
              product: products[i],
              heroPrefix: 'fast',
              artSize: 76,
              onTap: () => openProduct(context, products[i]),
              onAdd: (k) => addToCart(context, ref, products[i], from: k),
            ),
          ),
        ),
      ],
    );
  }
}
