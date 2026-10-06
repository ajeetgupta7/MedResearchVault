import { createContext, useContext, useMemo, useState } from 'react'
import api from '../services/api'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    const raw = sessionStorage.getItem('mrv_user')
    return raw ? JSON.parse(raw) : null
  })

  const login = async (username, password) => {
    const { data } = await api.post('/api/auth/login', { username, password })
    const payload = data.data
    sessionStorage.setItem('mrv_token', payload.token)
    sessionStorage.setItem('mrv_user', JSON.stringify(payload.user))
    setUser(payload.user)
  }

  const logout = () => {
    sessionStorage.removeItem('mrv_token')
    sessionStorage.removeItem('mrv_user')
    setUser(null)
  }

  const value = useMemo(() => ({ user, login, logout }), [user])

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  return useContext(AuthContext)
}
