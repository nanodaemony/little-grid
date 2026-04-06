class AppConstants {
  AppConstants._();

  // 应用信息
  static const String appName = '小方格';
  static const String appNameEn = 'LittleGrid';
  static const String version = '1.0.0';

  // 数据库
  static const String dbName = 'littlegrid.db';
  static const int dbVersion = 9;
  static const int logMaxCount = 1000;

  // 分类
  static const String categoryLife = 'life';
  static const String categoryGame = 'game';
  static const String categoryCalc = 'calc';

  static const Map<String, String> categoryNames = {
    categoryLife: '生活',
    categoryGame: '趣味',
    categoryCalc: '计算',
  };
}
