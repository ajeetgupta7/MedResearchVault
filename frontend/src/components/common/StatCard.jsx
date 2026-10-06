export default function StatCard({ title, value, subtitle }) {
  return (
    <div className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
      <p className="text-sm text-slate-500">{title}</p>
      <p className="mt-2 text-3xl font-semibold text-blue-900">{value ?? 0}</p>
      {subtitle && <p className="mt-1 text-xs text-teal-700">{subtitle}</p>}
    </div>
  )
}
