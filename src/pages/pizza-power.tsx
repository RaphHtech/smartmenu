// src/pages/pizza-power.tsx
import Head from 'next/head'
import { useState } from 'react'
import { Header } from '@/components/ui/Header'
import { Footer } from '@/components/ui/Footer'
import { CategoryNav } from '@/components/ui/CategoryNav'
import { MenuSection } from '@/components/pizza/MenuSection'
import { FloatingCart } from '@/components/pizza/FloatingCart'
import { OrderReviewModal } from '@/components/pizza/OrderReviewModal'
import { Notification } from '@/components/ui/Notification'
import type { CartItem, Category } from '@/components/ui/types'

export default function PizzaPowerPage() {
  // UI state
  const [activeCategory, setActiveCategory] = useState<string>('pizzas')
  const [cart, setCart] = useState<CartItem[]>([])
  const [cartTotal, setCartTotal] = useState<number>(0)
  const [cartCount, setCartCount] = useState<number>(0)
  const [showOrderReview, setShowOrderReview] = useState<boolean>(false)
  const [notification, setNotification] = useState<string | null>(null)

  const categories: Category[] = [
    { id: 'pizzas',   label: '🍕 Pizzas',   emoji: '🍕' },
    { id: 'entrees',  label: '🥗 Entrées',  emoji: '🥗' },
    { id: 'pates',    label: '🍝 Pâtes',    emoji: '🍝' },
    { id: 'desserts', label: '🍰 Desserts', emoji: '🍰' },
    { id: 'boissons', label: '🍹 Boissons', emoji: '🍹' },
  ]

  // Helpers
  const recalc = (items: CartItem[]) => {
    setCartCount(items.reduce((n, it) => n + it.quantity, 0))
    setCartTotal(items.reduce((s, it) => s + it.total, 0))
  }

  const addToCart = (name: string, price: number) => {
    const existing = cart.find(it => it.name === name)
    let next: CartItem[]
    if (existing) {
      next = cart.map(it => it.name === name ? { ...it, quantity: it.quantity + 1, total: (it.quantity + 1) * it.price } : it)
    } else {
      next = [...cart, { name, price, quantity: 1, total: price }]
    }
    setCart(next); recalc(next)
    notify(`✅ ${name} ajouté au panier !`)
  }

  const updateItem = (name: string, q: number) => {
    if (q <= 0) return removeItem(name)
    const next = cart.map(it => it.name === name ? { ...it, quantity: q, total: q * it.price } : it)
    setCart(next); recalc(next)
  }

  const removeItem = (name: string) => {
    const next = cart.filter(it => it.name !== name)
    setCart(next); recalc(next)
    notify(`❌ ${name} retiré du panier`)
  }

  const confirmOrder = () => {
    notify(`🎉 COMMANDE CONFIRMÉE !\nTOTAL: ₪${cartTotal.toFixed(2)}`, 8000)
    setCart([]); setCartCount(0); setCartTotal(0); setShowOrderReview(false)
  }

  const notify = (msg: string, ms = 3000) => {
    setNotification(msg)
    setTimeout(() => setNotification(null), ms)
  }

  const callServer = () => notify('📞 Un serveur arrive à votre table !', 4000)

  return (
    <>
      <Head>
        <title>PIZZA POWER - SmartMenu</title>
        <meta name="description" content="La vraie pizza italienne à Tel Aviv" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>

      {/* IMPORTANT: tokens thème Pizza appliqués par classes utilitaires */}
      <div className="min-h-screen theme-gradient text-white pb-36">
        <Header restaurantName="PIZZA POWER" onCallServer={callServer} theme="pizza" />

        {/* Hero */}
        <section className="text-center py-10 px-5 bg-black/10">
          <h1 className="text-4xl md:text-6xl font-black mb-3 bg-gradient-to-r from-white to-theme-accent bg-clip-text text-transparent drop-shadow-lg">
            🍕 PIZZA POWER
          </h1>
          <p className="text-lg md:text-xl font-semibold opacity-90">
            La vraie pizza italienne à Tel Aviv
          </p>
        </section>

        {/* Promo */}
        <section className="mx-5 my-5 bg-white/15 backdrop-blur-lg rounded-2xl p-5 text-center border border-white/20">
          <div className="text-lg md:text-xl font-bold theme-text-accent drop-shadow-md">
            ✨ 2ème Pizza à -50% • Livraison gratuite dès 80₪ ✨
          </div>
        </section>

        {/* Navigation catégories */}
        <CategoryNav
          categories={categories}
          activeCategory={activeCategory}
          onCategoryChange={setActiveCategory}
          theme="pizza"
        />

        {/* Section menu (les data vivent dans le composant) */}
        <MenuSection
          category={activeCategory}
          cart={cart}
          onAddToCart={addToCart}
          onUpdateCart={updateItem}
          theme="pizza"
        />

        <Footer theme="pizza" />

        {/* Panier flottant */}
        <FloatingCart
          cartCount={cartCount}
          cartTotal={cartTotal}
          onShowReview={() => cart.length ? setShowOrderReview(true) : notify('🛒 Panier vide')}
          theme="pizza"
        />

        {/* Modal révision commande */}
        {showOrderReview && (
          <OrderReviewModal
            cart={cart}
            cartTotal={cartTotal}
            onClose={() => setShowOrderReview(false)}
            onUpdateItem={updateItem}
            onRemoveItem={removeItem}
            onConfirm={confirmOrder}
            theme="pizza"
          />
        )}

        {/* Notifications */}
        {notification && (
          <Notification message={notification} onClose={() => setNotification(null)} theme="pizza" />
        )}
      </div>
    </>
  )
}
