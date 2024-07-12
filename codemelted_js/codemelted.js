// @ts-check
/**
 * @author Mark Shaffer
 * @license MIT
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
 * Defines the version for the module.
 */
const _version = "X.Y.Z (Last Updated yyyy-dd-mm)";

/**
 * The object that results from the codemelted.fetch function call.
 * @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Blob
 * @see https://developer.mozilla.org/en-US/docs/Web/API/FormData
 */
export class CFetchResult {
    /** @type {any} */
    #data = undefined;
    /** @type {number} */
    #status = -1;
    /** @type {string} */
    #statusText = "";

    /**
     * Data captured with request.
     * @readonly
     * @type {any}
     */
    get data() { return this.#data; }

    /**
     * The HTTP status code of the request.
     * @readonly
     * @type {number}
     */
    get status() { return this.#status; }

    /**
     * Any text associated with the request.
     * @readonly
     * @type {string}
     */
    get statusText() { return this.#statusText; }

    /**
     * Gets the data as a Blob reference if it is a Blob.
     * @readonly
     * @type {Blob?}
     */
    get asBlob() {
        return this.#data instanceof Blob
            ? this.#data
            : null;
    }

    /**
     * Gets the data as a FormData reference if it is a FormData.
     * @readonly
     * @type {FormData?}
     */
    get asFormData() {
        return this.#data instanceof FormData
            ? this.#data
            : null;
    }

    /**
     * Constructor for the class.
     * @param {any} data The data from the request.
     * @param {number} status The status code of the request.
     * @param {string} statusText Any text associated with the request.
     */
    constructor(data, status, statusText) {
        this.#data = data;
        this.#status = status;
        this.#statusText = statusText;
    }
}

// ----------------------------------------------------------------------------
// [Public API Implementation] ------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Implements the CodeMelted - Developer identified use cases to support the
 * Deno / Web runtimes. It leverages pure JavaScript with the power of JSDoc
 * and generated TypeScript types to leverage both developer environments
 * to catch bugs early and often.
 */
export class codemelted {
    /**
     * DO NOT INSTANTIATE. This class is the main interface into this module.
     * It is constructed of static methods and properties.
     */
    constructor() {
        throw new SyntaxError("Static utility interface. Do not instantiate.");
    }

    /**
     * The current version of the module.
     * @readonly
     * @type {string}
     */
    static get version() { return _version; }

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
     * @param {object} params The named parameters.
     * @param {object} params.obj The object to check for the key.
     * @param {string} params.key The property to check for.
     * @returns {boolean} true if property was found, false otherwise.
     */
    static checkHasProperty({obj, key}) {
        return Object.hasOwn(obj, key);
    }

    /**
     * Utility to check parameters of a function to ensure they are of an
     * expected type.
     * @param {object} params The named parameters.
     * @param {string | any} params.type The specified type to check the data
     * against.
     * @param {any} params.data The parameter to be checked.
     * @param {number} [params.count] Checks the data parameter function
     * signature to ensure the appropriate number of parameters are
     * specified.
     * @returns {boolean} true if it meets the expectations, false otherwise.
     */
    static checkType({type, data, count = undefined}) {
        const isExpectedType = typeof type !== "string"
            ? (data instanceof type)
            // deno-lint-ignore valid-typeof
            : typeof data === type;
        return typeof count === "number"
            ? isExpectedType && data.length === count
            : isExpectedType;
    }

    /**
     * Checks for a valid URL.
     * @param {object} params The named parameters.
     * @param {string} params.data String to parse to see if it is a valid URL.
     * @returns {boolean} true if valid, false otherwise.
     */
    static checkValidUrl({data}) {
        let url = undefined;
        try {
            url = new URL(data);
        } catch (_ex) {
            url = undefined;
        }
        return codemelted.checkType({type: URL, data: url});
    }

    /**
     * Converts a string to a JavaScript object.
     * @param {object} params The named parameters.
     * @param {string} params.data The data to parse.
     * @returns {object | null} Object or null if the parse failed.
     */
    static jsonParse({data}) {
        try {
            return JSON.parse(data);
        } catch (_ex) {
            return null;
        }
    }

    /**
     * Converts a JavaScript object into a string.
     * @param {object} params The named parameters.
     * @param {object} params.data An object with valid JSON attributes.
     * @returns {string | null} The string representation or null if the
     * stringify failed.
     */
    static jsonStringify({data}) {
        try {
            return JSON.stringify(data);
        } catch (_ex) {
            return null;
        }
    }

    /**
     * Determines if the specified object has the specified property.
     * @param {object} params The named parameters.
     * @param {object} params.obj The object to check for the key.
     * @param {string} params.key The property to check for.
     * @returns {void}
     * @throws {SyntaxError} if the property is not found.
     */
    static tryHasProperty({obj, key}) {
        if (!codemelted.checkHasProperty({obj: obj, key: key})) {
            throw new SyntaxError(`${obj} does not have property ${key}`);
        }
    }

    /**
     * Utility to check parameters of a function to ensure they are of an
     * expected type.
     * @param {object} params The named parameters.
     * @param {string | any} params.type he specified type to check the data
     * against.
     * @param {any} params.data The parameter to be checked.
     * @param {number} [params.count] Checks the data parameter function
     * signature to ensure the appropriate number of parameters are
     * specified.
     * @returns {void}
     * @throws {SyntaxError} if the type was not as expected
     */
    static tryType({type, data, count = undefined}) {
        if (!codemelted.checkType({type: type, data: data, count: count})) {
            throw new SyntaxError(
                `${data} parameter is not of type ${type} or does not ` +
                `contain expected ${count} for function`
            );
        }
    }

    /**
     * Checks for a valid URL.
     * @param {object} params The named parameters.
     * @param {string} params.data String to parse to see if it is a valid URL.
     * @returns {void}
     * @throws {SyntaxError} If v is not a valid url.
     */
    static tryValidUrl({data}) {
        if (!codemelted.checkValidUrl({data: data})) {
            throw new SyntaxError(`'${data}' is not a valid url`);
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

            return new CFetchResult(data, status, statusText);
        } catch (ex) {
            return new CFetchResult(
                null,
                500,
                ex instanceof Error
                    ? ex.message
                    : "unknown error occurred",
            );
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
     * @param {EventTarget} [params.obj] The optional EventTarget to attach
     * the event vs. globalThis event listener.
     */
    static addEventListener({
        type,
        listener,
        obj,
    }) {
        codemelted.tryType({type: "string", data: type});
        codemelted.tryType({type: "function", data: listener});
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
        codemelted.tryHasProperty({obj: globalThis, key: "print"});
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
     * @param {object} params The named parameters for this method.
     * @param {string} params.key The key to associate with the value.
     * @param {string} params.value The value to store.
     * @returns {void}
     */
    static storageSet({key, value}) {
        codemelted.tryType({type: "string", data: key});
        codemelted.tryType({type: "string", data: value});
        globalThis.localStorage.setItem(key, value);
    }

    /**
     * Gets a value associated with a key from local storage.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
     * @param {object} params The named parameters for this method.
     * @param {string} params.key The key to retrieve.
     * @returns {string | null} The string value or null if not found.
     */
    static storageGet({key}) {
        codemelted.tryType({type: "string", data: key});
        return globalThis.localStorage.getItem(key);
    }

    /**
     * Removes the key / value pair from local storage.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
     * @param {object} params The named parameters for this method.
     * @param {string} params.key The key to associate with the value.
     * @returns {void}
     */
    static storageRemove({key}) {
        codemelted.tryType({type: "string", data: key});
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
