// @ts-check
/**
 * @license MIT
 *
 * (C) 2024 Mark Shaffer. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the “Software”),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

// ----------------------------------------------------------------------------
// [Data Definitions] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * The object that results from the codemelted.fetch() function call.
 * @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Blob
 * @see https://developer.mozilla.org/en-US/docs/Web/API/FormData
 * @typedef {object} CFetchResult
 * @property {any} data something
 * @property {number} status something
 * @property {string} statusText something
 * @property {FormData?} asFormData something
 * @property {Blob?} asBlob something
 */

// ----------------------------------------------------------------------------
// [Public API Implementation] ------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Something....
 */
export class codemelted {
    /**
     * DO NOT INSTANTIATE. This class is the main interface into this module.
     * It is constructed of static methods and properties.
     */
    constructor() {
        throw new SyntaxError("Static utility interface. Do not instantiate.");
    }

    // ------------------------------------------------------------------------
    // [App View Implementation] ----------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Async IO Implementation] ----------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Audio Player Implementation] ------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Console Implementation] -----------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Database Implementation] ----------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Data Broker Implementation] -------------------------------------------
    // ------------------------------------------------------------------------

    /**
     * Determines if the specified object has the specified property.
     * @param {object} obj The object to check.
     * @param {string} key The property to find.
     * @returns {boolean} true if property was found, false otherwise.
     */
    static checkHasProperty(obj, key) {
        return Object.hasOwn(obj, key);
    }

    /**
     * Utility to check parameters of a function to ensure they are of an
     * expected type.
     * @param {string | any} type
     * @param {any} v The parameter to be checked.
     * @param {number} [count] Checks the v parameter function signature
     * to ensure the appropriate number of parameters are specified.
     * @returns {boolean} true if it meets the expectations, false otherwise.
     */
    static checkType(type, v, count = undefined) {
        const isExpectedType = typeof type !== "string"
            ? (v instanceof type)
            // deno-lint-ignore valid-typeof
            : typeof v === type;
        return typeof count === "number"
            ? isExpectedType && v.length === count
            : isExpectedType;
    }

    /**
     * Checks for a valid URL.
     * @param {string} v String to parse to see if it is a valid URL.
     * @returns {boolean} true if valid, false otherwise.
     */
    static checkValidUrl(v) {
        let url = undefined;
        try {
            url = new URL(v);
        } catch (_ex) {
            url = undefined;
        }
        return codemelted.checkType(URL, url);
    }

    /**
     * Converts a string to a JavaScript object.
     * @param {string} data The data to parse.
     * @returns {object | null} Object or null if the parse failed.
     */
    static jsonParse(data) {
        try {
            return JSON.parse(data);
        } catch (_ex) {
            return null;
        }
    }

    /**
     * Converts a JavaScript object into a string.
     * @param {object} data An object with valid JSON attributes.
     * @returns {string | null} The string representation or null if the
     * stringify failed.
     */
    static jsonStringify(data) {
        try {
            return JSON.stringify(data);
        } catch (_ex) {
            return null;
        }
    }

    /**
     * Determines if the specified object has the specified property.
     * @param {object} obj The object to check.
     * @param {string} key The property to find.
     * @returns {void}
     * @throws {SyntaxError} if the property is not found.
     */
    static tryHasProperty(obj, key) {
        if (!codemelted.checkHasProperty(obj, key)) {
            throw new SyntaxError(`${obj} does not have property ${key}`);
        }
    }

    /**
     * Utility to check parameters of a function to ensure they are of an
     * expected type.
     * @param {string | any} type
     * @param {any} v The parameter to be checked.
     * @param {number} [count] Checks the v parameter function signature
     * to ensure the appropriate number of parameters are specified.
     * @returns {void}
     * @throws {SyntaxError} if the type was not as expected
     */
    static tryType(type, v, count = undefined) {
        if (!codemelted.checkType(type, v, count)) {
            throw new SyntaxError(
                `${v} parameter is not of type ${type} or does not ` +
                `contain expected ${count} for function`
            );
        }
    }

    /**
     * Checks for a valid URL.
     * @param {string} v String to parse to see if it is a valid URL.
     * @returns {void}
     * @throws {SyntaxError} If v is not a valid url.
     */
    static tryValidUrl(v) {
        if (!codemelted.checkValidUrl(v)) {
            throw new SyntaxError(`'${v}' is not a valid url`);
        }
    }

    // ------------------------------------------------------------------------
    // [Device Orientation Implementation] ------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Dialog Implementation] ------------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Disk Manager Implementation] ------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Fetch Implementation] -------------------------------------------------
    // ------------------------------------------------------------------------

