import { useState } from "react";
import { Users, Home, ArrowRight } from "lucide-react";
import { Button } from "../../components/ui/button";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { API_BASE_URL } from "../../utils/apiConfig";

export const UserPreference = (): JSX.Element => {
  const [selectedOption, setSelectedOption] = useState<string>("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleOptionSelect = (option: string) => {
    setSelectedOption(option);
    setError("");
  };

  const navigate = useNavigate();

  const handleContinue = async () => {
    if (selectedOption) {
      setLoading(true);
      setError("");
      
      try {
        const token = localStorage.getItem('access_token');
        
        // Salvar a preferência do usuário no backend
        await axios.post(
          `${API_BASE_URL}/usuarios/preferences/`, 
          { preference_type: selectedOption },
          {
            headers: {
              'Authorization': `Bearer ${token}`
            }
          }
        );
        
        // Redirecionar com base na preferência
        if (selectedOption === "roommate") {
          navigate("/add-property");
        } else {
          // Se for "room", redirecionar para a página de busca de propriedades
          navigate("/properties");
        }
      } catch (error) {
        console.error("Erro ao salvar preferência:", error);
        setError("Não foi possível salvar sua preferência. Por favor, tente novamente.");
      } finally {
        setLoading(false);
      }
    }
  };

  const handleContinueNavigate = () => {
    if (!selectedOption) return;
    handleContinue();
  };

  return (
    <div className="bg-white min-h-screen w-full flex items-center justify-center p-6">
      <div className="w-full max-w-lg text-center">
        {/* Header */}
        <div className="mb-12">
          <h1 className="text-3xl lg:text-4xl font-bold text-gray-800 mb-6 leading-tight">
            Estamos quase lá!
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            Mas antes, conta pra gente: você está...
          </p>
        </div>

        {error && (
          <div className="bg-red-50 text-red-600 p-3 rounded-lg text-sm mb-6">
            {error}
          </div>
        )}

        {/* Options */}
        <div className="space-y-4 mb-12">
          {/* Option 1 - Procurando colega de quarto */}
          <button
            onClick={() => handleOptionSelect("roommate")}
            className={`w-full p-6 rounded-2xl border-2 transition-all duration-200 flex items-center justify-between ${
              selectedOption === "roommate"
                ? "border-orange-500 bg-orange-50"
                : "border-gray-200 hover:border-gray-300 hover:bg-gray-50"
            }`}
          >
            <div className="flex items-center">
              <div
                className={`w-12 h-12 rounded-full flex items-center justify-center mr-4 ${
                  selectedOption === "roommate"
                    ? "bg-orange-500 text-white"
                    : "bg-gray-100 text-gray-600"
                }`}
              >
                <Users className="w-6 h-6" />
              </div>
              <div className="text-left">
                <h3 className="font-semibold text-lg text-gray-800">
                  Procurando um colega de quarto
                </h3>
                <p className="text-gray-600 text-sm">
                  Você tem um quarto e quer encontrar alguém para dividir
                </p>
              </div>
            </div>
            <div
              className={`w-6 h-6 rounded-full border-2 flex items-center justify-center ${
                selectedOption === "roommate"
                  ? "border-orange-500 bg-orange-500"
                  : "border-gray-300"
              }`}
            >
              {selectedOption === "roommate" && (
                <div className="w-3 h-3 rounded-full bg-white"></div>
              )}
            </div>
          </button>

          {/* Option 2 - Procurando quarto */}
          <button
            onClick={() => handleOptionSelect("room")}
            className={`w-full p-6 rounded-2xl border-2 transition-all duration-200 flex items-center justify-between ${
              selectedOption === "room"
                ? "border-orange-500 bg-orange-50"
                : "border-gray-200 hover:border-gray-300 hover:bg-gray-50"
            }`}
          >
            <div className="flex items-center">
              <div
                className={`w-12 h-12 rounded-full flex items-center justify-center mr-4 ${
                  selectedOption === "room"
                    ? "bg-orange-500 text-white"
                    : "bg-gray-100 text-gray-600"
                }`}
              >
                <Home className="w-6 h-6" />
              </div>
              <div className="text-left">
                <h3 className="font-semibold text-lg text-gray-800">
                  Procurando um quarto
                </h3>
                <p className="text-gray-600 text-sm">
                  Você quer encontrar um quarto disponível para alugar
                </p>
              </div>
            </div>
            <div
              className={`w-6 h-6 rounded-full border-2 flex items-center justify-center ${
                selectedOption === "room"
                  ? "border-orange-500 bg-orange-500"
                  : "border-gray-300"
              }`}
            >
              {selectedOption === "room" && (
                <div className="w-3 h-3 rounded-full bg-white"></div>
              )}
            </div>
          </button>
        </div>

        {/* Continue Button */}
        <Button
          onClick={handleContinueNavigate}
          disabled={!selectedOption || loading}
          className={`w-full h-14 rounded-full text-lg font-bold transition-all duration-200 ${
            selectedOption && !loading
              ? "bg-orange-500 hover:bg-orange-600 text-white"
              : "bg-gray-200 text-gray-400 cursor-not-allowed"
          }`}
        >
          <span className="mr-2">{loading ? "Salvando..." : "Continuar"}</span>
          {!loading && <ArrowRight className="w-5 h-5" />}
        </Button>

        {/* Helper text */}
        <p className="text-sm text-gray-500 mt-4">
          Essa informação nos ajuda a personalizar sua experiência
        </p>
      </div>
    </div>
  );
};