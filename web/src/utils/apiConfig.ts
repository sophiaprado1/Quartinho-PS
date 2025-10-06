// Configuração da API
export const API_BASE_URL = 'http://localhost:8000';

// Função para obter headers com autenticação
export const getAuthHeaders = () => {
  const accessToken = localStorage.getItem('accessToken');
  return {
    'Content-Type': 'application/json',
    'Authorization': accessToken ? `Bearer ${accessToken}` : ''
  };
};

// Função para obter headers para upload de arquivos com autenticação
export const getAuthFileHeaders = () => {
  const accessToken = localStorage.getItem('accessToken');
  return {
    'Authorization': accessToken ? `Bearer ${accessToken}` : ''
  };
};