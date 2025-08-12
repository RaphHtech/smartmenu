interface OrderReviewModalProps {
  cart: CartItem[]
  cartTotal: number
  onClose: () => void
  onUpdateItem: (itemName: string, quantity: number) => void
  onRemoveItem: (itemName: string) => void
  onConfirm: () => void
  theme?: 'pizza' | 'falafel' // CORRECTIF: Optionnel
}

export function OrderReviewModal({
  cart,
  cartTotal,
  onClose,
  onUpdateItem,
  onRemoveItem,
  onConfirm,
  theme = 'pizza' // CORRECTIF: Valeur par défaut
}: OrderReviewModalProps) {
  const themeStyles = {
    pizza: {
      modalBg: 'theme-gradient',
      titleColor: 'theme-text-accent',
      totalColor: 'theme-text-accent',
      buttonBg: 'bg-gradient-to-r from-theme-accent to-theme-secondary',
      buttonText: 'text-theme-primary',
      qtyButtonBg: 'bg-theme-accent',
      qtyButtonText: 'text-theme-primary'
    },
    falafel: {
      modalBg: 'bg-gradient-to-br from-amber-700 via-yellow-600 to-yellow-400',
      titleColor: 'text-yellow-300',
      totalColor: 'text-yellow-300',
      buttonBg: 'bg-gradient-to-r from-yellow-400 to-amber-500',
      buttonText: 'text-amber-800',
      qtyButtonBg: 'bg-yellow-400',
      qtyButtonText: 'text-amber-800'
    }
  }

  // CORRECTIF: Fallback
  const styles = themeStyles[theme] || themeStyles.pizza

  // ... reste identique ...
}
