interface FloatingCartProps {
  cartCount: number
  cartTotal: number
  onShowReview: () => void
}

export function FloatingCart({ cartCount, cartTotal, onShowReview }: FloatingCartProps) {
  if (cartCount === 0) return null

  return (
    <div className="fixed bottom-5 left-5 right-5 bg-black/90 backdrop-blur-2xl rounded-2xl p-5 flex items-center justify-between shadow-2xl border border-white/10 z-40">
      <div className="font-bold text-lg text-yellow-300">
        🛒 Commandes ({cartCount}) - ₪{cartTotal.toFixed(2)}
      </div>
      
      <button
        onClick={onShowReview}
        className="bg-gradient-to-r from-yellow-300 to-orange-400 text-red-600 px-6 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[48px]"
      >
        VOIR COMMANDE
      </button>
    </div>
  )
}
