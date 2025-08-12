interface FloatingCartProps {
  cartCount: number
  cartTotal: number
  onShowReview: () => void
  theme: 'pizza' | 'falafel'
}

export function FloatingCart({ cartCount, cartTotal, onShowReview, theme }: FloatingCartProps) {
  // CORRECTIF: GUARD - Cache le panier si 0 article
  if (cartCount === 0) return null

  const themeStyles = {
    pizza: {
      summaryColor: 'theme-text-accent',
      buttonBg: 'bg-gradient-to-r from-theme-accent to-theme-secondary',
      buttonText: 'text-theme-primary'
    },
    falafel: {
      summaryColor: 'text-yellow-400',
      buttonBg: 'bg-gradient-to-r from-yellow-400 to-amber-500',
      buttonText: 'text-amber-800'
    }
  }

  const styles = themeStyles[theme]

  return (
    <div className="fixed bottom-5 left-5 right-5 bg-black/90 backdrop-blur-2xl rounded-2xl p-4 md:p-5 flex flex-col sm:flex-row items-center justify-between shadow-2xl border border-white/10 z-40 gap-3 sm:gap-0 animate-float-up">
      <div className={`font-bold text-base md:text-lg ${styles.summaryColor}`}>
        🛒 Commandes ({cartCount}) - ₪{cartTotal.toFixed(2)}
      </div>
      
      <button
        onClick={onShowReview}
        className={`${styles.buttonBg} ${styles.buttonText} px-6 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[48px] focus:outline-none focus:ring-2 focus:ring-white w-full sm:w-auto`}
        aria-label="Réviser votre commande"
      >
        VOIR COMMANDE
      </button>
    </div>
  )
}
