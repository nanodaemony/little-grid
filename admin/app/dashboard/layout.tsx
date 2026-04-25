'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { TopBar } from '@/components/topbar'
import { Sidebar } from '@/components/sidebar'

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
    <div className="min-h-screen" style={{ background: 'var(--surface-dim)' }}>
      <TopBar />
      <Sidebar />
      <main
        className="overflow-y-auto"
        style={{
          position: 'fixed',
          top: 'var(--topbar-height)',
          left: 'var(--sidebar-width)',
          right: 0,
          bottom: 0,
          padding: '24px 32px 32px',
        }}
      >
        {children}
      </main>
    </div>
  )
}
