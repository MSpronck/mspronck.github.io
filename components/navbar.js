class Navbar extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    let prefix = '';
    if (document.title != 'Myrthe Spronck') {
        prefix = '../';
    }
    this.innerHTML = `
        <nav class="navbar" id="navbar">
            <a href="javascript:void(0);" class="small-nav-toggle" onclick="toggle_small_nav()">Menu</a>
            <a href="` + prefix + `" class="navbar-first">Home</a>
            <a href="` + prefix + `publications/">Publications</a>
            <a href="` + prefix + `teaching/">Teaching</a>
            <a href="` + prefix + `cv/">CV</a>
            <a href="` + prefix + `non-academic/" class="navbar-last">Non-Academic</a>
        </nav>
    `;
  }
}

customElements.define('navbar-component', Navbar);

function toggle_small_nav() {
  var x = document.getElementById("navbar");
  if (x.className === "navbar") {
    x.className += " small-nav-visible";
  } else {
    x.className = "navbar";
  }
} 