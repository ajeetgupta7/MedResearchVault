import { useState } from 'react'

const tabs = ['Overview', 'Participants', 'Researchers', 'Samples', 'Experiments', 'Results', 'Publications', 'Activity']

export default function StudyDetailsPage() {
  const [activeTab, setActiveTab] = useState('Overview')

  return (
    <div className="space-y-4">
      <h2 className="text-2xl font-semibold text-blue-900">Study Details Workflow</h2>
      <div className="flex flex-wrap gap-2">
        {tabs.map((tab) => (
          <button key={tab} onClick={() => setActiveTab(tab)} className={`rounded-lg px-3 py-2 text-sm ${activeTab === tab ? 'bg-blue-600 text-white' : 'bg-white text-slate-700 border'}`}>
            {tab}
          </button>
        ))}
      </div>
      <div className="rounded-xl border bg-white p-4 text-sm text-slate-700">
        {activeTab} module is wired for progressive API-backed implementation and privacy-conscious data handling.
      </div>
    </div>
  )
}
