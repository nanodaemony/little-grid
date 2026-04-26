'use client'

import { useState, useCallback } from 'react'

const API_BASE = '/api/admin/db'

function getAuthHeaders(): HeadersInit {
  const token = typeof window !== 'undefined' ? localStorage.getItem('adminToken') : null
  return {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  }
}

export interface TableInfo {
  name: string
  rowCount: number
  comment: string
}

export interface ColumnInfo {
  name: string
  type: string
  nullable: string
  keyType: string
  defaultValue: any
  comment: string
  autoIncrement: boolean
}

export interface PagedData {
  rows: Record<string, any>[]
  total: number
  page: number
  size: number
}

export interface SqlResult {
  columns: string[]
  rows: Record<string, any>[]
  truncated: boolean
}

export function useDatabase() {
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

  const fetchTables = useCallback(() => {
    return request<TableInfo[]>(`${API_BASE}/tables`)
  }, [request])

  const fetchColumns = useCallback((tableName: string) => {
    return request<ColumnInfo[]>(`${API_BASE}/tables/${tableName}/columns`)
  }, [request])

  const fetchTableData = useCallback((tableName: string, page: number, size: number, sort?: string, order?: string) => {
    const params = new URLSearchParams({ page: String(page), size: String(size) })
    if (sort) params.set('sort', sort)
    if (order) params.set('order', order)
    return request<PagedData>(`${API_BASE}/tables/${tableName}/data?${params}`)
  }, [request])

  const insertRow = useCallback((tableName: string, data: Record<string, any>) => {
    return request<{ message: string }>(`${API_BASE}/tables/${tableName}/data`, {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }, [request])

  const updateRow = useCallback((tableName: string, data: Record<string, any>) => {
    return request<{ message: string }>(`${API_BASE}/tables/${tableName}/data`, {
      method: 'PUT',
      body: JSON.stringify(data),
    })
  }, [request])

  const deleteRow = useCallback((tableName: string, data: Record<string, any>) => {
    return request<{ message: string }>(`${API_BASE}/tables/${tableName}/data`, {
      method: 'DELETE',
      body: JSON.stringify(data),
    })
  }, [request])

  const executeSql = useCallback((sql: string) => {
    return request<SqlResult>(`${API_BASE}/sql`, {
      method: 'POST',
      body: JSON.stringify({ sql }),
    })
  }, [request])

  return { loading, error, fetchTables, fetchColumns, fetchTableData, insertRow, updateRow, deleteRow, executeSql }
}