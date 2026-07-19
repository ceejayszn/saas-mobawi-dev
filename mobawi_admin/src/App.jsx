import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import Dashboard from './pages/Dashboard';
import apiClient from './apiClient';

const AutoAuthRoute = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    const autoLogin = async () => {
      try {
        const response = await apiClient.post('/api/auth/login', {
          username: 'root',
          password: 'kali'
        });
        localStorage.setItem('nexus_token', response.data.token);
        setIsAuthenticated(true);
      } catch (err) {
        setError('Auto-login failed. Backend might still be deploying.');
      }
    };
    autoLogin();
  }, []);

  if (error) {
    return (
      <div style={{ height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#0a0a0a', color: '#ff4444', fontFamily: 'Inter' }}>
        <h2>{error}</h2>
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <div style={{ height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#0a0a0a', color: '#00f2fe', fontFamily: 'Inter' }}>
        <h2>Initializing Nexus Admin...</h2>
      </div>
    );
  }

  return children;
};

function App() {
  return (
    <Router>
      <Routes>
        <Route 
          path="/" 
          element={
            <AutoAuthRoute>
              <Dashboard />
            </AutoAuthRoute>
          } 
        />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}

export default App;
