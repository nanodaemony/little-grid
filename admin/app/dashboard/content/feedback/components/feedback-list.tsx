'use client'

import { useState, useEffect, useCallback } from 'react'
import { useFeedback, FeedbackListItem } from '../hooks/use-feedback'

interface FeedbackListProps {
  onSelect: (item: FeedbackListItem) => void
  selectedId: number | null
}

export function FeedbackList({ onSelect, selectedId }: FeedbackListProps) {
  const { fetchFeedbackList, markAsRead, loading, error } = useFeedback()
  const [items, setItems] = useState<FeedbackListItem[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [size, setSize] = useState(20)
  const [typeFilter, setTypeFilter] = useState<string>('')
  const [statusFilter, setStatusFilter] = useState<string>('')

  const loadData = useCallback(async () => {
    try {
      const data = await fetchFeedbackList(page, size, typeFilter || undefined, statusFilter || undefined)
      setItems(data.content)
      setTotal(data.totalElements)
    } catch {}
  }, [page, size, typeFilter, statusFilter, fetchFeedbackList])

  useEffect(() => {
    loadData()
  }, [loadData])

  const handleMarkAsRead = async (id: number, e: React.MouseEvent) => {
    e.stopPropagation()
    try {
      await markAsRead(id)
      loadData()
    } catch {}
  }

  const formatDate = (timestamp: number) => {
    return new Date(timestamp).toLocaleString('zh-CN')
  }

  const getTypeLabel = (type: string) => {
    return type === 'SUGGESTION' ? '建议' : '问题'
  }

  const getStatusLabel = (status: string) => {
    return status === 'READ' ? '已读' : '未读'
  }

  const totalPages = Math.ceil(total / size)

  return (
    <div className="flex flex-col h-full" style={{ width: 480, background: 'var(--surface)', borderRight: '1px solid var(--outline)' }}>
      <div className="p-4" style={{ borderBottom: '1px solid var(--outline-variant)' }}>
        <h2 className="text-base font-semibold mb-3" style={{ color: 'var(--on-surface)' }}>反馈列表</h2>

        <div className="flex gap-2 mb-3">
          <select
            value={typeFilter}
            onChange={(e) => { setTypeFilter(e.target.value); setPage(1) }}
            className="flex-1 px-2 py-1.5 rounded-md text-sm outline-none"
            style={{ background: 'var(--surface-container)', color: 'var(--on-surface-variant)', border: '1px solid var(--outline-variant)' }}
          >
            <option value="">全部类型</option>
            <option value="SUGGESTION">建议</option>
            <option value="ISSUE">问题</option>
          </select>
          <select
            value={statusFilter}
            onChange={(e) => { setStatusFilter(e.target.value); setPage(1) }}
            className="flex-1 px-2 py-1.5 rounded-md text-sm outline-none"
            style={{ background: 'var(--surface-container)', color: 'var(--on-surface-variant)', border: '1px solid var(--outline-variant)' }}
          >
            <option value="">全部状态</option>
            <option value="PENDING">未读</option>
            <option value="READ">已读</option>
          </select>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={loadData}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm cursor-pointer"
            style={{ color: 'var(--on-surface-variant)', background: 'var(--surface-container)' }}
          >
            <span className="material-icons-round" style={{ fontSize: 16 }}>refresh</span>
            刷新
          </button>
          <select
            value={size}
            onChange={(e) => { setSize(Number(e.target.value)); setPage(1) }}
            className="px-2 py-1.5 rounded-md text-sm outline-none ml-auto"
            style={{ background: 'var(--surface-container)', color: 'var(--on-surface-variant)', border: '1px solid var(--outline-variant)' }}
          >
            {[10, 20, 50].map((s) => (
              <option key={s} value={s}>{s} 条/页</option>
            ))}
          </select>
        </div>

        {error && (
          <p className="text-sm mt-2" style={{ color: 'var(--error)' }}>{error}</p>
        )}
      </div>

      <div className="flex-1 overflow-y-auto">
        {loading && items.length === 0 ? (
          <div className="px-4 py-8 text-center text-sm" style={{ color: 'var(--on-surface-variant)' }}>
            加载中...
          </div>
        ) : items.length === 0 ? (
          <div className="px-4 py-8 text-center text-sm" style={{ color: 'var(--on-surface-variant)' }}>
            暂无数据
          </div>
        ) : (
          items.map((item) => (
            <button
              key={item.id}
              onClick={() => onSelect(item)}
              className="w-full p-4 text-left transition-colors cursor-pointer border-b"
              style={{
                background: selectedId === item.id ? 'var(--primary-light)' : 'transparent',
                borderColor: 'var(--outline-variant)',
              }}
              onMouseEnter={(e) => {
                if (selectedId !== item.id) e.currentTarget.style.background = 'var(--surface-container)'
              }}
              onMouseLeave={(e) => {
                if (selectedId !== item.id) e.currentTarget.style.background = 'transparent'
              }}
            >
              <div className="flex items-start justify-between mb-1">
                <div className="flex items-center gap-2">
                  <span
                    className="text-xs px-1.5 py-0.5 rounded"
                    style={{
                      background: item.type === 'SUGGESTION' ? 'var(--primary-light)' : 'var(--error-light)',
                      color: item.type === 'SUGGESTION' ? 'var(--primary)' : 'var(--error)',
                    }}
                  >
                    {getTypeLabel(item.type)}
                  </span>
                  <span
                    className="text-xs px-1.5 py-0.5 rounded"
                    style={{
                      background: item.status === 'READ' ? 'var(--surface-container)' : 'var(--secondary-light)',
                      color: item.status === 'READ' ? 'var(--on-surface-variant)' : 'var(--secondary)',
                    }}
                  >
                    {getStatusLabel(item.status)}
                  </span>
                </div>
                {item.status === 'PENDING' && (
                  <button
                    onClick={(e) => handleMarkAsRead(item.id, e)}
                    className="text-xs px-2 py-0.5 rounded cursor-pointer"
                    style={{ color: 'var(--primary)', background: 'var(--primary-light)' }}
                  >
                    标记已读
                  </button>
                )}
              </div>
              <p className="text-sm font-medium mb-1" style={{ color: 'var(--on-surface)' }}>
                {item.userNickname || `用户 ${item.userId}`}
              </p>
              <p className="text-sm mb-2 line-clamp-2" style={{ color: 'var(--on-surface-variant)' }}>
                {item.description}
              </p>
              <div className="flex items-center justify-between text-xs" style={{ color: 'var(--outline)' }}>
                <span>
                  {item.screenshotCount > 0 && `${item.screenshotCount} 张截图`}
                </span>
                <span>{formatDate(item.createdAt)}</span>
              </div>
            </button>
          ))
        )}
      </div>

      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-2 p-4" style={{ borderTop: '1px solid var(--outline-variant)' }}>
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page <= 1}
            className="px-3 py-1 rounded-md text-sm cursor-pointer disabled:opacity-40"
            style={{ background: 'var(--surface-container)', color: 'var(--on-surface-variant)' }}
          >
            上一页
          </button>
          <span className="text-sm" style={{ color: 'var(--on-surface-variant)' }}>
            {page} / {totalPages} · 共 {total} 条
          </span>
          <button
            onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
            disabled={page >= totalPages}
            className="px-3 py-1 rounded-md text-sm cursor-pointer disabled:opacity-40"
            style={{ background: 'var(--surface-container)', color: 'var(--on-surface-variant)' }}
          >
            下一页
          </button>
        </div>
      )}
    </div>
  )
}
