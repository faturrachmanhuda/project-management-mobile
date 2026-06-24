import { X, Download, FileText, Image as ImageIcon, FileCode, FileQuestion } from 'lucide-react';

interface FilePreviewProps {
  url: string;
  name: string;
  onClose: () => void;
}

export function FilePreview({ url, name, onClose }: FilePreviewProps) {
  const extension = name.split('.').pop()?.toLowerCase() || '';
  const isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].includes(extension);
  const isPdf = extension === 'pdf';

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
      <div className="relative w-full max-w-4xl max-h-[90vh] bg-white rounded-2xl overflow-hidden flex flex-col shadow-2xl">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100 bg-white">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-red-50 text-red-800 rounded-lg flex items-center justify-center">
              {isImage ? <ImageIcon className="w-5 h-5" /> : isPdf ? <FileText className="w-5 h-5" /> : <FileQuestion className="w-5 h-5" />}
            </div>
            <div>
              <h3 className="text-sm font-bold text-gray-900 truncate max-w-[200px] sm:max-w-md">{name}</h3>
              <p className="text-xs text-gray-500 uppercase font-medium">{extension} File</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <a 
              href={url} 
              download={name}
              className="p-2 text-gray-500 hover:text-red-800 hover:bg-red-50 rounded-lg transition-colors"
              title="Download File"
            >
              <Download className="w-5 h-5" />
            </a>
            <button 
              onClick={onClose}
              className="p-2 text-gray-500 hover:text-red-800 hover:bg-red-50 rounded-lg transition-colors"
              title="Close Preview"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-auto bg-gray-50 flex items-center justify-center p-4 min-h-[300px]">
          {isImage ? (
            <img 
              src={url} 
              alt={name} 
              className="max-w-full max-h-full object-contain shadow-sm rounded-lg"
            />
          ) : isPdf ? (
            <iframe 
              src={`${url}#toolbar=0`} 
              className="w-full h-full min-h-[60vh] border-none rounded-lg"
              title="PDF Preview"
            />
          ) : (
            <div className="text-center p-12">
              <div className="w-20 h-20 bg-gray-200 rounded-full flex items-center justify-center mx-auto mb-4">
                <FileCode className="w-10 h-10 text-gray-400" />
              </div>
              <h4 className="text-lg font-bold text-gray-900 mb-2">Preview tidak tersedia</h4>
              <p className="text-gray-500 mb-6 max-w-xs mx-auto">
                File format .{extension} tidak dapat ditampilkan langsung. Silakan unduh file untuk melihat isinya.
              </p>
              <a 
                href={url} 
                download={name}
                className="inline-flex items-center gap-2 bg-red-800 hover:bg-red-900 text-white px-6 py-2.5 rounded-xl font-medium transition-colors shadow-lg shadow-red-800/20"
              >
                <Download className="w-4 h-4" />
                Unduh File
              </a>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
