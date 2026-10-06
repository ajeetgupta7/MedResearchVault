export default function DataTable({ columns, rows }) {
  return (
    <div className="overflow-auto rounded-xl border border-slate-200 bg-white shadow-sm">
      <table className="min-w-full text-sm">
        <thead className="bg-slate-100 text-left text-slate-700">
          <tr>
            {columns.map((col) => (
              <th key={col.key} className="px-4 py-2 font-medium">{col.label}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 ? (
            <tr><td className="px-4 py-3 text-slate-500" colSpan={columns.length}>No records</td></tr>
          ) : rows.map((row, idx) => (
            <tr key={idx} className="border-t border-slate-100">
              {columns.map((col) => (
                <td key={col.key} className="px-4 py-2 text-slate-700">{row[col.key]?.toString?.() ?? ''}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
