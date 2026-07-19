import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { login } from '../apiClient';

function Login() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const data = await login(username, password);
      if (data.user.role === 'nexus_admin') {
        navigate('/');
      } else {
        setError('Unauthorized: Nexus Admin access required.');
      }
    } catch (err) {
      setError(err.response?.data?.error || 'Login failed.');
    }
  };

  return (
    <div className="login-wrapper">
      <div className="glass-panel login-card">
        <h2 style={{ textAlign: 'center', marginBottom: '2rem' }}>Mobawi Nexus Admin</h2>
        {error && <div style={{ color: 'var(--danger)', marginBottom: '1rem', textAlign: 'center' }}>{error}</div>}
        <form onSubmit={handleLogin}>
          <div className="form-group">
            <label>Username</label>
            <input
              type="text"
              className="form-control"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label>Password</label>
            <input
              type="password"
              className="form-control"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <button type="submit" className="btn-primary" style={{ width: '100%', marginTop: '1rem' }}>
            Login to Nexus
          </button>
        </form>
      </div>
    </div>
  );
}

export default Login;
