import { useState } from 'react'
import { Header } from '@/components/ui/Header'
import { Footer } from '@/components/ui/Footer'
import { CategoryNav } from '@/components/ui/CategoryNav'
import { MenuSection } from '@/components/pizza/MenuSection'
import { FloatingCart } from '@/components/pizza/FloatingCart'
import { OrderReviewModal } from '@/components/pizza/OrderReviewModal'
import { Notification } from '@/components/ui/Notification'

export interface CartItem {
  name: string
  price: number
  quantity: number
  total: number
}

export default function PizzaPowerPage() {
  const [cart, setCart] = useState<CartItem[]>([])
  const [activeCategory, setActiveCategory] = useState('pizzas')
  const [showReviewModal, setShowReviewModal] = useState(false)
  const [notification, setNotification] = useState<string | null>(null)

  const categories = [
    { id: 'pizzas', label: 'Pizzas', emoji: '🍕' },
    { id: 'drinks', label: 'Boissons', emoji: '🥤' },
    { id: 'desserts', label: 'Desserts', emoji: '🍰' }
  ]

  const addToCart = (name: string, price: number) => {
    setCart(prev => {
      const existing = prev.find(item => item.name === name)
      if (existing) {
        return prev.map(item =>
          item.name === name
            ? { ...item, quantity: item.quantity + 1, total: (item.quantity + 1) * item.price }
            : item
        )
      } else {
        return [...prev, { name, price, quantity: 1, total: price }]
      }
    })
    setNotification(`${name} ajouté au panier !`)
    setTimeout(() => setNotification(null), 3000)
  }

  const updateCartItem = (itemName: string, quantity: number) => {
    if (quantity <= 0) {
      removeFromCart(itemName)
      return
    }
    setCart(prev =>
      prev.map(item =>
        item.name === itemName
          ? { ...item, quantity, total: quantity * item.price }
          : item
      )
    )
  }

  const removeFromCart = (itemName: string) => {
    setCart(prev => prev.filter(item => item.name !== itemName))
  }

  const cartTotal = cart.reduce((sum, item) => sum + item.total, 0)
  const cartCount = cart.reduce((sum, item) => sum + item.quantity, 0)

  const handleCallServer = () => {
    setNotification('Serveur appelé ! 📞')
    setTimeout(() => setNotification(null), 3000)
  }

  const handleOrderConfirmation = () => {
    setNotification('Commande confirmée ! Merci ! 🎉')
    setCart([])
    setShowReviewModal(false)
    setTimeout(() => setNotification(null), 5000)
  }

  return (
    <>
      <div className="min-h-screen bg-gradient-to-br from-red-600 via-orange-500 to-yellow-400">
        <Header restaurantName="Pizza Power" onCallServer={handleCallServer} theme="pizza" />
        
        <main className="container mx-auto px-4 py-8">
          <div className="text-center mb-8">
            <h1 className="text-5xl font-black text-white mb-4">
              🍕 PIZZA POWER
            </h1>
            <p className="text-xl text-yellow-100 font-semibold">
              Authentiques pizzas italiennes depuis 1985
            </p>
          </div>

          <CategoryNav 
            categories={categories}
            activeCategory={activeCategory}
            onCategoryChange={setActiveCategory}
          />

          <MenuSection 
            category={activeCategory}
            cart={cart}
            onAddToCart={addToCart}
            onUpdateCart={updateCartItem}
            theme="pizza"
          />
        </main>

        <Footer />

        <FloatingCart 
          cartCount={cartCount}
          cartTotal={cartTotal}
          onShowReview={() => setShowReviewModal(true)}
          theme="pizza"
        />

        {showReviewModal && (
          <OrderReviewModal
            cart={cart}
            cartTotal={cartTotal}
            onClose={() => setShowReviewModal(false)}
            onUpdateItem={updateCartItem}
            onRemoveItem={removeFromCart}
            onConfirmOrder={handleOrderConfirmation}
            theme="pizza"
          />
        )}

        {notification && (
          <Notification
            message={notification}
            onClose={() => setNotification(null)}
          />
        )}
      </div>
    </>
  )
}
