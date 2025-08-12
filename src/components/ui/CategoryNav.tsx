interface Category {
  id: string
  label: string
  emoji: string
}

interface CategoryNavProps {
  categories: Category[]
  activeCategory: string
  onCategoryChange: (categoryId: string) => void
}

export function CategoryNav({ categories, activeCategory, onCategoryChange }: CategoryNavProps) {
  return (
    <nav className="flex gap-3 px-5 py-5 overflow-x-auto scrollbar-hide">
      {categories.map((category) => (
        <button
          key={category.id}
          onClick={() => onCategoryChange(category.id)}
          className={`
            px-6 py-3 rounded-full font-semibold text-sm whitespace-nowrap transition-all duration-300 border-2 min-h-[44px]
            ${activeCategory === category.id
              ? 'bg-white/90 text-red-600 border-white transform -translate-y-1 shadow-xl'
              : 'bg-white/10 text-white border-white/30 hover:bg-white/20'
            }
          `}
        >
          {category.label}
        </button>
      ))}
    </nav>
  )
}
