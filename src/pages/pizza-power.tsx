import { useState } from 'react'

interface CartItem {
  name: string
  price: number
  quantity: number
  total: number
}

interface MenuItem {
  name: string
  description: string
  price: number
  emoji: string
  signature?: boolean
}

export default function PizzaPowerPage() {
  const [activeCategory, setActiveCategory] = useState('pizzas')
  const [cart, setCart] = useState<CartItem[]>([])
  const [cartTotal, setCartTotal] = useState(0)
  const [cartCount, setCartCount] = useState(0)
  const [showOrderReview, setShowOrderReview] = useState(false)
  const [notification, setNotification] = useState<string | null>(null)

  const menuData = {
    pizzas: [
      {
        name: 'Margherita Royale',
        description: 'Mozzarella di bufala, tomates San Marzano, basilic frais, huile d\'olive extra vierge, sur notre pâte artisanale 48h',
        price: 65,
        emoji: '🍕',
        signature: true
      },
      {
        name: 'Diavola Infernale',
        description: 'Sauce tomate épicée, mozzarella, salami piquant, piments jalapeños, oignons rouges, huile pimentée maison',
        price: 72,
        emoji: '🍕',
        signature: true
      },
      {
        name: 'Quatre Fromages',
        description: 'Mozzarella, gorgonzola DOP, parmesan 24 mois, ricotta fraîche, miel de truffe, noix',
        price: 78,
        emoji: '🍕'
      }
    ],
    entrees: [
      {
        name: 'Antipasti Misto',
        description: 'Sélection de charcuteries italiennes, fromages vieillis, olives marinées, légumes grillés',
        price: 55,
        emoji: '🥗'
      }
    ]
  }

  const categories = [
    { id: 'pizzas', label: '🍕 Pizzas' },
    { id: 'entrees', label: '🥗 Entrées' },
    { id: 'pates', label: '🍝 Pâtes' },
    { id: 'desserts', label: '🍰 Desserts' },
    { id: 'boissons', label: '🍹 Boissons' }
  ]

  const addToCart = (itemName: string, price: number) => {
    const existingItem = cart.find(item => item.name === itemName)
    
    if (existingItem) {
      updateCartItem(itemName, existingItem.quantity + 1)
    } else {
      const newItem: CartItem = {
        name: itemName,
        price,
        quantity: 1,
        total: price
      }
      setCart([...cart, newItem])
      setCartCount(cartCount + 1)
      setCartTotal(cartTotal + price)
    }
    
    showNotification(`✅ ${itemName} ajouté au panier !`)
  }

  const updateCartItem = (itemName: string, newQuantity: number) => {
    if (newQuantity <= 0) {
      removeFromCart(itemName)
      return
    }

    const updatedCart = cart.map(item => {
      if (item.name === itemName) {
        return {
          ...item,
          quantity: newQuantity,
          total: item.price * newQuantity
        }
      }
      return item
    })

    setCart(updatedCart)
    recalculateCart(updatedCart)
  }

  const removeFromCart = (itemName: string) => {
    const updatedCart = cart.filter(item => item.name !== itemName)
    setCart(updatedCart)
    recalculateCart(updatedCart)
    showNotification(`❌ ${itemName} retiré du panier`)
  }

  const recalculateCart = (updatedCart: CartItem[]) => {
    const newCount = updatedCart.reduce((sum, item) => sum + item.quantity, 0)
    const newTotal = updatedCart.reduce((sum, item) => sum + item.total, 0)
    setCartCount(newCount)
    setCartTotal(newTotal)
  }

  const confirmOrder = () => {
    showNotification('🎉 COMMANDE CONFIRMÉE !', 5000)
    setCart([])
    setCartCount(0)
    setCartTotal(0)
    setShowOrderReview(false)
  }

  const showNotification = (message: string, duration = 3000) => {
    setNotification(message)
    setTimeout(() => setNotification(null), duration)
  }

  const getItemQuantity = (itemName: string) => {
    const cartItem = cart.find(item => item.name === itemName)
    return cartItem?.quantity || 0
  }

  const currentMenu = menuData[activeCategory as keyof typeof menuData] || []

  return (
    <div 
      className="min-h-screen text-white pb-36"
      style={{
        background: 'linear-gradient(135deg, #DC2626 0%, #F97316 50%, #FCD34D 100%)'
      }}
    >
      {/* Header */}
      <header className="sticky top-0 z-50 bg-black/20 backdrop-blur-xl border-b border-white/10 px-5 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 font-bold text-xl" style={{ color: '#FCD34D' }}>
            🍽️ SmartMenu
          </div>
          <h1 className="flex-1 text-center text-xl md:text-2xl font-black bg-gradient-to-r from-white to-yellow-300 bg-clip-text text-transparent">
            PIZZA POWER
          </h1>
          <button
            className="px-4 md:px-5 py-3 rounded-full font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[44px] text-sm md:text-base"
            style={{ 
              backgroundColor: '#FCD34D', 
              color: '#DC2626' 
            }}
            onClick={() => showNotification('📞 Appel du serveur...', 4000)}
          >
            📞 Serveur
          </button>
        </div>
      </header>

      {/* Hero Section */}
      <section className="text-center py-10 px-5 bg-black/10">
        <h1 className="text-4xl md:text-6xl font-black mb-3 bg-gradient-to-r from-white to-yellow-300 bg-clip-text text-transparent drop-shadow-lg">
          🍕 PIZZA POWER
        </h1>
        <p className="text-lg md:text-xl font-semibold opacity-90">
          La vraie pizza italienne à Tel Aviv
        </p>
      </section>

      {/* Promo Section */}
      <section className="mx-5 my-5 bg-white/15 backdrop-blur-lg rounded-2xl p-5 text-center border border-white/20">
        <div className="text-lg md:text-xl font-bold drop-shadow-md" style={{ color: '#FCD34D' }}>
          ✨ 2ème Pizza à -50% • Livraison gratuite dès 80₪ ✨
        </div>
      </section>

      {/* Navigation */}
      <nav className="flex gap-3 px-5 py-5 overflow-x-auto" style={{ scrollbarWidth: 'none' }}>
        {categories.map((category) => (
          <button
            key={category.id}
            onClick={() => setActiveCategory(category.id)}
            className={`px-4 md:px-6 py-3 rounded-full font-semibold text-sm whitespace-nowrap transition-all duration-300 border-2 min-h-[44px] ${
              activeCategory === category.id
                ? 'bg-white/90 border-white transform -translate-y-1 shadow-xl'
                : 'bg-white/10 text-white border-white/30 hover:bg-white/20'
            }`}
            style={activeCategory === category.id ? { color: '#DC2626' } : {}}
          >
            {category.label}
          </button>
        ))}
      </nav>

      {/* Menu Section */}
      <section className="px-5 pb-5">
        <h2 className="text-2xl md:text-3xl font-black text-center mb-5 drop-shadow-lg" style={{ color: '#FCD34D' }}>
          🍕 PIZZAS SIGNATURE
        </h2>
        
        <div className="grid gap-5 max-w-4xl mx-auto">
          {currentMenu.map((item) => {
            const quantity = getItemQuantity(item.name)
            
            return (
              <article key={item.name} className="bg-gradient-to-br from-white/15 to-white/5 backdrop-blur-lg rounded-2xl overflow-hidden border border-white/10 hover:transform hover:-translate-y-2 hover:shadow-2xl transition-all duration-300 relative group">
                {item.signature && (
                  <div 
                    className="absolute top-4 right-4 px-3 py-1 rounded-full text-xs font-bold z-10 shadow-lg"
                    style={{ 
                      backgroundColor: '#FCD34D', 
                      color: '#DC2626' 
                    }}
                  >
                    SIGNATURE
                  </div>
                )}
                
                {/* Image */}
                <div 
                  className="h-48 flex items-center justify-center relative overflow-hidden"
                  style={{
                    background: 'linear-gradient(to bottom right, #DC2626, #F97316)'
                  }}
                >
                  <div className="text-6xl drop-shadow-2xl group-hover:scale-110 transition-transform duration-300">
                    {item.emoji}
                  </div>
                </div>
                
                {/* Content */}
                <div className="p-5">
                  <h3 className="text-lg md:text-xl font-bold mb-2" style={{ color: '#FCD34D' }}>
                    {item.name}
                  </h3>
                  <p className="text-sm opacity-90 mb-4 leading-relaxed">
                    {item.description}
                  </p>
                  
                  {/* Prix + Actions - CENTRÉ mobile */}
                  <div className="flex flex-col gap-3 md:flex-row md:justify-between md:items-center">
                    <span className="text-xl font-black drop-shadow-md text-center md:text-left" style={{ color: '#FCD34D' }}>
                      ₪{item.price}
                    </span>
                    
                    <div className="flex justify-center md:justify-end">
                      {quantity > 0 ? (
                        <div className="flex items-center gap-3 bg-white/10 rounded-full px-4 py-2 border border-white/20">
                          <button
                            onClick={() => updateCartItem(item.name, quantity - 1)}
                            className="w-8 h-8 rounded-full font-bold flex items-center justify-center hover:scale-110 transition-transform"
                            style={{ 
                              backgroundColor: '#FCD34D', 
                              color: '#DC2626' 
                            }}
                          >
                            -
                          </button>
                          <span className="font-bold text-lg min-w-[20px] text-center">
                            {quantity}
                          </span>
                          <button
                            onClick={() => updateCartItem(item.name, quantity + 1)}
                            className="w-8 h-8 rounded-full font-bold flex items-center justify-center hover:scale-110 transition-transform"
                            style={{ 
                              backgroundColor: '#FCD34D', 
                              color: '#DC2626' 
                            }}
                          >
                            +
                          </button>
                        </div>
                      ) : (
                        <button
                          onClick={() => addToCart(item.name, item.price)}
                          className="px-5 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[44px]"
                          style={{
                            background: 'linear-gradient(to right, #FCD34D, #F97316)',
                            color: '#DC2626'
                          }}
                        >
                          AJOUTER
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              </article>
            )
          })}
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-black/40 backdrop-blur-2xl p-6 md:p-8 text-center mt-10 border-t-2 border-white/20 shadow-2xl">
        <div className="flex items-center justify-center gap-2 font-bold text-xl md:text-2xl mb-2" style={{ color: '#FCD34D' }}>
          🍽️ SmartMenu
        </div>
        <div className="text-base md:text-lg font-semibold opacity-80 mb-4">
          Solutions digitales premium pour restaurants
        </div>
        <div className="text-xs md:text-sm opacity-70 leading-relaxed max-w-md mx-auto">
          📍 Dizengoff 45, Tel Aviv • 📞 03-1234567 • 🕐 Dim-Jeu 11h-23h, Ven 11h-15h
        </div>
      </footer>

      {/* Panier Flottant */}
      {cartCount > 0 && (
        <div className="fixed bottom-5 left-5 right-5 bg-black/90 backdrop-blur-2xl rounded-2xl p-4 md:p-5 flex flex-col sm:flex-row items-center justify-between shadow-2xl border border-white/10 z-40 gap-3 sm:gap-0">
          <div className="font-bold text-base md:text-lg" style={{ color: '#FCD34D' }}>
            🛒 Commandes ({cartCount}) - ₪{cartTotal.toFixed(2)}
          </div>
          
          <button
            onClick={() => setShowOrderReview(true)}
            className="px-6 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[48px] w-full sm:w-auto"
            style={{
              background: 'linear-gradient(to right, #FCD34D, #F97316)',
              color: '#DC2626'
            }}
          >
            VOIR COMMANDE
          </button>
        </div>
      )}

      {/* Notification */}
      {notification && (
        <div 
          className="fixed top-5 right-5 p-4 md:p-5 rounded-xl font-bold max-w-sm shadow-2xl z-50"
          style={{
            background: 'linear-gradient(to right, #FCD34D, #F97316)',
            color: '#DC2626',
            animation: 'slideIn 0.3s ease-out'
          }}
        >
          <button
            onClick={() => setNotification(null)}
            className="absolute top-2 right-3 font-bold text-lg hover:scale-110 transition-transform"
            style={{ color: '#DC2626' }}
          >
            ×
          </button>
          <div className="pr-6 text-sm md:text-base">
            {notification}
          </div>
        </div>
      )}

      {/* Modal Révision (simplifié) */}
      {showOrderReview && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-50 p-5">
          <div 
            className="rounded-3xl p-6 md:p-8 max-w-lg w-full max-h-[80vh] overflow-y-auto shadow-2xl border-2 border-white/20"
            style={{
              background: 'linear-gradient(135deg, #DC2626 0%, #F97316 50%, #FCD34D 100%)'
            }}
          >
            <div className="text-center mb-6">
              <h3 className="text-xl md:text-2xl font-black drop-shadow-lg" style={{ color: '#FCD34D' }}>
                📋 RÉVISION DE VOTRE COMMANDE
              </h3>
            </div>
            
            <div className="space-y-4 mb-5">
              {cart.map((item, index) => (
                <div key={index} className="flex items-center justify-between gap-4 py-4 border-b border-white/20">
                  <span className="font-bold text-white flex-1">{item.name}</span>
                  <span className="font-bold text-white">x{item.quantity}</span>
                  <span className="font-black min-w-[80px] text-right" style={{ color: '#FCD34D' }}>
                    ₪{item.total.toFixed(2)}
                  </span>
                </div>
              ))}
            </div>
            
            <div className="text-center py-5 border-t-2 border-white/30 bg-black/30 rounded-xl mb-5">
              <div className="text-xl font-black text-white drop-shadow-lg">
                TOTAL: <span style={{ color: '#FCD34D' }}>₪{cartTotal.toFixed(2)}</span>
              </div>
            </div>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <button
                onClick={() => setShowOrderReview(false)}
                className="bg-transparent text-white border-2 border-white px-6 py-3 rounded-xl font-bold hover:bg-white/10 transition-all min-h-[48px]"
              >
                ← MODIFIER
              </button>
              <button
                onClick={confirmOrder}
                className="px-6 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300 min-h-[48px]"
                style={{
                  background: 'linear-gradient(to right, #FCD34D, #F97316)',
                  color: '#DC2626'
                }}
              >
                CONFIRMER COMMANDE
              </button>
            </div>
          </div>
        </div>
      )}

      <style jsx>{`
        @keyframes slideIn {
          from { transform: translateX(100%); opacity: 0; }
          to { transform: translateX(0); opacity: 1; }
        }
      `}</style>
    </div>
  )
}
