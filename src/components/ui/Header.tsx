interface HeaderProps {
  restaurantName: string
  onCallServer: () => void
  theme: 'pizza' | 'falafel'
}

export function Header({ restaurantName, onCallServer, theme }: HeaderProps) {
  const themeStyles = {
    pizza: {
      logoColor: 'theme-text-accent', // CORRECTIF: Force l'accent doré
      buttonBg: 'bg-theme-accent',
      buttonText: 'text-theme-primary',
      gradientText: 'from-white to-theme-accent'
    },
    falafel: {
      logoColor: 'text-yellow-400',
      buttonBg: 'bg-yellow-400',
      buttonText: 'text-amber-800',
      gradientText: 'from-white to-yellow-400'
    }
  }

  const styles = themeStyles[theme]

  return (
    <header className="sticky top-0 z-50 bg-black/20 backdrop-blur-xl border-b border-white/10 px-5 py-4">
      <div className="flex items-center justify-between">
        {/* SmartMenu Logo - CORRECTIF: Accent doré exact */}
        <div className={`flex items-center gap-2 font-bold text-xl ${styles.logoColor}`}>
          🍽️ SmartMenu
        </div>

        {/* Restaurant Name */}
        <h1 className={`flex-1 text-center text-xl md:text-2xl font-black bg-gradient-to-r ${styles.gradientText} bg-clip-text text-transparent`}>
          {restaurantName}
        </h1>

        {/* Server Button */}
        <button
          onClick={onCallServer}
          className={`${styles.buttonBg} ${styles.buttonText} px-4 md:px-5 py-3 rounded-full font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[44px] text-sm md:text-base`}
          aria-label="Appeler le serveur"
        >
          📞 Serveur
        </button>
      </div>
    </header>
  )
}
