import axios from 'axios';
import type { RepurposeRequest, RepurposeResponse } from '../types';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 60000, // 60 second timeout for LLM processing
});

export async function repurposeContent(
  request: RepurposeRequest
): Promise<RepurposeResponse> {
  const response = await apiClient.post<RepurposeResponse>(
    '/api/repurpose',
    request
  );
  return response.data;
}

export async function healthCheck(): Promise<boolean> {
  try {
    const response = await apiClient.get('/health');
    return response.status === 200;
  } catch {
    return false;
  }
}
