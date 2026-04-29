export interface MenuItem {
  label: string
  icon: string
  href?: string
  children?: { label: string; href: string }[]
}

export const menuItems: MenuItem[] = [
  { label: '首页', icon: 'dashboard', href: '/dashboard' },
  {
    label: '用户管理',
    icon: 'people',
    children: [
      { label: 'APP 用户', href: '/dashboard/users/app' },
      { label: '管理员', href: '/dashboard/users/admin' },
    ],
  },
  {
    label: '内容管理',
    icon: 'article',
    children: [
      { label: '树洞审核', href: '/dashboard/content/treehole' },
      { label: '举报处理', href: '/dashboard/content/reports' },
      { label: '反馈管理', href: '/dashboard/content/feedback' },
    ],
  },
  {
    label: '支付管理',
    icon: 'payment',
    children: [
      { label: '交易记录', href: '/dashboard/payments/transactions' },
      { label: '支付宝配置', href: '/dashboard/payments/alipay' },
    ],
  },
  {
    label: '运维',
    icon: 'monitor_heart',
    children: [
      { label: '监控', href: '/dashboard/ops/monitor' },
      { label: '日志', href: '/dashboard/ops/logs' },
    ],
  },
  {
    label: '工具',
    icon: 'build',
    children: [
      { label: '文件上传', href: '/dashboard/tools/upload' },
      { label: '数据库管理', href: '/dashboard/tools/database' },
      { label: '存储管理', href: '/dashboard/tools/storage' },
      { label: '缓存管理', href: '/dashboard/tools/cache' },
    ],
  },
  { label: '系统设置', icon: 'tune', href: '/dashboard/settings' },
  { label: 'API 文档', icon: 'api', href: '/dashboard/api-docs' },
]