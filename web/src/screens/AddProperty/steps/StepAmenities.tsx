import { FormState } from "../types";

type Props = {
  form: FormState;
  setForm: React.Dispatch<React.SetStateAction<FormState>>;
  onNext?: () => void;
  onBack?: () => void;
};

const PRESET_TAGS = [
  'Garagem', 'Pet Friendly', 'Misto', 'Internet inclusa', 'Proximidade a linhas de ônibus', 'Mobiliado', 'Permite visitação'
];

const AMENITIES = [
  "Wi-fi",
  "Lavanderia",
  "Cozinha",
  "Mobiliado",
  "Estacionamento",
];

const StepAmenities = ({ form, setForm }: Props) => {
  const toggle = (amenity: string) => {
    setForm((s) => ({
      ...s,
      amenities: s.amenities.includes(amenity) ? s.amenities.filter((a) => a !== amenity) : [...s.amenities, amenity],
    }));
  };

  const toggleTag = (tag: string) => {
    setForm((s) => ({
      ...s,
      tags: s.tags.includes(tag) ? s.tags.filter((t) => t !== tag) : [...s.tags, tag],
    }));
  };

  return (
    <div className="space-y-4">
      <div className="p-4 bg-gray-50 rounded-2xl border">
        <h2 className="text-2xl font-semibold text-gray-900">Características do imóvel</h2>
        <p className="text-sm text-gray-500">Selecione quantidades e tags adicionais</p>

        <div className="mt-4 space-y-4">
          <div>
            <div className="text-sm font-medium text-gray-700 mb-2">Amenidades</div>
            <div className="flex gap-3 flex-wrap">
              {AMENITIES.map((a) => (
                <button key={a} onClick={() => toggle(a)} className={`px-4 py-2 rounded-full ${form.amenities.includes(a) ? 'bg-orange-500 text-white' : 'bg-gray-100 text-gray-700'}`}>{a}</button>
              ))}
            </div>
          </div>

          <div>
            <div className="text-sm font-medium text-gray-700 mb-2">Tags adicionais</div>
            <div className="flex gap-3 flex-wrap">
              {PRESET_TAGS.map((t) => (
                <button key={t} onClick={() => toggleTag(t)} className={`px-4 py-2 rounded-full ${form.tags.includes(t) ? 'bg-orange-500 text-white' : 'bg-gray-100 text-gray-700'}`}>{t}</button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default StepAmenities;
