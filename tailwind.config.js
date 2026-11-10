/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,jsx,ts,tsx}",
    "./components/**/*.{js,jsx,ts,tsx}",
    "./screens/**/*.{js,jsx,ts,tsx}"
  ],
  presets: [require("nativewind/preset")],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        brand: {
          primary: '#FF5A36',      // Electric Tangerine
          deep: '#D93E1B',         // Deep Tangerine
          honey: '#FFAA00',        // Golden Honey
          wash: '#FFF0EB',         // Soft Tangerine Wash
          washDark: '#2C1B16',
          mint: '#00C48C',         // Mint Green for delivery speed/status
        },
        paper: {
          light: '#FBF9F6',        // Warm Linen Cream
          dark: '#12100E',         // Dark theme surface
        },
        card: {
          light: '#FFFFFF',        // Card backgrounds
          dark: '#1C1917',
        },
        ink: {
          DEFAULT: '#181512',      // Charcoal Espresso
          soft: '#4A433E',         // Secondary body text
          muted: '#8A8179',        // Placeholders and hints
          darkDefault: '#F5F2EE',  // Dark mode primary text
          darkSoft: '#D1CAC2',
          darkMuted: '#78716C',
        },
        line: {
          light: '#EFECE6',        // Border lines
          dark: '#292524',
        }
      },
      fontFamily: {
        sans: ['Bricolage-Regular', 'sans-serif'],
        medium: ['Bricolage-Medium', 'sans-serif'],
        semibold: ['Bricolage-SemiBold', 'sans-serif'],
        bold: ['Bricolage-Bold', 'sans-serif'],
        extrabold: ['Bricolage-ExtraBold', 'sans-serif'],
      }
    },
  },
  plugins: [],
};
