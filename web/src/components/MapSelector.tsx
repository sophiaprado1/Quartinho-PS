import { useEffect, useState, useCallback } from 'react';
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

// Fix para ícones do Leaflet no React
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

interface MapSelectorProps {
  onLocationSelect: (address: string, lat: number, lng: number) => void;
  initialPosition?: [number, number];
  className?: string;
}

interface LocationMarkerProps {
  onLocationSelect: (address: string, lat: number, lng: number) => void;
  position: [number, number] | null;
}

const LocationMarker = ({ onLocationSelect, position }: LocationMarkerProps) => {
  useMapEvents({
    click(e) {
      const { lat, lng } = e.latlng;
      
      // Fazer geocoding reverso para obter o endereço
      fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=18&addressdetails=1`)
        .then(response => response.json())
        .then(data => {
          const address = data.display_name || `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
          onLocationSelect(address, lat, lng);
        })
        .catch(() => {
          // Em caso de erro, usar as coordenadas
          const address = `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
          onLocationSelect(address, lat, lng);
        });
    },
  });

  return position ? <Marker position={position} /> : null;
};

const MapSelector = ({ 
  onLocationSelect, 
  initialPosition = [-23.5505, -46.6333], // São Paulo como padrão
  className = "w-full h-72"
}: MapSelectorProps) => {
  const [markerPosition, setMarkerPosition] = useState<[number, number] | null>(null);
  const [mapCenter, setMapCenter] = useState<[number, number]>(initialPosition);

  const handleLocationSelect = useCallback((address: string, lat: number, lng: number) => {
    setMarkerPosition([lat, lng]);
    onLocationSelect(address, lat, lng);
  }, [onLocationSelect]);

  useEffect(() => {
    // Tentar obter localização atual do usuário
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          setMapCenter([latitude, longitude]);
        },
        (error) => {
          console.log('Erro ao obter localização:', error);
          // Continua com a posição padrão
        }
      );
    }
  }, []);

  return (
    <div className={className}>
      <div className="mb-2">
        <p className="text-sm text-gray-600">
          Clique no mapa para selecionar o endereço
        </p>
      </div>
      
      <div className="rounded-2xl overflow-hidden border border-gray-200">
        <MapContainer
          center={mapCenter}
          zoom={13}
          style={{ height: '100%', width: '100%', minHeight: '300px' }}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            maxZoom={19}
            subdomains={['a', 'b', 'c']}
            crossOrigin={true}
          />
          <LocationMarker onLocationSelect={handleLocationSelect} position={markerPosition} />
        </MapContainer>
      </div>
      
      <div className="mt-2">
        <p className="text-xs text-gray-500">
          💡 Dica: Você também pode usar a busca por CEP ou nome da rua
        </p>
      </div>
    </div>
  );
};

export default MapSelector;