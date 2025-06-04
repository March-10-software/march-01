import type { Config } from 'tailwindcss';
import plugin from 'tailwindcss/plugin';

export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}"
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        // Couleurs des modules PLANNER
        stageplanner: {
          50: '#e6f0ff',
          100: '#cce0ff',
          200: '#99c2ff',
          300: '#66a3ff',
          400: '#3385ff',
          500: '#0066ff', // Couleur principale STAGEPLANNER (Bleu)
          600: '#0052cc',
          700: '#003d99',
          800: '#002966',
          900: '#001433',
        },
        barplanner: {
          50: '#f5e6ff',
          100: '#ebccff',
          200: '#d699ff',
          300: '#c266ff',
          400: '#ad33ff',
          500: '#9900ff', // Couleur principale BARPLANNER (Violet)
          600: '#7a00cc',
          700: '#5c0099',
          800: '#3d0066',
          900: '#1f0033',
        },
        cleanplanner: {
          50: '#e6ffec',
          100: '#ccffd9',
          200: '#99ffb3',
          300: '#66ff8c',
          400: '#33ff66',
          500: '#00ff40', // Couleur principale CLEANPLANNER (Vert)
          600: '#00cc33',
          700: '#009926',
          800: '#00661a',
          900: '#00330d',
        },
        secureplanner: {
          50: '#fff2e6',
          100: '#ffe6cc',
          200: '#ffcc99',
          300: '#ffb366',
          400: '#ff9933',
          500: '#ff8000', // Couleur principale SECUREPLANNER (Orange)
          600: '#cc6600',
          700: '#994c00',
          800: '#663300',
          900: '#331900',
        },
        commerceplanner: {
          50: '#fffde6',
          100: '#fffbcc',
          200: '#fff799',
          300: '#fff366',
          400: '#ffef33',
          500: '#ffeb00', // Couleur principale COMMERCEPLANNER (Or)
          600: '#ccbc00',
          700: '#998d00',
          800: '#665e00',
          900: '#332f00',
        },
        festivalplanner: {
          50: '#ffe6e6',
          100: '#ffcccc',
          200: '#ff9999',
          300: '#ff6666',
          400: '#ff3333',
          500: '#ff0000', // Couleur principale FESTIVALPLANNER (Grenat)
          600: '#cc0000',
          700: '#990000',
          800: '#660000',
          900: '#330000',
        },
        // Couleurs de base pour l'interface
        glass: {
          DEFAULT: 'rgba(255, 255, 255, 0.2)',
          dark: 'rgba(15, 23, 42, 0.75)',
        },
        background: {
          light: '#f8fafc',
          dark: '#0f172a',
        }
      },
      boxShadow: {
        // Ombres pour le neumorphism
        'neu-light': '10px 10px 20px #d1d9e6, -10px -10px 20px #ffffff',
        'neu-dark': '10px 10px 20px #0c111f, -10px -10px 20px #121d35',
        'neu-inset-light': 'inset 5px 5px 10px #d1d9e6, inset -5px -5px 10px #ffffff',
        'neu-inset-dark': 'inset 5px 5px 10px #0c111f, inset -5px -5px 10px #121d35',
        // Ombres pour le glassmorphism
        'glass': '0 8px 32px 0 rgba(31, 38, 135, 0.37)',
      },
      backdropBlur: {
        'xs': '2px',
        'sm': '4px',
        'md': '8px',
        'lg': '12px',
        'xl': '16px',
        '2xl': '24px',
      },
      borderRadius: {
        'xl': '1rem',
        '2xl': '1.5rem',
        '3xl': '2rem',
      },
      animation: {
        'float': 'float 6s ease-in-out infinite',
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-10px)' },
        }
      },
    },
  },
  plugins: [
    require('daisyui'),
    // Plugin personnalisé pour le glassmorphism
    plugin(function({ addUtilities }) {
      const newUtilities = {
        '.glass': {
          backgroundColor: 'rgba(255, 255, 255, 0.2)',
          backdropFilter: 'blur(8px)',
          borderRadius: '1rem',
          border: '1px solid rgba(255, 255, 255, 0.18)',
          boxShadow: '0 8px 32px 0 rgba(31, 38, 135, 0.37)',
        },
        '.glass-dark': {
          backgroundColor: 'rgba(15, 23, 42, 0.75)',
          backdropFilter: 'blur(8px)',
          borderRadius: '1rem',
          border: '1px solid rgba(255, 255, 255, 0.08)',
          boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37)',
        },
        '.neu-convex': {
          borderRadius: '1rem',
          backgroundColor: '#f0f4f8',
          boxShadow: '10px 10px 20px #d1d9e6, -10px -10px 20px #ffffff',
        },
        '.neu-convex-dark': {
          borderRadius: '1rem',
          backgroundColor: '#0f172a',
          boxShadow: '10px 10px 20px #0c111f, -10px -10px 20px #121d35',
        },
        '.neu-concave': {
          borderRadius: '1rem',
          backgroundColor: '#f0f4f8',
          boxShadow: 'inset 5px 5px 10px #d1d9e6, inset -5px -5px 10px #ffffff',
        },
        '.neu-concave-dark': {
          borderRadius: '1rem',
          backgroundColor: '#0f172a',
          boxShadow: 'inset 5px 5px 10px #0c111f, inset -5px -5px 10px #121d35',
        },
      }
      addUtilities(newUtilities, ['responsive', 'hover']);
    }),
  ],
  // Configuration DaisyUI
  daisyui: {
    themes: [
      {
        light: {
          ...require('daisyui/src/theming/themes')['light'],
          primary: '#0066ff', // STAGEPLANNER comme thème par défaut
          secondary: '#9900ff',
          accent: '#ff8000',
          neutral: '#3d4451',
          'base-100': '#f8fafc',
          'base-200': '#f0f4f8',
          'base-300': '#e2e8f0',
        },
        dark: {
          ...require('daisyui/src/theming/themes')['dark'],
          primary: '#3385ff', // Version plus claire pour le mode sombre
          secondary: '#ad33ff',
          accent: '#ff9933',
          neutral: '#d1d5db',
          'base-100': '#0f172a',
          'base-200': '#1e293b',
          'base-300': '#334155',
        },
      },
    ],
    darkTheme: 'dark',
  },
} satisfies Config;
