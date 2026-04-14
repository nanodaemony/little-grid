-- 数据库浏览器菜单和权限初始化脚本
-- 请根据实际情况调整 menu_id 和 pid

-- 1. 添加一级菜单（系统工具下），pid=36 是"系统工具"的 menu_id
INSERT INTO `sys_menu` (`menu_id`, `pid`, `sub_count`, `type`, `title`, `name`, `component`, `menu_sort`, `icon`, `path`, `i_frame`, `cache`, `hidden`, `permission`, `create_by`, `update_by`, `create_time`, `update_time`)
VALUES (200, 36, 4, 1, '数据库浏览器', 'DatabaseBrowser', 'tools/databaseBrowser/index', 60, 'date', 'database-browser', b'0', b'0', b'0', 'databaseBrowser:list', 'admin', NULL, NOW(), NULL);

-- 2. 添加子菜单 - 查看数据
INSERT INTO `sys_menu` (`menu_id`, `pid`, `sub_count`, `type`, `title`, `name`, `component`, `menu_sort`, `icon`, `path`, `i_frame`, `cache`, `hidden`, `permission`, `create_by`, `update_by`, `create_time`, `update_time`)
VALUES (201, 200, 0, 2, '查看', NULL, NULL, 1, NULL, NULL, b'0', b'0', b'0', 'databaseBrowser:list', 'admin', NULL, NOW(), NULL);

-- 3. 添加子菜单 - 新增数据
INSERT INTO `sys_menu` (`menu_id`, `pid`, `sub_count`, `type`, `title`, `name`, `component`, `menu_sort`, `icon`, `path`, `i_frame`, `cache`, `hidden`, `permission`, `create_by`, `update_by`, `create_time`, `update_time`)
VALUES (202, 200, 0, 2, '新增', NULL, NULL, 2, NULL, NULL, b'0', b'0', b'0', 'databaseBrowser:add', 'admin', NULL, NOW(), NULL);

-- 4. 添加子菜单 - 编辑数据
INSERT INTO `sys_menu` (`menu_id`, `pid`, `sub_count`, `type`, `title`, `name`, `component`, `menu_sort`, `icon`, `path`, `i_frame`, `cache`, `hidden`, `permission`, `create_by`, `update_by`, `create_time`, `update_time`)
VALUES (203, 200, 0, 2, '编辑', NULL, NULL, 3, NULL, NULL, b'0', b'0', b'0', 'databaseBrowser:edit', 'admin', NULL, NOW(), NULL);

-- 5. 添加子菜单 - 删除数据
INSERT INTO `sys_menu` (`menu_id`, `pid`, `sub_count`, `type`, `title`, `name`, `component`, `menu_sort`, `icon`, `path`, `i_frame`, `cache`, `hidden`, `permission`, `create_by`, `update_by`, `create_time`, `update_time`)
VALUES (204, 200, 0, 2, '删除', NULL, NULL, 4, NULL, NULL, b'0', b'0', b'0', 'databaseBrowser:del', 'admin', NULL, NOW(), NULL);

-- 6. 更新系统工具菜单的 sub_count（原先是 6，现在加 1 变成 7）
UPDATE `sys_menu` SET `sub_count` = 7 WHERE `menu_id` = 36;