    /**
     * provides the ability to interact with server REST API endpoints to
     * retrieve and manage data.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Headers
     * @param {object} params Set of named parameters to support the
     * chosen action.
     * @param {string} params.action "delete", "get", "post", "put"
     * @param {string} params.url The URL that hosts the given REST API or resource
     * @param {object} [params.body] Optional information needed for the request
     * @param {object} [params.headers] Data to append as part of the request
     * @returns {Promise<CFetchResult>} The result of the completed
     * transaction
     */
    static async fetch({
        action = "",
        url = "",
        body = undefined,
        headers = undefined,
    }) {
        try {
            if (action !== "delete" && action !== "get" &&
                action !== "post" && action !== "put") {
                throw new SyntaxError(
                    `codemelted.fetch(): received invalid [action] ` +
                    `${action}`
                );
            }

            // Form the options we need for the fetch
            const options = {
                method: action.toUpperCase(),
            };
            if (headers) {
                // @ts-ignore headers are attached if specified.
                options["headers"] = headers;
            }
            if (body) {
                // @ts-ignore body is attached if specified.
                options["body"] = body;
            }

            // Now go do the fetch to form the return data
            const resp = await fetch(url, options);
            const contentType = resp.headers.get("Content-Type") ?? "";
            const status = resp.status;
            const statusText = resp.statusText;
            const data = contentType.includes("application/json")
                ? await resp.json()
                : contentType.includes("form-data")
                    ? await resp.formData()
                    : contentType.includes("application/octet-stream")
                        ? await resp.blob()
                        : contentType.includes("text/")
                            ? await resp.text()
                            : "";

            return {
                data: data,
                status: status,
                statusText: statusText,
                asBlob: data instanceof Blob ? data : null,
                asFormData: data instanceof FormData ? data : null,
            }
        } catch (ex) {
            return {
                data: null,
                status: 500,
                statusText: ex instanceof Error
                    ? ex.message
                    : "unknown error occurred",
                asBlob: null,
                asFormData: null,
            };
        }
    }

    // ------------------------------------------------------------------------
    // [Hardware Peripheral Implementation] -----------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Link Opener Definition] -----------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Logger Implementation] ------------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Math Implementation] --------------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Network Socket Implementation] ----------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Runtime Implementation] -----------------------------------------------
    // ------------------------------------------------------------------------

    /**
     * Adds an event listener either to the global object or to the specified
     * event target.
     * @param {object} params The named parameters for this method.
     * @param {string} params.type A case-sensitive string representing the
     * event type to listen for.
     * @param {EventListener} params.listener Callback function to handle the
     * event fired with optional receipt of an event object.
     * @param {EventTarget} [params.obj] The optional
     */
    static addEventListener({
        type,
        listener,
        obj,
    }) {
        codemelted.tryType("string", type);
        codemelted.tryType("function", listener);
        if (!obj) {
            globalThis.addEventListener(type, listener);
        } else {
            obj.addEventListener(type, listener);
        }
    }

    /**
     * Prints an HTML document.
     *
     * SUPPORTED RUNTIMES: web
     * @returns {void}
     */
    static print() {
        codemelted.tryHasProperty(globalThis, "print");
        // @ts-ignore In web context, print will exist.
        globalThis.print();
    }

    // ------------------------------------------------------------------------
    // [Share Implementation] -------------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Storage Implementation] -----------------------------------------------
    // ------------------------------------------------------------------------

    /**
     * Sets a key / value pair with the local storage.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
     * @param {string} key The key to associate with the value.
     * @param {string} value The value to store.
     * @returns {void}
     */
    static storageSet(key, value) {
        codemelted.tryType("string", key);
        codemelted.tryType("string", value);
        globalThis.localStorage.setItem(key, value);
    }

    /**
     * Gets a value associated with a key from local storage.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
     * @param {string} key The key to retrieve.
     * @returns {string | null} The string value or null if not found.
     */
    static storageGet(key) {
        codemelted.tryType("string", key);
        return globalThis.localStorage.getItem(key);
    }

    /**
     * Removes the key / value pair from local storage.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
     * @param {string} key The key to associate with the value.
     * @returns {void}
     */
    static storageRemove(key) {
        codemelted.tryType("string", key);
        globalThis.localStorage.removeItem(key);
    }

    /**
     * Clears the local storage of the runtime.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
     * @returns {void}
     */
    static storageClear() {
        globalThis.localStorage.clear();
    }

    // ------------------------------------------------------------------------
    // [Themes Implementation] ------------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Web RTC Implementation] -----------------------------------------------
    // ------------------------------------------------------------------------

    // TBD

    // ------------------------------------------------------------------------
    // [Widgets Implementation] -----------------------------------------------
    // ------------------------------------------------------------------------

    // TBD
}
