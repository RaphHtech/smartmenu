interface FooterProps {
  theme?: 'pizza' | 'falafel' // CORRECTIF: Optionnel
}

export function Footer({ theme = 'pizza' }: FooterProps) {
  const themeStyles = {
    pizza: {
      logoColor: 'theme-text-accent'
    },
    falafel: {
      logoColor: 'text-yellow-400'
    }
  }

  // CORRECTIF: Fallback
  const styles = themeStyles[theme] || themeStyles.pizza

  // ... reste identique ...
}
