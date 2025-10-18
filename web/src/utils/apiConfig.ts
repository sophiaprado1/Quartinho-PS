// Configuração da API
// Nota: usar 127.0.0.1 evita problemas quando 'localhost' resolve para IPv6 (::1)
export const API_BASE_URL = 'http://127.0.0.1:8000';

// Util para obter token considerando chaves novas e antigas
const getToken = (): string | null => {
  // preferir chave nova
  const t1 = localStorage.getItem('accessToken');
  if (t1) return t1;
  // fallback para chave antiga usada em algumas telas
  const t2 = localStorage.getItem('access_token');
  return t2 || null;
};

// Função para obter headers com autenticação
export const getAuthHeaders = () => {
  const accessToken = getToken();
  return {
    'Content-Type': 'application/json',
    'Authorization': accessToken ? `Bearer ${accessToken}` : ''
  };
};

// Função para obter headers para upload de arquivos com autenticação
export const getAuthFileHeaders = () => {
  const accessToken = getToken();
  return {
    'Authorization': accessToken ? `Bearer ${accessToken}` : ''
  };
};