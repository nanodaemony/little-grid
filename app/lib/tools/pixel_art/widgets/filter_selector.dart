import 'package:flutter/material.dart';
import '../pixel_art_filters.dart';

class FilterSelector extends StatelessWidget {
  final PixelFilterType selectedFilter;
  final ValueChanged<PixelFilterType> onFilterSelected;

  const FilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '滤镜风格',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: PixelFilterType.values.length,
            itemBuilder: (context, index) {
              final filterType = PixelFilterType.values[index];
              final filter = PixelArtFilters.get(filterType);
              final isSelected = filterType == selectedFilter;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(filter.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onFilterSelected(filterType);
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
