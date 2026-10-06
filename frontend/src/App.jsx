import { Navigate, Route, Routes } from 'react-router-dom'
import { AuthProvider } from './hooks/useAuth'
import ProtectedRoute from './components/common/ProtectedRoute'
import AppLayout from './layouts/AppLayout'
import LoginPage from './pages/LoginPage'
import DashboardPage from './pages/DashboardPage'
import ResourcePage from './pages/ResourcePage'
import StudyDetailsPage from './pages/StudyDetailsPage'
import AnalyticsPage from './pages/AnalyticsPage'
import DBMSOperationsPage from './pages/DBMSOperationsPage'
import SettingsPage from './pages/SettingsPage'

function LayoutRoute() {
  return (
    <ProtectedRoute>
      <AppLayout />
    </ProtectedRoute>
  )
}

export default function App() {
  return (
    <AuthProvider>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/" element={<LayoutRoute />}>
          <Route index element={<DashboardPage />} />
          <Route path="research/studies" element={<ResourcePage title="Studies" resource="studies" />} />
          <Route path="research/studies/:id" element={<StudyDetailsPage />} />
          <Route path="research/researchers" element={<ResourcePage title="Researchers" resource="researchers" />} />
          <Route path="research/participants" element={<ResourcePage title="Participants" resource="participants" />} />
          <Route path="research/diseases" element={<ResourcePage title="Diseases" resource="diseases" />} />
          <Route path="laboratory/samples" element={<ResourcePage title="Samples" resource="samples" />} />
          <Route path="laboratory/experiments" element={<ResourcePage title="Experiments" resource="experiments" />} />
          <Route path="laboratory/biomarkers" element={<ResourcePage title="Biomarkers" resource="biomarkers" />} />
          <Route path="publications" element={<ResourcePage title="Publications" resource="publications" />} />
          <Route path="results" element={<ResourcePage title="Research Results" resource="results" />} />
          <Route path="analytics" element={<AnalyticsPage />} />
          <Route path="dbms-operations" element={<DBMSOperationsPage />} />
          <Route path="audit-logs" element={<ResourcePage title="Audit Logs" resource="audit-logs" />} />
          <Route path="settings" element={<SettingsPage />} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AuthProvider>
  )
}
