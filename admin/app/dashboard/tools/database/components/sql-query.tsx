'use client'

import { useState } from 'react'
import { useDatabase, SqlResult } from '../hooks/use-database'

export function SqlQuery() {
  const { executeSql } = useDatabase()
  const [sql, setSql] = useState('')
  const [result, setResult] = useState<SqlResult | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleExecute = async () => {
    if (!sql.trim()) return
    setLoading(true)
    setError(null)
    try {
      const data = await executeSql(sql)
      setResult(data)
    } catch (err: any) {
      setError(err.message)
      setResult(null)
    } finally {
      setLoading(false)
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') {
      handleExecute()
    }
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="rounded-lg p-4" style={{ background: 'var(--surface)', border: '1px solid var(--outline-variant)' }}>
        <div className="flex items-center justify-between mb-2">
          <span className="text-sm font-medium" style={{ color: 'var(--on-surface)' }}>SQL 查询</span>
          <span className="text-xs" style={{ color: 'var(--on-surface-variant)' }}>Ctrl+Enter 执行 · 仅支持 SELECT · 最大 1000 行</span>
        </div>
        <textarea
          value={sql}
          onChange={(e) => setSql(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="SELECT * FROM table_name LIMIT 100"
          rows={6}
          className="w-full px-3 py-2 rounded-md text-sm outline-none resize-y font-mono"
          style={{ background: 'var(--surface-container-low)', color: 'var(--on-surface)', border: '1px solid var(--outline-variant)' }}
        />
        <div className="flex items-center gap-2 mt-2">
          <button
            onClick={handleExecute}
            disabled={loading || !sql.trim()}
            className="flex items-center gap-1.5 px-4 py-1.5 rounded-md text-sm cursor-pointer disabled:opacity-40"
            style={{ color: 'var(--on-primary)', background: 'var(--primary)' }}
          >
            <span className="material-icons-round" style={{ fontSize: 16 }}>play_arrow</span>
            执行
          </button>
          <button
            onClick={() => { setSql(''); setResult(null); setError(null) }}
            className="px-4 py-1.5 rounded-md text-sm cursor-pointer"
            style={{ color: 'var(--on-surface-variant)', background: 'var(--surface-container)' }}
          >
            清空
          </button>
        </div>
      </div>

      {error && (
        <div className="rounded-lg p-3 text-sm" style={{ background: '#fce8e6', color: 'var(--error)', border: '1px solid #f5c6c0' }}>
          <span className="material-icons-round align-middle mr-1" style={{ fontSize: 16 }}>error</span>
          {error}
        </div>
      )}

      {result && (
        <div className="rounded-lg overflow-auto" style={{ background: 'var(--surface)', border: '1px solid var(--outline-variant)', maxHeight: 'calc(100vh - 480px)' }}>
          {result.truncated && (
            <div className="px-3 py-2 text-xs" style={{ background: '#fef7e0', color: 'var(--warning)', borderBottom: '1px solid var(--outline-variant)' }}>
              结果已截断，最大返回 1000 行
            </div>
          )}
          <table className="w-full text-sm">
            <thead>
              <tr style={{ background: 'var(--surface-container)' }}>
                {result.columns.map((col) => (
                  <th key={col} className="text-left px-3 py-2.5 font-medium whitespace-nowrap" style={{ color: 'var(--on-surface-variant)', borderBottom: '1px solid var(--outline-variant)' }}>
                    {col}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {result.rows.length === 0 ? (
                <tr><td colSpan={result.columns.length} className="px-3 py-6 text-center" style={{ color: 'var(--on-surface-variant)' }}>无结果</td></tr>
              ) : (
                result.rows.map((row, i) => (
                  <tr key={i} style={{ background: i % 2 === 0 ? 'var(--surface)' : 'var(--surface-container-low)' }}>
                    {result.columns.map((col) => (
                      <td key={col} className="px-3 py-2 whitespace-nowrap" style={{ color: 'var(--on-surface)', maxWidth: 300, overflow: 'hidden', textOverflow: 'ellipsis' }}>
                        {row[col] != null ? String(row[col]) : <span style={{ color: 'var(--outline)' }}>NULL</span>}
                      </td>
                    ))}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}