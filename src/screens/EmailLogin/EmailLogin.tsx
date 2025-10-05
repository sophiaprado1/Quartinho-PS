import { ArrowLeft, MailIcon } from "lucide-react";
import { Link } from "react-router-dom";
import { Button } from "../../components/ui/button";

export const EmailLogin = (): JSX.Element => {
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
            <MailIcon className="w-16 h-16 mx-auto mb-4 text-orange-500" />
            <h1 className="text-2xl lg:text-3xl font-bold text-gray-800 mb-2">
              Entre com seu e-mail
            </h1>
            <p className="text-gray-600">
              Digite seu e-mail para continuar sua busca por um quartinho
            </p>
          </div>

          {/* Form */}
          <div className="space-y-6">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
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
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Senha
              </label>
              <input
                type="password"
                id="password"
                placeholder="Digite sua senha"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
              />
            </div>

            <Button className="w-full bg-orange-500 hover:bg-orange-600 rounded-full h-12 transition-colors duration-200">
              <span className="font-bold text-white">
                Continuar
              </span>
            </Button>
          </div>

          {/* Additional options */}
          <div className="mt-8 text-center">
            <p className="text-sm text-gray-600 mb-4">
              Ou continue com suas redes sociais
            </p>
            
            <div className="flex gap-4">
              <Button
                variant="secondary"
                className="flex-1 h-12 bg-gray-50 hover:bg-gray-100 rounded-lg border border-gray-200 transition-colors duration-200"
              >
                <img
                  className="w-5 h-5 mr-2"
                  alt="Google"
                  src="/logo---google---normal.png"
                />
                <span className="text-sm font-medium">Google</span>
              </Button>
              
              <Button
                variant="secondary"
                className="flex-1 h-12 bg-gray-50 hover:bg-gray-100 rounded-lg border border-gray-200 transition-colors duration-200"
              >
                <img
                  className="w-5 h-5 mr-2"
                  alt="Facebook"
                  src="/logo---facebook---normal.png"
                />
                <span className="text-sm font-medium">Facebook</span>
              </Button>
            </div>
          </div>

          {/* Footer */}
          <div className="text-center mt-12">
            <p className="text-sm text-gray-600">
              Ainda não tem uma conta?{" "}
              <Link to="/register" className="font-bold text-orange-500 hover:text-orange-600 transition-colors duration-200">
                Cadastre-se aqui
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};