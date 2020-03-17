"use strict"

import fetchInject from "fetch-inject"

customElements.define(
    "comment-area",
    class extends HTMLElement {
        constructor() {
            super();
            const shadow = this.attachShadow({ mode: "open" });
            // const script = document.createElement("script")
            // script.setAttribute("data-auto-init", "false")

            // script.src = "https://cdn.commento.io/js/commento.js"

            const view = document.createElement("div")
            view.id = "commento"

            fetchInject([
                'https://cdn.commento.io/js/commento.js'
            ])


            shadow.appendChild(view);


            document.getElementsByTagName('head')[0].appendChild(script);

        }
        connectedCallback() {

        }
    }
);