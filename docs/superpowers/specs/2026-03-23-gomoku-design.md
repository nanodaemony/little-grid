# 五子棋功能设计文档

## 概述

在小方格应用中新增五子棋对战游戏功能格子，支持双人对战模式，棋盘大小为 100×100，支持边界拖动浏览。

## 功能需求

### 游戏模式
- **双人对战**：两个玩家在同一设备上轮流下棋
- **人机对战**：作为后续迭代，本次不实现

### 棋盘规格
- 大小：100×100 格
- 格子尺寸：40px
- 棋盘总尺寸：4000×4000px
- 初始视图：居中显示棋盘中心

### 交互方式
- 点击格子落子
- 边界拖动浏览棋盘不同区域
- 悔棋：单步悔棋
- 重新开始：清空棋盘

### 胜利判定
- 任意方向（横、竖、斜、反斜）连续 5 个同色棋子获胜
- 胜利后弹窗提示，点击确认后重新开始

## 技术设计

### 目录结构

```
lib/tools/gomoku/
├── gomoku_tool.dart      # ToolModule 实现
├── gomoku_page.dart      # 页面入口
├── gomoku_board.dart     # 棋盘绘制 + 拖动
├── gomoku_logic.dart     # 游戏逻辑
└── gomoku_models.dart    # 数据模型
```

### 数据模型

**棋子状态**
```dart
enum Stone { empty, black, white }
```

**坐标位置**
```dart
class Position {
  final int row;
  final int col;
}
```

**游戏状态**
```dart
class GomokuState {
  final List<List<Stone>> board;    // 100×100 棋盘
  final Stone currentPlayer;         // 当前玩家
  final List<Position> history;      // 落子历史
  final bool isGameOver;             // 游戏是否结束
  final Stone? winner;               // 胜者
}
```

### 游戏逻辑 (GomokuLogic)

**落子逻辑**
1. 检查目标位置是否为空
2. 落子后切换玩家
3. 记录历史用于悔棋
4. 检测胜负

**胜负判断**
- 每次落子后，检查该位置的四个方向
- 方向：水平、垂直、主对角线、副对角线
- 任意方向连续 5 个同色棋子则获胜

**悔棋逻辑**
- 从历史记录中取出最后一步
- 清空该位置
- 恢复为上一个玩家

### UI 组件

**GomokuPage**
- AppBar：标题 + 悔棋按钮 + 重新开始按钮
- Body：InteractiveViewer 包裹 GomokuBoard
- 底部：当前玩家指示器

**GomokuBoard**
- CustomPaint 绘制棋盘网格线和棋子
- GestureDetector 处理点击落子
- 使用 InteractiveViewer 实现拖动和边界约束

**胜利弹窗**
- AlertDialog 显示胜者
- 单个按钮触发重新开始

### 边界拖动实现

使用 Flutter 的 `InteractiveViewer` 组件：
- 设置 `constrained: false` 允许内容超出视口
- 通过 `boundaryMargin` 控制拖动边界
- 初始位置通过 `Matrix4.translation` 设置为棋盘中心

## 集成方式

1. 在 `main.dart` 中注册 GomokuTool
2. ToolCategory 设置为 `game`
3. 图标使用 `Icons.grid_on` 或类似棋盘图标
4. gridSize 设置为 1（小格子）

## 测试要点

1. 落子功能：黑白交替、边界落子
2. 胜负判断：四个方向的五连检测
3. 悔棋功能：单步撤回
4. 拖动功能：边界约束、初始居中
5. 重新开始：棋盘清空、状态重置