'use client'

import { useState } from 'react'
import { TableInfo } from '../hooks/use-database'

interface TableListProps {
  tables: TableInfo[]
  selectedTable: string | null
  onSelect: (tableName: string) => void
}

export function TableList({ tables, selectedTable, onSelect }: TableListProps) {
  const [search, setSearch] = useState('')

  const filtered = tables.filter((t) =>
    t.name.toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div className="flex flex-col h-full" style={{ width: 240, background: 'var(--surface)', borderRight: '1px solid var(--outline)' }}>
      <div className="p-3" style={{ borderBottom: '1px solid var(--outline-variant)' }}>
        <div className="relative">
          <span className="material-icons-round absolute left-2.5 top-1/2 -translate-y-1/2" style={{ fontSize: 18, color: 'var(--on-surface-variant)' }}>search</span>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="搜索表名..."
            className="w-full pl-8 pr-3 py-1.5 rounded-md text-sm outline-none"
            style={{ background: 'var(--surface-container)', color: 'var(--on-surface)', border: '1px solid var(--outline-variant)' }}
          />
        </div>
      </div>
      <div className="flex-1 overflow-y-auto py-1">
        {filtered.map((table) => (
          <button
            key={table.name}
            onClick={() => onSelect(table.name)}
            className="flex items-center gap-2 w-full px-3 py-2 text-left text-sm transition-colors cursor-pointer"
            style={{
              color: selectedTable === table.name ? 'var(--primary)' : 'var(--on-surface-variant)',
              background: selectedTable === table.name ? 'var(--primary-light)' : 'transparent',
              fontWeight: selectedTable === table.name ? 500 : 400,
            }}
            onMouseEnter={(e) => {
              if (selectedTable !== table.name) e.currentTarget.style.background = 'var(--surface-container)'
            }}
            onMouseLeave={(e) => {
              if (selectedTable !== table.name) e.currentTarget.style.background = 'transparent'
            }}
          >
            <span className="material-icons-round" style={{ fontSize: 16 }}>table_chart</span>
            <span className="truncate">{table.name}</span>
            <span className="ml-auto text-xs" style={{ color: 'var(--on-surface-variant)' }}>
              {table.rowCount >= 0 ? table.rowCount : '-'}
            </span>
          </button>
        ))}
        {filtered.length === 0 && (
          <div className="px-3 py-6 text-center text-sm" style={{ color: 'var(--on-surface-variant)' }}>
            无匹配表
          </div>
        )}
      </div>
    </div>
  )
}
