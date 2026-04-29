'use client'

import { useState, useCallback } from 'react'

const API_BASE = '/api/admin/feedback'

function getAuthHeaders(): HeadersInit {
  const token = typeof window !== 'undefined' ? localStorage.getItem('adminToken') : null
  return {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  }
}

export interface FeedbackListItem {
  id: number
  userId: number
  userNickname: string | null
  type: 'SUGGESTION' | 'ISSUE'
  description: string
  screenshotCount: number
  status: 'PENDING' | 'READ'
  createdAt: number
}

export interface FeedbackDetail {
  id: number
  userId: number
  userNickname: string | null
  userAvatar: string | null
  type: 'SUGGESTION' | 'ISSUE'
  description: string
  screenshots: string[]
  status: 'PENDING' | 'READ'
  createdAt: number
}

export interface PageResult<T> {
  content: T[]
  totalElements: number
}

export function useFeedback() {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const request = useCallback(async <T>(url: string, options?: RequestInit): Promise<T> => {
    setLoading(true)
    setError(null)
    try {
      const res = await fetch(url, {
        ...options,
        headers: { ...getAuthHeaders(), ...options?.headers },
      })
      const data = await res.json()
      if (!res.ok) {
        throw new Error(data.message || '请求失败')
      }
      return data as T
    } catch (err: any) {
      setError(err.message)
      throw err
    } finally {
      setLoading(false)
    }
  }, [])

  const fetchFeedbackList = useCallback((page: number, size: number, type?: string, status?: string) => {
    const params = new URLSearchParams({ page: String(page), size: String(size) })
    if (type) params.set('type', type)
    if (status) params.set('status', status)
    return request<PageResult<FeedbackListItem>>(`${API_BASE}?${params}`)
  }, [request])

  const fetchFeedbackDetail = useCallback((id: number) => {
    return request<FeedbackDetail>(`${API_BASE}/${id}`)
  }, [request])

  const markAsRead = useCallback((id: number) => {
    return request<{ message: string }>(`${API_BASE}/${id}/read`, {
      method: 'PUT',
    })
  }, [request])

  return { loading, error, fetchFeedbackList, fetchFeedbackDetail, markAsRead }
}
