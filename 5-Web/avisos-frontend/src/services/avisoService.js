import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000'

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  },
  timeout: 10000
})

apiClient.interceptors.response.use(
  response => response,
  error => {
    console.error('API Error:', error)
    return Promise.reject(error)
  }
)

export default {
  async getAllAvisos() {
    const response = await apiClient.get('/api/v1/avisos')
    return response.data
  },

  async getAvisoById(id) {
    const response = await apiClient.get(`/api/v1/avisos/${id}`)
    return response.data
  },

  async createAviso(data) {
    const response = await apiClient.post('/api/v1/avisos', data)
    return response.data
  },

  async updateAviso(id, data) {
    const response = await apiClient.put(`/api/v1/avisos/${id}`, data)
    return response.data
  },

  async deleteAviso(id) {
    const response = await apiClient.delete(`/api/v1/avisos/${id}`)
    return response.data
  }
}
