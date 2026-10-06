import { useEffect, useState } from 'react'
import api from '../services/api'
import DataTable from '../components/common/DataTable'

export default function DBMSOperationsPage() {
  const [operations, setOperations] = useState([])
  const [selected, setSelected] = useState('')
  const [rows, setRows] = useState([])

  useEffect(() => {
    api.get('/api/dbms/operations').then(({ data }) => {
      setOperations(data.data || [])
      if (data.data?.length) setSelected(data.data[0])
    })
  }, [])

  useEffect(() => {
    if (!selected) return
    api.get(`/api/dbms/operations/${selected}`).then(({ data }) => setRows(data.data || []))
  }, [selected])

  const columns = Object.keys(rows[0] || {}).map((k) => ({ key: k, label: k }))

  return (
    <div className="space-y-4">
      <h2 className="text-2xl font-semibold text-blue-900">DBMS Operations</h2>
      <select className="rounded-lg border px-3 py-2" value={selected} onChange={(e) => setSelected(e.target.value)}>
        {operations.map((op) => <option key={op}>{op}</option>)}
      </select>
      <DataTable columns={columns} rows={rows} />
    </div>
  )
}
