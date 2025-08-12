// ... props identiques ...

export function MenuCard({ 
  name, description, price, emoji, signature, quantity, onAddToCart, onUpdateQuantity, theme = 'pizza'
}: MenuCardProps) {
  
  return (
    <article className="bg-gradient-to-br from-white/15 to-white/5 backdrop-blur-lg rounded-2xl overflow-hidden border border-white/10 hover:transform hover:-translate-y-2 hover:shadow-2xl transition-all duration-300 relative group">
      {signature && (
        <div className="absolute top-4 right-4 bg-[#FCD34D] text-[#DC2626] px-3 py-1 rounded-full text-xs font-bold z-10 shadow-lg">
          SIGNATURE
        </div>
      )}
      
      {/* Image avec gradient exact */}
      <div className="h-48 bg-gradient-to-br from-[#DC2626] to-[#F97316] flex items-center justify-center relative overflow-hidden">
        <div className="text-6xl drop-shadow-2xl group-hover:scale-110 transition-transform duration-300">{emoji}</div>
      </div>
      
      {/* Content */}
      <div className="p-5">
        <h3 className="text-lg md:text-xl font-bold mb-2 text-[#FCD34D]">{name}</h3>
        <p className="text-sm opacity-90 mb-4 leading-relaxed">{description}</p>
        
        {/* CORRECTIF MOBILE: Copie exacte de l'HTML */}
        <div className="flex flex-col gap-3 md:flex-row md:justify-between md:items-center">
          {/* Prix CENTRÉ en mobile */}
          <span className="text-xl font-black text-[#FCD34D] drop-shadow-md text-center md:text-left">
            ₪{price}
          </span>
          
          {/* Bouton/Controls CENTRÉS en mobile */}
          <div className="flex justify-center md:justify-end">
            {quantity > 0 ? (
              <div className="flex items-center gap-3 bg-white/10 rounded-full px-4 py-2 border border-white/20">
                <button
                  onClick={() => onUpdateQuantity(quantity - 1)}
                  className="w-8 h-8 bg-[#FCD34D] text-[#DC2626] rounded-full font-bold flex items-center justify-center hover:scale-110 transition-transform"
                >
                  -
                </button>
                <span className="font-bold text-lg min-w-[20px] text-center">
                  {quantity}
                </span>
                <button
                  onClick={() => onUpdateQuantity(quantity + 1)}
                  className="w-8 h-8 bg-[#FCD34D] text-[#DC2626] rounded-full font-bold flex items-center justify-center hover:scale-110 transition-transform"
                >
                  +
                </button>
              </div>
            ) : (
              <button
                onClick={onAddToCart}
                className="bg-gradient-to-r from-[#FCD34D] to-[#F97316] text-[#DC2626] px-5 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[44px]"
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
