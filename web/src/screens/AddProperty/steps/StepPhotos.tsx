type Props = {
  photos: File[];
  setPhotos: React.Dispatch<React.SetStateAction<File[]>>;
  onNext?: () => void;
  onBack?: () => void;
};

const StepPhotos = ({ photos, setPhotos }: Props) => {
  const handleFiles = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files) return;
    setPhotos(Array.from(e.target.files));
  };

  return (
    <div className="space-y-4">
      <div>
        <h2 className="text-2xl font-semibold text-gray-900">Adicione fotos para seu anúncio</h2>
        <p className="text-sm text-gray-500">Mostre os melhores ângulos do imóvel</p>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
        {photos.map((p, i) => (
          <div key={i} className="w-full pb-[100%] relative rounded-2xl overflow-hidden border">
            <img src={URL.createObjectURL(p)} alt={p.name} className="absolute inset-0 w-full h-full object-cover" />
            <button className="absolute top-2 right-2 w-8 h-8 rounded-full bg-orange-500 text-white">×</button>
          </div>
        ))}

        <label className="flex items-center justify-center rounded-2xl border border-dashed border-gray-200 bg-gray-50 p-6 cursor-pointer">
          <input type="file" multiple accept="image/*" onChange={handleFiles} className="hidden" />
          <div className="text-2xl text-gray-400">＋</div>
        </label>
      </div>
    </div>
  );
};

export default StepPhotos;
