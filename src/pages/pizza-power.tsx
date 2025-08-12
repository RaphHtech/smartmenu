import { useState } from 'react'

interface CartItem {
  name: string
  price: number
  quantity: number
  total: number
}

export default function PizzaPowerPage() {
  const [activeCategory, setActiveCategory] = useState('pizzas')
  const [cart, setCart] = useState<CartItem[]>([])
  const [cartTotal, setCartTotal] = useState(0)
  const [cartCount, setCartCount] = useState(0)
  const [showOrderReview, setShowOrderReview] = useState(false)
  const [notification, setNotification] = useState<string | null>(null)

  // TOUTES les données menu comme dans l'HTML
  const menuData = {
    pizzas: {
      title: '🍕 PIZZAS SIGNATURE',
      items: [
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
        },
        {
          name: 'Jambon Champignons',
          description: 'Prosciutto di Parma 18 mois, champignons porcini, mozzarella, roquette, copeaux de parmesan',
          price: 82,
          emoji: '🍕'
        },
        {
          name: 'Végétarienne Suprême',
          description: 'Aubergines grillées, courgettes, poivrons rouges, champignons, olives Kalamata, mozzarella, basilic',
          price: 68,
          emoji: '🍕'
        },
        {
          name: 'Fruits de Mer',
          description: 'Crevettes, calamars, moules, tomates cerises, ail, persil, huile d\'olive, sans fromage',
          price: 85,
          emoji: '🍕'
        }
      ]
    },
    entrees: {
      title: '🥗 ENTRÉES',
      items: [
        {
          name: 'Antipasti Misto',
          description: 'Sélection de charcuteries italiennes, fromages vieillis, olives marinées, légumes grillés',
          price: 55,
          emoji: '🥗'
        }
      ]
    },
    pates: {
      title: '🍝 PÂTES FRAÎCHES',
      items: [
        {
          name: 'Carbonara Classique',
          description: 'Spaghetti, guanciale, œufs fermiers, pecorino romano, poivre noir fraîchement moulu',
          price: 62,
          emoji: '🍝'
        }
      ]
    },
    desserts: {
      title: '🍰 DESSERTS',
      items: [
        {
          name: 'Tiramisu Maison',
          description: 'Mascarpone, café expresso, cacao pur, biscuits savoiardi, rhum arrangé',
          price: 32,
          emoji: '🍰'
        }
      ]
    },
    boissons: {
      title: '🍹 BOISSONS',
      items: [
        {
          name: 'Chianti Classico',
          description: 'Vin rouge toscan, bouteille 750ml, notes de cerise et épices',
          price: 120,
          emoji: '🍷'
        }
      ]
    }
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

  const currentCategoryData = menuData[activeCategory as keyof typeof menuData]

  return (
    <div 
      className="min-h-screen text-white"
      style={{
        background: 'linear-gradient(135deg, #DC2626 0%, #F97316 50%, #FCD34D 100%)',
        paddingBottom: '140px'
      }}
    >
      {/* Header */}
      <header 
        className="sticky top-0 z-50 px-5 py-4"
        style={{
          background: 'rgba(0,0,0,0.2)',
          backdropFilter: 'blur(10px)',
          borderBottom: '1px solid rgba(255,255,255,0.1)'
        }}
      >
        <div className="flex items-center justify-between">
          <div className="text-xl font-bold" style={{ color: '#FCD34D' }}>
            🍽️ SmartMenu
          </div>
          <h1 
            className="flex-1 text-center text-lg md:text-2xl font-black"
            style={{
              background: 'linear-gradient(45deg, #FFFFFF, #FCD34D)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent'
            }}
          >
            PIZZA POWER
          </h1>
          <button
            className="px-5 py-3 rounded-full font-bold transition-all duration-300"
            style={{ 
              backgroundColor: '#FCD34D', 
              color: '#DC2626',
              minHeight: '44px'
            }}
            onClick={() => showNotification('📞 Appel du serveur...', 4000)}
          >
            📞 Serveur
          </button>
        </div>
      </header>

      {/* Hero Section */}
      <section className="text-center py-10 px-5" style={{ background: 'rgba(0,0,0,0.1)' }}>
        <h1 
          className="text-4xl md:text-6xl font-black mb-3 drop-shadow-lg"
          style={{
            background: 'linear-gradient(45deg, #FFFFFF, #FCD34D)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent'
          }}
        >
          🍕 PIZZA POWER
        </h1>
        <p className="text-lg font-semibold opacity-90">
          La vraie pizza italienne à Tel Aviv
        </p>
      </section>

      {/* Promo Section */}
      <section 
        className="mx-5 my-5 rounded-2xl p-5 text-center border"
        style={{
          background: 'rgba(255,255,255,0.15)',
          backdropFilter: 'blur(10px)',
          borderColor: 'rgba(255,255,255,0.2)'
        }}
      >
        <div className="text-lg font-bold drop-shadow-md" style={{ color: '#FCD34D' }}>
          ✨ 2ème Pizza à -50% • Livraison gratuite dès 80₪ ✨
        </div>
      </section>

      {/* Navigation */}
      <nav className="flex gap-3 px-5 py-5 overflow-x-auto" style={{ scrollbarWidth: 'none' }}>
        {categories.map((category) => (
          <button
            key={category.id}
            onClick={() => setActiveCategory(category.id)}
            className={`px-6 py-3 rounded-full font-semibold text-sm whitespace-nowrap transition-all duration-300 border-2 ${
              activeCategory === category.id
                ? 'transform -translate-y-0.5'
                : ''
            }`}
            style={{
              background: activeCategory === category.id 
                ? 'rgba(255,255,255,0.9)' 
                : 'rgba(255,255,255,0.1)',
              color: activeCategory === category.id ? '#DC2626' : 'white',
              borderColor: activeCategory === category.id ? 'white' : 'rgba(255,255,255,0.3)',
              minHeight: '44px',
              boxShadow: activeCategory === category.id ? '0 8px 25px rgba(220, 38, 38, 0.3)' : 'none'
            }}
          >
            {category.label}
          </button>
        ))}
      </nav>

      {/* Menu Section */}
      <section className="px-5 pb-5">
        <h2 className="text-2xl md:text-3xl font-black text-center mb-5 drop-shadow-lg" style={{ color: '#FCD34D' }}>
          {currentCategoryData.title}
        </h2>
        
        <div className="grid gap-5">
          {currentCategoryData.items.map((item) => {
            const quantity = getItemQuantity(item.name)
            
            return (
              <article 
                key={item.name} 
                className="rounded-2xl overflow-hidden border transition-all duration-300 hover:transform hover:-translate-y-2 relative group"
                style={{
                  background: 'linear-gradient(135deg, rgba(255,255,255,0.15), rgba(255,255,255,0.05))',
                  borderColor: 'rgba(255,255,255,0.1)',
                  backdropFilter: 'blur(10px)',
                  boxShadow: '0 8px 25px rgba(220, 38, 38, 0.3)'
                }}
              >
                {item.signature && (
                  <div 
                    className="absolute top-4 right-4 px-3 py-1 rounded-full text-xs font-bold z-10"
                    style={{ 
                      backgroundColor: '#FCD34D', 
                      color: '#DC2626',
                      boxShadow: '0 4px 15px rgba(0,0,0,0.2)'
                    }}
                  >
                    SIGNATURE
                  </div>
                )}
                
                {/* Image */}
                <div 
                  className="h-48 flex items-center justify-center relative overflow-hidden"
                  style={{
                    background: 'linear-gradient(45deg, #DC2626, #F97316)'
                  }}
                >
                  <div className="text-6xl group-hover:scale-110 transition-transform duration-300" style={{ filter: 'drop-shadow(0 4px 15px rgba(0,0,0,0.3))' }}>
                    {item.emoji}
                  </div>
                </div>
                
                {/* Content */}
                <div className="p-5">
                  <h3 className="text-lg font-bold mb-2" style={{ color: '#FCD34D' }}>
                    {item.name}
                  </h3>
                  <p className="text-sm opacity-90 mb-4 leading-relaxed">
                    {item.description}
                  </p>
                  
                  {/* Footer - RESPONSIVE comme HTML */}
                  <div className="flex justify-between items-center gap-4 mobile:flex-col mobile:gap-3">
                    <span className="text-xl font-black drop-shadow-md" style={{ color: '#FCD34D' }}>
                      ₪{item.price}
                    </span>
                    
                    <div className="flex items-center gap-3">
                      {quantity > 0 ? (
                        <div 
                          className="flex items-center gap-3 rounded-full px-4 py-2 border"
                          style={{
                            background: 'rgba(255,255,255,0.1)',
                            borderColor: 'rgba(255,255,255,0.2)'
                          }}
                        >
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
                          className="px-5 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300"
                          style={{
                            background: 'linear-gradient(45deg, #FCD34D, #F97316)',
                            color: '#DC2626',
                            minHeight: '44px',
                            boxShadow: '0 4px 15px rgba(0,0,0,0.2)'
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
      <footer 
        className="p-8 text-center mt-10 border-t-2"
        style={{
          background: 'rgba(0,0,0,0.4)',
          backdropFilter: 'blur(15px)',
          borderColor: 'rgba(255,255,255,0.2)',
          boxShadow: '0 -8px 25px rgba(0,0,0,0.3)'
        }}
      >
        <div className="text-2xl font-bold mb-2" style={{ color: '#FCD34D' }}>
          🍽️ SmartMenu
        </div>
        <div className="text-lg font-semibold opacity-80 mb-4">
          Solutions digitales premium pour restaurants
        </div>
        <div className="text-sm opacity-70 leading-relaxed">
          📍 Dizengoff 45, Tel Aviv • 📞 03-1234567 • 🕐 Dim-Jeu 11h-23h, Ven 11h-15h
        </div>
      </footer>

      {/* Panier Flottant - SEULEMENT si cartCount > 0 */}
      {cartCount > 0 && (
        <div 
          className="fixed bottom-5 left-5 right-5 rounded-2xl p-5 flex justify-between items-center shadow-2xl border z-50"
          style={{
            background: 'rgba(0,0,0,0.9)',
            backdropFilter: 'blur(15px)',
            borderColor: 'rgba(255,255,255,0.1)'
          }}
        >
          <div className="font-bold text-lg" style={{ color: '#FCD34D' }}>
            🛒 Commandes ({cartCount}) - ₪{cartTotal.toFixed(2)}
          </div>
          
          <button
            onClick={() => setShowOrderReview(true)}
            className="px-6 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300"
            style={{
              background: 'linear-gradient(45deg, #FCD34D, #F97316)',
              color: '#DC2626',
              minHeight: '48px',
              boxShadow: '0 4px 15px rgba(0,0,0,0.2)'
            }}
          >
            VOIR COMMANDE
          </button>
        </div>
      )}

      {/* Notification */}
      {notification && (
        <div 
          className="fixed top-5 right-5 p-5 rounded-xl font-bold max-w-sm shadow-2xl z-50"
          style={{
            background: 'linear-gradient(45deg, #FCD34D, #F97316)',
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
          <div className="pr-6">
            {notification}
          </div>
        </div>
      )}

      {/* Modal Révision (simplifié) */}
      {showOrderReview && (
        <div className="fixed inset-0 bg-black bg-opacity-80 flex items-center justify-center z-50 p-5" style={{ backdropFilter: 'blur(5px)' }}>
          <div 
            className="rounded-3xl p-8 max-w-lg w-full max-h-4/5 overflow-y-auto shadow-2xl border-2"
            style={{
              background: 'linear-gradient(135deg, #DC2626 0%, #F97316 50%, #FCD34D 100%)',
              borderColor: 'rgba(255,255,255,0.2)'
            }}
          >
            <div className="text-center mb-6">
              <h3 className="text-2xl font-black drop-shadow-lg" style={{ color: '#FCD34D' }}>
                📋 RÉVISION DE VOTRE COMMANDE
              </h3>
            </div>
            
            <div className="space-y-4 mb-5">
              {cart.map((item, index) => (
                <div key={index} className="flex items-center justify-between gap-4 py-4 border-b" style={{ borderColor: 'rgba(255,255,255,0.2)' }}>
                  <span className="font-bold text-white flex-1">{item.name}</span>
                  <span className="font-bold text-white">x{item.quantity}</span>
                  <span className="font-black min-w-20 text-right" style={{ color: '#FCD34D' }}>
                    ₪{item.total.toFixed(2)}
                  </span>
                </div>
              ))}
            </div>
            
            <div 
              className="text-center py-5 border-t-2 rounded-xl mb-5"
              style={{
                borderColor: 'rgba(255,255,255,0.3)',
                background: 'rgba(0,0,0,0.3)'
              }}
            >
              <div className="text-xl font-black text-white drop-shadow-lg">
                TOTAL: <span style={{ color: '#FCD34D' }}>₪{cartTotal.toFixed(2)}</span>
              </div>
            </div>
            
            <div className="flex gap-4 justify-center">
              <button
                onClick={() => setShowOrderReview(false)}
                className="bg-transparent text-white border-2 border-white px-6 py-3 rounded-xl font-bold hover:bg-white hover:bg-opacity-10 transition-all"
                style={{ minHeight: '48px' }}
              >
                ← MODIFIER
              </button>
              <button
                onClick={confirmOrder}
                className="px-6 py-3 rounded-xl font-bold hover:transform hover:-translate-y-1 hover:shadow-xl transition-all duration-300"
                style={{
                  background: 'linear-gradient(45deg, #FCD34D, #F97316)',
                  color: '#DC2626',
                  minHeight: '48px'
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
        
        @media (max-width: 768px) {
          .mobile\\:flex-col {
            flex-direction: column;
          }
          .mobile\\:gap-3 {
            gap: 0.75rem;
          }
        }
      `}</style>
    </div>
  )
}
