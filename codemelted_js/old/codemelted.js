/**
 * @file Something about the file
 * @version 0.0.0 [Last Updated YYYY-mm-dd]
 * @copyright © 2024 Mark Shaffer. All Rights Reserved
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

// ============================================================================
// [Use Case Support Definitions] =============================================
// ============================================================================

// ----------------------------------------------------------------------------
// [App View Definition] ------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Async IO Definition] ------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Audio Player Definition] --------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Console Definition] -------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Database Definition] ------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Data Broker Definition] ---------------------------------------------------
// ----------------------------------------------------------------------------

// No Definitions Necessary for Implementation.

// ----------------------------------------------------------------------------
// [Device Orientation Definition] --------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Dialog Definition] --------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Disk Manager Definition] --------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Fetch Definition] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Named parameters for the codemelted.fetch() function.
 * @typedef CFetchParams
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Headers
 * @property {string} action "beacon", "delete", "get", "post", "put"
 * @property {string} url The URL that hosts the given REST API or resource
 * @property {Headers} [headers] Optional information needed for the request
 * @property {Object} [body] Data to append as part of the request
 */

/**
 * The object that results from the codemelted.fetch() function call.
 * @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Blob
 * @see https://developer.mozilla.org/en-US/docs/Web/API/FormData
 */
export class CFetchResult {
    // Member Fields:
    #data = undefined;
    #status = -1;
    #statusText = "";

    /**
     * Constructor for the class.
     * @param {number} status The status code of the transaction.
     * @param {string} statusText The text associated with the code.
     * @param {any} data The data captured with the request.
     */
    constructor(status, statusText, data) {
        this.#data = data;
        this.#status = status;
        this.#statusText = statusText;
    }

