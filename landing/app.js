// Mobile-Burger-Menu Toggle
(function () {
  const nav = document.getElementById('nav');
  const burger = document.getElementById('navBurger');
  const mobile = document.getElementById('navMobile');
  if (!nav || !burger || !mobile) return;

  burger.addEventListener('click', () => {
    const isOpen = nav.classList.toggle('is-open');
    mobile.hidden = !isOpen;
    burger.querySelector('.material-symbols-rounded').textContent =
      isOpen ? 'close' : 'menu';
  });

  // Close mobile-menu when clicking a link inside it
  mobile.querySelectorAll('a').forEach((a) => {
    a.addEventListener('click', () => {
      nav.classList.remove('is-open');
      mobile.hidden = true;
      burger.querySelector('.material-symbols-rounded').textContent = 'menu';
    });
  });
})();

// Subtle scroll-driven nav shadow
(function () {
  const nav = document.getElementById('nav');
  if (!nav) return;
  let last = 0;
  const onScroll = () => {
    const y = window.scrollY;
    if (y > 8 && last <= 8) nav.style.boxShadow = '0 1px 0 rgba(0,0,0,0.04)';
    if (y <= 8 && last > 8) nav.style.boxShadow = '';
    last = y;
  };
  window.addEventListener('scroll', onScroll, { passive: true });
})();
