import type { Config } from "tailwindcss"

const config: Config = {
  content: [
    "./App.{ts,tsx}",
    "./src/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}

module.exports = config;