import { FormState } from "../types";
import { Separator } from "../../../components/ui/separator";

const ListingTypes = ["Colega de quarto", "República"];
const PropertyTypes = ["Apartamento", "Casa", "Kitnet"];

type Props = {
  form: FormState;
  setForm: React.Dispatch<React.SetStateAction<FormState>>;
  formErrors?: { price?: string };
  onClearError?: (field: string) => void;
};

const StepBasicInfo = ({ form, setForm, formErrors, onClearError }: Props) => {
  const inc = (k: "rooms" | "bathrooms" | "balconies") => {
    setForm((s) => ({ ...s, [k]: (Number(s[k]) || 0) + 1 } as any));
  };
  const dec = (k: "rooms" | "bathrooms" | "balconies") => {
    setForm((s) => ({ ...s, [k]: Math.max((Number(s[k]) || 0) - 1, 0) } as any));
  };

  // erros ficam no container (AddProperty). Aqui apenas dispara limpeza quando usuário digita
  const handlePriceChange = (value: string) => {
    setForm((s) => ({ ...s, price: value } as any));
    if (onClearError) onClearError('price');
  };

  return (
    <div className="space-y-6">
      <div className="p-6 bg-gray-50 rounded-2xl border">
        <h2 className="text-2xl font-semibold text-gray-900">Oi, Carla! Conte mais sobre seu imóvel</h2>
        <p className="text-sm text-gray-500 mt-1">Adicione título, tipo de anúncio e tipo de imóvel.</p>

        <div className="mt-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Título</label>
            <input
              name="title"
              value={form.title}
              onChange={(e) => setForm((s) => ({ ...s, title: e.target.value }))}
              className="w-full rounded-full border border-gray-100 p-4 focus:outline-none focus:ring-2 focus:ring-orange-200 text-lg"
              placeholder="Ex: Quarto com varanda"
            />
          </div>

          

          <div>
            <div className="text-sm font-medium text-gray-700 mb-2">Listing type</div>
            <div className="flex items-center gap-3">
              {ListingTypes.map((lt) => (
                <button key={lt} onClick={() => setForm((s) => ({ ...s, listingType: lt }))} className={`px-6 py-3 rounded-full ${form.listingType === lt ? 'bg-orange-500 text-white' : 'bg-gray-100 text-gray-700'}`}>
                  {lt}
                </button>
              ))}
            </div>
          </div>

          {/* Campo Valor colocado por último */}
          <div className="mt-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">Valor (R$)</label>
            <div className="flex items-center gap-4">
              <input
                name="price"
                inputMode="decimal"
                value={form.price}
                onChange={(e) => handlePriceChange(e.target.value)}
                className="flex-1 rounded-full border border-gray-100 p-4 text-lg focus:outline-none"
                placeholder="R$ 915"
              />
              <div className="flex flex-col gap-2">
                <button onClick={() => setForm((s) => ({ ...s, priceFrequency: 'monthly' }))} className={`px-4 py-2 rounded-full ${form.priceFrequency === 'monthly' ? 'bg-orange-500 text-white' : 'bg-gray-100 text-gray-700'}`}>Mensal</button>
                <button onClick={() => setForm((s) => ({ ...s, priceFrequency: 'annual' }))} className={`px-4 py-2 rounded-full ${form.priceFrequency === 'annual' ? 'bg-orange-500 text-white' : 'bg-gray-100 text-gray-700'}`}>Anual</button>
              </div>
            </div>
            {formErrors?.price && (
              <div className="text-sm text-red-600 mt-2">{formErrors.price}</div>
            )}
          </div>

          <div>
            <div className="text-sm font-medium text-gray-700 mb-2">Tipo de imóvel</div>
            <div className="flex items-center gap-3">
              {PropertyTypes.map((pt) => (
                <button key={pt} onClick={() => setForm((s) => ({ ...s, propertyType: pt }))} className={`px-6 py-3 rounded-full ${form.propertyType === pt ? 'bg-orange-500 text-white' : 'bg-gray-100 text-gray-700'}`}>
                  {pt}
                </button>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Quartos</label>
              <div className="flex items-center gap-3">
                <button onClick={() => dec('rooms')} className="w-10 h-10 rounded-full bg-orange-100 text-orange-700">−</button>
                <div className="text-lg font-medium">{form.rooms || 0}</div>
                <button onClick={() => inc('rooms')} className="w-10 h-10 rounded-full bg-orange-500 text-white">+</button>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Banheiros</label>
              <div className="flex items-center gap-3">
                <button onClick={() => dec('bathrooms')} className="w-10 h-10 rounded-full bg-orange-100 text-orange-700">−</button>
                <div className="text-lg font-medium">{form.bathrooms}</div>
                <button onClick={() => inc('bathrooms')} className="w-10 h-10 rounded-full bg-orange-500 text-white">+</button>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Varandas</label>
              <div className="flex items-center gap-3">
                <button onClick={() => dec('balconies')} className="w-10 h-10 rounded-full bg-orange-100 text-orange-700">−</button>
                <div className="text-lg font-medium">{form.balconies}</div>
                <button onClick={() => inc('balconies')} className="w-10 h-10 rounded-full bg-orange-500 text-white">+</button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <Separator />
    </div>
  );
};

export default StepBasicInfo;
