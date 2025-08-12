interface HeaderProps {
  restaurantName: string
  onCallServer: () => void
}

export function Header({ restaurantName, onCallServer }: HeaderProps) {
  return (
    <header className="sticky top-0 z-50 bg-black/20 backdrop-blur-xl border-b border-white/10 px-5 py-4">
      <div className="flex items-center justify-between">
        {/* SmartMenu Logo */}
        <div className="flex items-center gap-2 text-yellow-300 font-bold text-xl">
          🍽️ SmartMenu
        </div>

        {/* Restaurant Name */}
        <h1 className="flex-1 text-center text-2xl font-black bg-gradient-to-r from-white to-yellow-300 bg-clip-text text-transparent">
          {restaurantName}
        </h1>

        {/* Server Button */}
        <button
          onClick={onCallServer}
          className="bg-yellow-300 text-red-600 px-5 py-3 rounded-full font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[44px]"
        >
          📞 Serveur
        </button>
      </div>
    </header>
  )
}
