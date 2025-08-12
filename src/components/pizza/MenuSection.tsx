interface MenuSectionProps {
  category: string
  cart: CartItem[]
  onAddToCart: (itemName: string, price: number) => void
  onUpdateCart: (itemName: string, quantity: number) => void
  theme?: 'pizza' | 'falafel' // CORRECTIF: Optionnel
}

export function MenuSection({ category, cart, onAddToCart, onUpdateCart, theme = 'pizza' }: MenuSectionProps) {
  // ... reste identique car pas de themeStyles dans ce composant
}
