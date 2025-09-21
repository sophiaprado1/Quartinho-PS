import { ArrowLeft, UserPlus } from "lucide-react";
import { Link } from "react-router-dom";
import { Button } from "../../components/ui/button";

export const Register = (): JSX.Element => {
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
          <form className="space-y-4">
            <div>
              <label htmlFor="fullName" className="block text-sm font-medium text-gray-700 mb-1">
                Nome completo
              </label>
              <input
                type="text"
                id="fullName"
                placeholder="Digite seu nome completo"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label htmlFor="birthDate" className="block text-sm font-medium text-gray-700 mb-1">
                  Data de nascimento
                </label>
                <input
                  type="date"
                  id="birthDate"
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
                />
              </div>

              <div>
                <label htmlFor="cpf" className="block text-sm font-medium text-gray-700 mb-1">
                  CPF
                </label>
                <input
                  type="text"
                  id="cpf"
                  placeholder="000.000.000-00"
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
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
                placeholder="Digite seu e-mail"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
                Senha
              </label>
              <input
                type="password"
                id="password"
                placeholder="Digite sua senha"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
              />
            </div>

            {/* Terms checkbox */}
            <div className="flex items-start space-x-3 pt-2">
              <input
                type="checkbox"
                id="terms"
                className="mt-1 w-4 h-4 text-orange-500 border-gray-300 rounded focus:ring-orange-500"
              />
              <label htmlFor="terms" className="text-sm text-gray-600">
                Concordo com os{" "}
                <button type="button" className="text-orange-500 hover:text-orange-600 font-medium">
                  termos da plataforma Quartinho
                </button>
              </label>
            </div>

            <Link to="/user-preference">
              <Button className="w-full bg-orange-500 hover:bg-orange-600 rounded-full h-12 mt-6 transition-colors duration-200">
                <span className="font-bold text-white">
                  Criar conta
                </span>
              </Button>
            </Link>
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