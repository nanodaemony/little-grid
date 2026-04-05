import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'models/wheel_collection.dart';
import 'models/wheel_option.dart';
import 'services/big_wheel_service.dart';
import 'widgets/wheel_painter.dart';
import 'widgets/wheel_pointer.dart';
import 'widgets/result_dialog.dart';

/// Single wheel view with animation
class BigWheelView extends StatefulWidget {
  final WheelCollection collection;
  final VoidCallback? onEditCollection;
  final VoidCallback? onManageOptions;

  const BigWheelView({
    super.key,
    required this.collection,
    this.onEditCollection,
    this.onManageOptions,
  });

  @override
  State<BigWheelView> createState() => _BigWheelViewState();
}

class _BigWheelViewState extends State<BigWheelView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<WheelOption> _options = [];
  bool _isSpinning = false;
  double _currentRotation = 0.0;
  double _targetRotation = 0.0;

  // Wheel configuration
  static const double _minRotations = 3.0;
  static const double _maxRotations = 8.0;
  static const Duration _spinDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _spinDuration,
      vsync: this,
    );
    _animationController.addListener(_onAnimationUpdate);
    _animationController.addStatusListener(_onAnimationStatusChange);
    _loadOptions();
  }

  @override
  void didUpdateWidget(covariant BigWheelView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collection.id != widget.collection.id) {
      _loadOptions();
      _currentRotation = 0.0;
      _targetRotation = 0.0;
    }
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationUpdate);
    _animationController.removeStatusListener(_onAnimationStatusChange);
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    if (widget.collection.id == null) return;
    try {
      final options = await BigWheelService.getOptions(widget.collection.id!);
      setState(() {
        _options = options;
      });
    } catch (e) {
      debugPrint('Error loading options: $e');
    }
  }

  void _onAnimationUpdate() {
    setState(() {
      _currentRotation = _animation.value;
    });
  }

  void _onAnimationStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isSpinning = false;
      });
      _showResult();
    }
  }

  /// Select a random option based on weights
  WheelOption _selectRandomOption() {
    final totalWeight = _options.fold<double>(
      0,
      (sum, option) => sum + option.weight,
    );
    final random = math.Random();
    double randomValue = random.nextDouble() * totalWeight;

    for (final option in _options) {
      randomValue -= option.weight;
      if (randomValue <= 0) {
        return option;
      }
    }
    return _options.last;
  }

  /// Calculate the target rotation angle to land on the selected option
  /// The pointer is at the top (270 degrees or -90 degrees in standard position)
  /// We need the selected option's sector to end up under the pointer
  double _calculateTargetRotation(WheelOption selectedOption) {
    final totalWeight = _options.fold<double>(
      0,
      (sum, option) => sum + option.weight,
    );

    // Find the selected option's position in the list
    double currentAngle = 0;
    double selectedStartAngle = 0;
    double selectedSweepAngle = 0;

    for (final option in _options) {
      final sweepAngle = (option.weight / totalWeight) * 2 * math.pi;
      if (option.id == selectedOption.id) {
        selectedStartAngle = currentAngle;
        selectedSweepAngle = sweepAngle;
        break;
      }
      currentAngle += sweepAngle;
    }

    // The pointer is at the top (-90 degrees or 270 degrees in standard position)
    // We want the middle of the selected sector to be at the pointer
    // Current sector middle angle
    final sectorMiddleAngle = selectedStartAngle + selectedSweepAngle / 2;

    // To land at the top (which is -PI/2 in standard position where 0 is right)
    // We need to rotate the wheel so that sectorMiddleAngle ends up at -PI/2
    // targetAngle = -PI/2 - sectorMiddleAngle
    final baseTarget = -math.pi / 2 - sectorMiddleAngle;

    // Add random number of rotations (3-8 full rotations)
    final random = math.Random();
    final rotations = _minRotations + random.nextDouble() * (_maxRotations - _minRotations);
    final fullRotation = rotations * 2 * math.pi;

    // Make sure we rotate in the positive direction
    return _currentRotation + fullRotation + (baseTarget - (_currentRotation % (2 * math.pi)));
  }

  void _spin() {
    if (_isSpinning || _options.isEmpty) return;

    final selectedOption = _selectRandomOption();
    _targetRotation = _calculateTargetRotation(selectedOption);

    // Store selected option for result dialog
    _selectedOption = selectedOption;

    setState(() {
      _isSpinning = true;
    });

    _animation = Tween<double>(
      begin: _currentRotation,
      end: _targetRotation,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.decelerate,
      ),
    );

    _animationController.reset();
    _animationController.forward();
  }

  WheelOption? _selectedOption;

  void _showResult() {
    if (_selectedOption == null) return;

    showResultDialog(
      context: context,
      option: _selectedOption!,
      onClose: () {
        Navigator.of(context).pop();
      },
      onSpinAgain: () {
        Navigator.of(context).pop();
        // Small delay before spinning again
        Future.delayed(const Duration(milliseconds: 300), _spin);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Collection header
        _buildHeader(),

        // Wheel area
        Expanded(
          child: Center(
            child: _buildWheelArea(),
          ),
        ),

        // Spin button and controls
        _buildControls(),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Collection icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                widget.collection.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Collection name
          Text(
            widget.collection.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelArea() {
    if (_options.isEmpty) {
      return _buildEmptyWheel();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // The spinning wheel
        RepaintBoundary(
          child: CustomPaint(
            size: const Size(300, 300),
            painter: WheelPainter(
              options: _options,
              rotationAngle: _currentRotation,
            ),
          ),
        ),

        // Fixed pointer at the top
        Positioned(
          top: -5,
          child: WheelPointer(size: 30),
        ),
      ],
    );
  }

  Widget _buildEmptyWheel() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              '暂无选项',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '点击管理添加选项',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Edit collection button
          _buildActionButton(
            icon: Icons.edit,
            label: '编辑',
            onPressed: widget.onEditCollection,
          ),
          const SizedBox(width: 24),
          // Spin button
          _buildSpinButton(),
          const SizedBox(width: 24),
          // Manage options button
          _buildActionButton(
            icon: Icons.settings,
            label: '管理',
            onPressed: widget.onManageOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildSpinButton() {
    final bool canSpin = _options.isEmpty == false && !_isSpinning;

    return GestureDetector(
      onTap: canSpin ? _spin : null,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: canSpin
                ? [Colors.blue, Colors.blue.shade700]
                : [Colors.grey.shade400, Colors.grey.shade500],
          ),
          shape: BoxShape.circle,
          boxShadow: canSpin
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.rotate_right,
                size: 32,
                color: canSpin ? Colors.white : Colors.grey.shade300,
              ),
              const SizedBox(height: 4),
              Text(
                '开始',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: canSpin ? Colors.white : Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: onPressed != null ? Colors.blue : Colors.grey.shade400,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: onPressed != null ? Colors.blue : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
