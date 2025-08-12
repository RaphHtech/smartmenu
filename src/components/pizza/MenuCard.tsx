interface MenuCardProps {
  name: string
  description: string
  price: number
  emoji: string
  signature?: boolean
  quantity: number
  onAddToCart: () => void
  onUpdateQuantity: (quantity: number) => void
  theme?: 'pizza' | 'falafel' // CORRECTIF: Optionnel
}

export function MenuCard({ 
  name, 
  description, 
  price, 
  emoji, 
  signature, 
  quantity, 
  onAddToCart, 
  onUpdateQuantity,
  theme = 'pizza' // CORRECTIF: Valeur par défaut
}: MenuCardProps) {
  const themeStyles = {
    pizza: {
      badgeBg: 'bg-theme-accent',
      badgeText: 'text-theme-primary',
      imageBg: 'from-theme-primary to-theme-secondary',
      titleColor: 'theme-text-accent',
      priceColor: 'theme-text-accent',
      buttonBg: 'bg-gradient-to-r from-theme-accent to-theme-secondary',
      buttonText: 'text-theme-primary',
      qtyButtonBg: 'bg-theme-accent',
      qtyButtonText: 'text-theme-primary'
    },
    falafel: {
      badgeBg: 'bg-yellow-400',
      badgeText: 'text-amber-800',
      imageBg: 'from-amber-700 to-yellow-500',
      titleColor: 'text-yellow-400',
      priceColor: 'text-yellow-400',
      buttonBg: 'bg-gradient-to-r from-yellow-400 to-amber-500',
      buttonText: 'text-amber-800',
      qtyButtonBg: 'bg-yellow-400',
      qtyButtonText: 'text-amber-800'
    }
  }

  // CORRECTIF: Fallback sécurisé
  const styles = themeStyles[theme] || themeStyles.pizza

  // ... reste du composant identique ...
}
