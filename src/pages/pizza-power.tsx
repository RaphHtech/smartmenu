// ... imports identiques ...

export default function PizzaPowerPage() {
  // ... state identique ...

  return (
    <>
      <Head>
        <title>PIZZA POWER - SmartMenu</title>
        <meta name="description" content="La vraie pizza italienne à Tel Aviv" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>

      {/* CORRECTIF: Utiliser pizza-gradient au lieu de theme-gradient */}
      <div className="min-h-screen pizza-gradient text-white pb-36">
        <Header 
          restaurantName="PIZZA POWER"
          onCallServer={callServer}
          theme="pizza"
        />

        {/* Hero Section */}
        <section className="text-center py-10 px-5 bg-black/10">
          <h1 className="text-4xl md:text-6xl font-black mb-3 bg-gradient-to-r from-white to-[#FCD34D] bg-clip-text text-transparent drop-shadow-lg">
            🍕 PIZZA POWER
          </h1>
          <p className="text-lg md:text-xl font-semibold opacity-90">
            La vraie pizza italienne à Tel Aviv
          </p>
        </section>

        {/* Promo Section */}
        <section className="mx-5 my-5 bg-white/15 backdrop-blur-lg rounded-2xl p-5 text-center border border-white/20">
          <div className="text-lg md:text-xl font-bold text-[#FCD34D] drop-shadow-md">
            ✨ 2ème Pizza à -50% • Livraison gratuite dès 80₪ ✨
          </div>
        </section>

        {/* ... reste identique ... */}
      </div>
    </>
  )
}
