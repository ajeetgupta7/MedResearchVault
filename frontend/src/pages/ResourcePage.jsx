import { useEffect, useState } from 'react'
import api from '../services/api'
import LoadingState from '../components/common/LoadingState'
import DataTable from '../components/common/DataTable'

const defaultColumns = {
  studies: ['study_id', 'study_code', 'title', 'status'],
  researchers: ['researcher_id', 'researcher_code', 'first_name', 'last_name', 'specialization'],
  participants: ['participant_id', 'participant_code', 'study_id', 'disease_id', 'status'],
  diseases: ['disease_id', 'disease_code', 'disease_name', 'category'],
  samples: ['sample_id', 'sample_code', 'sample_type', 'status', 'storage_location'],
  experiments: ['experiment_id', 'experiment_code', 'experiment_type', 'status', 'success_score'],
  biomarkers: ['biomarker_id', 'biomarker_code', 'biomarker_name', 'unit'],
  results: ['result_id', 'experiment_id', 'confidence_score'],
  publications: ['publication_id', 'publication_code', 'title', 'journal'],
}

export default function ResourcePage({ title, resource }) {
  const [loading, setLoading] = useState(true)
  const [rows, setRows] = useState([])

  useEffect(() => {
    const load = async () => {
      setLoading(true)
      const { data } = await api.get(`/api/${resource}?per_page=25&page=1`)
      setRows(data.data.items || [])
      setLoading(false)
    }
    load()
  }, [resource])

  if (loading) return <LoadingState />

  const columns = (defaultColumns[resource] || Object.keys(rows[0] || {})).map((k) => ({ key: k, label: k }))

  return (
    <div className="space-y-4">
      <h2 className="text-2xl font-semibold text-blue-900">{title}</h2>
      <DataTable columns={columns} rows={rows} />
    </div>
  )
}
