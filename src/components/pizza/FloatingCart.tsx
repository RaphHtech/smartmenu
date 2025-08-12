interface FloatingCartProps {
  cartCount: number
  cartTotal: number
  onShowReview: () => void
  theme?: 'pizza' | 'falafel' // CORRECTIF: Optionnel
}

export function FloatingCart({ cartCount, cartTotal, onShowReview, theme = 'pizza' }: FloatingCartProps) {
  if (cartCount === 0) return null

  const themeStyles = {
    pizza: {
      summaryColor: 'theme-text-accent',
      buttonBg: 'bg-gradient-to-r from-theme-accent to-theme-secondary',
      buttonText: 'text-theme-primary'
    },
    falafel: {
      summaryColor: 'text-yellow-400',
      buttonBg: 'bg-gradient-to-r from-yellow-400 to-amber-500',
      buttonText: 'text-amber-800'
    }
  }

  // CORRECTIF: Fallback
  const styles = themeStyles[theme] || themeStyles.pizza

  // ... reste identique ...
}
