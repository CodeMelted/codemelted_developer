/**
 * @file Provides the <codemelted-navigation></codemelted-navigation> custom
 * widget to support each of the codemelted.com sub-domains. This file
 * utilizes the codemelted-navigation.css file for all the styling of the
 * widget between each of the domains and the main layout of the overall
 * navigation.
 * @copyright © 2025 Mark Shaffer. All Rights Reserved
 * @version 2.5.0 <br />
 * - 2.5.0 [2025-04-21]: Cleaned up for using Word Press.
 * - 2.4.0 [2025-04-17]: Adding labels to nav bar and removed services.
 * - 2.3.0 [2025-04-16]: Back to the footer driving the menu. Also made it to
 * where the main domains are the nav bar. Better navigation that way. Lastly
 * made the print, share, and read aloud buttons call into other methods to
 * allow for page overrides with iframes.
 * - 2.2.1 [2025-03-18]: Fix how we hide the web drawer.
 * - 2.2.0 [2025-03-18]: Hide the menu when PWA is loaded.
 * - 2.1.0 [2025-03-17]: Updated footer for less icons.
 * - 2.0.1 [2025-03-15]: Now for bug fixes. First was missing double quote.
 * - 2.0.0 [2025-03-15]: Implemented a new binding with the PWA to open
 * the PWAs drawer or our own drawer if we are not in the PWA via a
 * BroadcastChannel. This will allow smoother nav between the sites if
 * found via search vs. opened in the PWA. Also put the secondary controls
 * on all the domains.
 * - 1.9.1 [2025-01-26]: Fix redirect to avoid redirect security error with
 * host gator. <br />
 * - 1.9.0 [2025-01-25]: Removed embedding logic. We removing google
 * sites. <br />
 */

// ============================================================================
// [Event Handlers] ===========================================================
// ============================================================================

/**
 * Wrapper for the Browser SpeechSynthesisUtterance to read a loaded page.
 */
class CTextToSpeechPlayer {
  /** @type {SpeechSynthesisUtterance} */
  #utterance = new SpeechSynthesisUtterance();

