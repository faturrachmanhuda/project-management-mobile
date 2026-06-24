import { useState, useRef, useEffect, KeyboardEvent } from 'react';
import { Pencil, Check, X } from 'lucide-react';

interface InlineEditProps {
  value: string;
  onSave: (newValue: string) => void;
  className?: string;       // class untuk teks tampilan
  inputClassName?: string;  // class untuk input
  disabled?: boolean;
  placeholder?: string;
}

export function InlineEdit({
  value,
  onSave,
  className = '',
  inputClassName = '',
  disabled = false,
  placeholder = 'Masukkan nama...',
}: InlineEditProps) {
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(value);
  const inputRef = useRef<HTMLInputElement>(null);

  // Sync jika value dari luar berubah saat tidak editing
  useEffect(() => {
    if (!editing) setDraft(value);
  }, [value, editing]);

  const startEdit = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (disabled) return;
    setDraft(value);
    setEditing(true);
  };

  useEffect(() => {
    if (editing) {
      inputRef.current?.focus();
      inputRef.current?.select();
    }
  }, [editing]);

  const commit = (e?: React.MouseEvent | React.FocusEvent) => {
    e?.preventDefault();
    e?.stopPropagation();
    const trimmed = draft.trim();
    if (trimmed && trimmed !== value) {
      onSave(trimmed);
    }
    setEditing(false);
  };

  const cancel = (e?: React.MouseEvent) => {
    e?.preventDefault();
    e?.stopPropagation();
    setDraft(value);
    setEditing(false);
  };

  const handleKey = (e: KeyboardEvent<HTMLInputElement>) => {
    e.stopPropagation();
    if (e.key === 'Enter') { e.preventDefault(); commit(); }
    if (e.key === 'Escape') cancel();
  };

  if (editing) {
    return (
      <span className="inline-flex items-center gap-1.5 w-full" onClick={(e) => e.stopPropagation()}>
        <input
          ref={inputRef}
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          onKeyDown={handleKey}
          onBlur={commit}
          placeholder={placeholder}
          className={`flex-1 min-w-0 px-2 py-1 border border-red-400 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-300 bg-white text-gray-900 ${inputClassName}`}
        />
        <button
          onMouseDown={(e) => { e.preventDefault(); commit(); }}
          className="shrink-0 p-1 rounded-md bg-green-100 hover:bg-green-200 text-green-700 transition-colors"
          title="Simpan"
        >
          <Check className="w-3.5 h-3.5" />
        </button>
        <button
          onMouseDown={(e) => { e.preventDefault(); cancel(); }}
          className="shrink-0 p-1 rounded-md bg-gray-100 hover:bg-gray-200 text-gray-600 transition-colors"
          title="Batal"
        >
          <X className="w-3.5 h-3.5" />
        </button>
      </span>
    );
  }

  return (
    <span className="inline-flex items-center gap-1.5 group/ie min-w-0">
      <span className={`min-w-0 ${className}`}>{value}</span>
      {!disabled && (
        <button
          onClick={startEdit}
          className="shrink-0 opacity-0 group-hover/ie:opacity-100 focus:opacity-100 p-1 rounded-md hover:bg-gray-100 text-gray-400 hover:text-red-700 transition-all"
          title="Ubah nama"
        >
          <Pencil className="w-3.5 h-3.5" />
        </button>
      )}
    </span>
  );
}
