import { CartItem } from '@/components/ui/types'
import { MenuCard } from './MenuCard'

// ... menuData inchangé ...

interface MenuSectionProps {
  category: string
  cart: CartItem[]
  onAddToCart: (itemName: string, price: number) => void
  onUpdateCart: (itemName: string, quantity: number) => void
  theme: 'pizza' | 'falafel'
}

export function MenuSection({ category, cart, onAddToCart, onUpdateCart, theme }: MenuSectionProps) {
  const categoryData = menuData[category as keyof typeof menuData]
  
  if (!categoryData) return null

  const getItemQuantity = (itemName: string) => {
    const cartItem = cart.find(item => item.name === itemName)
    return cartItem?.quantity || 0
  }

  return (
    <section className="px-5 pb-5" role="main" aria-label={categoryData.title}>
      {/* CORRECTIF: Force theme-text-accent (doré #FCD34D) */}
      <h2 className="text-2xl md:text-3xl font-black text-center mb-5 theme-text-accent drop-shadow-lg">
        {categoryData.title}
      </h2>
      
      <div className="grid gap-5 max-w-4xl mx-auto">
        {categoryData.items.map((item) => (
          <MenuCard
            key={item.name}
            name={item.name}
            description={item.description}
            price={item.price}
            emoji={item.emoji}
            signature={item.signature}
            quantity={getItemQuantity(item.name)}
            onAddToCart={() => onAddToCart(item.name, item.price)}
            onUpdateQuantity={(quantity) => onUpdateCart(item.name, quantity)}
            theme={theme}
          />
        ))}
      </div>
    </section>
  )
}
