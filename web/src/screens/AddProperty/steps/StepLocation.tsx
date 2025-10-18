import { FormState } from "../types";
import MapSelector from "../../../components/MapSelector";

type Props = {
  form: FormState;
  setForm: (updater: (prev: FormState) => FormState) => void;
  onNext?: () => void;
  onBack?: () => void;
};

const StepLocation = ({ form, setForm }: Props) => {
  const handleLocationSelect = (address: string, lat: number, lng: number) => {
    setForm((prev) => ({
      ...prev,
      address: address,
      latitude: lat,
      longitude: lng
    }));
  };

  const handleAddressChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm((prev) => ({
      ...prev,
      address: e.target.value
    }));
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-semibold text-gray-900">Qual é o endereço?</h2>
        <p className="text-sm text-gray-500">Insira o endereço manualmente ou selecione no mapa</p>
      </div>

      {/* Campo de entrada manual */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Endereço completo
        </label>
        <input
          type="text"
          value={form.address || ''}
          onChange={handleAddressChange}
          placeholder="Digite o endereço completo ou selecione no mapa abaixo"
          className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-colors"
        />
      </div>

      {/* Endereço selecionado */}
      {form.address && (
        <div className="flex items-center gap-4 p-4 bg-green-50 rounded-lg border border-green-200">
          <div className="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center">📍</div>
          <div>
            <div className="text-sm font-medium text-green-800">Endereço selecionado:</div>
            <div className="text-green-700">{form.address}</div>
          </div>
        </div>
      )}

      {/* Mapa interativo */}
      <MapSelector
        onLocationSelect={handleLocationSelect}
        className="w-full h-80"
      />
    </div>
  );
};

export default StepLocation;
