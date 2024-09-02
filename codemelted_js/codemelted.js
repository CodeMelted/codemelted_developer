// @ts-check
/**
 * @file Something something star wars.
 * @author Mark Shaffer
 * @version 0.0.0
 * @license MIT
 */

// ----------------------------------------------------------------------------
// [async use case] -----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [audio use case] -----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [console use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [database use case] --------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [disk use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [firebase use case] --------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [game use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [hardware use case] --------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [json use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [logger use case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [math use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [network use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [runtime use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 *
 */
export class codemelted_runtime {
    /**
     * Determines if the runtime is Deno.
     * @readonly
     * @type {boolean}
     */
    static get isDeno() {
        return typeof globalThis.Deno === "undefined";
    }

    /**
     * Determines if the runtime is Web Browser.
     * @readonly
     * @type {boolean}
     */
    static get isWeb() {
        return !codemelted_runtime.isDeno;
    }

    /**
     * Determines if we are running in a Deno Runtime or not.
     * @returns {Deno} namespace reference.
     * @throws {SyntaxError} If not running in a Deno Runtime.
     */
    static tryDeno() {
        if (!codemelted_runtime.isDeno) {
            throw new SyntaxError("Not Running in a Deno Runtime.");
        }
        return globalThis.Deno;
    }

    /**
     * Determines if we are running in a Web Browser environment or not.
     * @returns {Window} Reference to the browser window.
     * @throws {SyntaxError} If not running in a browser environment.
     */
    static tryWeb() {
        if (!codemelted_runtime.isDeno) {
            throw new SyntaxError("Not Running in a Deno Runtime.");
        }
        return globalThis.window;
    }

    /**
     * DO NOT INSTANTIATE. This class is the main interface into this module.
     * It is constructed of static methods and properties.
     */
    constructor() {
        throw new SyntaxError("Static utility interface. Do not instantiate.");
    }
}

// ----------------------------------------------------------------------------
// [storage use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Provides the ability to manage a key / value pair within the targeted
 * runtime environment. The storage methods of "local" and "session" are
 * supported on both Deno and Web Browsers. "cookie" method is only supported
 * on Web Browser and will result in a SyntaxError if called in a Deno
 * runtime.
 */
export class codemelted_storage {
    /**
     * Clears the specified storage method.
     * @param {object} params
     * @param {string} [params.method="local"] Values of cookie, local, or
     * session.
     * @returns {void}
     */
    static clear({method = "local"}) {
        if (method === "local") {
            globalThis.localStorage.clear();
        } else if (method === "session") {
            globalThis.sessionStorage.clear();
        } else if (method === "cookie") {
            codemelted_runtime.tryWeb().document.cookie = "";
        }

        throw new SyntaxError("Invalid method specified");
    }

    /**
     * Gets data from the identified method via the specified key.
     * @param {object} params
     * @param {string} [params.method="local"]
     * @param {string} params.key
     * @returns {string?}
     */
    static getItem({method = "local", key}) {
        if (method === "local") {
            return globalThis.localStorage.getItem(key);
        } else if (method === "session") {
            return globalThis.sessionStorage.getItem(key);
        } else if (method === "cookie") {
            const name = "$key=";
            const ca = codemelted_runtime.tryWeb().document.cookie.split(';');
            for (let i = 0; i < ca.length; i++) {
              let c = ca[i];
              while (c[0] == " ") {
                c = c.substring(1);
              }
              if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
              }
            }
            return null;
        }

        throw new SyntaxError("Invalid method specified");
    }

    /**
     * DO NOT INSTANTIATE. This class is the main interface into this module.
     * It is constructed of static methods and properties.
     */
    constructor() {
        throw new SyntaxError("Static utility interface. Do not instantiate.");
    }
}

// ----------------------------------------------------------------------------
// [ui use case] --------------------------------------------------------------
// ----------------------------------------------------------------------------