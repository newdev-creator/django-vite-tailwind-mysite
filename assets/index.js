// Import HTMX
import htmx from 'htmx.org';

// Import Alpine.js
import Alpine from 'alpinejs';

// Rendre HTMX disponible globalement
window.htmx = htmx;

// Initialiser Alpine.js
window.Alpine = Alpine;
Alpine.start();

// Configuration HTMX (optionnel)
document.addEventListener('DOMContentLoaded', () => {
  // Configuration HTMX
  htmx.config.defaultSwapStyle = 'innerHTML';
  htmx.config.defaultSwapDelay = 0;
  htmx.config.defaultSettleDelay = 20;
  
  console.log('HTMX et Alpine.js initialisés');
});