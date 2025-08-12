interface MenuCardProps {
  name: string
  description: string
  price: number
  emoji: string
  signature?: boolean
  quantity: number
  onAddToCart: () => void
  onUpdateQuantity: (quantity: number) => void
}

export function MenuCard({ 
  name, 
  description, 
  price, 
  emoji, 
  signature, 
  quantity, 
  onAddToCart, 
  onUpdateQuantity 
}: MenuCardProps) {
  return (
    <article className="bg-gradient-to-br from-white/15 to-white/5 backdrop-blur-lg rounded-2xl overflow-hidden border border-white/10 hover:transform hover:-translate-y-2 hover:shadow-2xl transition-all duration-300 relative">
      {signature && (
        <div className="absolute top-4 right-4 bg-yellow-300 text-red-600 px-3 py-1 rounded-full text-xs font-bold z-10 shadow-lg">
          SIGNATURE
        </div>
      )}
      
      {/* Image */}
      <div className="h-48 bg-gradient-to-br from-red-600 to-orange-500 flex items-center justify-center relative overflow-hidden">
        <div className="text-6xl drop-shadow-2xl">{emoji}</div>
      </div>
      
      {/* Content */}
      <div className="p-5">
        <h3 className="text-xl font-bold mb-2 text-yellow-300">{name}</h3>
        <p className="text-sm opacity-90 mb-4 leading-relaxed">{description}</p>
        
        <div className="flex items-center justify-between gap-4">
          <span className="text-xl font-black text-yellow-300 drop-shadow-md">
            ₪{price}
          </span>
          
          <div className="flex items-center gap-3">
            {quantity > 0 ? (
              <div className="flex items-center gap-3 bg-white/10 rounded-full px-4 py-2 border border-white/20">
                <button
                  onClick={() => onUpdateQuantity(quantity - 1)}
                  className="w-8 h-8 bg-yellow-300 text-red-600 rounded-full font-bold flex items-center justify-center hover:scale-110 transition-transform"
                >
                  -
                </button>
                <span className="font-bold text-lg min-w-[20px] text-center">
                  {quantity}
                </span>
                <button
                  onClick={() => onUpdateQuantity(quantity + 1)}
                  className="w-8 h-8 bg-yellow-300 text-red-600 rounded-full font-bold flex items-center justify-center hover:scale-110 transition-transform"
                >
                  +
                </button>
              </div>
            ) : (
              <button
                onClick={onAddToCart}
                className="bg-gradient-to-r from-yellow-300 to-orange-400 text-red-600 px-5 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[44px]"
              >
                AJOUTER
              </button>
            )}
          </div>
        </div>
      </div>
    </article>
  )
}
