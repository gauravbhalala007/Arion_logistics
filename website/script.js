/* ═══════════════════════════════════════════════════════════
   LANGUAGE TOGGLE (DE / EN)
═══════════════════════════════════════════════════════════ */
const html       = document.documentElement;
const langToggle = document.getElementById('langToggle');
let currentLang  = localStorage.getItem('lang') || 'de';

function applyLang(lang) {
  currentLang = lang;
  html.setAttribute('data-lang', lang);
  html.lang = lang;
  langToggle.textContent = lang === 'de' ? 'EN' : 'DE';
  localStorage.setItem('lang', lang);

  document.querySelectorAll('[data-de]').forEach(el => {
    const text = el.getAttribute(`data-${lang}`);
    if (text) el.innerHTML = text;
  });
}

applyLang(currentLang);

langToggle.addEventListener('click', () => {
  applyLang(currentLang === 'de' ? 'en' : 'de');
});

/* ═══════════════════════════════════════════════════════════
   NAVBAR — scroll effect
═══════════════════════════════════════════════════════════ */
const navbar = document.getElementById('navbar');
window.addEventListener('scroll', () => {
  navbar.classList.toggle('scrolled', window.scrollY > 24);
}, { passive: true });

/* ═══════════════════════════════════════════════════════════
   MOBILE MENU
═══════════════════════════════════════════════════════════ */
const menuToggle = document.getElementById('menuToggle');
const navLinks   = document.getElementById('nav-links');

menuToggle.addEventListener('click', () => {
  navLinks.classList.toggle('open');
});

navLinks.querySelectorAll('a').forEach(link => {
  link.addEventListener('click', () => navLinks.classList.remove('open'));
});

/* ═══════════════════════════════════════════════════════════
   FOOTER YEAR
═══════════════════════════════════════════════════════════ */
document.getElementById('year').textContent = new Date().getFullYear();

/* ═══════════════════════════════════════════════════════════
   SCROLL-REVEAL ANIMATION
═══════════════════════════════════════════════════════════ */
const revealTargets = document.querySelectorAll(
  '.service-card, .team-card, .stat-item, .about-grid, .contact-grid'
);

const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.style.opacity    = '1';
      entry.target.style.transform  = 'translateY(0)';
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

revealTargets.forEach(el => {
  el.style.opacity   = '0';
  el.style.transform = 'translateY(28px)';
  el.style.transition = 'opacity 0.55s ease, transform 0.55s ease';
  observer.observe(el);
});

/* ═══════════════════════════════════════════════════════════
   CONTACT FORM — basic client-side validation + success state
   NOTE: Replace the submit handler with your backend / Formspree / etc.
═══════════════════════════════════════════════════════════ */
const contactForm  = document.getElementById('contactForm');
const formSuccess  = document.getElementById('formSuccess');

contactForm.addEventListener('submit', async (e) => {
  e.preventDefault();

  const name    = contactForm.name.value.trim();
  const email   = contactForm.email.value.trim();
  const message = contactForm.message.value.trim();

  if (!name || !email || !message) {
    // Simple shake animation on missing fields
    [contactForm.name, contactForm.email, contactForm.message].forEach(field => {
      if (!field.value.trim()) shake(field);
    });
    return;
  }

  const submitBtn = contactForm.querySelector('[type="submit"]');
  submitBtn.disabled = true;
  submitBtn.style.opacity = '.6';

  // ── Replace this block with your actual form submission ──
  // e.g. Formspree: fetch('https://formspree.io/f/YOUR_ID', { method:'POST', body: new FormData(contactForm) })
  await new Promise(r => setTimeout(r, 800)); // simulate network
  // ────────────────────────────────────────────────────────

  contactForm.reset();
  submitBtn.disabled = false;
  submitBtn.style.opacity = '1';
  formSuccess.hidden = false;
  setTimeout(() => { formSuccess.hidden = true; }, 5000);
});

function shake(el) {
  el.animate([
    { transform: 'translateX(0)' },
    { transform: 'translateX(-6px)' },
    { transform: 'translateX(6px)' },
    { transform: 'translateX(-4px)' },
    { transform: 'translateX(4px)' },
    { transform: 'translateX(0)' },
  ], { duration: 360, easing: 'ease-in-out' });
  el.style.borderColor = '#d9534f';
  setTimeout(() => { el.style.borderColor = ''; }, 1500);
}
