import 'package:flutter/material.dart';
import '../models/anniversary_models.dart';

class AnniversaryDialog extends StatefulWidget {
  final AnniversaryBase? item;

  const AnniversaryDialog({
    super.key,
    this.item,
  });

  @override
  State<AnniversaryDialog> createState() => _AnniversaryDialogState();
}

class _AnniversaryDialogState extends State<AnniversaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  late AnniversaryType _type;
  late RepeatType _repeatType;
  late int _selectedColor;

  final List<Color> _colorOptions = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _titleController.text = widget.item!.title;
      _notesController.text = widget.item!.notes ?? '';
      _selectedDate = widget.item!.targetDate;
      _type = widget.item!.type;
      _repeatType = widget.item!.repeatType;
      _selectedColor = widget.item!.iconColor;
    } else {
      _selectedDate = DateTime.now();
      _type = AnniversaryType.anniversary;
      _repeatType = RepeatType.none;
      _selectedColor = _colorOptions[0].value;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入标题')),
        );
        return;
      }

      AnniversaryBase result;
      if (_type == AnniversaryType.anniversary) {
        result = AnniversaryItem(
          id: widget.item?.id,
          title: _titleController.text.trim(),
          targetDate: _selectedDate,
          repeatType: _repeatType,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          iconColor: _selectedColor,
          createdAt: widget.item?.createdAt,
        );
      } else {
        result = CountdownItem(
          id: widget.item?.id,
          title: _titleController.text.trim(),
          targetDate: _selectedDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          iconColor: _selectedColor,
          createdAt: widget.item?.createdAt,
        );
      }

      Navigator.of(context).pop(result);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _getRepeatTypeText(RepeatType type) {
    switch (type) {
      case RepeatType.none:
        return '不循环';
      case RepeatType.daily:
        return '每天';
      case RepeatType.weekly:
        return '每周';
      case RepeatType.monthly:
        return '每月';
      case RepeatType.yearly:
        return '每年';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return AlertDialog(
      title: Text(isEditing ? '编辑' : '添加'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '标题 *',
                  hintText: '请输入标题',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '标题不能为空';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('日期'),
                subtitle: Text(_formatDate(_selectedDate)),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 16),
              const Text('类型'),
              const SizedBox(height: 8),
              SegmentedButton<AnniversaryType>(
                segments: const [
                  ButtonSegment(
                    value: AnniversaryType.anniversary,
                    label: Text('纪念日'),
                    icon: Icon(Icons.favorite),
                  ),
                  ButtonSegment(
                    value: AnniversaryType.countdown,
                    label: Text('倒数日'),
                    icon: Icon(Icons.timer),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _type = newSelection.first;
                    if (_type == AnniversaryType.countdown) {
                      _repeatType = RepeatType.none;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RepeatType>(
                value: _repeatType,
                decoration: const InputDecoration(
                  labelText: '循环周期',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: RepeatType.values
                    .where((type) {
                      if (_type == AnniversaryType.countdown) {
                        return type == RepeatType.none;
                      }
                      return true;
                    })
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(_getRepeatTypeText(type)),
                        ))
                    .toList(),
                onChanged: _type == AnniversaryType.countdown
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _repeatType = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 16),
              const Text('图标颜色'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorOptions.map((color) {
                  final isSelected = color.value == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color.value;
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Colors.white,
                                width: 3,
                              )
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '备注（可选）',
                  hintText: '添加备注信息',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
