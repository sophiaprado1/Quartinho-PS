import { useState } from "react";
import { useNavigate } from "react-router-dom";
import StepBasicInfo from "./steps/StepBasicInfo";
import StepPhotos from "./steps/StepPhotos";
import StepLocation from "./steps/StepLocation";
import StepAmenities from "./steps/StepAmenities";
import StepReview from "./steps/StepReview";
import { Button } from "../../components/ui/button";
import { FormState, initialForm } from "./types";

const AddProperty = (): JSX.Element => {
  const navigate = useNavigate();
  const [form, setForm] = useState<FormState>(initialForm);
  const [formErrors, setFormErrors] = useState<{ price?: string }>({});
  const [photos, setPhotos] = useState<File[]>([]);
  const [step, setStep] = useState<number>(0);
  const [showSuccess, setShowSuccess] = useState<boolean>(false);

  const next = () => setStep((s) => Math.min(s + 1, 4));
  const back = () => (step === 0 ? navigate(-1) : setStep((s) => Math.max(s - 1, 0)));

  const handlePublish = async () => {
    // Aqui você integraria com a API. Por enquanto apenas log e mostra modal de sucesso.
    console.log("Publicando imóvel:", { ...form, photos });
    setShowSuccess(true);
  };

  const stepTitles = [
    "Informações básicas",
    "Fotos",
    "Localização",
    "Características",
    "Revisão",
  ];

  return (
    <div className="min-h-screen bg-gray-50 flex items-start justify-center py-12 px-6">
      <div className="w-full max-w-4xl">
        <header className="mb-8">
          <div>
            <div className="text-sm text-gray-600">Adicionar listagem</div>
            <h1 className="text-3xl font-semibold text-gray-900">Estamos quase lá! Adicione mais detalhes</h1>
          </div>
        </header>

        <div className="bg-white p-8 rounded-3xl shadow-md border">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="hidden lg:block">
              <nav className="space-y-4 sticky top-6">
                {stepTitles.map((t, i) => (
                  <div key={t} className={`p-3 rounded-xl ${i === step ? "bg-orange-50" : "bg-white"}`}>
                    <div className="flex items-center gap-3">
                      <div className={`w-10 h-10 rounded-full flex items-center justify-center font-medium ${i === step ? "bg-orange-500 text-white" : i < step ? "bg-orange-100 text-orange-700" : "bg-gray-100 text-gray-600"}`}>
                        {i + 1}
                      </div>
                      <div className="text-sm text-gray-700">{t}</div>
                    </div>
                  </div>
                ))}
              </nav>
            </div>

            <main className="lg:col-span-2 space-y-6">
              {step === 0 && (
                <StepBasicInfo form={form} setForm={setForm} onClearError={(f) => setFormErrors((e) => ({ ...e, [f]: undefined }))} formErrors={formErrors} />
              )}
              {step === 1 && (
                <StepPhotos photos={photos} setPhotos={setPhotos} onNext={next} onBack={back} />
              )}
              {step === 2 && (
                <StepLocation form={form} onNext={next} onBack={back} />
              )}
              {step === 3 && (
                <StepAmenities form={form} setForm={setForm} onNext={next} onBack={back} />
              )}
              {step === 4 && (
                <StepReview form={form} photos={photos} />
              )}

              <div className="mt-4 flex items-center justify-between">
                <Button variant="secondary" className="rounded-full h-12 px-6" onClick={back}>
                  {step === 0 ? "Voltar" : "Anterior"}
                </Button>
                <div className="text-sm text-gray-600">Passo {step + 1} de 5</div>
                <Button
                  className="rounded-full h-12 px-8"
                  onClick={() => {
                    // validações por step
                    if (step === 0) {
                      const cleaned = (form.price || "").replace(/\s/g, '').replace(',', '.').replace(/[^0-9.]/g, '');
                      const num = parseFloat(cleaned);
                      if (!form.price || form.price.trim() === '') {
                        setFormErrors({ price: 'Insira o valor do aluguel' });
                        return;
                      }
                      if (isNaN(num) || num <= 0) {
                        setFormErrors({ price: 'Insira um valor válido' });
                        return;
                      }
                    }
                      if (step < 4) next();
                      else handlePublish();
                  }}
                >
                  {step < 4 ? "Próximo" : "Publicar"}
                </Button>
              </div>
            </main>
          </div>
        </div>
      </div>
        {showSuccess && (
          <div className="fixed inset-0 z-50 flex items-center justify-center">
            <div className="absolute inset-0 bg-black/80 z-40" />

            <div className="relative w-full max-w-md flex items-center justify-center z-50">

              {/* ...badge externo removido — permanece apenas o badge dentro do card */}

              <div className="relative rounded-2xl p-8 pt-16 w-full shadow-lg z-50 flex flex-col items-center gap-6 overflow-visible" style={{ backgroundColor: 'rgba(255,255,255,1)', opacity: 1 }}>
                {/* Badge movido para dentro do card e totalmente visível */}
                <div className="absolute left-1/2 -translate-x-1/2 z-60 pointer-events-none" style={{ top: '-28px' }}>
                  <div className="w-14 h-14 rounded-full bg-orange-500 flex items-center justify-center shadow-sm">
                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden>
                      <circle cx="12" cy="12" r="12" fill="transparent" />
                      <path d="M20 6L9 17l-5-5" stroke="#fff" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" />
                    </svg>
                  </div>
                </div>

                <h3 className="text-xl font-semibold">Anúncio publicado</h3>
                <p className="text-center text-sm text-gray-600">Seu imóvel foi publicado com sucesso e já está visível para potenciais interessados.</p>
                <div className="w-full flex justify-center">
                  <Button onClick={() => navigate('/')} className="rounded-full bg-orange-500 text-white px-8">Ir para início</Button>
                </div>
              </div>
            </div>
          </div>
        )}
    </div>
  );
};

export default AddProperty;
