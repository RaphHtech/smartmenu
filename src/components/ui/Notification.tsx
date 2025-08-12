interface NotificationProps {
  message: string
  onClose: () => void
}

export function Notification({ message, onClose }: NotificationProps) {
  return (
    <div className="fixed top-5 right-5 bg-gradient-to-r from-yellow-300 to-orange-400 text-red-600 p-5 rounded-xl font-bold max-w-sm shadow-2xl z-50 animate-slide-in">
      <button
        onClick={onClose}
        className="absolute top-2 right-3 text-red-600 font-bold text-lg hover:scale-110 transition-transform"
      >
        ×
      </button>
      <div className="pr-6 whitespace-pre-line">
        {message}
      </div>
    </div>
  )
}
