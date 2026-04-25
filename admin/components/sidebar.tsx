'use client'

import { useState } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { menuItems } from '@/lib/menu-config'

export function Sidebar() {
  const pathname = usePathname()
  const [expanded, setExpanded] = useState<Record<string, boolean>>({})

  const toggleExpand = (label: string) => {
    setExpanded((prev) => ({ ...prev, [label]: !prev[label] }))
  }

  const isItemActive = (href: string) => pathname === href
  const isParentActive = (children: { href: string }[]) =>
    children.some((c) => pathname === c.href)

  return (
    <aside
      className="fixed left-0 bottom-0 overflow-y-auto py-2 bg-white border-r"
      style={{
        top: 'var(--topbar-height)',
        width: 'var(--sidebar-width)',
        borderColor: 'var(--outline)',
      }}
    >
      <nav className="flex flex-col gap-0.5 px-3">
        {menuItems.map((item) => {
          if (item.children) {
            const parentActive = isParentActive(item.children)
            const isOpen = expanded[item.label] || parentActive

            return (
              <div key={item.label}>
                <button
                  onClick={() => toggleExpand(item.label)}
                  className="flex items-center gap-3.5 w-full h-11 px-4 rounded-lg text-sm transition-colors cursor-pointer"
                  style={{
                    color: parentActive ? 'var(--primary)' : 'var(--on-surface-variant)',
                    background: parentActive ? 'var(--primary-light)' : 'transparent',
                    fontWeight: parentActive ? 500 : 400,
                  }}
                  onMouseEnter={(e) => {
                    if (!parentActive) e.currentTarget.style.background = 'var(--surface-container)'
                  }}
                  onMouseLeave={(e) => {
                    if (!parentActive) e.currentTarget.style.background = 'transparent'
                  }}
                >
                  <span className="material-icons-round" style={{ fontSize: 20 }}>{item.icon}</span>
                  <span>{item.label}</span>
                  <span
                    className="material-icons-round ml-auto transition-transform"
                    style={{
                      fontSize: 18,
                      color: 'var(--on-surface-variant)',
                      transform: isOpen ? 'rotate(90deg)' : 'rotate(0)',
                    }}
                  >
                    chevron_right
                  </span>
                </button>
                <div
                  className="overflow-hidden transition-[max-height] duration-200"
                  style={{ maxHeight: isOpen ? 300 : 0 }}
                >
                  {item.children.map((child) => (
                    <Link
                      key={child.href}
                      href={child.href}
                      className="flex items-center gap-3.5 h-[38px] pl-[50px] pr-4 rounded-lg text-[13px] transition-colors"
                      style={{
                        color: isItemActive(child.href) ? 'var(--primary)' : 'var(--on-surface-variant)',
                        background: isItemActive(child.href) ? 'var(--primary-light)' : 'transparent',
                        fontWeight: isItemActive(child.href) ? 500 : 400,
                      }}
                      onMouseEnter={(e) => {
                        if (!isItemActive(child.href)) e.currentTarget.style.background = 'var(--surface-container)'
                      }}
                      onMouseLeave={(e) => {
                        if (!isItemActive(child.href)) e.currentTarget.style.background = 'transparent'
                      }}
                    >
                      <span
                        className="shrink-0 rounded-full transition-all"
                        style={{
                          width: 6,
                          height: 6,
                          background: isItemActive(child.href) ? 'var(--primary)' : 'var(--outline)',
                        }}
                      />
                      {child.label}
                    </Link>
                  ))}
                </div>
              </div>
            )
          }

          return (
            <Link
              key={item.label}
              href={item.href!}
              className="flex items-center gap-3.5 h-11 px-4 rounded-lg text-sm transition-colors"
              style={{
                color: isItemActive(item.href!) ? 'var(--primary)' : 'var(--on-surface-variant)',
                background: isItemActive(item.href!) ? 'var(--primary-light)' : 'transparent',
                fontWeight: isItemActive(item.href!) ? 500 : 400,
              }}
              onMouseEnter={(e) => {
                if (!isItemActive(item.href!)) e.currentTarget.style.background = 'var(--surface-container)'
              }}
              onMouseLeave={(e) => {
                if (!isItemActive(item.href!)) e.currentTarget.style.background = 'transparent'
              }}
            >
              <span className="material-icons-round" style={{ fontSize: 20 }}>{item.icon}</span>
              <span>{item.label}</span>
            </Link>
          )
        })}
      </nav>
      <div className="mt-4 mx-4 pt-4 border-t flex items-center gap-1.5 text-xs" style={{ borderColor: 'var(--outline-variant)', color: 'var(--on-surface-variant)' }}>
        <span className="material-icons-round" style={{ fontSize: 14 }}>info</span>
        v0.1.0 · build 2026.04
      </div>
    </aside>
  )
}