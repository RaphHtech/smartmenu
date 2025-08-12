import { CartItem } from '@/pages/pizza-power'
import { MenuCard } from './MenuCard'

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

interface MenuSectionProps {
  category: string
  cart: CartItem[]
  onAddToCart: (itemName: string, price: number) => void
  onUpdateCart: (itemName: string, quantity: number) => void
}

export function MenuSection({ category, cart, onAddToCart, onUpdateCart }: MenuSectionProps) {
  const categoryData = menuData[category as keyof typeof menuData]
  
  if (!categoryData) return null

  const getItemQuantity = (itemName: string) => {
    const cartItem = cart.find(item => item.name === itemName)
    return cartItem?.quantity || 0
  }

  return (
    <section className="px-5 pb-5">
      <h2 className="text-3xl font-black text-center mb-5 text-yellow-300 drop-shadow-lg">
        {categoryData.title}
      </h2>
      
      <div className="grid gap-5">
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
          />
        ))}
      </div>
    </section>
  )
}
