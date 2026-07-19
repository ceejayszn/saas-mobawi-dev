import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'https://mobawi-backend-api.onrender.com';

const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('nexus_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const login = async (username, password) => {
  const response = await apiClient.post('/api/auth/login', { username, password });
  if (response.data.token) {
    localStorage.setItem('nexus_token', response.data.token);
    localStorage.setItem('nexus_user', JSON.stringify(response.data.user));
  }
  return response.data;
};

export const logout = () => {
  localStorage.removeItem('nexus_token');
  localStorage.removeItem('nexus_user');
  window.location.href = '/login';
};

export const getOverview = async () => {
  const response = await apiClient.get('/api/nexus/overview');
  return response.data;
};

export const getBusinesses = async () => {
  const response = await apiClient.get('/api/admin/businesses');
  return response.data;
};

export const getApplications = async () => {
  const response = await apiClient.get('/api/nexus/applications');
  return response.data;
};

export const suspendBusiness = async (id) => {
  const response = await apiClient.post(`/api/admin/businesses/${id}/suspend`);
  return response.data;
};

export const activateBusiness = async (id) => {
  const response = await apiClient.post(`/api/admin/businesses/${id}/activate`);
  return response.data;
};

export default apiClient;
