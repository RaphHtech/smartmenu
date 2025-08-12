import { Category } from './types'

interface CategoryNavProps {
  categories: Category[]
  activeCategory: string
  onCategoryChange: (categoryId: string) => void
  theme?: 'pizza' | 'falafel' // CORRECTIF: Optionnel
}

export function CategoryNav({ categories, activeCategory, onCategoryChange, theme = 'pizza' }: CategoryNavProps) {
  const themeStyles = {
    pizza: {
      active: 'bg-white/90 text-theme-primary border-white theme-shadow',
      inactive: 'bg-white/10 text-white border-white/30 hover:bg-white/20'
    },
    falafel: {
      active: 'bg-white/90 text-amber-800 border-white shadow-lg',
      inactive: 'bg-white/10 text-white border-white/30 hover:bg-white/20'
    }
  }

  // CORRECTIF: Fallback
  const styles = themeStyles[theme] || themeStyles.pizza

  return (
    <nav className="flex gap-3 px-5 py-5 overflow-x-auto scrollbar-hide" role="navigation" aria-label="Catégories du menu">
      {categories.map((category) => (
        <button
          key={category.id}
          onClick={() => onCategoryChange(category.id)}
          className={`
            px-4 md:px-6 py-3 rounded-full font-semibold text-sm whitespace-nowrap transition-all duration-300 border-2 min-h-[44px]
            ${activeCategory === category.id
              ? `${styles.active} transform -translate-y-1`
              : styles.inactive
            }
          `}
          aria-pressed={activeCategory === category.id}
          aria-label={`Afficher la section ${category.label}`}
        >
          {category.label}
        </button>
      ))}
    </nav>
  )
}
