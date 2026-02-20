class Footer extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.innerHTML = `
      <footer>
        <p>Last edited ` + document.getElementsByName('edited')[0].getAttribute('content') + `</p>
      </footer> 
    `;
  }
}

customElements.define('footer-component', Footer);