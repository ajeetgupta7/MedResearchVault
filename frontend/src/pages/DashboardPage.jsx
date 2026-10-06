import { useEffect, useState } from 'react'
import api from '../services/api'
import LoadingState from '../components/common/LoadingState'
import StatCard from '../components/common/StatCard'
import BarChartCard from '../charts/BarChartCard'

export default function DashboardPage() {
  const [loading, setLoading] = useState(true)
  const [kpi, setKpi] = useState({})
  const [studiesByStatus, setStudiesByStatus] = useState([])
  const [participantsByDisease, setParticipantsByDisease] = useState([])
  const [experimentsByType, setExperimentsByType] = useState([])
  const [topBiomarkers, setTopBiomarkers] = useState([])

  useEffect(() => {
    const load = async () => {
      setLoading(true)
      const [a, b, c, d, e] = await Promise.all([
        api.get('/api/analytics/dashboard'),
        api.get('/api/analytics/studies-by-status'),
        api.get('/api/analytics/participants-by-disease'),
        api.get('/api/analytics/experiments-by-type'),
        api.get('/api/analytics/top-biomarkers'),
      ])
      setKpi(a.data.data)
      setStudiesByStatus(b.data.data)
      setParticipantsByDisease(c.data.data)
      setExperimentsByType(d.data.data)
      setTopBiomarkers(e.data.data)
      setLoading(false)
    }
    load()
  }, [])

  if (loading) return <LoadingState />

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-semibold text-blue-900">Dashboard</h2>
        <p className="text-sm text-slate-600">Database-driven research KPI overview</p>
      </div>
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <StatCard title="Studies" value={kpi.studies} />
        <StatCard title="Participants" value={kpi.participants} />
        <StatCard title="Experiments" value={kpi.experiments} />
        <StatCard title="Biomarkers" value={kpi.biomarkers} />
      </div>
      <div className="grid gap-4 xl:grid-cols-2">
        <BarChartCard title="Studies by Status" data={studiesByStatus} xKey="status" barKey="count" />
        <BarChartCard title="Participants by Disease" data={participantsByDisease} xKey="disease" barKey="count" />
        <BarChartCard title="Experiments by Type" data={experimentsByType} xKey="type" barKey="count" />
        <BarChartCard title="Top Biomarkers" data={topBiomarkers} xKey="biomarker" barKey="avg_value" />
      </div>
    </div>
  )
}
