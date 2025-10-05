import { FormState } from "../types";

type Props = {
  form: FormState;
  onNext?: () => void;
  onBack?: () => void;
};

const StepLocation = ({ form }: Props) => {
  return (
    <div className="space-y-4">
      <div>
        <h2 className="text-2xl font-semibold text-gray-900">Qual é o endereço?</h2>
        <p className="text-sm text-gray-500">Insira o endereço ou selecione no mapa</p>
      </div>

      <div className="flex items-center gap-4">
        <div className="w-12 h-12 rounded-full bg-gray-100 flex items-center justify-center">📍</div>
        <div className="text-gray-700">{form.address || 'Endereço não informado'}</div>
      </div>

      <div className="w-full h-72 bg-gray-50 rounded-2xl border overflow-hidden">
        {/* Placeholder para mapa */}
        <div className="w-full h-full flex items-center justify-center text-gray-400">Mapa - selecione no mapa</div>
      </div>
    </div>
  );
};

export default StepLocation;
