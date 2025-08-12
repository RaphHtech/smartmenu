interface NotificationProps {
  message: string
  onClose: () => void
  theme?: 'pizza' | 'falafel' // CORRECTIF: Optionnel
}

export function Notification({ message, onClose, theme = 'pizza' }: NotificationProps) {
  const themeStyles = {
    pizza: {
      bg: 'bg-gradient-to-r from-theme-accent to-theme-secondary',
      text: 'text-theme-primary'
    },
    falafel: {
      bg: 'bg-gradient-to-r from-yellow-400 to-amber-500',
      text: 'text-amber-800'
    }
  }

  // CORRECTIF: Fallback
  const styles = themeStyles[theme] || themeStyles.pizza

  // ... reste identique ...
}
