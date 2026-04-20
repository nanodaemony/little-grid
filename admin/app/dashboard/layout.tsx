'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const router = useRouter()

  useEffect(() => {
    const token = localStorage.getItem('adminToken')
    if (!token) {
      router.push('/')
    }
  }, [router])

  return (
    <div className="min-h-screen">
      <nav className="bg-slate-900 text-white p-4 flex justify-between items-center">
        <h1 className="text-xl font-bold">Admin 后台</h1>
        <button
          onClick={() => {
            localStorage.removeItem('adminToken')
            router.push('/')
          }}
          className="px-4 py-2 bg-red-600 rounded hover:bg-red-700"
        >
          退出登录
        </button>
      </nav>
      <div className="flex">
        <aside className="w-64 bg-slate-100 min-h-screen p-4">
          <nav className="space-y-2">
            <a href="/dashboard" className="block px-4 py-2 rounded hover:bg-slate-200">
              首页
            </a>
          </nav>
        </aside>
        <main className="flex-1 p-6">{children}</main>
      </div>
    </div>
  )
}
