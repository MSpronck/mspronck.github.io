class Header extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.innerHTML = `
      <header>
        <div class="header-left"></div>
        <h1>`+ document.title + `</h1>
        <div class="header-right"></div>
      </header>
    `;
  }
}

customElements.define('header-component', Header);