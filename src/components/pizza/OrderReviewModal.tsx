import { CartItem } from '@/pages/pizza-power'

interface OrderReviewModalProps {
  cart: CartItem[]
  cartTotal: number
  onClose: () => void
  onUpdateItem: (itemName: string, quantity: number) => void
  onRemoveItem: (itemName: string) => void
  onConfirm: () => void
}

export function OrderReviewModal({
  cart,
  cartTotal,
  onClose,
  onUpdateItem,
  onRemoveItem,
  onConfirm
}: OrderReviewModalProps) {
  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-50 p-5">
      <div className="bg-gradient-to-br from-red-600 via-orange-500 to-yellow-400 rounded-3xl p-8 max-w-lg w-full max-h-[80vh] overflow-y-auto shadow-2xl border-2 border-white/20">
        
        {/* Header */}
        <div className="text-center mb-6">
          <h3 className="text-2xl font-black text-yellow-300 drop-shadow-lg">
            📋 RÉVISION DE VOTRE COMMANDE
          </h3>
        </div>
        
        {/* Order Items */}
        <div className="space-y-4 mb-5">
          {cart.map((item, index) => (
            <div key={index} className="flex items-center justify-between gap-4 py-4 border-b border-white/20">
              <span className="font-bold text-white flex-1">{item.name}</span>
              
              <div className="flex items-center gap-3">
                <button
                  onClick={() => onUpdateItem(item.name, item.quantity - 1)}
                  className="w-8 h-8 bg-yellow-300 text-red-600 rounded-full font-bold flex items-center justify-center hover:scale-110 transition-transform"
                >
                  -
                </button>
                <span className="font-bold text-white min-w-[20px] text-center">
                  {item.quantity}
                </span>
                <button
                  onClick={() => onUpdateItem(item.name, item.quantity + 1)}
                  className="w-8 h-8 bg-yellow-300 text-red-600 rounded-full font-bold flex items-center justify-center hover:scale-110 transition-transform"
                >
                  +
                </button>
                <button
                  onClick={() => onRemoveItem(item.name)}
                  className="bg-red-500 text-white px-2 py-1 rounded-lg text-sm hover:bg-red-600 transition-colors"
                >
                  🗑️
                </button>
              </div>
              
              <span className="font-black text-yellow-300 min-w-[80px] text-right">
                ₪{item.total.toFixed(2)}
              </span>
            </div>
          ))}
        </div>
        
        {/* Total */}
        <div className="text-center py-5 border-t-2 border-white/30 bg-black/30 rounded-xl mb-5">
          <div className="text-xl font-black text-white drop-shadow-lg">
            TOTAL: ₪{cartTotal.toFixed(2)}
          </div>
        </div>
        
        {/* Actions */}
        <div className="flex gap-4 justify-center">
          <button
            onClick={onClose}
            className="bg-transparent text-white border-2 border-white px-6 py-3 rounded-xl font-bold hover:bg-white/10 transition-all min-h-[48px]"
          >
            ← MODIFIER
          </button>
          <button
            onClick={onConfirm}
            className="bg-gradient-to-r from-yellow-300 to-orange-400 text-red-600 px-6 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[48px]"
          >
            CONFIRMER COMMANDE
          </button>
        </div>
      </div>
    </div>
  )
}
