import { FormState } from "../types";

type Props = {
  form: FormState;
  photos: File[];
  onBack?: () => void;
  onPublish?: () => void;
};

const StepReview = ({ form, photos }: Props) => {
  return (
    <div className="space-y-4">
      <div>
        <h2 className="text-2xl font-semibold">Revisão</h2>
        <p className="text-sm text-gray-500">Confira as informações antes de publicar</p>
      </div>

      <div className="space-y-4 p-4 bg-gray-50 rounded-2xl border">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <div className="text-sm font-semibold">Título</div>
            <div className="text-sm text-gray-700">{form.title || "-"}</div>
          </div>
          <div>
            <div className="text-sm font-semibold">Tipo</div>
            <div className="text-sm text-gray-700">{form.listingType} • {form.propertyType}</div>
          </div>
        </div>

        <div>
          <div className="text-sm font-semibold">Descrição</div>
          <div className="text-sm text-gray-700">{form.description || "-"}</div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <div className="text-sm font-semibold">Endereço</div>
            <div className="text-sm text-gray-700">{form.address || "-"}</div>
          </div>
          <div>
            <div className="text-sm font-semibold">Valor</div>
            <div className="text-sm text-gray-700">{form.price ? `${form.price} / ${form.priceFrequency === 'monthly' ? 'mês' : 'ano'}` : '-'}</div>
          </div>
        </div>

        <div className="grid grid-cols-3 gap-4">
          <div>
            <div className="text-sm font-semibold">Quartos</div>
            <div className="text-sm text-gray-700">{String(form.rooms || 0)}</div>
          </div>
          <div>
            <div className="text-sm font-semibold">Banheiros</div>
            <div className="text-sm text-gray-700">{form.bathrooms}</div>
          </div>
          <div>
            <div className="text-sm font-semibold">Varandas</div>
            <div className="text-sm text-gray-700">{form.balconies}</div>
          </div>
        </div>

        <div>
          <div className="text-sm font-semibold">Amenidades</div>
          <div className="text-sm text-gray-700">{form.amenities.length ? form.amenities.join(", ") : "-"}</div>
        </div>

        <div>
          <div className="text-sm font-semibold">Tags</div>
          <div className="flex gap-2 flex-wrap mt-2">
            {form.tags.length ? form.tags.map((t) => <div key={t} className="px-3 py-1 rounded-full bg-gray-100 text-sm">{t}</div>) : <div className="text-sm text-gray-500">Nenhuma</div>}
          </div>
        </div>

        <div>
          <div className="text-sm font-semibold">Fotos</div>
          <div className="mt-2 flex gap-2 flex-wrap">
            {photos.map((p, i) => (
              <div key={i} className="w-28 h-20 bg-gray-100 rounded overflow-hidden border">
                <img src={URL.createObjectURL(p)} alt={p.name} className="object-cover w-full h-full" />
              </div>
            ))}
            {photos.length === 0 && <div className="text-sm text-gray-500">Nenhuma foto adicionada.</div>}
          </div>
        </div>
      </div>
    </div>
  );
};

export default StepReview;
