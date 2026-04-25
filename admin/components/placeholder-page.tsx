interface PlaceholderPageProps {
  title: string
  description?: string
}

export function PlaceholderPage({ title, description }: PlaceholderPageProps) {
  return (
    <div>
      <div className="mb-6">
        <h1 className="text-[22px] font-semibold" style={{ color: 'var(--on-surface)' }}>{title}</h1>
        {description && (
          <p className="text-sm mt-0.5" style={{ color: 'var(--on-surface-variant)' }}>{description}</p>
        )}
      </div>
      <div
        className="flex flex-col items-center justify-center rounded-xl border border-dashed py-20"
        style={{ borderColor: 'var(--outline)', background: 'var(--surface)' }}
      >
        <span className="material-icons-round mb-3" style={{ fontSize: 40, color: 'var(--outline)' }}>
          construction
        </span>
        <p className="text-sm" style={{ color: 'var(--on-surface-variant)' }}>功能开发中</p>
      </div>
    </div>
  )
}