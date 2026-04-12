import 'package:flutter/material.dart';
import '../models/history_item.dart';

class HistorySection extends StatefulWidget {
  final List<HistoryItem> history;
  final ValueChanged<HistoryItem> onItemTap;
  final ValueChanged<String> onDeleteItem;
  final ValueChanged<(String, String?)> onUpdateLabel;

  const HistorySection({
    super.key,
    required this.history,
    required this.onItemTap,
    required this.onDeleteItem,
    required this.onUpdateLabel,
  });

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              '计算历史 (${widget.history.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.history.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = widget.history[index];
                return _HistoryItemTile(
                  item: item,
                  onTap: () => widget.onItemTap(item),
                  onDelete: () => widget.onDeleteItem(item.id),
                  onUpdateLabel: (label) => widget.onUpdateLabel((item.id, label)),
                );
              },
            ),
          if (_isExpanded) const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HistoryItemTile extends StatefulWidget {
  final HistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<String?> onUpdateLabel;

  const _HistoryItemTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onUpdateLabel,
  });

  @override
  State<_HistoryItemTile> createState() => _HistoryItemTileState();
}

class _HistoryItemTileState extends State<_HistoryItemTile> {
  bool _isEditingLabel = false;
  final _labelController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditingLabel)
                    TextField(
                      controller: _labelController..text = widget.item.label ?? '',
                      decoration: const InputDecoration(
                        hintText: '添加标签...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        isDense: true,
                      ),
                      onSubmitted: (value) {
                        widget.onUpdateLabel(value.isEmpty ? null : value);
                        setState(() => _isEditingLabel = false);
                      },
                      autofocus: true,
                    )
                  else
                    Row(
                      children: [
                        if (widget.item.label != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.item.label!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        if (widget.item.label == null)
                          InkWell(
                            onTap: () {
                              setState(() => _isEditingLabel = true);
                            },
                            child: Text(
                              '添加标签',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '税前 ¥${widget.item.preTaxSalary.toStringAsFixed(0)} → 税后 ¥${widget.item.afterTaxSalary.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.item.cityName} · ${_formatDate(widget.item.timestamp)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.grey,
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
