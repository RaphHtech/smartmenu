interface FloatingCartProps {
  cartCount: number
  cartTotal: number
  onShowReview: () => void
  theme?: 'pizza' | 'falafel'
}

export function FloatingCart({ cartCount, cartTotal, onShowReview, theme = 'pizza' }: FloatingCartProps) {
  // GARDE ABSOLU - Ne rien rendre si panier vide
  if (cartCount === 0 || cartTotal === 0) {
    return null
  }

  return (
    <div className="fixed bottom-5 left-5 right-5 bg-black/90 backdrop-blur-2xl rounded-2xl p-4 md:p-5 flex flex-col sm:flex-row items-center justify-between shadow-2xl border border-white/10 z-40 gap-3 sm:gap-0">
      <div className="font-bold text-base md:text-lg text-[#FCD34D]">
        🛒 Commandes ({cartCount}) - ₪{cartTotal.toFixed(2)}
      </div>
      
      <button
        onClick={onShowReview}
        className="bg-gradient-to-r from-[#FCD34D] to-[#F97316] text-[#DC2626] px-6 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[48px] w-full sm:w-auto"
      >
        VOIR COMMANDE
      </button>
    </div>
  )
}
