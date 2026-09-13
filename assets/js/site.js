document.addEventListener("DOMContentLoaded", function () {
  var navbar = document.querySelector(".site-nav");
  var toggle = document.querySelector(".nav-toggle");
  var menu = document.querySelector(".nav-menu");

  if (!navbar || !toggle || !menu) return;

  toggle.addEventListener("click", function () {
    var isOpen = navbar.classList.toggle("nav-open");
    toggle.setAttribute("aria-expanded", isOpen.toString());
  });

  menu.querySelectorAll("a").forEach(function (link) {
    link.addEventListener("click", function () {
      navbar.classList.remove("nav-open");
      toggle.setAttribute("aria-expanded", "false");
    });
  });
});