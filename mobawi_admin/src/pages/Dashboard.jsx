import { useEffect, useState } from 'react';
import { getOverview, getBusinesses, getApplications, logout, suspendBusiness, activateBusiness } from '../apiClient';

function Dashboard() {
  const [overview, setOverview] = useState(null);
  const [businesses, setBusinesses] = useState([]);
  const [apps, setApps] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [overviewData, bizData, appData] = await Promise.all([
        getOverview(),
        getBusinesses(),
        getApplications()
      ]);
      setOverview(overviewData);
      setBusinesses(bizData);
      setApps(appData);
    } catch (err) {
      console.error(err);
      if (err.response?.status === 401) logout();
    } finally {
      setLoading(false);
    }
  };

  const handleToggleStatus = async (id, currentStatus) => {
    try {
      if (currentStatus === 'ACTIVE') {
        await suspendBusiness(id);
      } else {
        await activateBusiness(id);
      }
      fetchData();
    } catch (err) {
      alert('Failed to update status');
    }
  };

  if (loading) return <div className="dashboard-container">Loading Nexus...</div>;

  return (
    <div className="dashboard-container">
      <div className="header">
        <h1>Mobawi Nexus Control</h1>
        <button className="btn-primary" onClick={logout} style={{ background: 'var(--danger)' }}>Logout</button>
      </div>

      <div className="grid-cards">
        <div className="glass-panel metric-card">
          <div className="metric-title">Active Tenants</div>
          <div className="metric-value">{overview?.activeTenants || 0}</div>
        </div>
        <div className="glass-panel metric-card">
          <div className="metric-title">Total Processed Revenue</div>
          <div className="metric-value">${overview?.totalProcessedRevenue?.toLocaleString() || 0}</div>
        </div>
        <div className="glass-panel metric-card">
          <div className="metric-title">Platform Apps</div>
          <div className="metric-value">{apps.length}</div>
        </div>
        <div className="glass-panel metric-card">
          <div className="metric-title">System Status</div>
          <div className="metric-value" style={{ color: 'var(--success)' }}>Operational</div>
        </div>
      </div>

      <h2 style={{ marginTop: '3rem', marginBottom: '1.5rem' }}>Business Tenants</h2>
      <div className="glass-panel table-container">
        <table>
          <thead>
            <tr>
              <th>Business Name</th>
              <th>Type</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {businesses.map((biz) => (
              <tr key={biz.id}>
                <td>{biz.name}</td>
                <td>{biz.type}</td>
                <td>
                  <span className={`status-badge ${biz.status === 'ACTIVE' ? 'status-active' : 'status-suspended'}`}>
                    {biz.status}
                  </span>
                </td>
                <td>
                  <button 
                    className="btn-primary" 
                    style={{ padding: '0.4rem 0.8rem', fontSize: '0.8rem', background: biz.status === 'ACTIVE' ? 'var(--danger)' : 'var(--success)' }}
                    onClick={() => handleToggleStatus(biz.id, biz.status)}
                  >
                    {biz.status === 'ACTIVE' ? 'Suspend' : 'Activate'}
                  </button>
                </td>
              </tr>
            ))}
            {businesses.length === 0 && <tr><td colSpan="4">No tenants found.</td></tr>}
          </tbody>
        </table>
      </div>

      <h2 style={{ marginTop: '3rem', marginBottom: '1.5rem' }}>Platform Applications</h2>
      <div className="glass-panel table-container">
        <table>
          <thead>
            <tr>
              <th>App Name</th>
              <th>Package</th>
              <th>Version</th>
              <th>Last Seen</th>
            </tr>
          </thead>
          <tbody>
            {apps.map((app) => (
              <tr key={app.id}>
                <td>{app.name}</td>
                <td>{app.packageName}</td>
                <td>{app.version} (b{app.buildNumber})</td>
                <td>{new Date(app.lastSeen).toLocaleString()}</td>
              </tr>
            ))}
            {apps.length === 0 && <tr><td colSpan="4">No applications registered.</td></tr>}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default Dashboard;
