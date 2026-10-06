import { Link, Outlet, useLocation } from 'react-router-dom'
import { Activity, Database, FlaskConical, FolderSearch, Microscope, Settings, ShieldCheck } from 'lucide-react'
import { useAuth } from '../hooks/useAuth'

const navItems = [
  { to: '/', label: 'Dashboard', icon: Activity },
  { to: '/research/studies', label: 'Research Modules', icon: FolderSearch },
  { to: '/laboratory/samples', label: 'Laboratory Modules', icon: Microscope },
  { to: '/publications', label: 'Publications', icon: FlaskConical },
  { to: '/analytics', label: 'Analytics', icon: Database },
  { to: '/dbms-operations', label: 'DBMS Operations', icon: ShieldCheck },
  { to: '/audit-logs', label: 'Audit Logs', icon: ShieldCheck },
  { to: '/settings', label: 'Settings', icon: Settings },
]

const roleVisibility = {
  Administrator: navItems.map((i) => i.to),
  'Principal Investigator': navItems.map((i) => i.to),
  'Research Assistant': navItems.filter((i) => i.to !== '/audit-logs').map((i) => i.to),
  'Data Analyst': ['/', '/analytics', '/dbms-operations', '/audit-logs', '/settings'],
}

export default function AppLayout() {
  const location = useLocation()
  const { user, logout } = useAuth()
  const allowed = roleVisibility[user?.role] ?? []

  return (
    <div className="flex min-h-screen bg-slate-50 text-slate-900">
      <aside className="w-72 border-r border-slate-200 bg-white p-4">
        <h1 className="text-xl font-bold text-blue-900">MedResearchVault</h1>
        <p className="text-xs text-teal-700">MRV • Medical Research Data Management & Analytics System</p>
        <p className="mt-2 text-[11px] text-amber-700">Academic Research Data Management System — Not for Clinical Diagnosis.</p>
        <nav className="mt-6 space-y-1">
          {navItems.filter((item) => allowed.includes(item.to)).map((item) => {
            const Icon = item.icon
            const active = location.pathname === item.to || location.pathname.startsWith(item.to + '/')
            return (
              <Link key={item.to} to={item.to} className={`flex items-center gap-2 rounded-lg px-3 py-2 text-sm ${active ? 'bg-blue-100 text-blue-900' : 'text-slate-600 hover:bg-slate-100'}`}>
                <Icon size={16} /> {item.label}
              </Link>
            )
          })}
        </nav>
        <button onClick={logout} className="mt-8 rounded-lg bg-blue-600 px-3 py-2 text-sm text-white hover:bg-blue-700">Logout</button>
      </aside>
      <main className="flex-1 p-6">
        <Outlet />
      </main>
    </div>
  )
}
