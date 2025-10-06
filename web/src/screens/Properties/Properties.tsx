import { useState, useEffect } from "react";
import { Search, Filter, MapPin, Heart, Star, Bed, Bath, Car, Wifi } from "lucide-react";
import { Button } from "../../components/ui/button";
import axios from "axios";
import { API_BASE_URL } from "../../utils/apiConfig";

interface Property {
  id: number;
  titulo: string;
  descricao: string;
  tipo: string;
  preco: number;
  endereco: string;
  cidade: string;
  estado: string;
  quartos: number;
  banheiros: number;
  area?: number;
  mobiliado: boolean;
  aceita_pets: boolean;
  internet: boolean;
  estacionamento: boolean;
  fotos: Array<{
    id: number;
    imagem: string;
    principal: boolean;
  }>;
}

export const Properties = (): JSX.Element => {
  const [properties, setProperties] = useState<Property[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [searchTerm, setSearchTerm] = useState("");
  const [filters, setFilters] = useState({
    tipo: "",
    preco_min: "",
    preco_max: "",
    cidade: ""
  });

  useEffect(() => {
    fetchProperties();
  }, [filters]); // Adiciona filters como dependência para refazer a busca quando os filtros mudarem

  const fetchProperties = async () => {
    try {
      const token = localStorage.getItem('access_token');
      const response = await axios.get(`${API_BASE_URL}/propriedades/propriedades/`, {
        headers: {
          'Authorization': `Bearer ${token}`
        },
        params: filters
      });
      setProperties(response.data);
    } catch (error) {
      console.error("Erro ao buscar propriedades:", error);
      setError("Não foi possível carregar as propriedades. Tente novamente.");
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = () => {
    setFilters(prev => ({ ...prev, cidade: searchTerm }));
  };

  const handleFilterChange = (key: string, value: string) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(price);
  };

  const getPropertyImage = (property: Property) => {
    const principalPhoto = property.fotos?.find(foto => foto.principal);
    return principalPhoto?.imagem || property.fotos?.[0]?.imagem || '/placeholder-property.jpg';
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando propriedades...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <h1 className="text-3xl font-bold text-gray-900 mb-6">
            Encontre seu quarto ideal
          </h1>
          
          {/* Search Bar */}
          <div className="flex gap-4 mb-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Buscar por cidade..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
              />
            </div>
            <Button 
              onClick={handleSearch}
              className="bg-orange-500 hover:bg-orange-600 px-6"
            >
              Buscar
            </Button>
          </div>

          {/* Filters */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tipo de Imóvel
              </label>
              <select
                value={filters.tipo}
                onChange={(e) => handleFilterChange('tipo', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              >
                <option value="">Todos os tipos</option>
                <option value="apartamento">Apartamento</option>
                <option value="casa">Casa</option>
                <option value="kitnet">Kitnet</option>
                <option value="republica">República</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Preço Mínimo
              </label>
              <input
                type="number"
                placeholder="R$ 0"
                value={filters.preco_min}
                onChange={(e) => handleFilterChange('preco_min', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Preço Máximo
              </label>
              <input
                type="number"
                placeholder="R$ 10.000"
                value={filters.preco_max}
                onChange={(e) => handleFilterChange('preco_max', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Cidade
              </label>
              <input
                type="text"
                placeholder="Digite a cidade"
                value={filters.cidade}
                onChange={(e) => handleFilterChange('cidade', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-7xl mx-auto px-4 py-8">
        {error && (
          <div className="bg-red-50 text-red-600 p-4 rounded-lg mb-6">
            {error}
          </div>
        )}

        {properties.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-gray-400 mb-4">
              <Search className="w-16 h-16 mx-auto" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Nenhuma propriedade encontrada
            </h3>
            <p className="text-gray-600">
              Tente ajustar seus filtros de busca ou verifique novamente mais tarde.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {properties.map((property) => (
              <div key={property.id} className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-shadow">
                {/* Property Image */}
                <div className="relative h-48">
                  <img
                    src={getPropertyImage(property)}
                    alt={property.titulo}
                    className="w-full h-full object-cover"
                  />
                  <button className="absolute top-3 right-3 p-2 bg-white rounded-full shadow-md hover:bg-gray-50">
                    <Heart className="w-4 h-4 text-gray-600" />
                  </button>
                  <div className="absolute bottom-3 left-3 bg-white px-2 py-1 rounded-md text-sm font-medium">
                    {property.tipo}
                  </div>
                </div>

                {/* Property Info */}
                <div className="p-4">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold text-lg text-gray-900 truncate">
                      {property.titulo}
                    </h3>
                    <div className="flex items-center">
                      <Star className="w-4 h-4 text-yellow-400 fill-current" />
                      <span className="text-sm text-gray-600 ml-1">4.8</span>
                    </div>
                  </div>

                  <div className="flex items-center text-gray-600 mb-3">
                    <MapPin className="w-4 h-4 mr-1" />
                    <span className="text-sm truncate">{property.cidade}, {property.estado}</span>
                  </div>

                  <p className="text-gray-600 text-sm mb-4 line-clamp-2">
                    {property.descricao}
                  </p>

                  {/* Amenities */}
                  <div className="flex items-center gap-4 mb-4 text-sm text-gray-600">
                    <div className="flex items-center">
                      <Bed className="w-4 h-4 mr-1" />
                      <span>{property.quartos}</span>
                    </div>
                    <div className="flex items-center">
                      <Bath className="w-4 h-4 mr-1" />
                      <span>{property.banheiros}</span>
                    </div>
                    {property.estacionamento && (
                      <div className="flex items-center">
                        <Car className="w-4 h-4 mr-1" />
                      </div>
                    )}
                    {property.internet && (
                      <div className="flex items-center">
                        <Wifi className="w-4 h-4 mr-1" />
                      </div>
                    )}
                  </div>

                  {/* Tags */}
                  <div className="flex flex-wrap gap-2 mb-4">
                    {property.mobiliado && (
                      <span className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full">
                        Mobiliado
                      </span>
                    )}
                    {property.aceita_pets && (
                      <span className="px-2 py-1 bg-green-100 text-green-800 text-xs rounded-full">
                        Pet Friendly
                      </span>
                    )}
                  </div>

                  {/* Price and Action */}
                  <div className="flex items-center justify-between">
                    <div>
                      <span className="text-2xl font-bold text-gray-900">
                        {formatPrice(property.preco)}
                      </span>
                      <span className="text-gray-600 text-sm">/mês</span>
                    </div>
                    <Button className="bg-orange-500 hover:bg-orange-600">
                      Ver detalhes
                    </Button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};