    /**
     * The data retrieved as part of the fetch.
     * @readonly
     * @type {any}
     */
    get data() { return this.#data; }

    /**
     * Will get the data if it is a FormData or null if not that object
     * type.
     * @readonly
     * @type {FormData?}
     */
    get asFormData() {
        return this.#data instanceof FormData ? this.#data : null;
    }

    /**
     * Will get the data if it is a Blob or null if not that object type.
     * @readonly
     * @type {Blob?}
     */
    get asBlob() {
        return this.#data instanceof Blob ? this.#data : null;
    }

    /**
     * The status of the network fetch request.
     * @readonly
     * @type {number}
     */
    get status() { return this.#status; }

    /**
     * The text associated with the network fetch status.
     * @readonly
     * @type {string}
     */
    get statusText() { return this.#statusText; }
}

// ----------------------------------------------------------------------------
// [Hardware Device Definition] -----------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Link Opener Definition] ---------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Optional parameter for the COpenParams to support the additional formatting
 * for the mailto scheme.
 */
export class CMailToParams {
    // Member Fields:
    #mailto = [];
    #cc = [];
    #bcc = [];
    #subject = null;
    #body = null;

    /**
     * Adds an email address to the mailto parameter.
     * @param {string} v The email address.
     * @returns {void}
     */
    addMailTo(v) {
        tryType("string", v);
        this.#mailto.push(v);
    }

    /**
     * Removes an email address from the mailto parameter.
     * @param {string} v The email address.
     * @returns {void}
     */
    removeMailTo(v) { this.#mailto = this.#mailto.filter(v => v !== v); }

    /**
     * Adds an email address to the cc parameter.
     * @param {string} v The email address.
     * @returns {void}
     */
    addCC(v) {
        tryType("string", v);
        this.#cc.push(v);
    }

    /**
     * Removes an email address from the cc parameter.
     * @param {string} v The email address.
     * @returns {void}
     */
    removeCC(v) { this.#cc = this.#bcc.filter(v => v !== v); }

    /**
     * Adds an email address to the bcc parameter.
     * @param {string} v The email address.
     * @returns {void}
     */
    addBCC(v) {
        tryType("string", v);
        this.#bcc.push(v);
    }

    /**
     * Removes an email address from the bcc parameter.
     * @param {string} v The email address.
     * @returns {void}
     */
    removeBCC(v) { this.#bcc = this.#bcc.filter(v => v !== v); }

    /**
     * Sets / gets the subject parameter.
     * @type {string?}
     */
    get subject() { return this.#subject; }
    set subject(v) {
        tryType("string", v);
        this.#subject = v;
    }

    /**
     * Sets / gets the body parameter.
     * @type {string?}
     */
    get body() { return this.#body; }
    set body(v) {
        tryType("string", v);
        this.#body = v;
    }

    /**
     * Formats the mailto protocol represented by the values set in this
     * object.
     * @returns {string}
     */
    toString() {
        let url = "mailto:";
        if (this.#mailto.length === 0) {
            throw new SyntaxError(
                "codemelted.open(): 'mailto' scheme requires mailto " +
                "to be set."
            );
        }

        // Go format the mailto part of the url.
        this.#mailto.forEach((v) => {
            url += `${v};`;
        });
        url = url.substring(0, url.length - 1);

        // Go format the cc part of the url.
        let delimiter = "?";
        if (this.#cc.length > 0) {
            url += `${delimiter}cc=`;
            delimiter = "&";
            this.#cc.forEach((v) => {
                url += `${v};`;
            });
            url = url.substring(0, url.length - 1);
        }

        // Go format the bcc part of the url.
        if (this.#bcc.length > 0) {
            url += `${delimiter}bcc=`;
            delimiter = "&";
            this.#bcc.forEach((v) => {
                url += `${v};`;
            });
            url = url.substring(0, url.length - 1);
        }

        // Go format the subject part of the url.
        if (this.#subject.trim() !== "") {
            url += `${delimiter}subject=${this.#subject}`;
            delimiter = "&";
        }

        // Go format the body part of the url.
        if (this.#body.trim() !== "") {
            url += `${delimiter}body=${this.#body}`;
            delimiter = "&";
        }

        return url;
    }

    constructor() {}
}

/**
 * Named parameters for the codemelted.open() function.
 * @typedef COpenParams
 * @property {string} scheme "http", "https", "mailto", "tel", "sms"
 * @property {string} [url] The formatted url value associated with the
 * specified scheme. You do not need to include the scheme in the url. This
 * is required for all schemes except mailto if the mailtoParams is specified.
 * @property {CMailToParams} [mailtoParams] Optional object to assist in
 * constructing of the mailto scheme url. Do not specify the url parameter
 * if utilizing this option.
 * @property {boolean} [isPopup=false] Specify whether to open this as a popup
 * window or leave it up to the open facility.
 * @property {string} [target] Target for browser context as '_self',
 * '_blank', '_parent', and '_top'.
 * @property {string} [width] Width of the popup window.
 * @property {string} [height] Height of the popup window.
 */

// ----------------------------------------------------------------------------
// [Logger Definition] --------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Utility class to facilitate the module's logging utility.
 * @private
 */
class CLogLevel {
    /**
     * @readonly
     * @type {number}
     */
    static get debug() { return  0; }

    /**
     * @readonly
     * @type {number}
     */
    static get info() { return 1; }

    /**
     * @readonly
     * @type {number}
     */
    static get warning() { return 2; }

    /**
     * @readonly
     * @type {number}
     */
    static get error() { return 3; }

    /**
     * @readonly
     * @type {number}
     */
    static get off() { return 4; }

    /**
     * Utility to determine if the event can be logged or not.
     * @param {number} currentLogLevel Current module log level.
     * @param {number} eventLogLevel Event log level.
     * @returns {bool} true it can be logged, false otherwise.
     */
    static canLog(currentLogLevel, eventLogLevel) {
        if (currentLogLevel === CLogLevel.off) {
            return false;
        }
        return eventLogLevel >= currentLogLevel;
    }

    /**
     * Translates the number to the enumerated string.
     * @param {number} v The number to translate.
     * @returns {string} DEBUG, INFO, WARNING, ERROR, OFF
     */
    static getLabel(v) {
        if (v === CLogLevel.debug) {
            return "debug";
        } else if (v === CLogLevel.info) {
            return "info";
        } else if (v === CLogLevel.warning) {
            return "warning";
        } else if (v === CLogLevel.error) {
            return "error";
        }
        return "off"
    }

    /**
     * Retrieves the corresponding log level based on the string.
     * @param {string} v The string representation of the log level.
     * @returns {number}
     * @throws {SyntaxError} If the log level specified in not
     * an expected string representation of the log level.
     */
    static getLevel(v) {
        if (v.toLowerCase() === "debug") {
            return CLogLevel.debug;
        } else if (v.toLowerCase() === "info") {
            return CLogLevel.info;
        } else if (v.toLowerCase() === "warning") {
            return CLogLevel.warning;
        } else if (v.toLowerCase() === "error") {
            return CLogLevel.error;
        }
        throw new SyntaxError(
            `${v} is not a valid codemelted.logLevel`
        );
    }
}

/**
 * Supports the codemelted.onLogEvent callback handler for post processing
 * events logged.
 */
export class CLogRecord {
    // Member Fields:
    #time = undefined;
    #level = "";
    #data = undefined;

    /**
     * The time of the event.
     * @readonly
     * @type {Date}
     */
    get time() { return this.#time; }

    /**
     * The log level of the event.
     * @readonly
     * @type {string}
     */
    get level() { return this.#level; }

    /**
     * The data captured with the logged event.
     * @readonly
     * @type {any}
     */
    get data() { return this.#data; }

    /**
     * Constructor for the class.
     * @param {number} level The CLogLevel.XXX constant of the log event.
     * @param {any} data The data associated with the logged event.
     */
    constructor(level, data) {
        this.#time = new Date();
        this.#level = CLogLevel.getLabel(level);
        this.#data = data;
    }
}

/**
 * A log handler for further processing of a logged event.
 * @callback CLogHandler
 * @param {CLogRecord} record The record logged.
 */

// Module fields to support module logging facility.
let _logLevel = CLogLevel.error;
let _onLoggedEvent = undefined;

// ----------------------------------------------------------------------------
// [Math Definition] ----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Network Socket Definition] ------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Runtime Definition] -------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Supports the CRuntimeParams for the codemelted.addEventListener() and
 * function codemelted.removeEventListener() functions.
 * @callback CHtmlEventHandler
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Event
 * @param {Event} e The Event object that is being handled.
 */

/**
 * Named parameters for the codemelted.addEventListener() and
 * codemelted.removeEventListener() functions.
 * @typedef CHtmlEventParams
 * @property {string} type The type of event handler to add / remove
 * @property {CHtmlEventHandler} handler The event handler for the event.
 * @property {HTMLElement} [obj] The object to add / remove the event listener
 * or don't specify to add / remove to the general globalThis object.
 */

// ----------------------------------------------------------------------------
// [Share Definition] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * The results of the codemelted.share() function.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share
 */
export class CShareResult {
    // Member Fields:
    #status = undefined;
    #message = undefined;

    /**
     * The share was successful.
     * @readonly
     * @type {number}
     */
    static get success() { return 0; }

    /**
     * The user canceled the share operation or there are no share targets
     * available.
     * @readonly
     * @type {number}
     */
    static get abort() { return 1; }

    /**
     * There was a problem starting the share target or transmitting the data.
     * The specified share data cannot be validated.
     * @readonly
     * @type {number}
     */
    static get dataIssue() { return 2; }

    /**
     * The document is not fully active, or other sharing operations are in
     * progress.
     * @readonly
     * @type {number}
     */
    static get invalidState() { return 3; }

    /**
     * The user canceled the share operation or there are no share targets
     * available.
     * @readonly
     * @type {number}
     */
    static get notAllowed() { return 4; }

    /**
     * Unknown error encountered.
     * @readonly
     * @type {number}
     */
    static get unknown() { return 5; }

    /**
     * Provides the status of the transaction. The codes are constants on this
     * object.
     * @readonly
     * @type {number}
     */
    get status() { return this.#status; }

    /**
     * Provides the message associated with any status code that is not 0.
     * @readonly
     * @type {string}
     */
    get message() { return this.#message; }

    /**
     * Constructor for the share result.
     * @param {Error | undefined} ex Any error associated with the share.
     */
    constructor(ex = undefined) {
        if (!ex) {
            this.#status = CShareResult.success;
            this.#message = "";
        } else if (ex instanceof TypeError) {
            this.#status = CShareResult.dataIssue;
            this.#message = ex.message;
        } else if (ex instanceof DOMException) {
            if (ex.name.includes("AbortError")) {
                this.#status = CShareResult.abort;
            } else if (ex.name.includes("DataError")) {
                this.#status = CShareResult.dataIssue;
            } else if (ex.name.includes("InvalidStateError")) {
                this.#status = CShareResult.invalidState;
            } else if (ex.name.includes("NotAllowedError")) {
                this.#status = CShareResult.notAllowed;
            } else {
                this.#status = CShareResult.unknown;
            }
            this.#message = ex.toString();
        }
    }
}

// ----------------------------------------------------------------------------
// [Storage Definition] -------------------------------------------------------
// ----------------------------------------------------------------------------

// No Definitions Necessary for Implementation.

// ----------------------------------------------------------------------------
// [Themes Definition] --------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Web RTC Definition] -------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Widgets Definition] -------------------------------------------------------
// ----------------------------------------------------------------------------


// ============================================================================
// [Main API Implementation] ==================================================
// ============================================================================

/**
 * Say something about the module.
 * @module codemelted
 */
export default Object.freeze({
    // ------------------------------------------------------------------------
    // [App View Implementation] ----------------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Async IO Implementation] ----------------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Audio Player Implementation] ------------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Console Implementation] -----------------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Database Implementation] ----------------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Data Broker Implementation] -------------------------------------------
    // ------------------------------------------------------------------------

    /**
     * Determines if the specified object has the specified property.
     * @function
     * @param {object} obj The object to check.
     * @param {string} key The property to find.
     * @returns {boolean} true if property was found, false otherwise.
     */
    checkHasProperty(obj, key) {
        return Object.hasOwn(obj, key);
    },

    /**
     * Utility to check parameters of a function to ensure they are of an
     * expected type.
     * @function
     * @param {string | any} type
     * @param {any} v The parameter to be checked.
     * @param {number} [count] Checks the v parameter function signature
     * to ensure the appropriate number of parameters are specified.
     * @returns {boolean} true if it meets the expectations, false otherwise.
     */
    checkType(type, v, count = undefined) {
        const isExpectedType = typeof type !== "string"
            ? (v instanceof type)
            // deno-lint-ignore valid-typeof
            : typeof v === type;
        return typeof count === "number"
            ? isExpectedType && v.length === count
            : isExpectedType;
    },

    /**
     * Checks for a valid URL.
     * @function
     * @param {string} v String to parse to see if it is a valid URL.
     * @returns {boolean} true if valid, false otherwise.
     */
    checkValidUrl(v) {
        let url = undefined;
        try {
            url = new URL(v);
        } catch (_err) {
            url = undefined;
        }
        return this.checkType(URL, url);
    },

    /**
     * Converts a string to a JavaScript object.
     * @function
     * @param {string} data The data to parse.
     * @returns {object | null} Object or null if the parse failed.
     */
    jsonParse(data) {
        try {
            return JSON.parse(data);
        } catch (ex) {
            return null;
        }
    },

    /**
     * Converts a JavaScript object into a string.
     * @function
     * @param {object} data An object with valid JSON attributes.
     * @returns {string | null} The string representation or null if the
     * stringify failed.
     */
    jsonStringify(data) {
        try {
            return JSON.stringify(data);
        } catch (ex) {
            return null;
        }
    },

    /**
     * Determines if the specified object has the specified property.
     * @function
     * @param {object} obj The object to check.
     * @param {string} key The property to find.
     * @returns {void}
     * @throws {SyntaxError} if the property is not found.
     */
    tryHasProperty(obj, key) {
        if (!this.checkHasProperty(obj, key)) {
            throw new SyntaxError(`${obj} does not have property ${key}`);
        }
    },

    /**
     * Utility to check parameters of a function to ensure they are of an
     * expected type.
     * @function
     * @param {string | any} type
     * @param {any} v The parameter to be checked.
     * @param {number} [count] Checks the v parameter function signature
     * to ensure the appropriate number of parameters are specified.
     * @returns {void}
     * @throws {SyntaxError} if the type was not as expected
     */
    tryType(type, v, count = undefined) {
        if (!this.checkType(type, v, count)) {
            throw new SyntaxError(
                `${v} parameter is not of type ${type} or does not ` +
                `contain expected ${count} for function`
            );
        }
    },

    /**
     * Checks for a valid URL.
     * @function
     * @param {string} v String to parse to see if it is a valid URL.
     * @returns {void}
     * @throws {SyntaxError} If v is not a valid url.
     */
    tryValidUrl(v) {
        if (!this.isValidUrl(v)) {
            throw new SyntaxError(`'${v}' is not a valid url`);
        }
    },

    // ------------------------------------------------------------------------
    // [Device Orientation Implementation] ------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Dialog Implementation] ------------------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Disk Manager Implementation] ------------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Fetch Implementation] -------------------------------------------------
    // ------------------------------------------------------------------------

    /**
     * provides the ability to interact with server REST API endpoints to
     * retrieve and manage data.
     *
     * SUPPORTED RUNTIMES: deno / web
     *
     * @see https://developer.mozilla.org/en-US/docs/Web/API/fetch
     * @function
     * @param {CFetchParams} params Set of named parameters to support the
     * chosen action.
     * @returns {Promise<CFetchResult>} The result of the completed
     * transaction
     */
    async fetch({
        action = undefined,
        url = undefined,
        body = undefined,
        headers = undefined,
    } = {}) {
        try {
            this.tryType("string", action);
            this.tryType("string", url);
            if (action === "beacon") {
                if (!globalThis.navigator.sendBeacon) {
                    throw new SyntaxError(
                        "codemelted.fetch(): beacon action not supported " +
                        "on this runtime."
                    );
                }
                const success = globalThis.navigator.sendBeacon(url, body);
                return success
                    ? new CFetchResult(200, "OK")
                    : new CFetchResult(499, "beacon was not queued");
            }

            if (action !== "delete" && action !== "get" &&
                action !== "post" && action !== "put") {
                throw new SyntaxError(
                    `codemelted.fetch(): received invalid [action] ` +
                    `${action}`
                );
            }

            // Form the options we need for the fetch
            const options = {
                method: action.toUpperCase()
            };
            if (headers) {
                options["headers"] = headers;
            }
            if (body) {
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

            return new CFetchResult(status, statusText, data);
        } catch (ex) {
            this.logError(ex);
            return new CFetchResult(
                418,
                this.checkHasProperty(ex, "message")
                    ? ex.message
                    : "unknown error encountered",
                null
            );
        }
    },

    // ------------------------------------------------------------------------
    // [Hardware Device Implementation] ---------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Link Opener Implementation] -------------------------------------------
    // ------------------------------------------------------------------------

    /**
     * Implements the ability to open supported schemes to a browser
     * window either as a popup or new tab. The popup window may
     * not carry out as expected if the browser does not know how to
     * carry out the given request either via a new browser window or
     * service registered with the host operating system.
     *
     * SUPPORTED RUNTIMES: web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Window
     * @function
     * @param {COpenParams} params Named parameters for this function.
     * @returns {boolean} true if successful, false otherwise.
     */
    open({
        scheme = undefined,
        url = undefined,
        mailtoParams = undefined,
        target = undefined,
        width = undefined,
        height = undefined,
    }) {
        // Ensure the function is available. Will only be in a browser
        // context.
        if (!globalThis.open) {
            throw new SyntaxError(
                "codemelted.open(): is not supported on this runtime"
            );
        }

        // Setup our window settings depending on what we are doing.
        const w = width ?? 900;
        const h = height ?? 600;
        const top = (globalThis.screen.height - h) / 2;
        const left = (globalThis.screen.width - w) / 2;
        const settings = `toolbar=no, location=no, ` +
            `directories=no, status=no, menubar=no, ` +
            `scrollbars=no, resizable=yes, copyhistory=no, ` +
            `width=${w}, height=${h}, top=${top}, left=${left}`;

        // Go form our urlString to open.
        let urlString = "";
        if (scheme === "http" || scheme === "https" || scheme === "tel" ||
            scheme === "sms") {
            this.checkType("string", url);
            urlString = scheme === "http" || scheme === "https"
                ? `${scheme}://${url}`
                : `${scheme}:${url}`;
        } else if (scheme === "mailto") {
            if (this.checkType(CMailToParams, mailtoParams)) {
                urlString = mailtoParams.toString();
            } else {
                this.checkType("string", url);
                urlString = `${scheme}:${url}`;
            }
        } else {
            throw new SyntaxError(
                `codemelted.open(): Unsupported scheme ${scheme} specified.`
            );
        }

        // Now go open the browser window.
        try {
            if (!target) {
                window.open(url, "_blank", settings);
            } else {
                window.open(url, target);
            }
            return true;
        } catch (ex) {
            this.logWarning(ex);
            return false;
        }
    },

    // ------------------------------------------------------------------------
    // [Logger Implementation] ------------------------------------------------
    // ------------------------------------------------------------------------

    /**
     * Sets / gets the log level for the module. Utilize the
     * CLogLevel type to define the value.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @type {string}
     */
    get logLevel() { return _logLevel; },
    set logLevel(v) {
        this.tryType("string", v);
        let level = CLogLevel.getLevel(v);
        CLogLevel.tryLogLevel(level);
        _logLevel = level;
    },

    /**
     * Sets / gets the log handler associated with the module
     * logging capability.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @type {CLogHandler?}
     */
    get onLoggedEvent() { return _onLoggedEvent; },
    set onLoggedEvent(v) {
        if (v) {
            this.tryType("function", v, 1);
        }
        _onLoggedEvent = v;
    },

    /**
     * Logs a debug event.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @param {any} data
     * @returns {void}
     */
    logDebug(data) {
        // Check to see if we can log the event.
        if (!CLogLevel.canLog(_logLevel, CLogLevel.debug)) {
            return;
        }

        // We can so go handle it.
        const time = new Date();
        console.log(time.toISOString, "DEBUG", data);
        if (this.onLoggedEvent) {
            this.onLoggedEvent(new CLogRecord(CLogRecord.debug, data));
        }
    },

    /**
     * Logs a info event.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @param {any} data
     * @returns {void}
     */
    logInfo(data) {
        // Check to see if we can log the event.
        if (!CLogLevel.canLog(_logLevel, CLogLevel.info)) {
            return;
        }

        // We can so go handle it.
        const time = new Date();
        console.info(time.toISOString, "INFO", data);
        if (this.onLoggedEvent) {
            this.onLoggedEvent(new CLogRecord(CLogRecord.info, data));
        }
    },

    /**
     * Logs a warning event.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @param {any} data
     * @returns {void}
     */
    logWarning(data) {
        // Check to see if we can log the event.
        if (!CLogLevel.canLog(_logLevel, CLogLevel.warning)) {
            return;
        }

        // We can so go handle it.
        const time = new Date();
        console.warn(time.toISOString, "WARN", data);
        if (this.onLoggedEvent) {
            this.onLoggedEvent(new CLogRecord(CLogRecord.warning, data));
        }
    },

    /**
     * Logs a error event.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @param {any} data
     * @returns {void}
     */
    logError(data) {
        // Check to see if we can log the event.
        if (!CLogLevel.canLog(_logLevel, CLogLevel.error)) {
            return;
        }

        // We can so go handle it.
        const time = new Date();
        console.error(time.toISOString, "ERROR", data);
        if (this.onLoggedEvent) {
            this.onLoggedEvent(new CLogRecord(CLogRecord.error, data));
        }
    },

    // ------------------------------------------------------------------------
    // [Math Implementation] --------------------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Network Socket Implementation] ----------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Runtime Implementation] -----------------------------------------------
    // ------------------------------------------------------------------------

    /**
     * Provides runtime hook to add HTML event listeners on the window or
     * HTML DOM object.
     * @see https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener
     * @function
     * @param {CHtmlEventParams} params The parameters for adding an event
     * handler.
     * @returns {void}
     */
    addEventListener({
        type = undefined,
        handler = undefined,
        obj = undefined,
    } = {}) {
        try {
            this.tryType("string", type);
            if (obj == null) {
                globalThis.addEventListener(type, handler);
            } else {
                obj.addEventListener(type, handler);
            }
        } catch (ex) {
            this.logError(ex);
        }
    },

    /**
     * Provides runtime hook to remove HTML event listeners on the window or
     * HTML DOM object.
     * @see https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/removeEventListener
     * @function
     * @param {CHtmlEventParams} params The parameters for removing an event
     * handler.
     * @returns {void}
     */
    removeEventListener({
        type = undefined,
        handler = undefined,
        obj = undefined,
    } = {}) {
        try {
            this.tryType("string", type);
            if (obj == null) {
                globalThis.removeEventListener(type, handler);
            } else {
                obj.removeEventListener(type, handler);
            }
        } catch (ex) {
           this.logError(ex);
        }
    },

    /**
     * Attempts to open a print dialog for the currently loaded browser
     * document.
     *
     * SUPPORTED RUNTIMES: web
     * @function
     * @returns {void}
     */
    print() {
        // Ensure the function is available. Will only be in a browser
        // context.
        if (!globalThis.print) {
            throw new SyntaxError(
                "codemelted.print(): is not supported on this runtime"
            );
        }
        globalThis.print();
    },

    // ------------------------------------------------------------------------
    // [Share Implementation] -------------------------------------------------
    // ------------------------------------------------------------------------

    /**
     * Provides the ability to share items via the share services. You specify
     * options via the shareData object parameters.
     *
     * SUPPORTED RUNTIMES: web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share
     * @function
     * @param {object} shareData Optional set of arguments to pass to the share.
     * @returns {Promise<CShareResult>} Object with a status field detailing
     * the result of the request.
     */
    async share(shareData) {
        if (!globalThis.navigator.share) {
            throw new SyntaxError(
                "codemelted.share(): is not supported on this runtime."
            );
        }

        try {
            await globalThis.navigator.share(shareData);
            return new CShareResult();
        } catch (ex) {
            this.logWarning(ex);
            return new CShareResult(ex);
        }
    },

    // ------------------------------------------------------------------------
    // [Storage Implementation] -----------------------------------------------
    // ------------------------------------------------------------------------

    /**
     * Sets a key / value pair with the local storage.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
     * @function
     * @param {string} key The key to associate with the value.
     * @param {string} value The value to store.
     * @returns {void}
     */
    storageSet(key, value) {
        this.tryType("string", key);
        this.tryType("string", value);
        try {
            globalThis.localStorage.setItem(key, value);
        } catch (ex) {
            this.logError(ex);
        }
    },

    /**
     * Gets a value associated with a key from local storage.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
     * @function
     * @param {string} key The key to retrieve.
     * @returns {string | null} The string value or null if not found.
     */
    storageGet(key) {
        this.tryType("string", key);
        try {
            return globalThis.localStorage.getItem(key, value);
        } catch (ex) {
            this.logError(ex);
        }
    },

    /**
     * Removes the key / value pair from local storage.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
     * @function
     * @param {string} key The key to associate with the value.
     * @returns {void}
     */
    storageRemove(key) {
        this.tryType("string", key);
        try {
            globalThis.localStorage.removeItem(key, value);
        } catch (ex) {
            this.logError(ex);
        }
    },

    /**
     * Clears the local storage of the runtime.
     *
     * SUPPORTED RUNTIMES: deno / web
     * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
     * @function
     * @returns {void}
     */
    storageClear() {
        try {
            globalThis.localStorage.clear();
        } catch (ex) {
            this.logError(ex);
        }
    },

    // ------------------------------------------------------------------------
    // [Themes Implementation] ------------------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Web RTC Implementation] -----------------------------------------------
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // [Widgets Implementation] -----------------------------------------------
    // ------------------------------------------------------------------------
});
