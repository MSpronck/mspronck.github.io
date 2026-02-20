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
            <a href="` + prefix + `index.html" class="navbar-first">Home</a>
            <a href="` + prefix + `pages/publications.html">Publications</a>
            <a href="` + prefix + `pages/teaching.html">Education</a>
            <a href="` + prefix + `pages/cv.html">CV</a>
            <a href="` + prefix + `pages/hobbies.html" class="navbar-last">Non-Academic</a>
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