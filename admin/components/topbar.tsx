'use client'

export function TopBar() {
  return (
    <header
      className="fixed top-0 left-0 right-0 z-50 flex items-center justify-between px-4 bg-white border-b"
      style={{ height: 'var(--topbar-height)', borderColor: 'var(--outline)' }}
    >
      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2.5">
          <div
            className="flex items-center justify-center rounded-lg font-bold text-sm text-white"
            style={{ width: 36, height: 36, background: 'var(--primary)' }}
          >
            LG
          </div>
          <span className="text-lg font-semibold" style={{ color: 'var(--on-surface)' }}>
            LittleGrid
          </span>
        </div>
        <div className="relative ml-6">
          <span
            className="material-icons-round absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none"
            style={{ fontSize: 20, color: 'var(--on-surface-variant)' }}
          >
            search
          </span>
          <input
            type="text"
            placeholder="搜索..."
            className="h-10 w-[340px] rounded-full border bg-[var(--surface-container-low)] pl-11 pr-4 text-sm outline-none transition-all focus:border-[var(--primary)] focus:bg-white focus:ring-2 focus:ring-[var(--primary-light)]"
            style={{ borderColor: 'var(--outline)', color: 'var(--on-surface)' }}
          />
        </div>
      </div>
      <div className="flex items-center gap-1">
        <button
          className="flex items-center justify-center rounded-full transition-colors hover:bg-[var(--surface-container)] relative"
          style={{ width: 40, height: 40, color: 'var(--on-surface-variant)' }}
        >
          <span className="material-icons-round" style={{ fontSize: 22 }}>notifications_none</span>
          <span
            className="absolute rounded-full border-2 border-white"
            style={{ width: 8, height: 8, background: 'var(--error)', top: 9, right: 9 }}
          />
        </button>
        <button
          className="flex items-center justify-center rounded-full transition-colors hover:bg-[var(--surface-container)]"
          style={{ width: 40, height: 40, color: 'var(--on-surface-variant)' }}
        >
          <span className="material-icons-round" style={{ fontSize: 22 }}>settings</span>
        </button>
        <div
          className="flex items-center justify-center rounded-full text-sm font-semibold text-white ml-2 cursor-pointer"
          style={{ width: 36, height: 36, background: 'var(--primary)' }}
        >
          A
        </div>
      </div>
    </header>
  )
}