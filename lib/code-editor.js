"use strict";

import Prism from "prismjs";
import "prismjs/components/prism-elm";
import "prismjs/components/prism-jsx";
import "prismjs/components/prism-tsx";
import "prismjs/components/prism-bash";
import "./native-shim.js";

const syntaxCSS = `

@import url('https://fonts.googleapis.com/css2?family=Fira+Code&display=swap');



code[class*="language-"],
pre[class*="language-"] {
	text-align: left;
	white-space: pre;
	word-spacing: normal;
	word-break: normal;
	word-wrap: normal;
	color: #c3cee3;
	background: #263238;
    font-family: 'Fira Code', monospace;
	font-size: 1em;
	line-height: 1.5em;

	-moz-tab-size: 4;
	-o-tab-size: 4;
	tab-size: 4;

	-webkit-hyphens: none;
	-moz-hyphens: none;
	-ms-hyphens: none;
	hyphens: none;
	
}

code[class*="language-"]::-moz-selection,
pre[class*="language-"]::-moz-selection,
code[class*="language-"] ::-moz-selection,
pre[class*="language-"] ::-moz-selection {
	background: #363636;
}

code[class*="language-"]::selection,
pre[class*="language-"]::selection,
code[class*="language-"] ::selection,
pre[class*="language-"] ::selection {
	background: #363636;
}

:not(pre) > code[class*="language-"] {
	white-space: normal;
	border-radius: 0.2em;
	padding: 0.1em;
}

pre[class*="language-"] {
	overflow: auto;
	position: relative;
	margin: 0.5em 0;
	padding: 1.25em 1em;
}

.language-css > code,
.language-sass > code,
.language-scss > code {
	color: #fd9170;
}

[class*="language-"] .namespace {
	opacity: 0.7;
}

.token.atrule {
	color: #c792ea;
}

.token.attr-name {
	color: #ffcb6b;
}

.token.attr-value {
	color: #c3e88d;
}

.token.attribute {
	color: #c3e88d;
}

.token.boolean {
	color: #c792ea;
}

.token.builtin {
	color: #ffcb6b;
}

.token.cdata {
	color: #80cbc4;
}

.token.char {
	color: #80cbc4;
}

.token.class {
	color: #ffcb6b;
}

.token.class-name {
	color: #f2ff00;
}

.token.color {
	color: #f2ff00;
}

.token.comment {
	color: #546e7a;
}

.token.constant {
	color: #c792ea;
}

.token.deleted {
	color: #f07178;
}

.token.doctype {
	color: #546e7a;
}

.token.entity {
	color: #f07178;
}

.token.function {
	color: #c792ea;
}

.token.hexcode {
	color: #f2ff00;
}

.token.id {
	color: #c792ea;
	font-weight: bold;
}

.token.important {
	color: #c792ea;
	font-weight: bold;
}

.token.inserted {
	color: #80cbc4;
}

.token.keyword {
	color: #c792ea;
	font-style: italic;
}

.token.number {
	color: #fd9170;
}

.token.operator {
	color: #89ddff;
}

.token.prolog {
	color: #546e7a;
}

.token.property {
	color: #80cbc4;
}

.token.pseudo-class {
	color: #c3e88d;
}

.token.pseudo-element {
	color: #c3e88d;
}

.token.punctuation {
	color: #89ddff;
}

.token.regex {
	color: #f2ff00;
}

.token.selector {
	color: #f07178;
}

.token.string {
	color: #c3e88d;
}

.token.symbol {
	color: #c792ea;
}

.token.tag {
	color: #f07178;
}

.token.unit {
	color: #f07178;
}

.token.url {
	color: #fd9170;
}

.token.variable {
	color: #f07178;
}

pre {
  padding: 18px;
  background: #263238;
  overflow: auto;
  font-size: 16px;
  border-radius: 7px;

}

@media only screen and (min-width: 1000px) {
	pre {
	    margin: 0 -3rem;
  		padding: 3rem;
	}
  }
`;

customElements.define(
  "code-editor",
  class extends HTMLElement {
    constructor() {
      super();
      this._editorValue =
        "-- If you see this, the Elm code didn't set the value.";
    }

    get editorValue() {
      return this._editorValue;
    }

    set editorValue(value) {
      if (this._editorValue === value) return;
      this._editorValue = value;
      if (!this._editor) return;
      this._editor.setValue(value);
    }

    get lang() {
      return this.getAttribute("language");
    }

    connectedCallback() {
      let shadow = this.attachShadow({ mode: "open" });

      let style = document.createElement("style");
      style.textContent = syntaxCSS;

      let code = document.createElement("code");
      code.setAttribute("class", `language-${this.lang}`);
      code.innerHTML = Prism.highlight(
        this.editorValue,
        Prism.languages[this.lang],
        this.lang
      );

      let pre = document.createElement("pre");
      pre.appendChild(code);

      shadow.appendChild(style);
      shadow.appendChild(pre);
    }
  }
);
