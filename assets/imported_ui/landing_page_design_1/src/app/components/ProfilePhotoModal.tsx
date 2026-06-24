import { useState, useRef } from 'react';
import { X, Upload, Camera } from 'lucide-react';
import { toast } from 'sonner';

interface ProfilePhotoModalProps {
  currentPhotoUrl?: string;
  userName: string;
  onClose: () => void;
  onSave: (photoUrl: string) => void;
}

export function ProfilePhotoModal({ currentPhotoUrl, userName, onClose, onSave }: ProfilePhotoModalProps) {
  const [previewUrl, setPreviewUrl] = useState<string | undefined>(currentPhotoUrl);
  const [isHovering, setIsHovering] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const cameraInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = (file: File) => {
    if (!file.type.startsWith('image/')) {
      toast.error('File harus berupa gambar');
      return;
    }

    const maxSize = 2 * 1024 * 1024; // 2MB
    if (file.size > maxSize) {
      toast.error('Ukuran file maksimal 2 MB');
      return;
    }

    const reader = new FileReader();
    reader.onload = (e) => {
      const result = e.target?.result as string;
      setPreviewUrl(result);
    };
    reader.readAsDataURL(file);
  };

  const handleSave = () => {
    if (previewUrl) {
      onSave(previewUrl);
      toast.success('Foto profil berhasil diperbarui');
      onClose();
    }
  };

  const handleRemove = () => {
    setPreviewUrl(undefined);
  };

  return (
    <>
      {/* Backdrop */}
      <div className="fixed inset-0 bg-black/40 z-50 animate-in fade-in duration-200" onClick={onClose} />

      {/* Modal */}
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 pointer-events-none">
        <div
          className="bg-white rounded-2xl shadow-2xl w-full max-w-md pointer-events-auto animate-in fade-in zoom-in-95 duration-200"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Header */}
          <div className="flex items-center justify-between px-6 py-5 border-b border-gray-100">
            <h2 className="text-lg font-semibold text-gray-900">Ubah foto profil</h2>
            <button
              onClick={onClose}
              className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-gray-100 transition-colors text-gray-400 hover:text-gray-600"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Content */}
          <div className="px-6 py-6">
            {/* Avatar Preview */}
            <div className="flex justify-center mb-6">
              <div
                className="relative group"
                onMouseEnter={() => setIsHovering(true)}
                onMouseLeave={() => setIsHovering(false)}
              >
                <div className="w-24 h-24 rounded-full overflow-hidden bg-gradient-to-br from-red-800 to-red-900 flex items-center justify-center shadow-lg ring-4 ring-gray-100">
                  {previewUrl ? (
                    <img
                      src={previewUrl}
                      alt={userName}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <span className="text-white text-3xl font-bold">
                      {userName.charAt(0).toUpperCase()}
                    </span>
                  )}
                </div>

                {/* Camera Icon Overlay */}
                {isHovering && (
                  <div className="absolute inset-0 bg-black/40 rounded-full flex items-center justify-center transition-opacity">
                    <Camera className="w-8 h-8 text-white" />
                  </div>
                )}
              </div>
            </div>

            {/* Action Buttons */}
            <div className="space-y-3">
              <button
                onClick={() => fileInputRef.current?.click()}
                className="w-full flex items-center justify-center gap-3 px-4 py-3.5 bg-red-800 hover:bg-red-900 text-white rounded-xl font-medium transition-all hover:shadow-md active:scale-[0.98]"
              >
                <Upload className="w-5 h-5" />
                Upload dari perangkat
              </button>

              <button
                onClick={() => cameraInputRef.current?.click()}
                className="w-full flex items-center justify-center gap-3 px-4 py-3.5 border-2 border-gray-200 hover:border-red-800 hover:bg-red-50 text-gray-700 hover:text-red-800 rounded-xl font-medium transition-all active:scale-[0.98]"
              >
                <Camera className="w-5 h-5" />
                Ambil foto
              </button>

              {previewUrl && (
                <button
                  onClick={handleRemove}
                  className="w-full px-4 py-3 text-sm text-red-600 hover:bg-red-50 rounded-xl font-medium transition-colors"
                >
                  Hapus foto
                </button>
              )}
            </div>

            {/* Hidden File Inputs */}
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) handleFileSelect(file);
              }}
            />
            <input
              ref={cameraInputRef}
              type="file"
              accept="image/*"
              capture="user"
              className="hidden"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) handleFileSelect(file);
              }}
            />
          </div>

          {/* Footer */}
          <div className="flex items-center justify-end gap-3 px-6 py-4 border-t border-gray-100 bg-gray-50 rounded-b-2xl">
            <button
              onClick={onClose}
              className="px-5 py-2.5 text-sm font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-200 rounded-lg transition-colors"
            >
              Batal
            </button>
            <button
              onClick={handleSave}
              disabled={!previewUrl}
              className="px-5 py-2.5 text-sm font-medium bg-red-800 hover:bg-red-900 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-red-800"
            >
              Simpan
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
