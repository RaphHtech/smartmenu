import { useState } from 'react'
import { Header } from '@/components/ui/Header'
import { Footer } from '@/components/ui/Footer'
import { CategoryNav } from '@/components/ui/CategoryNav'
import { MenuSection } from '@/components/pizza/MenuSection'
import { FloatingCart } from '@/components/pizza/FloatingCart'
import { OrderReviewModal } from '@/components/pizza/OrderReviewModal'
import { Notification } from '@/components/ui/Notification'
import { CartItem, Category } from '@/components/ui/types'

export default function PizzaPowerPage() {
  const [activeCategory, setActiveCategory] = useState('pizzas')
  const [cart, setCart] = useState<CartItem[]>([])
  const [cartTotal, setCartTotal] = useState(0)
  const [cartCount, setCartCount] = useState(0)
  const [showOrderReview, setShowOrderReview] = useState(false)
  const [notification, setNotification] = useState<string | null>(null)

  const categories: Category[] = [
    { id: 'pizzas', label: '🍕 Pizzas', emoji: '🍕' },
    { id: 'entrees', label: '🥗 Entrées', emoji: '🥗' },
    { id: 'pates', label: '🍝 Pâtes', emoji: '🍝' },
    { id: 'desserts', label: '🍰 Desserts', emoji: '🍰' },
    { id: 'boissons', label: '🍹 Boissons', emoji: '🍹' }
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
    const orderSummary = cart.map(item => 
      `• ${item.name} x${item.quantity} - ₪${item.total.toFixed(2)}`
    ).join('\n')

    showNotification(
      `🎉 COMMANDE CONFIRMÉE !\n\n📋 RÉCAPITULATIF:\n\n${orderSummary}\n\nTOTAL: ₪${cartTotal.toFixed(2)}\n\n✅ Votre commande a été transmise à la cuisine !\n⏱️ Temps d'attente estimé: 15-20 minutes`,
      8000
    )

    // Reset cart
    setCart([])
    setCartCount(0)
    setCartTotal(0)
    setShowOrderReview(false)
  }

  const showNotification = (message: string, duration = 3000) => {
    setNotification(message)
    setTimeout(() => setNotification(null), duration)
  }

  const callServer = () => {
    showNotification(
      '📞 Appel du serveur...\nUn membre de notre équipe arrive à votre table !',
      4000
    )
  }

  const handleShowReview = () => {
    if (cart.length === 0) {
      showNotification('🛒 Votre panier est vide !\nAjoutez des plats avant de commander.', 3000)
      return
    }
    setShowOrderReview(true)
  }

  return (
    <div className="min-h-screen pizza-gradient text-white pb-36">
      <Header 
        restaurantName="PIZZA POWER"
        onCallServer={callServer}
        theme="pizza"
      />

      {/* Hero Section */}
      <section className="text-center py-10 px-5 bg-black/10">
        <h1 className="text-4xl md:text-6xl font-black mb-3 bg-gradient-to-r from-white to-[#FCD34D] bg-clip-text text-transparent drop-shadow-lg">
          🍕 PIZZA POWER
        </h1>
        <p className="text-lg md:text-xl font-semibold opacity-90">
          La vraie pizza italienne à Tel Aviv
        </p>
      </section>

      {/* Promo Section */}
      <section className="mx-5 my-5 bg-white/15 backdrop-blur-lg rounded-2xl p-5 text-center border border-white/20">
        <div className="text-lg md:text-xl font-bold text-[#FCD34D] drop-shadow-md">
          ✨ 2ème Pizza à -50% • Livraison gratuite dès 80₪ ✨
        </div>
      </section>

      <CategoryNav 
        categories={categories}
        activeCategory={activeCategory}
        onCategoryChange={setActiveCategory}
        theme="pizza"
      />

      <MenuSection 
        category={activeCategory}
        cart={cart}
        onAddToCart={addToCart}
        onUpdateCart={updateCartItem}
        theme="pizza"
      />

      <Footer theme="pizza" />

      <FloatingCart 
        cartCount={cartCount}
        cartTotal={cartTotal}
        onShowReview={handleShowReview}
        theme="pizza"
      />

      {showOrderReview && (
        <OrderReviewModal
          cart={cart}
          cartTotal={cartTotal}
          onClose={() => setShowOrderReview(false)}
          onUpdateItem={updateCartItem}
          onRemoveItem={removeFromCart}
          onConfirm={confirmOrder}
          theme="pizza"
        />
      )}

      {notification && (
        <Notification 
          message={notification}
          onClose={() => setNotification(null)}
          theme="pizza"
        />
      )}
    </div>
  )
}
