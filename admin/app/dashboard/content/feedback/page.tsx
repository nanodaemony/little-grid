'use client'

import { useState, useCallback } from 'react'
import { FeedbackList } from './components/feedback-list'
import { FeedbackDetail } from './components/feedback-detail'
import { FeedbackListItem } from './hooks/use-feedback'

export default function FeedbackPage() {
  const [selectedItem, setSelectedItem] = useState<FeedbackListItem | null>(null)
  const [refreshKey, setRefreshKey] = useState(0)

  const handleSelect = useCallback((item: FeedbackListItem) => {
    setSelectedItem(item)
  }, [])

  const handleMarkedAsRead = useCallback(() => {
    setRefreshKey((k) => k + 1)
  }, [])

  return (
    <div className="flex h-[calc(100vh-var(--topbar-height)-64px)] -m-6">
      <FeedbackList
        key={refreshKey}
        onSelect={handleSelect}
        selectedId={selectedItem?.id || null}
      />
      <FeedbackDetail
        item={selectedItem}
        onMarkedAsRead={handleMarkedAsRead}
      />
    </div>
  )
}
