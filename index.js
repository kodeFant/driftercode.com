import "./lib/code-editor.js";
import "./style.css";

const { Elm } = require("./src/Main.elm");
const pagesInit = require("elm-pages");

const webMention = document.createElement("link");
webMention.rel = "webmention";
webMention.href = "https://webmention.io/driftercode.com/webmention";

const pingback = document.createElement("link");
pingback.rel = "pingback";
pingback.href = "https://webmention.io/driftercode.com/xmlrpc";

document.querySelector("head").appendChild(webMention);
document.querySelector("head").appendChild(pingback);

// const adsenseCode = `<script data-ad-client="ca-pub-6495242829238439" async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>`
// document.querySelector("head").insertAdjacentElement("beforeend", adsenseCode)


pagesInit({
  mainElmModule: Elm.Main,
}).then((app) => {});

// Google Analytics Usage Tracking
if (process.env.NODE_ENV === "production") {
  console.log(process.env.NODE_ENV);
  (function (i, s, o, g, r, a, m) {
    i["GoogleAnalyticsObject"] = r;
    (i[r] =
      i[r] ||
      function () {
        (i[r].q = i[r].q || []).push(arguments);
      }),
      (i[r].l = 1 * new Date());
    (a = s.createElement(o)), (m = s.getElementsByTagName(o)[0]);
    a.async = 1;
    a.src = g;
    m.parentNode.insertBefore(a, m);
  })(
    window,
    document,
    "script",
    "https://www.google-analytics.com/analytics.js",
    "ga"
  );

  ga("create", "UA-163362016-1", "auto");
  ga("set", "anonymizeIp", true);
  ga("send", "pageview");
}
