/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        treasure: {
          50: '#fdf8f0',
          100: '#f9eddb',
          200: '#f2d8b4',
          300: '#e9bd83',
          400: '#df9c4f',
          500: '#d6832e',
          600: '#c76b23',
          700: '#a5521f',
          800: '#854220',
          900: '#6c371d',
          950: '#3a1b0d',
        },
        forest: {
          50: '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
          800: '#166534',
          900: '#14532d',
          950: '#052e16',
        },
      },
      fontFamily: {
        display: ['Georgia', 'Cambria', 'serif'],
        body: ['system-ui', '-apple-system', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
