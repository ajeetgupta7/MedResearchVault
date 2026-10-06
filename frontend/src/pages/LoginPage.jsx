import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../hooks/useAuth'

export default function LoginPage() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const [username, setUsername] = useState('admin')
  const [password, setPassword] = useState('MRV@1234')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const onSubmit = async (e) => {
    e.preventDefault()
    try {
      setLoading(true)
      setError('')
      await login(username, password)
      navigate('/')
    } catch {
      setError('Login failed. Check credentials.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 p-4">
      <form onSubmit={onSubmit} className="w-full max-w-md rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <h1 className="text-2xl font-bold text-blue-900">MedResearchVault Login</h1>
        <p className="mt-1 text-xs text-amber-700">Academic Research Data Management System — Not for Clinical Diagnosis.</p>
        <div className="mt-4 space-y-3">
          <input value={username} onChange={(e) => setUsername(e.target.value)} className="w-full rounded-lg border px-3 py-2" placeholder="Username" />
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} className="w-full rounded-lg border px-3 py-2" placeholder="Password" />
        </div>
        {error && <p className="mt-3 text-sm text-red-600">{error}</p>}
        <button disabled={loading} className="mt-4 w-full rounded-lg bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:opacity-50">{loading ? 'Signing in...' : 'Sign in'}</button>
      </form>
    </div>
  )
}
