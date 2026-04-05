import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import '../../core/ui/app_colors.dart';
import 'calendar_models.dart';
import 'calendar_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  Set<String> _datesWithNotes = {};
  List<CalendarNote> _selectedDateNotes = [];
  late PageController _pageController;
  static const int _initialPage = 1200; // 足够大的中间值，支持前后100年

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _pageController = PageController(initialPage: _initialPage);
    _loadDatesWithNotes();
    _loadNotesForDate(_formatDate(DateTime.now()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDatesWithNotes() async {
    final dates = await CalendarService.getDatesWithNotes(
      _currentMonth.year,
      _currentMonth.month,
    );
    setState(() {
      _datesWithNotes = dates;
    });
  }

  Future<void> _loadNotesForDate(String date) async {
    final notes = await CalendarService.getNotesByDate(date);
    setState(() {
      _selectedDateNotes = notes;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _previousMonth() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextMonth() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page) {
    final now = DateTime.now();
    final monthOffset = page - _initialPage;
    final newMonth = DateTime(now.year, now.month + monthOffset, 1);
    setState(() {
      _currentMonth = newMonth;
    });
    _loadDatesWithNotes();
  }

  DateTime _getMonthFromPageIndex(int index) {
    final now = DateTime.now();
    final monthOffset = index - _initialPage;
    return DateTime(now.year, now.month + monthOffset, 1);
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadNotesForDate(_formatDate(date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日历'),
      ),
      body: Column(
        children: [
          // 月份切换
          _buildMonthHeader(),
          // 星期标题
          _buildWeekdayHeader(),
          // 日历网格（支持滑动）
          Expanded(child: _buildCalendarGrid()),
          // 记事列表
          SizedBox(
            height: 200,
            child: _buildNotesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedDate == null ? null : _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            '${_currentMonth.year}年${_currentMonth.month}月',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
      ),
      child: Row(
        children: weekdays.map((day) {
          final isWeekend = day == '六' || day == '日';
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color: isWeekend ? AppColors.error : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: _initialPage * 2,
      itemBuilder: (context, index) {
        final month = _getMonthFromPageIndex(index);
        return _buildMonthGrid(month);
      },
    );
  }

  Widget _buildMonthGrid(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // 计算第一天是周几（1-7，周一为1）
    int startWeekday = firstDayOfMonth.weekday;

    final days = <Widget>[];

    // 填充月初空白
    for (int i = 1; i < startWeekday; i++) {
      days.add(const SizedBox());
    }

    // 填充日期
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(month.year, month.month, day);
      days.add(_buildDayCell(date));
    }

    return GridView.count(
      crossAxisCount: 7,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
    );
  }

  Widget _buildDayCell(DateTime date) {
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final isSelected = _selectedDate != null &&
        date.year == _selectedDate!.year &&
        date.month == _selectedDate!.month &&
        date.day == _selectedDate!.day;
    final isWeekend = date.weekday == 6 || date.weekday == 7;
    final dateStr = _formatDate(date);
    final hasNote = _datesWithNotes.contains(dateStr);

    // 农历信息
    final lunar = Lunar.fromDate(date);
    final lunarDay = lunar.getDayInChinese();
    final lunarMonth = lunar.getMonthInChinese();
    final solarTerm = lunar.getJieQi();
    final festival = lunar.getFestivals();

    // 显示内容：优先节假日，其次农历
    String displayText = lunarDay;
    if (solarTerm != null && solarTerm.isNotEmpty) {
      displayText = solarTerm;
    } else if (festival.isNotEmpty) {
      displayText = festival.first;
    } else if (lunarDay == '初一') {
      displayText = lunarMonth;
    }

    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : null,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isWeekend
                              ? AppColors.error
                              : AppColors.textPrimary,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? Colors.white70
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (hasNote && !isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    if (_selectedDate == null) {
      return const Center(child: Text('请选择日期'));
    }

    if (_selectedDateNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text('暂无记事', style: TextStyle(color: AppColors.textTertiary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedDateNotes.length,
      itemBuilder: (context, index) {
        final note = _selectedDateNotes[index];
        return Card(
          child: ListTile(
            title: Text(note.content),
            subtitle: Text(
              '创建于 ${_formatDateTime(note.createdAt)}',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteNote(note),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _addNote() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('添加记事 - ${_selectedDate!.month}/${_selectedDate!.day}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '输入记事内容',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      final note = CalendarNote(
        date: _formatDate(_selectedDate!),
        content: controller.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await CalendarService.addNote(note);
      _loadDatesWithNotes();
      _loadNotesForDate(_formatDate(_selectedDate!));
    }
  }

  Future<void> _deleteNote(CalendarNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记事吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && note.id != null) {
      await CalendarService.deleteNote(note.id!);
      _loadDatesWithNotes();
      _loadNotesForDate(_formatDate(_selectedDate!));
    }
  }
}