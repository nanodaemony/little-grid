'use client'

import { useState, useEffect, useCallback } from 'react'
import { useDatabase, ColumnInfo } from '../hooks/use-database'
import { RowEditDialog } from './row-edit-dialog'

interface DataTableProps {
  tableName: string
  columns: ColumnInfo[]
}

export function DataTable({ tableName, columns }: DataTableProps) {
  const { fetchTableData, insertRow, updateRow, deleteRow } = useDatabase()
  const [rows, setRows] = useState<Record<string, any>[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [size, setSize] = useState(20)
  const [sort, setSort] = useState<string | null>(null)
  const [order, setOrder] = useState<'asc' | 'desc'>('asc')
  const [loading, setLoading] = useState(false)
  const [editOpen, setEditOpen] = useState(false)
  const [editMode, setEditMode] = useState<'insert' | 'update'>('insert')
  const [editRow, setEditRow] = useState<Record<string, any> | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<Record<string, any> | null>(null)

  const loadData = useCallback(async () => {
    setLoading(true)
    try {
      const data = await fetchTableData(tableName, page, size, sort || undefined, order)
      setRows(data.rows)
      setTotal(data.total)
    } catch {}
    setLoading(false)
  }, [tableName, page, size, sort, order, fetchTableData])

  useEffect(() => {
    loadData()
  }, [loadData])

  useEffect(() => {
    setPage(1)
  }, [tableName])

  const handleSort = (colName: string) => {
    if (sort === colName) {
      setOrder((prev) => (prev === 'asc' ? 'desc' : 'asc'))
    } else {
      setSort(colName)
      setOrder('asc')
    }
    setPage(1)
  }

  const handleInsert = () => {
    setEditMode('insert')
    setEditRow(null)
    setEditOpen(true)
  }

  const handleEdit = (row: Record<string, any>) => {
    setEditMode('update')
    setEditRow(row)
    setEditOpen(true)
  }

  const handleEditConfirm = async (data: Record<string, any>) => {
    try {
      if (editMode === 'insert') {
        await insertRow(tableName, data)
      } else {
        await updateRow(tableName, data)
      }
      setEditOpen(false)
      loadData()
    } catch {}
  }

  const handleDelete = async () => {
    if (!deleteTarget) return
    try {
      await deleteRow(tableName, deleteTarget)
      setDeleteTarget(null)
      loadData()
    } catch {}
  }

  const totalPages = Math.ceil(total / size)
  const primaryKeys = columns.filter((c) => c.keyType === 'PRI').map((c) => c.name)

  return (
    <div>
      <div className="flex items-center gap-2 mb-3">
        <button
          onClick={handleInsert}
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm cursor-pointer"
          style={{ color: 'var(--on-primary)', background: 'var(--primary)' }}
        >
          <span className="material-icons-round" style={{ fontSize: 16 }}>add</span>
          新增
        </button>
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
          className="px-2 py-1.5 rounded-md text-sm outline-none"
          style={{ background: 'var(--surface-container)', color: 'var(--on-surface-variant)', border: '1px solid var(--outline-variant)' }}
        >
          {[10, 20, 50, 100].map((s) => (
            <option key={s} value={s}>{s} 条/页</option>
          ))}
        </select>
        <span className="ml-auto text-sm" style={{ color: 'var(--on-surface-variant)' }}>
          共 {total.toLocaleString()} 条
        </span>
      </div>

      <div className="rounded-lg overflow-hidden" style={{ background: 'var(--surface)', border: '1px solid var(--outline-variant)' }}>
        <table className="w-full text-sm">
          <thead>
            <tr style={{ background: 'var(--surface-container)' }}>
              {columns.map((col) => (
                <th
                  key={col.name}
                  onClick={() => handleSort(col.name)}
                  className="text-left px-3 py-2.5 font-medium whitespace-nowrap cursor-pointer select-none"
                  style={{ color: 'var(--on-surface-variant)', borderBottom: '1px solid var(--outline-variant)' }}
                >
                  {col.name}
                  {sort === col.name && (
                    <span className="material-icons-round align-middle ml-0.5" style={{ fontSize: 14 }}>
                      {order === 'asc' ? 'arrow_upward' : 'arrow_downward'}
                    </span>
                  )}
                </th>
              ))}
              <th className="px-3 py-2.5 font-medium" style={{ color: 'var(--on-surface-variant)', borderBottom: '1px solid var(--outline-variant)' }}>
                操作
              </th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan={columns.length + 1} className="px-3 py-6 text-center" style={{ color: 'var(--on-surface-variant)' }}>加载中...</td></tr>
            ) : rows.length === 0 ? (
              <tr><td colSpan={columns.length + 1} className="px-3 py-6 text-center" style={{ color: 'var(--on-surface-variant)' }}>暂无数据</td></tr>
            ) : (
              rows.map((row, i) => (
                <tr key={i} style={{ background: i % 2 === 0 ? 'var(--surface)' : 'var(--surface-container-low)' }}>
                  {columns.map((col) => (
                    <td key={col.name} className="px-3 py-2 whitespace-nowrap" style={{ color: 'var(--on-surface)', maxWidth: 300, overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {row[col.name] != null ? String(row[col.name]) : <span style={{ color: 'var(--outline)' }}>NULL</span>}
                    </td>
                  ))}
                  <td className="px-3 py-2 whitespace-nowrap">
                    <button
                      onClick={() => handleEdit(row)}
                      className="mr-2 text-xs cursor-pointer"
                      style={{ color: 'var(--primary)' }}
                    >
                      <span className="material-icons-round align-middle" style={{ fontSize: 16 }}>edit</span>
                      编辑
                    </button>
                    <button
                      onClick={() => setDeleteTarget(row)}
                      className="text-xs cursor-pointer"
                      style={{ color: 'var(--error)' }}
                    >
                      <span className="material-icons-round align-middle" style={{ fontSize: 16 }}>delete</span>
                      删除
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-2 mt-3">
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page <= 1}
            className="px-3 py-1 rounded-md text-sm cursor-pointer disabled:opacity-40"
            style={{ background: 'var(--surface-container)', color: 'var(--on-surface-variant)' }}
          >
            上一页
          </button>
          <span className="text-sm" style={{ color: 'var(--on-surface-variant)' }}>
            {page} / {totalPages}
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

      <RowEditDialog
        open={editOpen}
        mode={editMode}
        columns={columns}
        rowData={editRow}
        onConfirm={handleEditConfirm}
        onCancel={() => setEditOpen(false)}
      />

      {deleteTarget && (
        <div className="fixed inset-0 z-50 flex items-center justify-center" style={{ background: 'rgba(0,0,0,0.3)' }}>
          <div className="w-[360px] rounded-xl shadow-lg p-5" style={{ background: 'var(--surface)' }}>
            <h3 className="text-base font-semibold mb-2" style={{ color: 'var(--on-surface)' }}>确认删除</h3>
            <p className="text-sm mb-4" style={{ color: 'var(--on-surface-variant)' }}>
              确定要删除此行吗？{primaryKeys.length > 0 && (
                <span className="block mt-1">
                  主键: {primaryKeys.map((k) => `${k}=${deleteTarget[k]}`).join(', ')}
                </span>
              )}
            </p>
            <div className="flex justify-end gap-2">
              <button
                onClick={() => setDeleteTarget(null)}
                className="px-4 py-1.5 rounded-md text-sm cursor-pointer"
                style={{ color: 'var(--on-surface-variant)', background: 'var(--surface-container)' }}
              >
                取消
              </button>
              <button
                onClick={handleDelete}
                className="px-4 py-1.5 rounded-md text-sm cursor-pointer"
                style={{ color: 'white', background: 'var(--error)' }}
              >
                删除
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
