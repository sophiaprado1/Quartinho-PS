// Tipos para os dados do usuário
interface UserData {
  id: number;
  email: string;
  full_name: string;
  preference?: string;
  [key: string]: any; // Para outros campos que possam existir
}

// Salvar tokens no localStorage
export const saveTokens = (accessToken: string, refreshToken: string) => {
  localStorage.setItem('accessToken', accessToken);
  localStorage.setItem('refreshToken', refreshToken);
};

// Salvar dados do usuário no localStorage
export const saveUserData = (userData: UserData) => {
  localStorage.setItem('userData', JSON.stringify(userData));
};

// Obter dados do usuário do localStorage
export const getUserData = (): UserData | null => {
  // Primeiro tenta buscar com a chave 'userData' (nova)
  let userData = localStorage.getItem('userData');
  
  // Se não encontrar, tenta com a chave 'user_data' (antiga)
  if (!userData) {
    userData = localStorage.getItem('user_data');
  }
  
  if (userData) {
    try {
      return JSON.parse(userData);
    } catch (error) {
      console.error('Erro ao analisar dados do usuário:', error);
      return null;
    }
  }
  return null;
};

// Verificar se o usuário está autenticado
export const isAuthenticated = (): boolean => {
  return !!localStorage.getItem('accessToken');
};

// Limpar dados de autenticação (logout)
export const clearAuth = () => {
  localStorage.removeItem('accessToken');
  localStorage.removeItem('refreshToken');
  localStorage.removeItem('userData');
};

// Obter token de acesso
export const getAccessToken = (): string | null => {
  // Primeiro tenta buscar com a chave 'accessToken' (nova)
  let token = localStorage.getItem('accessToken');
  
  // Se não encontrar, tenta com a chave 'access_token' (antiga)
  if (!token) {
    token = localStorage.getItem('access_token');
  }
  
  return token;
};

// Obter token de atualização
export const getRefreshToken = (): string | null => {
  return localStorage.getItem('refreshToken');
};