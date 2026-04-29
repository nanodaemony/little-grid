'use client'

import { useState, useEffect, useCallback } from 'react'
import { useFeedback, FeedbackDetail as FeedbackDetailType, FeedbackListItem } from '../hooks/use-feedback'

interface FeedbackDetailProps {
  item: FeedbackListItem | null
  onMarkedAsRead: () => void
}

export function FeedbackDetail({ item, onMarkedAsRead }: FeedbackDetailProps) {
  const { fetchFeedbackDetail, markAsRead, loading, error } = useFeedback()
  const [detail, setDetail] = useState<FeedbackDetailType | null>(null)
  const [imageViewerOpen, setImageViewerOpen] = useState(false)
  const [currentImageIndex, setCurrentImageIndex] = useState(0)

  const loadDetail = useCallback(async () => {
    if (!item) return
    try {
      const data = await fetchFeedbackDetail(item.id)
      setDetail(data)
    } catch {}
  }, [item, fetchFeedbackDetail])

  useEffect(() => {
    loadDetail()
  }, [loadDetail])

  const handleMarkAsRead = async () => {
    if (!item) return
    try {
      await markAsRead(item.id)
      onMarkedAsRead()
      if (detail) {
        setDetail({ ...detail, status: 'READ' })
      }
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

  if (!item) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center">
        <span className="material-icons-round mb-3" style={{ fontSize: 40, color: 'var(--outline)' }}>feedback</span>
        <p className="text-sm" style={{ color: 'var(--on-surface-variant)' }}>
          请从左侧选择一条反馈
        </p>
      </div>
    )
  }

  const displayData = detail || item

  return (
    <div className="flex-1 flex flex-col min-w-0 p-6">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <span
            className="text-xs px-2 py-1 rounded"
            style={{
              background: displayData.type === 'SUGGESTION' ? 'var(--primary-light)' : 'var(--error-light)',
              color: displayData.type === 'SUGGESTION' ? 'var(--primary)' : 'var(--error)',
            }}
          >
            {getTypeLabel(displayData.type)}
          </span>
          <span
            className="text-xs px-2 py-1 rounded"
            style={{
              background: displayData.status === 'READ' ? 'var(--surface-container)' : 'var(--secondary-light)',
              color: displayData.status === 'READ' ? 'var(--on-surface-variant)' : 'var(--secondary)',
            }}
          >
            {getStatusLabel(displayData.status)}
          </span>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={loadDetail}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm cursor-pointer"
            style={{ color: 'var(--on-surface-variant)', background: 'var(--surface-container)' }}
          >
            <span className="material-icons-round" style={{ fontSize: 16 }}>refresh</span>
            刷新
          </button>
          {displayData.status === 'PENDING' && (
            <button
              onClick={handleMarkAsRead}
              disabled={loading}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm cursor-pointer disabled:opacity-40"
              style={{ color: 'var(--on-primary)', background: 'var(--primary)' }}
            >
              <span className="material-icons-round" style={{ fontSize: 16 }}>check</span>
              标记已读
            </button>
          )}
        </div>
      </div>

      {error && (
        <p className="text-sm mb-4" style={{ color: 'var(--error)' }}>{error}</p>
      )}

      <div className="flex-1 overflow-y-auto">
        <div className="rounded-lg p-4 mb-4" style={{ background: 'var(--surface)', border: '1px solid var(--outline-variant)' }}>
          <h3 className="text-sm font-medium mb-3" style={{ color: 'var(--on-surface-variant)' }}>用户信息</h3>
          <div className="flex items-center gap-3">
            <div
              className="w-10 h-10 rounded-full flex items-center justify-center"
              style={{ background: 'var(--primary-light)', color: 'var(--primary)' }}
            >
              {detail?.userAvatar ? (
                <img src={detail.userAvatar} alt="" className="w-full h-full rounded-full object-cover" />
              ) : (
                <span className="material-icons-round">person</span>
              )}
            </div>
            <div>
              <p className="text-sm font-medium" style={{ color: 'var(--on-surface)' }}>
                {displayData.userNickname || `用户 ${displayData.userId}`}
              </p>
              <p className="text-xs" style={{ color: 'var(--outline)' }}>
                用户 ID: {displayData.userId}
              </p>
            </div>
          </div>
        </div>

        <div className="rounded-lg p-4 mb-4" style={{ background: 'var(--surface)', border: '1px solid var(--outline-variant)' }}>
          <h3 className="text-sm font-medium mb-3" style={{ color: 'var(--on-surface-variant)' }}>反馈内容</h3>
          <p className="text-sm whitespace-pre-wrap" style={{ color: 'var(--on-surface)' }}>
            {displayData.description}
          </p>
        </div>

        {detail && detail.screenshots.length > 0 && (
          <div className="rounded-lg p-4" style={{ background: 'var(--surface)', border: '1px solid var(--outline-variant)' }}>
            <h3 className="text-sm font-medium mb-3" style={{ color: 'var(--on-surface-variant)' }}>
              截图 ({detail.screenshots.length})
            </h3>
            <div className="grid grid-cols-4 gap-2">
              {detail.screenshots.map((url, index) => (
                <button
                  key={index}
                  onClick={() => { setCurrentImageIndex(index); setImageViewerOpen(true) }}
                  className="aspect-square rounded overflow-hidden cursor-pointer border"
                  style={{ borderColor: 'var(--outline-variant)' }}
                >
                  <img src={url} alt={`截图 ${index + 1}`} className="w-full h-full object-cover" />
                </button>
              ))}
            </div>
          </div>
        )}

        <div className="rounded-lg p-4 mt-4" style={{ background: 'var(--surface)', border: '1px solid var(--outline-variant)' }}>
          <h3 className="text-sm font-medium mb-3" style={{ color: 'var(--on-surface-variant)' }}>时间信息</h3>
          <p className="text-sm" style={{ color: 'var(--on-surface)' }}>
            提交时间: {formatDate(displayData.createdAt)}
          </p>
        </div>
      </div>

      {imageViewerOpen && detail && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center"
          style={{ background: 'rgba(0,0,0,0.9)' }}
          onClick={() => setImageViewerOpen(false)}
        >
          <button
            onClick={(e) => { e.stopPropagation(); setCurrentImageIndex((i) => (i - 1 + detail.screenshots.length) % detail.screenshots.length) }}
            className="absolute left-4 p-2 rounded-full cursor-pointer"
            style={{ background: 'rgba(255,255,255,0.1)' }}
          >
            <span className="material-icons-round" style={{ fontSize: 32, color: 'white' }}>chevron_left</span>
          </button>
          <img
            src={detail.screenshots[currentImageIndex]}
            alt={`截图 ${currentImageIndex + 1}`}
            className="max-w-[90vw] max-h-[90vh] object-contain"
            onClick={(e) => e.stopPropagation()}
          />
          <button
            onClick={(e) => { e.stopPropagation(); setCurrentImageIndex((i) => (i + 1) % detail.screenshots.length) }}
            className="absolute right-4 p-2 rounded-full cursor-pointer"
            style={{ background: 'rgba(255,255,255,0.1)' }}
          >
            <span className="material-icons-round" style={{ fontSize: 32, color: 'white' }}>chevron_right</span>
          </button>
          <button
            onClick={() => setImageViewerOpen(false)}
            className="absolute top-4 right-4 p-2 rounded-full cursor-pointer"
            style={{ background: 'rgba(255,255,255,0.1)' }}
          >
            <span className="material-icons-round" style={{ fontSize: 24, color: 'white' }}>close</span>
          </button>
          <div className="absolute bottom-4 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full text-sm" style={{ background: 'rgba(0,0,0,0.5)', color: 'white' }}>
            {currentImageIndex + 1} / {detail.screenshots.length}
          </div>
        </div>
      )}
    </div>
  )
}
