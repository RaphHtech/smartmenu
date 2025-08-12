import { useState } from 'react'
// CORRECTIF: Supprimer Head ou utiliser le bon import
// import Head from 'next/head'  // Supprimer cette ligne

import { Header } from '@/components/ui/Header'
import { Footer } from '@/components/ui/Footer'
// ... autres imports

export default function PizzaPowerPage() {
  // ... state identique ...

  return (
    <>
      {/* CORRECTIF: Supprimer le bloc Head pour l'instant */}
      {/* 
      <Head>
        <title>PIZZA POWER - SmartMenu</title>
        <meta name="description" content="La vraie pizza italienne à Tel Aviv" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      */}

      <div className="min-h-screen pizza-gradient text-white pb-36">
        <Header 
          restaurantName="PIZZA POWER"
          onCallServer={callServer}
          theme="pizza"
        />

        {/* ... reste identique ... */}
      </div>
    </>
  )
}
