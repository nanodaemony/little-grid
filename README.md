<div align="center">

# <img src="https://img.shields.io/badge/小方格-LittleGrid-5B9BD5?style=for-the-badge&logo=flutter&logoColor=white" alt="LittleGrid"/>

### 🧩 一个优雅的模块化工具集合

<img src="https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat-square&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=flat-square" />
<img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" />
<img src="https://img.shields.io/badge/Version-1.0.1-orange?style=flat-square" />

</div>

---

<p align="center">
  <b>🎲 投硬币</b> · <b>🎯 掷骰子</b> · <b>🃏 抽卡</b> · <b>✅ 待办事项</b> · <b>🔢 计算器</b>
</p>

---

## ✨ 特性

<table>
<tr>
<td width="50%">

### 🧩 模块化架构
- **即插即用** - 每个工具都是独立模块
- **一键注册** - `ToolRegistry.register()` 即可添加新工具
- **生命周期管理** - 完整的 init/dispose/enter/exit 钩子

</td>
<td width="50%">

### 🎨 精美设计
- **Material 3** - 现代化设计语言
- **清新配色** - 淡蓝色主题，赏心悦目
- **流畅动画** - flutter_animate 加持

</td>
</tr>
<tr>
<td width="50%">

### 📊 数据驱动
- **使用统计** - 追踪每个工具的使用频率
- **智能排序** - 常用工具自动靠前
- **本地存储** - SQLite 持久化数据

</td>
<td width="50%">

### 🔧 高度可扩展
- **分类系统** - 生活/游戏/计算三大分类
- **自定义配置** - 每个工具可独立配置
- **置顶功能** - 快速访问常用工具

</td>
</tr>
</table>

---

## 🛠️ 内置工具

| 工具 | 分类 | 描述 |
|:---:|:---:|:---|
| 🪙 **投硬币** | `LIFE` | 正反面随机，快速决策 |
| 🎲 **掷骰子** | `GAME` | 支持1-6个骰子，动画效果 |
| 🃏 **抽卡** | `GAME` | 随机抽取，趣味十足 |
| ✅ **待办事项** | `LIFE` | 简洁的任务管理 |
| 🔢 **计算器** | `CALC` | 支持复杂表达式计算 |
| ⚖️ **BMI计算器** | `CALC` | 计算身体质量指数，提供健康建议 |

---

## 🚀 快速开始

### 环境要求

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`

### 安装运行

```bash
# 克隆项目
git clone https://github.com/yourusername/littlegrid.git
cd littlegrid/app

# 安装依赖
flutter pub get

# 运行 (Android)
flutter run

# 运行 (iOS)
cd ios && pod install && cd .. && flutter run
```

---

## 📦 项目结构

```
app/lib/
├── main.dart              # 应用入口
├── core/                  # 核心模块
│   ├── constants/         # 常量定义
│   ├── models/            # 数据模型
│   ├── services/          # 服务层
│   │   ├── tool_registry.dart   # 工具注册中心 ⭐
│   │   ├── database_service.dart
│   │   ├── storage_service.dart
│   │   └── usage_service.dart
│   └── ui/                # UI组件
│       ├── app_colors.dart
│       └── theme.dart
├── pages/                 # 页面
│   ├── grid_page.dart     # 工具格子页
│   └── profile_page.dart  # 个人中心
├── providers/             # 状态管理
│   └── app_provider.dart
└── tools/                 # 工具模块
    ├── coin/              # 投硬币
    ├── dice/              # 掷骰子
    ├── card/              # 抽卡
    ├── todo/              # 待办事项
    └── calculator/         # 计算器
```

---

## 🔌 创建新工具

只需 3 步，即可创建一个新工具：

### 1️⃣ 创建工具模块

```dart
// tools/my_tool/my_tool.dart
class MyTool implements ToolModule {
  @override
  String get id => 'my_tool';

  @override
  String get name => '我的工具';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.extension;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) => MyToolPage();
}
```

### 2️⃣ 注册工具

```dart
// main.dart
void main() {
  ToolRegistry.register(MyTool());
  runApp(const MyApp());
}
```

### 3️⃣ 完成！

新工具会自动出现在格子页面 🎉

---

## 🎯 技术栈

| 技术 | 用途 |
|:---:|:---|
| **Flutter** | 跨平台 UI 框架 |
| **Provider** | 状态管理 |
| **SQLite** | 本地数据存储 |
| **fl_chart** | 图表可视化 |
| **flutter_animate** | 流畅动画 |
| **math_expressions** | 数学表达式解析 |

---

## 📸 界面预览

<div align="center">

| 工具格子 | 个人中心 |
|:---:|:---:|
| 🔲 工具网格布局 | 👤 使用统计 |

</div>

---

## 🤝 参与贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

---

## 📝 开发计划

- [ ] 深色模式支持
- [ ] 更多实用工具
- [ ] 云同步功能
- [ ] 小组件支持
- [ ] 自定义主题

---

<div align="center">

## 📄 License

MIT License © 2024 LittleGrid

---

**Made with ❤️ by LittleGrid Team**

⭐ 如果这个项目对你有帮助，请给个 Star！

</div>