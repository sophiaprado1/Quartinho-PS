import { ArrowLeft, UserPlus } from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import { useState } from "react";
import axios from "axios";

// =========================================================
// MOCKS TEMPORÁRIOS PARA RESOLVER ERROS DE IMPORTAÇÃO
// =========================================================

/**
 * [MOCK] Componente Button simples para permitir a compilação.
 */
const Button = ({ children, className = "", type = "button", disabled = false, onClick = () => {} }: any) => (
  <button
    type={type}
    className={`p-2 rounded-lg ${className} ${disabled ? 'opacity-50 cursor-not-allowed' : ''}`}
    disabled={disabled}
    onClick={onClick}
  >
    {children}
  </button>
);

/**
 * [MOCK] Definição da API_BASE_URL para permitir a execução da lógica.
 */
const API_BASE_URL = "http://localhost:8000"; 

// =========================================================

export const Register = (): JSX.Element => {
  const [formData, setFormData] = useState({
    nome_completo: "",
    data_nascimento: "",
    cpf: "",
    email: "",
    password: "",
  });
  const [acceptTerms, setAcceptTerms] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  // Importa a função de navegação do React Router
  const navigate = useNavigate();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { id, value } = e.target;
    setFormData(prev => ({ ...prev, [id]: value }));
  };

  /**
   * Função para verificar se o e-mail já está cadastrado.
   */
  const checkEmailExists = async () => {
    try {
      const response = await axios.post(`${API_BASE_URL}/usuarios/check-email/`, {
        email: formData.email
      });
      // A API deve retornar response.data.exists = true ou false
      return response.data.exists;
    } catch (err) {
      console.error("Erro ao verificar email:", err);
      // Em caso de falha na requisição, assume que o email não existe para continuar
      return false;
    }
  };

  /**
   * Função auxiliar para formatar erros do backend (geralmente erros de validação)
   */
  const formatBackendError = (errorData: any): string => {
    if (!errorData) {
      return "Erro desconhecido. Por favor, tente novamente.";
    }

    // Se o backend retornou uma string simples ou a propriedade 'detail'
    if (typeof errorData === 'string') {
      return errorData;
    }
    if (errorData.detail) {
      return errorData.detail;
    }

    // Se o backend retornou um objeto de validação (como Django Rest Framework, FastAPI)
    // Exemplo: { field_name: ["Error message 1", "Error message 2"], ... }
    const errorMessages = Object.entries(errorData)
      .map(([key, value]) => {
        // Formata a chave para ser mais legível (ex: nome_completo -> Nome completo)
        const displayKey = key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
        
        if (Array.isArray(value)) {
          return `${displayKey}: ${value.join('; ')}`;
        }
        return `${displayKey}: ${value}`;
      })
      .join(' | ');

    return errorMessages || "Dados inválidos. Verifique todos os campos.";
  };

  /**
   * Envia o formulário para registrar o usuário.
   */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!acceptTerms) {
      setError("Você precisa aceitar os termos de uso para continuar.");
      return;
    }

    setLoading(true);

    try {
      // 1. Verificar se o email já existe
      const emailExists = await checkEmailExists();
      if (emailExists) {
        setError("Este email já está cadastrado. Tente fazer login.");
        setLoading(false);
        return;
      }

      // NOVO: Loga os dados que estão sendo enviados para depuração 400
      console.log("Dados de registro sendo enviados:", formData);

      // 2. Registrar o usuário
      await axios.post(`${API_BASE_URL}/usuarios/usercreate/`, formData);
      
      // 3. Após o registro, redireciona para a tela de login.
      navigate("/email-login", { 
        state: { 
          registrationSuccess: true, 
          email: formData.email 
        } 
      });

    } catch (err: any) {
      console.error("Erro ao registrar:", err);
      
      // NOVO: Adiciona lógica para exibir a mensagem de erro detalhada do 400
      const apiErrorMessage = formatBackendError(err.response?.data);

      if (err.response && err.response.status === 400) {
        setError(`Erro de validação: ${apiErrorMessage}`);
      } else {
        // Para outros erros (ex: 500 Server Error)
        setError(apiErrorMessage || "Erro ao criar conta. Tente novamente mais tarde.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-white min-h-screen w-full flex flex-col">
      {/* Header with back button */}
      <div className="flex items-center p-6">
        <Link to="/" className="flex items-center text-gray-600 hover:text-gray-800 transition-colors">
          <ArrowLeft className="w-6 h-6 mr-2" />
          <span className="text-sm font-medium">Voltar</span>
        </Link>
      </div>

      {/* Main content */}
      <div className="flex-1 flex items-center justify-center p-6">
        <div className="w-full max-w-md">
          {/* Header */}
          <div className="text-center mb-8">
            <UserPlus className="w-12 h-12 mx-auto mb-4 text-orange-500" />
            <h1 className="text-2xl lg:text-3xl font-bold text-gray-800 mb-2">
              Criar conta
            </h1>
            <p className="text-gray-600">
              Preencha seus dados para criar sua conta no Quartinho
            </p>
          </div>

          {/* Form */}
          <form className="space-y-4" onSubmit={handleSubmit}>
            {error && (
              <div className="bg-red-50 text-red-600 p-3 rounded-lg text-sm rounded-xl">
                {error}
              </div>
            )}
            
            {/* Campos do Formulário (Nome, Data, CPF, Email, Senha) */}
            <div>
              <label htmlFor="nome_completo" className="block text-sm font-medium text-gray-700 mb-1">
                Nome completo
              </label>
              <input
                type="text"
                id="nome_completo"
                value={formData.nome_completo}
                onChange={handleChange}
                placeholder="Digite seu nome completo"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
                required
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label htmlFor="data_nascimento" className="block text-sm font-medium text-gray-700 mb-1">
                  Data de nascimento
                </label>
                <input
                  type="date"
                  id="data_nascimento"
                  value={formData.data_nascimento}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
                  required
                />
              </div>

              <div>
                <label htmlFor="cpf" className="block text-sm font-medium text-gray-700 mb-1">
                  CPF
                </label>
                <input
                  type="text"
                  id="cpf"
                  value={formData.cpf}
                  onChange={handleChange}
                  placeholder="000.000.000-00"
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
                  required
                />
              </div>
            </div>

            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
                E-mail
              </label>
              <input
                type="email"
                id="email"
                value={formData.email}
                onChange={handleChange}
                placeholder="Digite seu e-mail"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
                required
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
                Senha
              </label>
              <input
                type="password"
                id="password"
                value={formData.password}
                onChange={handleChange}
                placeholder="Digite sua senha"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
                required
              />
            </div>

            {/* Termos de Uso */}
            <div className="flex items-start mt-6">
              <input
                type="checkbox"
                id="terms"
                checked={acceptTerms}
                onChange={(e) => setAcceptTerms(e.target.checked)}
                className="mt-1 h-4 w-4 text-orange-500 focus:ring-orange-500 border-gray-300 rounded"
              />
              <label htmlFor="terms" className="ml-2 block text-sm text-gray-700">
                Eu concordo com os{" "}
                <a href="#" className="text-orange-500 hover:text-orange-600 font-medium">
                  Termos de Uso
                </a>{" "}
                e{" "}
                <a href="#" className="text-orange-500 hover:text-orange-600 font-medium">
                  Política de Privacidade
                </a>
              </label>
            </div>

            {/* Botão de Submissão */}
            <Button 
              type="submit" 
              className="w-full bg-orange-500 hover:bg-orange-600 rounded-full h-12 transition-colors duration-200 mt-6"
              disabled={loading}
            >
              <span className="font-bold text-white">
                {loading ? "Criando conta..." : "Criar conta"}
              </span>
            </Button>
          </form>

          {/* Footer */}
          <div className="text-center mt-8">
            <p className="text-sm text-gray-600">
              Já tem uma conta?{" "}
              <Link to="/email-login" className="font-bold text-orange-500 hover:text-orange-600 transition-colors duration-200">
                Faça login
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
