module.exports = {
  theme: {
    extend: {
      fontFamily: {
        sans: ['"DM Sans"', 'ui-sans-serif', 'system-ui', '-apple-system', 'sans-serif']
      }
    }
  },
  plugins: [
    require('daisyui')
  ],
  daisyui: {
    // MightyWELL brand theme. Theme key kept as `docuseal` so the
    // `data-theme="docuseal"` in the layouts needs no changes.
    // Brand: navy #1F3A5F (structure / primary buttons), lime #7AC943 (CTA accent).
    themes: [
      {
        docuseal: {
          'color-scheme': 'light',
          primary: '#7AC943',
          'primary-content': '#ffffff',
          secondary: '#1F3A5F',
          'secondary-content': '#ffffff',
          accent: '#1F3A5F',
          'accent-content': '#ffffff',
          neutral: '#1F3A5F',
          'neutral-content': '#ffffff',
          'base-100': '#ffffff',
          'base-200': '#EEF5FF',
          'base-300': '#DBE8FC',
          'base-content': '#1F3A5F',
          info: '#234A8F',
          'info-content': '#ffffff',
          success: '#7AC943',
          'success-content': '#ffffff',
          warning: '#F5B301',
          'warning-content': '#1F3A5F',
          error: '#C53030',
          'error-content': '#ffffff',
          '--rounded-btn': '0.5rem',
          '--tab-border': '2px',
          '--tab-radius': '.5rem'
        }
      }
    ]
  }
}
