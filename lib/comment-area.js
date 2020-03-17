"use strict"

customElements.define(
    "comment-area",
    class extends HTMLElement {
        constructor() {
            super();
        }
        connectedCallback() {
            const shadow = this.attachShadow({ mode: "open" });

            const view = document.createElement("div")
            view.id = "commento"

            const script = document.createElement("script")
            script.src = "https://cdn.commento.io/js/commento.js"


            shadow.appendChild(view);
            shadow.appendChild(script);
        }
    }
);