  /**
   * Plays the queued up text to the platform speaker.
   * @returns {void}
   */
  play() {
    this.stop();
    globalThis.speechSynthesis.speak(this.#utterance);
  }

  /**
   * Will pause the currently queued text.
   * @returns {void}
   */
  async pause() {
    if (!globalThis.speechSynthesis.paused) {
      globalThis.speechSynthesis.pause();
    }
  }

  /**
   * Will resume the currently queued text.
   * @returns {void}
   */
  async resume() {
    if (globalThis.speechSynthesis.paused) {
      globalThis.speechSynthesis.resume();
    }
  }

  /**
   * Will cancel any queued up text requiring it to be re-queued.
   * @returns {void}
   */
  async stop() {
    globalThis.speechSynthesis.cancel();
  }

  /**
   * Determine if the text to speech is actively playing or not.
   * @readonly
   * @type {boolean}
   */
  get playing() { return globalThis.speechSynthesis.speaking; }

  /**
   * Determine if the text to speech is actively paused or not.
   * @readonly
   * @type {boolean}
   */
  get paused() { return globalThis.speechSynthesis.paused; }

  /**
   * Sets / gets the pitch for the text-to-speech object. The valid range is
   * (0.0 - 2.0). Anything set outside this range will be set to the min / max
   * of the range.
   * @type {number}
   */
  get pitch() { return this.#utterance.pitch; }
  set pitch(v) {
    this.#utterance.pitch = v < 0.0
      ? 0.0
      : v > 2.0
        ? 2.0
        : v;
  }

  /**
   * Sets / gets the rate for the text-to-speech object. The valid range is
   * (0.1 - 10.0). Anything set outside this range will be set to the min / max
   * of the range.
   * @type {number}
   */
  get rate() { return this.#utterance.rate; }
  set rate(v) {
    this.#utterance.rate = v < 0.1
      ? 0.1
      : v > 10.0
        ? 10.0
        : v;
  }

  /**
   * Sets / gets the volume for the text-to-speech object.  The valid range is
   * (0.0 - 1.0). Anything set outside this range will be set to the min / max
   * of the range.
   */
  get volume() { return this.#utterance.volume; }
  set volume(v) {
    this.#utterance.volume = v < 0.0
      ? 0.0
      : v > 1.0
        ? 1.0
        : v;
  }

  /**
   * Constructor for the object
   * @param {number} id The factory created object.
   * @param {string} source The audio source text to speak.
   */
  constructor(id, source) {
    this.#utterance.text = source;
    this.#utterance.onerror = (evt) => {
      if (!evt.error.includes("interrupted")) {
        console.error("CTextToSpeechPlayer Error = ", evt);
      }
    };
  }
}

/** @type {CTextToSpeechPlayer} */
let _ttsPlayer = undefined;

/**
 * Handles a text-to-speech translation of the page to read the content to the
 * user.
 * @returns {void}
 */
function onReadPageClicked() {
  const btn = document.getElementById("btnTTS");
  if (_ttsPlayer.playing) {
    _ttsPlayer.stop();
    btn.innerHTML = "🗣️";
    btn.title = "Read Page";
  } else {
    _ttsPlayer.play();
    btn.innerHTML = "🛑";
    btn.title = "Stop Reading Page";
  }
}

/**
 * Handles the sharing of the individual page when clicked. So gets the
 * URL and then and calls the navigator share.
 * @param {ShareData?} data The data to share
 * @returns {Promise<boolean>} true if successful, false otherwise. Check the
 * error string for details of the failure.
 */
async function onSharePageClicked() {
  try {
    // It was granted, go perform the copy.
    const isMobile = 'ontouchstart' in window ||
      navigator.maxTouchPoints > 0 ||
      navigator.msMaxTouchPoints > 0
    const tooltip = globalThis.document.getElementById("divTooltip");
    let href = window.location.href.replaceAll("www.", "");
    await globalThis.navigator.clipboard.writeText(href);
    if (!isMobile) {
      tooltip.style.display = "inline-block";
      setTimeout(() => { tooltip.style.display = "none"; }, 750);
    }
  } catch (err) {
    // Something failed, go report it.
    let msg = Object.hasOwn(err, "message")
      ? err.message
      : "unable to perform share";
    console.error("onSharePageClicked()", msg);
    alert(msg);
    return false;
  }
}

/**
 * Handles the print icon click action.
 * @returns {void}
 */
function onPrintPageClicked() {
  window.print();
}

/**
 * Handles the showing / hiding of the disqus_thread widget on the page.
 * @returns {void}
 */
function onDisqusClicked() {
  const a = document.getElementById("anchorDisqus");
  const w = document.getElementById("disqus_thread");
  if (w.style.display == "none") {
    document.body.style.overflow = "hidden";
    w.style.display = "block";
    a.innerHTML = "❌ DISQUS ❌";
  } else {
    document.body.style.overflow = "auto";
    w.style.display = "none";
    a.innerHTML = "💬 DISQUS 💬";
  }
}

/**
 * Handles opening domain navigation link forcing a fresh pool from net to
 * avoid cache.
 * @param {string} url The url to navigate to.
 * @returns {void}
 */
function onDomainNavClicked(url) {
  const navUrl = `${url}?rand=${Math.random()}`;
  window.open(navUrl, "_self");
}

/**
 * Handles the opening of the social links in a new window.
 * @param {string} url The URL to open the social link as a new window.
 * @returns {void}
 */
function onOpenLinkClicked(url) {
  const w = 900;
  const h = 600;
  const top = (window.screen.height - h) / 2;
  const left = (window.screen.width - w) / 2;
  const settings = `toolbar=no, location=no, ` +
    `directories=no, status=no, menubar=no, ` +
    `scrollbars=no, resizable=yes, copyhistory=no, ` +
    `width=${w}, height=${h}, top=${top}, left=${left}`;
  window.open(
    `https://${url}`,
    "_blank",
    settings,
  );
}

/**
 * Will open either the codemelted_navigation menu or the PWA if we are under
 * it.
 * @returns {void}
 */
function onOpenMenuClicked() {
  const divDrawer = document.getElementById("divDrawer");
  const divOverlay = document.getElementById("divOverlay");
  divOverlay.onclick = () => {
    divDrawer.style.display = "none";
    divOverlay.style.display = "none";
  }
  divDrawer.style.display = "block";
  divOverlay.style.display = "block";
}

// ============================================================================
// [HTML Templates] ===========================================================
// ============================================================================

const _htmlTemplate = `
  <!-- Setup the overall style for the page -->
  <style>
    /*
    -------------------------------------------------------------------------------
    [Scrollbars] ------------------------------------------------------------------
    -------------------------------------------------------------------------------
    */

    /* width */
    ::-webkit-scrollbar {
      width: 7px;
      height: 3px;
    }

    /* Track */
    ::-webkit-scrollbar-track {
      background: black;
    }

    /* Handle */
    ::-webkit-scrollbar-thumb {
      background: #888;
    }

    /* Handle on hover */
    ::-webkit-scrollbar-thumb:hover {
      background: #555;
    }

    /*
    -------------------------------------------------------------------------------
    [Footer] ----------------------------------------------------------------------
    -------------------------------------------------------------------------------
    */

    /* Setup the overall footer layout */
    .codemelted-footer {
      border-top: 1px solid red;
      border-bottom: 1px solid red;
      position: fixed;
      width: 100%;
      bottom: 0;
      left: 0;
      background-color: #161E27;
      z-index: 2147483644;
    }

    /* First row of control layouts */
    .codemelted-footer-main-control-layout {
      padding: 5px;
      display: grid;
      grid-template-columns: auto auto;
    }
    .codemelted-footer-main-control-layout div {
      text-align: right;
    }
    .codemelted-footer-main-control-layout a {
      color: white;
      font-size: normal;
      font-weight: bold;
      padding-top: 10px;
      padding-bottom: 5px;
      padding-left: 10px;
      padding-right: 10px;
      text-decoration: none;
      cursor: pointer;
    }

    /* Setup the social control layouts */
    .codemelted-footer-socials-layout {
      border-top: 1px solid red;
      display: grid;
      text-align: center;
      cursor: pointer;
      grid-template-columns: auto auto auto auto;
    }
    .codemelted-footer-socials-layout a {
      text-decoration: none;
      padding-top: 5px;
      padding-bottom: 5px;
      border-right: 1px solid red;
      color: white;
      font-size: smaller;
    }
    .codemelted-footer-socials-layout a:nth-child(4) {
      border: none;
    }
    .codemelted-footer-socials-layout a:hover {
      background-color: blue;
    }
    .codemelted-footer-socials-layout img {
      height: 30px;
    }

    /* Handle mobile touch stickiness with hover. */
    @media only screen and (max-width: 768px) {
      .codemelted-footer-socials-layout a:hover {
        background-color: transparent;
      }
    }

    /* Commenting Disqus Widget */
    #disqus_thread {
      margin-left: 1px;
      margin-right: 1px;
      height: 500px;
      overflow-x: scroll;
      border-bottom: 1px solid red;
      background-color: #161E27;
      color: white;
    }
    :root {
      color-scheme: light;
    }

    /* Setup the print page by hiding unnecessary information */
    @media print {
      #disqus_thread, .codemelted-footer {
        display: none;
      }
    }

    /*
    ---------------------------------------------------------------------------
    [Tooltip] -----------------------------------------------------------------
    ---------------------------------------------------------------------------
    */
    .codemelted-tooltip {
      display: none;
      position: fixed;
      text-align: center;
      background-color: black;
      width: 140px;
      color: white;
      right: 5px;
      bottom: 115px;
      margin-left: -5px;
      border-width: 5px;
      border-style: solid;
      border-color: #555 transparent transparent transparent;
      border-radius: 6px;
      padding: 5px;
      opacity: 0.8;
      z-index: 9999999;
    }

    #divDrawer {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      bottom: 0;
      width: 225px;
      background-color: #161E27;
      color: white;
      z-index: 2147483647;
    }

    #divDrawer ul {
      display: block;
      margin-left: 5px;
      padding: 0;
      list-style: none;
    }

    #divDrawer li {
      padding: 5px;
      font-size: larger;
    }

    #divDrawer a {
      cursor: pointer;
      text-decoration: none;
      color: white;
    }

    #divOverlay {
      position: fixed;
      display: none;
      width: 100%;
      height: 100%;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-color: rgba(0,0,0,0.5);
      z-index: 2147483646;
      cursor: pointer;
    }
  </style>

  <!-- Our Page Drawer -->
  <div id="divDrawer">
    <img style="width: 100%; height: 75px;" src="https://codemelted.com/assets/images/logo-codemelted-twitter.png" />
    <ul>
      <li><a href="https://codemelted.com/services/about-me.html"><img style="height: 25px;" src="https://codemelted.com/assets/images/icon-me.jpg" />&nbsp;&nbsp;&nbsp;About Me</li></a>
      <li><a href="https://codemelted.com/services/github-gists.html"><img style="height: 25px;" src="https://codemelted.com/assets/images/icon-github.png" />&nbsp;&nbsp;&nbsp;GitHub Gists</li></a>
      <li><a href="https://codemelted.com/services/media-player.html"><img style="height: 25px;" src="https://codemelted.com/assets/images/icon-media.png" />&nbsp;&nbsp;&nbsp;Media Player</li></a>
      <li><a href="https://codemelted.com/services/presentations.html"><img style="height: 25px;" src="https://codemelted.com/assets/images/icon-education.png" />&nbsp;&nbsp;&nbsp;Presentations</li></a>
      <li><a href="https://codemelted.com/services/uml-modeler.html"><img style="height: 25px;" src="https://codemelted.com/assets/images/icon-uml.png" />&nbsp;&nbsp;&nbsp;UML Modeler</li></a>
    </ul>
  </div>
  <div id="divOverlay"></div>

  <!-- Footer for all codemelted.com domain content -->
  <div id="divTooltip" class="codemelted-tooltip">URL Copied!</div>
  <div class="codemelted-footer">
    <div style="display: none;" id="disqus_thread"></div>
    <div class="codemelted-footer-main-control-layout">
      <div><a class="codemelted-nav-control" id="anchorDisqus" onclick="onDisqusClicked(); return false;">💬 DISQUS 💬</a></div>
      <div id="divPageOptions">
        <a class="codemelted-nav-control" id="btnTTS" title="Read Page" onclick="onReadPageClicked(); return false;" >🗣️</a>
        <a class="codemelted-nav-control" id="btnSharePage" title="Share Page" onclick="onSharePageClicked(); return false;" >🔗</a>
        <a class="codemelted-nav-control" id="btnPrintPage" title="Print Page" onclick="onPrintPageClicked(); return false;">🖨️</a>
      </div>
    </div>
    <div id="divFeatures" class="codemelted-footer-socials-layout">
      <a class="codemelted-nav-control" id="aOpenPWA"     title="Open Menu"               onclick="onOpenMenuClicked(); return false;" ><img src="https://codemelted.com/assets/favicon/apple-touch-icon.png" /><br />START</a>
      <a class="codemelted-nav-control" id="aBlog"        title="Blog"                    onclick="onDomainNavClicked('https://codemelted.com/blog/index.html'); return false;"><img src="https://codemelted.com/assets/images/icon-blog.png" /><br />BLOG</a>
      <a class="codemelted-nav-control" id="aDeveloper"   title="CodeMelted DEV Project"  onclick="onDomainNavClicked('https://codemelted.com/developer/index.html'); return false;"><img src="https://codemelted.com/assets/images/icon-code.png" /><br />DEV</a>
      <a class="codemelted-nav-control" id="aPhotography" title="Photography"             onclick="onDomainNavClicked('https://codemelted.com/photography/index.html'); return false;"><img src="https://codemelted.com/assets/images/icon-camera.png" /><br />PHOTOS</a>
    </div>
  </div>
`;

// ============================================================================
// [Component Definition] =====================================================
// ============================================================================

/**
 * Sets up the overall navigation component.
 */
class CodeMeltedNavigation extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.innerHTML = _htmlTemplate;
  }
}

// Register our component with the DOM
globalThis.customElements.define(
  'codemelted-navigation',
  CodeMeltedNavigation
);

// ============================================================================
// [Main Entry] ===============================================================
// ============================================================================

/**
 * Kicks off asynchronously so once the page is loaded it can properly
 * configure items.
 */
async function main() {
  setTimeout(() => {
    // Setup our Text-To-Speech
    const source = document.body.innerText;
    _ttsPlayer = new CTextToSpeechPlayer(0, source);

    // Highlight the "active" button
    let aList = [
      document.getElementById("aDeveloper"),
      document.getElementById("aPhotography"),
      document.getElementById("aBlog"),
    ];
    if (window.location.href.includes("/developer/")) {
      aList[0].style.backgroundColor = "maroon";
    } else if (window.location.href.includes("/photography/")) {
      aList[1].style.backgroundColor = "maroon";
    } else if (window.location.href.includes("/blog/")) {
      aList[2].style.backgroundColor = "maroon";
    } else {
      console.warn("aList did not have an active bottom navigation!");
    }

    // Setup disqus comment registration
    let disqus_config = function () {
      this.page.title = window.title;
      this.page.url = window.href;
    };
    (function() { // DON'T EDIT BELOW THIS LINE
      let d = document, s = d.createElement('script');
      s.src = 'https://codemelted.disqus.com/embed.js';
      s.setAttribute('data-timestamp', +new Date());
      (d.head || d.body).appendChild(s);
    })();
  }, 500);
}
main();