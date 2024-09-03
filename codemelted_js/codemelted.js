// @ts-check
/**
 * @file Implementation of the codemelted.js cross platform module.
 * @author Mark Shaffer
 * @version 0.0.0
 * @license MIT
 */

/**
 * Collection of global namespaces implementing the CodeMelted - Developer
 * cross platform use case modules. Meant for Deno / Web Browser runtime
 * environments. In support of the global namespaces include a set of utility
 * classes that are the result of a namespace function call.
 *
 * <p>The identified classes must be imported. The documented types are global
 * like the namespaces.</p>
 * @module codemelted
 */

// ----------------------------------------------------------------------------
// [async use case] -----------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: Deno process.

/**
 * Data that is received via the
 * @typedef {object} CAsyncData
 * @property {string} type "data" or "error".
 * @property {any} data The actual data associated with the type.
 */

/**
 * Message handler that receives a JSON object with two fields. "type" which
 * equals either "error" or "data". Then "data" which contains the actual
 * data received.
 * @callback CAsyncWorkerListener
 * @param {CAsyncData} data The data received via the wrapped worker.
 * @returns {void}
 */

/**
 * The task to run as part of the different module async functions.
 * @callback CAsyncTask
 * @param {any} [data] The data to process on the backend.
 * @returns {any} The calculated answer to the task if any.
 */

/**
 * Definition class for a dedicated FIFO thread separated worker /
 * process. Data is queued to this worker via CAsyncWorker.postMessage
 * method and terminated via the CAsyncWorker.terminate method.
 */
export class CAsyncWorker {
    /**
     * Identifies the constructed worker.
     * @type {Worker | undefined}
     */
    #worker = undefined;

    /**
     * Posts dynamic data to the background worker.
     * @param {any} data The data to transmit.
     * @returns {void}
     */
    postMessage(data) {
        this.#worker?.postMessage(data);
    }

    /**
     * Terminates the dedicated background worker.
     * @returns {void}
     */
    terminate() {
        this.#worker?.terminate();
    }

    /**
     * Constructor for the worker.
     * @param {CAsyncWorkerListener} onDataReceived The callback for received data.
     * @param {string} url The URL of the dedicated worker.
     */
    constructor(onDataReceived, url) {
        this.#worker = new Worker(url, {type: "module"});
        this.#worker.onerror = (e) => {
            onDataReceived({type: "error", data: e.error});
        };
        this.#worker.onmessage = (e) => {
            onDataReceived({type: "data", data: e.data});
        }
        this.#worker.onmessageerror = (e) => {
            onDataReceived({type: "error", data: e.data});
        }
    }
}

/**
 * Holds a timer kicked off by the codemelted_async.timer function.
 */
export class CTimer {
    /**
     * The id of the kicked-off timer.
     * @type {number}
     */
    #id;

    /**
     * Stops the running timer.
     */
    stop() {
        clearInterval(this.#id);
    }

    /**
     * Constructor for the object.
     * @param {number} id The interval timer id.
     */
    constructor(id) {
        this.#id = id;
    }
}

/**
 * Implements the Async IO API collecting ways of properly doing asynchronous
 * programming within a Deno or Web Browser runtime.
 * @namespace codemelted.codemelted_async
 */
globalThis["codemelted_async"] = Object.freeze({
    /**
     * Identifies the number of processors to facilitate dedicated workers.
     * @memberof codemelted.codemelted_async
     * @readonly
     * @type {number}
     */
    get hardwareConcurrency() {
        return globalThis.navigator.hardwareConcurrency;
    },

    /**
     * Will sleep an asynchronous task for the specified delay in
     * milliseconds.
     * @memberof codemelted.codemelted_async
     * @param {object} params The named parameters.
     * @param {number} params.delay The specified delay in milliseconds.
     * @returns {Promise<void>}
     */
    sleep: function({delay}) {
        return new Promise((resolve, reject) => {
            try {
                codemelted_json.tryType({type: "number", data: delay});
                if (delay < 0) {
                    throw new SyntaxError("delay must be greater than 0");
                }
                setTimeout(() => resolve(), delay);
            } catch (err) {
                reject(err)
            }
        });
    },

    /**
     * Will process a one off asynchronous task on the main thread.
     * @memberof codemelted.codemelted_async
     * @param {object} params The named parameters.
     * @param {CAsyncTask} params.task The task to run.
     * @param {any} params.data The data to pass to the task.
     * @param {number} params.delay The specified delay in milliseconds to
     * schedule to run the task.
     * @returns {Promise<any>} The calculated result or Error object if a
     * failure occurred.
     */
    task: function({task, data, delay}) {
        return new Promise((resolve, reject) => {
            try {
                codemelted_json.tryType({type: "function",
                    data: task, count: 1});
                codemelted_json.tryType({type: "number", data: delay});
                if (delay < 0) {
                    throw new SyntaxError("delay must be greater than 0");
                }
                setTimeout(() => {
                    const answer = task(data);
                    resolve(answer);
                }, delay);
            } catch (err) {
                reject(err);
            }
        });
    },

    /**
     * Kicks off a timer to schedule tasks on the thread for which it is
     * created calling the task on the interval specified in milliseconds.
     * @memberof codemelted.codemelted_async
     * @param {object} params The named parameters.
     * @param {CAsyncTask} params.task The task to repeat.
     * @param {number} params.interval The interval to repeat the task in
     * milliseconds.
     * @returns {CTimer} The created timer.
     */
    timer: function({task, interval}) {
        codemelted_json.tryType({type: "function", data: task, count: 1});
        codemelted_json.tryType({type: "number", data: interval});
        if (interval < 0) {
            throw new SyntaxError("delay must be greater than 0");
        }
        const id = setInterval(() => task(), interval);
        return new CTimer(id);
    },

    /**
     * Creates the CAsyncWorker dedicated FIFO worker for background work to
     * the client.
     * @memberof codemelted.codemelted_async
     * @param {object} params The named parameters.
     * @param {CAsyncWorkerListener} params.onDataReceived The listener
     * for received data from the worker.
     * @param {string} params.workerUrl The url to the dedicated worker.
     * @returns {CAsyncWorker} The worker created from this namespace.
     */
    worker: function({onDataReceived, workerUrl}) {
        codemelted_json.checkType({type: "function",
            data: onDataReceived, count: 1});
        codemelted_json.checkType({type: "string", data: workerUrl});
        return new CAsyncWorker(onDataReceived, workerUrl);
    }
});

// ----------------------------------------------------------------------------
// [audio use case] -----------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * UNDER DEVELOPMENT
 * @namespace codemelted.codemelted_audio
 */
globalThis["codemelted_audio"] = Object.freeze({
    //
});

// ----------------------------------------------------------------------------
// [console use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Provides the console use case function to gather data via a
 * terminal. The actions correspond to the type of input / output
 * that will be interacted with via STDIN and STDOUT.
 * @namespace codemelted.codemelted_console
 */
globalThis["codemelted_console"] = Object.freeze({
    /**
     * Alerts a message to STDOUT with a [Enter] to halt execution.
     * @memberof codemelted.codemelted_console
     * @param {object} params The named parameters.
     * @param {string} params.message The message to display to STDOUT.
     * @returns {void}
     */
    alert: function({message}) {
        codemelted_runtime.tryDeno();
        codemelted_json.tryType({type: "string", data: message});
        globalThis.alert(message);
    },

    /**
     * Prompts a [y/N] to STDOUT with the message as a question.
     * @memberof codemelted.codemelted_console
     * @param {object} params The named parameters.
     * @param {string} params.message The message to display to STDOUT.
     * @returns {boolean} true if y selected, false otherwise.
     */
    confirm: function({message}) {
        codemelted_runtime.tryDeno();
        codemelted_json.tryType({type: "string", data: message});
        return globalThis.confirm(message);
    },

    /**
     * Prompts a list of choices for the user to select from.
     * @memberof codemelted.codemelted_console
     * @param {object} params The named parameters.
     * @param {string} params.message The message to display to STDOUT.
     * @param {string[]} params.choices The choices to select from.
     * @returns {number} The index of the chosen item.
     */
    choose: function({message, choices}) {
        codemelted_runtime.tryDeno();
        codemelted_json.tryType({type: "string", data: message});
        codemelted_json.tryType({type: Array, data: choices});

        let answer = -1;
        do {
            globalThis.console.log();
            globalThis.console.log("-".repeat(message.length));
            globalThis.console.log(message);
            globalThis.console.log("-".repeat(message.length));
            choices.forEach((v, index) => {
                globalThis.console.log(`${index}. ${v}`);
            });
            answer = parseInt(globalThis.prompt(
                `Make a Selection [0 = ${choices.length - 1}]:`
            ) ?? "-1");
            if (isNaN(answer) || answer >= choices.length) {
                console.log(
                    "ERROR: Entered value was invalid. " +
                    "Please try again."
                );
                answer = -1;
            }
        } while (answer === -1);
        return answer;
    },

    /**
     * Prompts for a password not showing the text typed via STDIN.
     * @memberof codemelted.codemelted_console
     * @param {object} params The named parameters.
     * @param {string} params.message The message to display to STDOUT.
     * @returns {string} The typed password.
     */
    password: function({message}) {
        // Setup our variables
        const deno = codemelted_runtime.tryDeno();
        codemelted_json.tryType({type: "string", data: message});
        const buf = new Uint8Array(1);
        const decoder = new TextDecoder();
        let answer = "";
        let done = false;

        // Go prompt for the password
        deno.stdin.setRaw(true);
        globalThis.console.log(`${message}:`);
        do {
            const nread = deno.stdin.readSync(buf);
            if (nread === null) {
                done = true;
            } else if (buf && buf[0] === 0x03) {
                done = true;
            } else if (buf && buf[0] === 13) {
                done = true;
            }
            const text = decoder.decode(buf.subarray(0, nread ?? undefined));
            answer += text;
        } while (!done);
        deno.stdin.setRaw(false);
        return answer;
    },

    /**
     * Prompts to STDOUT and returns the typed message via STDIN.
     * @memberof codemelted.codemelted_console
     * @param {object} params The named parameters.
     * @param {string} params.message The message to display to STDOUT.
     * @returns {string?} The result typed.
     */
    prompt: function({message}) {
        codemelted_runtime.tryDeno();
        codemelted_json.tryType({type: "string", data: message});
        return globalThis.prompt(message);
    },

    /**
     * Write a message to STDOUT.
     * @memberof codemelted.codemelted_console
     * @param {object} params The named parameters.
     * @param {string} params.message The message to display to STDOUT.
     * @returns {void}
     */
    writeln: function({message}) {
        codemelted_runtime.tryDeno();
        codemelted_json.tryType({type: "string", data: message});
        globalThis.console.log(message);
    },
});

// ----------------------------------------------------------------------------
// [database use case] --------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * UNDER DEVELOPMENT
 * @namespace codemelted.codemelted_database
 */
globalThis["codemelted_database"] = Object.freeze({
    //
});

// ----------------------------------------------------------------------------
// [disk use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: CFileBroker for reading / writing data to a file.

/**
 * Identifies file information based on a codemelted_disk.ls call.
 */
export class CFileInfo {
    /** @type {string} */
    #filename;

    /**
     * The name of the file on disk.
     * @readonly
     * @type {string}
     */
    get filename() { return this.#filename; }

    /** @type {boolean} */
    #isDirectory;

    /**
     * Is a directory or not.
     * @readonly
     * @type {boolean}
     */
    get isDirectory() { return this.#isDirectory; }

    /** @type {boolean} */
    #isFile;

    /**
     * Is a file or not.
     * @readonly
     * @type {boolean}
     */
    get isFile() { return this.#isFile; }

    /** @type {boolean} */
    #isSymLink;

     /**
      * If symbolic link or not.
     * @readonly
     * @type {boolean}
     */
     get isSymLink() { return this.#isSymLink; }

    /** @type {number} */
    #size;

    /**
     * Size of file on disk.
     * @readonly
     * @type {number}
     */
    get size() { return this.#size; }

    /**
     * Constructor for the class.
     * @param {string} filename The filename to include full path.
     * @param {boolean} isDirectory true if directory, false otherwise.
     * @param {boolean} isFile true if file, false otherwise.
     * @param {boolean} isSymLink true if symbolic link, false otherwise.
     * @param {number} size Size of the file in bytes on disk.
     */
    constructor(filename, isDirectory, isFile, isSymLink, size) {
        this.#filename = filename;
        this.#isDirectory = isDirectory;
        this.#isFile = isFile;
        this.#isSymLink = isSymLink;
        this.#size = size;
    }
}

/**
 * Provides the ability to manage items on disk. This includes file
 * manipulation, reading / writing files, and opening files for additional
 * work. Only supported on the Deno runtime and will throw a SyntaxError if
 * attempting to run within a Web Browser.
 * @namespace codemelted.codemelted_disk
 */
globalThis["codemelted_disk"] = Object.freeze({
    /**
     * Copies a file / directory from its currently source location to the
     * specified destination.
     * @memberof codemelted.codemelted_disk
     * @param {object} params The named parameters.
     * @param {string} params.src The source item to copy.
     * @param {string} params.dest The destination of where to copy the item.
     * @returns {boolean} true if carried out, false otherwise.
     */
    cp: function({src, dest}) {
        try {
            const deno = codemelted_runtime.tryDeno();
            codemelted_json.tryType({type: "string", data: src});
            codemelted_json.tryType({type: "string", data: dest});
            deno.copyFileSync(src, dest);
            return true;
        } catch (err) {
            if (err instanceof SyntaxError) {
                throw err;
            }
            return false;
        }
    },

    /**
     * List the files in the specified source location.
     * @memberof codemelted.codemelted_disk
     * @param {object} params The named parameters.
     * @param {string} params.path The path to list.
     * @returns {CFileInfo[]?} Array of files found.
     */
    ls: function({path}) {
        try {
            const deno = codemelted_runtime.tryDeno();
            codemelted_json.tryType({type: "string", data: path});
            const dirList = deno.readDirSync(path);
            const fileInfoList = [];
            for (const dirEntry of dirList) {
                const fileInfo = deno.lstatSync(
                    `${path}/${dirEntry.name}`
                );
                fileInfoList.push(new CFileInfo(
                    dirEntry.name,
                    fileInfo.isDirectory,
                    fileInfo.isFile,
                    fileInfo.isSymlink,
                    fileInfo.size
                ));
            }
            return fileInfoList;
        } catch (err) {
            if (err instanceof SyntaxError) {
                throw err;
            }
            return null;
        }
    },

    /**
     * Makes a directory at the specified location.
     * @memberof codemelted.codemelted_disk
     * @param {object} params The named parameters.
     * @param {string} params.path The source item to create.
     * @returns {boolean}
     */
    mkdir: function({path}) {
        try {
            const deno = codemelted_runtime.tryDeno();
            codemelted_json.tryType({type: "string", data: path});
            deno.mkdirSync(path);
            return true;
        } catch (err) {
            if (err instanceof SyntaxError) {
                throw err;
            }
            return false;
        }
    },

    /**
     * Identifies the path separator for files on disk.
     * @memberof codemelted.codemelted_disk
     * @readonly
     * @type {string}
     */
    get pathSeparator() {
        return codemelted_runtime.osName === "windows"
            ? "\\"
            : "/"
    },

    /**
     * Reads a file to disk.
     * @memberof codemelted.codemelted_disk
     * @param {object} params The named parameters.
     * @param {string} params.filename The filename to write.
     * @param {boolean} params.isTextFile true if text file, false if binary.
     * @returns {string | Uint8Array | null}
     */
    readFile: function({filename, isTextFile}) {
        try {
            const deno = codemelted_runtime.tryDeno();
            codemelted_json.tryType({type: "string", data: filename});
            codemelted_json.tryType({type: "boolean", data: isTextFile});
            if (isTextFile) {
                return deno.readTextFileSync(filename);
            } else {
                return deno.readFileSync(filename);
            }
        } catch (err) {
            if (err instanceof SyntaxError) {
                throw err;
            }
            return null;
        }
    },

    /**
     * Removes a file or directory at the specified location.
     * @memberof codemelted.codemelted_disk
     * @param {object} params The named parameters.
     * @param {string} params.path The source item to create.
     * @returns {boolean}
     */
    rm: function({path}) {
        try {
            const deno = codemelted_runtime.tryDeno();
            codemelted_json.tryType({type: "string", data: path});
            deno.removeSync(path);
            return true;
        } catch (err) {
            if (err instanceof SyntaxError) {
                throw err;
            }
            return false;
        }
    },

    /**
     * Identifies the temp directory on disk. Null is returned if on
     * web browser.
     * @memberof codemelted.codemelted_disk
     * @readonly
     * @type {string?}
     */
    get tempPath() {
        return codemelted_runtime.isDeno
            ? codemelted_runtime.tryDeno().env.get("TMPDIR") ||
              codemelted_runtime.tryDeno().env.get("TMP") ||
              codemelted_runtime.tryDeno().env.get("TEMP") ||
              "/tmp"
            : null;
    },

    /**
     * Writes a file to disk.
     * @memberof codemelted.codemelted_disk
     * @param {object} params The named parameters.
     * @param {string} params.filename The filename to write.
     * @param {string | Uint8Array} params.data The data to write.
     * @param {boolean} params.append true to append the data, false
     * to overwrite the file.
     * @returns {boolean} true if successful, false otherwise.
     */
    writeFile: function({filename, data, append}) {
        try {
            const deno = codemelted_runtime.tryDeno();
            codemelted_json.tryType({type: "string", data: filename});
            codemelted_json.tryType({type: "boolean", data: append});
            if (codemelted_json.checkType({type: "string", data: data})) {
                // @ts-ignore: checked it is string previous line.
                deno.writeTextFileSync(filename, data, append)
            } else if (codemelted_json.checkType({
                    type: Uint8Array, data: data})) {
                // @ts-ignore: checked it is string previous line.
                deno.writeFileSync(filename, data, append);
            } else {
                throw SyntaxError("data is not of an expected type");
            }
            return true;
        } catch (err) {
            if (err instanceof SyntaxError) {
                throw err;
            }
            return false;
        }
    },
});

// ----------------------------------------------------------------------------
// [firebase use case] --------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * UNDER DEVELOPMENT
 * @namespace codemelted.codemelted_firebase
 */
globalThis["codemelted_firebase"] = Object.freeze({
    //
});

// ----------------------------------------------------------------------------
// [game use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * UNDER DEVELOPMENT
 * @namespace codemelted.codemelted_game
 */
globalThis["codemelted_game"] = Object.freeze({
    //
});

// ----------------------------------------------------------------------------
// [hardware use case] --------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * UNDER DEVELOPMENT
 * @namespace codemelted.codemelted_hardware
 */
globalThis["codemelted_hardware"] = Object.freeze({
    //
});

// ----------------------------------------------------------------------------
// [json use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: CArray object, CObject object like flutter.

/**
 * Defines a set of utility methods for performing data conversions for JSON
 * along with data validation.
 * @namespace codemelted.codemelted_json
 */
globalThis["codemelted_json"] = Object.freeze({
    /**
     * Determines if the specified object has the specified property.
     * @memberof codemelted.codemelted_json
     * @param {object} params The named parameters.
     * @param {object} params.obj The object to check for the key.
     * @param {string} params.key The property to check for.
     * @returns {boolean} true if property was found, false otherwise.
     */
    checkHasProperty: function({ obj, key }) {
        return Object.hasOwn(obj, key);
    },

    /**
     * Utility to check parameters of a function to ensure they are of an
     * expected type.
     * @memberof codemelted.codemelted_json
     * @param {object} params The named parameters.
     * @param {string | any} params.type The specified type to check the data
     * against.
     * @param {any} params.data The parameter to be checked.
     * @param {number} [params.count] Checks the data parameter function
     * signature to ensure the appropriate number of parameters are
     * specified.
     * @returns {boolean} true if it meets the expectations, false otherwise.
     */
    checkType: function({ type, data, count = undefined }) {
        const isExpectedType = typeof type !== "string"
            ? (data instanceof type)
            // deno-lint-ignore valid-typeof
            : typeof data === type;
        return typeof count === "number"
            ? isExpectedType && data.length === count
            : isExpectedType;
    },

    /**
     * Checks for a valid URL.
     * @memberof codemelted.codemelted_json
     * @param {object} params The named parameters.
     * @param {string} params.data String to parse to see if it is a valid URL.
     * @returns {boolean} true if valid, false otherwise.
     */
    checkValidUrl: function({ data }) {
        let url = undefined;
        try {
            url = new URL(data);
        }
        catch (_ex) {
            url = undefined;
        }
        return codemelted_json.checkType({ type: URL, data: url });
    },

    /**
     * Converts a string to a JavaScript object.
     * @memberof codemelted.codemelted_json
     * @param {object} params The named parameters.
     * @param {string} params.data The data to parse.
     * @returns {object | null} Object or null if the parse failed.
     */
    jsonParse: function({ data }) {
        try {
            return JSON.parse(data);
        }
        catch (_ex) {
            return null;
        }
    },

    /**
     * Converts a JavaScript object into a string.
     * @memberof codemelted.codemelted_json
     * @param {object} params The named parameters.
     * @param {object} params.data An object with valid JSON attributes.
     * @returns {string | null} The string representation or null if the
     * stringify failed.
     */
    jsonStringify: function({ data }) {
        try {
            return JSON.stringify(data);
        }
        catch (_ex) {
            return null;
        }
    },

    /**
     * Determines if the specified object has the specified property.
     * @memberof codemelted.codemelted_json
     * @param {object} params The named parameters.
     * @param {object} params.obj The object to check for the key.
     * @param {string} params.key The property to check for.
     * @returns {void}
     * @throws {SyntaxError} if the property is not found.
     */
    tryHasProperty: function({ obj, key }) {
        if (!this.checkHasProperty({ obj: obj, key: key })) {
            throw new SyntaxError(`${obj} does not have property ${key}`);
        }
    },

    /**
     * Utility to check parameters of a function to ensure they are of an
     * expected type.
     * @memberof codemelted.codemelted_json
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
    tryType: function({ type, data, count = undefined }) {
        if (!this.checkType({ type: type, data: data, count: count })) {
            throw new SyntaxError(`${data} parameter is not of type ${type} or does not ` +
                `contain expected ${count} for function`);
        }
    },

    /**
     * Checks for a valid URL.
     * @memberof codemelted.codemelted_json
     * @param {object} params The named parameters.
     * @param {string} params.data String to parse to see if it is a valid URL.
     * @returns {void}
     * @throws {SyntaxError} If v is not a valid url.
     */
    tryValidUrl: function({ data }) {
        if (!this.checkValidUrl({ data: data })) {
            throw new SyntaxError(`'${data}' is not a valid url`);
        }
    },
});

// ----------------------------------------------------------------------------
// [logger use case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Wraps the handled logged event for later processing.
 */
export class CLogRecord {
    /** @type {Date} */
    #time;
    /**
     * The time of the event.
     * @type {Date}
     */
    get time() { return this.#time; }

    /** @type {number} */
    #level;
    /**
     * The log level of the event.
     * @type {number}
     */
    get level() { return this.#level; }

    /** @type {any}*/
    #data;
    /**
     * The data associated with the event.
     * @readonly
     * @type {any}
     */
    get data() { return this.#data; }

    /** @type {string?} */
    #stackTrace = null;
    /**
     * A stack trace associated with the data.
     * @readonly
     * @type {string?}
     */
    get stackTrace() { return this.#stackTrace; }

    /**
     * Formatted log record
     * @returns {string}
     */
    toString() {
        const levelStr = this.level === 0
            ? "debug"
            : this.level === 1
                ? "info"
                : this.level === 2
                    ? "warning"
                    : "error";
        let msg = `${this.time.toISOString()} [${levelStr}]: ${this.data}`;
        msg = this.stackTrace != null ? `${msg}\n${this.stackTrace}` : msg;
        return msg;
    }

    /**
     * Constructor for the class
     * @param {number} level The level of the logged event.
     * @param {any} data The data associated with it.
     */
    constructor(level, data) {
        this.#time = new Date();
        this.#level = level;
        this.#data = data;
        if (codemelted_json.checkType({type: Error, data: data})) {
            this.#stackTrace = data.stack;
        }
    }
}

/**
 * Handler to support the codemelted_flutter module for post processing of a
 * logged event.
 * @callback COnLogEventListener
 * @param {CLogRecord} record The log record that was received.
 * @returns {void}
 */

/**
 * The currently set module log level.
 * @type {number}
 * @private
 */
let _logLevel = 1; // The information setting

/**
 * The module holder for the codemelted_logger.onLogEvent property.
 * @type {COnLogEventListener?}
 * @private
 */
let _onLogEventHandler = null;

/**
 * Sets up the logging facility for the module. Events logged are sent to
 * the runtime console with the [onLogEvent] handling more advanced
 * logging if set.
 * @namespace codemelted.codemelted_logger
 */
globalThis["codemelted_logger"] = Object.freeze({
    /**
     * debug log level.
     * @memberof codemelted.codemelted_logger
     * @readonly
     * @type {number}
     */
    get debugLevel() { return 0; },

    /**
     * info log level.
     * @memberof codemelted.codemelted_logger
     * @readonly
     * @type {number}
     */
    get infoLevel() { return 1; },

    /**
     * warning log level.
     * @memberof codemelted.codemelted_logger
     * @readonly
     * @type {number}
     */
    get warningLevel() { return 2; },

    /**
     * error log level.
     * @memberof codemelted.codemelted_logger
     * @readonly
     * @type {number}
     */
    get errorLevel() { return 3; },

    /**
     * off log level.
     * @memberof codemelted.codemelted_logger
     * @readonly
     * @type {number}
     */
    get offLevel() { return 4; },

    /**
     * The current log level for the module as set by the namespaced
     * constants.
     * @memberof codemelted.codemelted_logger
     * @type {number}
     */
    set level(v) {
        codemelted_json.checkType({type: "number", data: v});
        if (v < this.debugLevel || v > this.offLevel) {
            throw new SyntaxError("level not set in valid range");
        }
        _logLevel = v;
    },
    get level() { return _logLevel; },

    /**
     * Sets / gets the listener for post processing of log events once they
     * are handled by the module.
     * @memberof codemelted.codemelted_logger
     * @type {COnLogEventListener?}
     */
    set onLogEvent(v) {
        if (v) {
            codemelted_json.checkType({type: "function", data: v, count: 1});
        }
        _onLogEventHandler = v == undefined ? null : v;
    },
    get onLogEvent() { return _onLogEventHandler; },

    /**
     * Will log debug level messages via the module.
     * @memberof codemelted.codemelted_logger
     * @param {object} params The named parameters
     * @param {any} params.data The data to log.
     * @returns {void}
     */
    debug: function({data}) {
        if (this.level <= this.debugLevel && this.level != this.offLevel) {
            const record = new CLogRecord(this.debugLevel, data);
            console.log(data.toString());
            if (this.onLogEvent) {
                this.onLogEvent(record);
            }
        }
    },

    /**
     * Will log info level messages via the module.
     * @memberof codemelted.codemelted_logger
     * @param {object} params The named parameters
     * @param {any} params.data The data to log.
     * @returns {void}
     */
    info: function({data}) {
        if (this.level <= this.infoLevel && this.level != this.offLevel) {
            const record = new CLogRecord(this.infoLevel, data);
            console.info(data.toString());
            if (this.onLogEvent) {
                this.onLogEvent(record);
            }
        }
    },

    /**
     * Will log warning level messages via the module.
     * @memberof codemelted.codemelted_logger
     * @param {object} params The named parameters
     * @param {any} params.data The data to log.
     * @returns {void}
     */
    warning: function({data}) {
        if (this.level <= this.warningLevel && this.level != this.offLevel) {
            const record = new CLogRecord(this.warningLevel, data);
            console.warn(data.toString());
            if (this.onLogEvent) {
                this.onLogEvent(record);
            }
        }
    },

    /**
     * Will log error level messages via the module.
     * @memberof codemelted.codemelted_logger
     * @param {object} params The named parameters
     * @param {any} params.data The data to log.
     * @returns {void}
     */
    error: function({data}) {
        if (this.level <= this.errorLevel && this.level != this.offLevel) {
            const record = new CLogRecord(this.errorLevel, data);
            console.error(data.toString());
            if (this.onLogEvent) {
                this.onLogEvent(record);
            }
        }
    },
});

// ----------------------------------------------------------------------------
// [math use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Provides a math utility API with a collection of mathematical formulas I
 * have either had to use, research, or just found on the Internet.
 * @namespace codemelted.codemelted_math
 */
globalThis["codemelted_math"] = Object.freeze({
    /**
     * Converts celsius to fahrenheit.
     * @memberof codemelted.codemelted_math
     * @param {object} params The named parameters
     * @param {number} params.temp The temperature to convert.
     * @returns {number} The converted temperature
     */
    celsiusToFahrenheit: function({temp}) {
        return (temp * (9 / 5)) + 32;
    },

    /**
     * Converts celsius to kelvin.
     * @memberof codemelted.codemelted_math
     * @param {object} params The named parameters
     * @param {number} params.temp The temperature to convert.
     * @returns {number} The converted temperature
     */
    celsiusToKelvin: function({temp}) {
        return temp + 273.15;
    },

    /**
     * Converts fahrenheit to celsius
     * @memberof codemelted.codemelted_math
     * @param {object} params The named parameters
     * @param {number} params.temp The temperature to convert.
     * @returns {number} The converted temperature
     */
    fahrenheitToCelsius: function({temp}) {
        return (temp - 32) * (5 / 9);
    },

    /**
     * Converts fahrenheit to kelvin
     * @memberof codemelted.codemelted_math
     * @param {object} params The named parameters
     * @param {number} params.temp The temperature to convert.
     * @returns {number} The converted temperature
     */
    fahrenheitToKelvin: function({temp}) {
        return (temp - 32) * (5 / 9) + 273.15;
    },

    /**
     * Calculates the distance in meters between two WGS84 points.
     * @memberof codemelted.codemelted_math
     * @param {object} params The named parameters
     * @param {number} params.startLatitude The starting latitude coordinate.
     * @param {number} params.startLongitude The starting longitude
     * coordinate.
     * @param {number} params.endLatitude The ending latitude coordinate.
     * @param {number} params.endLongitude The ending longitude
     * coordinate.
     * @returns {number} The calculated distance.
     */
    geodeticDistance: function({
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      }) {
        // Convert degrees to radians
        const lat1 = startLatitude * Math.PI / 180.0;
        const lon1 = startLongitude * Math.PI / 180.0;

        const lat2 = endLatitude * Math.PI / 180.0;
        const lon2 = endLongitude * Math.PI / 180.0;

        // radius of earth in metres
        const r = 6378100;

        // P
        const rho1 = r * Math.cos(lat1);
        const z1 = r * Math.sin(lat1);
        const x1 = rho1 * Math.cos(lon1);
        const y1 = rho1 * Math.sin(lon1);

        // Q
        const rho2 = r * Math.cos(lat2);
        const z2 = r * Math.sin(lat2);
        const x2 = rho2 * Math.cos(lon2);
        const y2 = rho2 * Math.sin(lon2);

        // Dot product
        const dot = (x1 * x2 + y1 * y2 + z1 * z2);
        const cosTheta = dot / (r * r);
        const theta = Math.acos(cosTheta);

        // Distance in meters
        return r * theta;
    },

    /**
     * Calculates the geodetic heading WGS84 to true north represented as 0
     * and rotating around 360 degrees.
     * @memberof codemelted.codemelted_math
     * @param {object} params The named parameters
     * @param {number} params.startLatitude The starting latitude coordinate.
     * @param {number} params.startLongitude The starting longitude
     * coordinate.
     * @param {number} params.endLatitude The ending latitude coordinate.
     * @param {number} params.endLongitude The ending longitude
     * coordinate.
     * @returns {number} The calculated heading.
     */
    geodeticHeading: function({
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
    }) {
        // Get the initial data from our variables:
        const lat1 = startLatitude * (Math.PI / 180);
        const lon1 = startLongitude * (Math.PI / 180);
        const lat2 = endLatitude * (Math.PI / 180);
        const lon2 = endLongitude * (Math.PI / 180);

        // Set up our calculations
        const y = Math.sin(lon2 - lon1) * Math.cos(lat2);
        const x = Math.cos(lat1) * Math.sin(lat2) -
            Math.sin(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1);
        let rtnval = Math.atan2(y, x) * (180 / Math.PI);
        rtnval = (rtnval + 360) % 360;
        return rtnval;
    },

    /**
     * Calculates the speed between two points in meters per second.
     * @memberof codemelted.codemelted_math
     * @param {object} params The named parameters
     * @param {number} params.startMilliseconds The starting time in
     * milliseconds.
     * @param {number} params.startLatitude The starting latitude coordinate.
     * @param {number} params.startLongitude The starting longitude
     * coordinate.
     * @param {number} params.endMilliseconds The ending time in milliseconds.
     * @param {number} params.endLatitude The ending latitude coordinate.
     * @param {number} params.endLongitude The ending longitude
     * coordinate.
     * @returns {number} The calculated heading.
     */
    geodeticSpeed: function({
        startMilliseconds,
        startLatitude,
        startLongitude,
        endMilliseconds,
        endLatitude,
        endLongitude,
    }) {
        // Get the lat / lon for start / end positions
        const distMeters = this.geodeticDistance({
            startLatitude: startLatitude,
            startLongitude: startLongitude,
            endLatitude: endLatitude,
            endLongitude: endLongitude,
        });

        const timeS = (endMilliseconds - startMilliseconds) / 1000.0;
        return distMeters / timeS;
    },

    /**
     * Converts kelvin to celsius.
     * @memberof codemelted.codemelted_math
     * @param {object} params The named parameters
     * @param {number} params.temp The temperature to convert.
     * @returns {number} The converted temperature
     */
    kelvinToCelsius: function({temp}) {
        return temp - 273.15;
    },

    /**
     * Converts kelvin to fahrenheit.
     * @memberof codemelted.codemelted_math
     * @param {object} params The named parameters
     * @param {number} params.temp The temperature to convert.
     * @returns {number} The converted temperature
     */
    kelvinToFahrenheit: function({temp}) {
        return (temp - 273.15) * (9 / 5) + 32;
    },
});

// ----------------------------------------------------------------------------
// [network use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: HTTP Server, WebSocket Client / Server, WebRTC

/**
 * Message handler that receives a JSON object with two fields. "type" which
 * equals either "error" or "data". Then "data" which contains the actual
 * data received.
 * @callback COnMessageListener
 * @param {object} data The object identifying the type of data and the
 * actual data.
 */

/**
 * Wrapper object for the Broadcast Channel API. Constructed via the
 * codemelted_network.broadcastChannel and provides the bindings for
 * working with the channel.
 */
export class CBroadcastChannel {
    /** @type {BroadcastChannel} */
    #channel;

    /**
     * Closes the channel.
     * @returns {void}
     */
    close() {
        this.#channel.close();
    }

    /**
     * Broadcasts a message via the channel
     * @param {any} data The data to communicate.
     * @returns {void}
     */
    postMessage(data) {
        this.#channel.postMessage(data);
    }

    /**
     * Constructor for the class.
     * @param {string} name The url that
     * @param {COnMessageListener} onMessage The receiver for messages.
     */
    constructor(name, onMessage) {
        this.#channel = new BroadcastChannel(name);
        this.#channel.onmessage = (e) => {
            onMessage({
                type: "message",
                data: e.data,
            });
        };
        this.#channel.onmessageerror = (e) => {
            onMessage({
                type: "error",
                data: e.data,
            });
        };
    }
}

/**
 * The EventSource interface is web content's interface to server-sent
 * events. An EventSource instance opens a persistent connection to an
 * HTTP server, which sends events in text/event-stream format. The
 * connection remains open until closed.
 */
export class CEventSource {
    /** @type {EventSource} */
    #eventSource;

    /**
     * Identifies an connecting state for the object.
     * @readonly
     * @type {number}
     */
    static get CONNECTING() { return 0; }

    /**
     * Identifies an open state for the object.
     * @readonly
     * @type {number}
     */
    static get OPEN() { return 1; }

     /**
     * Identifies an closed state for the object.
     * @readonly
     * @type {number}
     */
     static get CLOSED() { return 2; }

    /**
     * Determines the current state of the object. Once in a CLOSED state
     * you will need to get a new object.
     * @readonly
     * @type {number}
     */
    get state() { return this.#eventSource.readyState; }

    /**
     * Closes the server sent event receiver.
     */
    close() {
        this.#eventSource.close();
    }

    /**
     * Constructor for the class.
     * @param {string} url The url to the server streaming the events.
     * @param {boolean} withCredentials True if using CORS, false otherwise.
     * @param {COnMessageListener} onMessage The callback for received messages.
     */
    constructor(url, withCredentials, onMessage) {
        this.#eventSource = new EventSource(
            url,
            {withCredentials: withCredentials}
        );
        this.#eventSource.onerror = (e) => {
            onMessage({
                type: "error",
                data: e
            });
        };
        this.#eventSource.onmessage = (e) => {
            onMessage({
                type: "data",
                data: e.data,
            });
        }
    }
}

export class CFetchResponse {
    /** @type {any} */
    #data;

    /**
     * The retrieved with the fetch request. May be null.
     * @readonly
     * @type {any}
     */
    get data() { return this.#data; }

    /**
     * Will treat the data as a Blob object.
     * @readonly
     * @type {Blob?}
     */
    get asBlob() {
        return this.#data instanceof Blob
            ? this.#data
            : null;
    }

    /**
     * Will treat the data as a Blob object.
     * @readonly
     * @type {FormData?}
     */
    get asFormData() {
        return this.#data instanceof FormData
            ? this.#data
            : null;
    }

    /**
     * Will treat the data as a JavaScript object.
     * @readonly
     * @type {object?}
     */
    get asObject() {
        return typeof this.#data === "object"
            ? this.#data
            : null;
    }

    /**
     * Will treat the data as a string.
     * @readonly
     * @type {string?}
     */
    get asString() {
        return typeof this.#data === "string"
            ? this.#data
            : null;
    }

    /** @type {number} */
    #status;

    /**
     * The HTTP status code of the request.
     * @readonly
     * @type {number}
     */
    get status() { return this.#status; }

    /** @type {string} */
    #statusText;

    /**
     * The HTTP status text of the request.
     * @readonly
     * @type {string}
     */
    get statusText() { return this.#statusText; }

    /**
     * Constructor for the object.
     * @param {number} status The HTTP status of the fetch.
     * @param {string} statusText The associated text.
     * @param {any} data The data retrieved.
     */
    constructor(status, statusText, data) {
        this.#status = status;
        this.#statusText = statusText ? statusText : "";
        this.#data = data;
    }
}

/**
 * Event listener for messages received from different loaded pages.
 * @callback COnWindowMessageListener
 * @param {string} origin Where the message originated.
 * @param {any} data The data received from the other window.
 */

/**
 * Wrapper object for receiving and posting messages between pages.
 */
export class CWindowMessenger {
    /** @type {number} */
    static #count = 0;

    /**
     * Removes the callback from the window object.
     */
    close() {
        CWindowMessenger.#count = 0;
        globalThis.onmessage = null;
    }

    /**
     * Sends data to another window.
     * @param {object} params The named parameters
     * @param {string} [params.targetOrigin] Who the message is for.
     * @param {any} params.data The data to send.
     */
    postMessage({targetOrigin, data}) {
        if (targetOrigin) {
            globalThis.postMessage(data, targetOrigin);
        } else {
            globalThis.postMessage(data);
        }
    }

    /**
     * Constructor for the class.
     * @param {COnWindowMessageListener} onMessage The item to parse
     * received messages.
     */
    constructor(onMessage) {
        if (CWindowMessenger.#count >= 1) {
            throw new SyntaxError(
                "Only one CWindowMessenger object can exist"
            );
        }
        CWindowMessenger.#count += 1;
        globalThis.onmessage = (e) => {
            onMessage(e.origin, e.data);
        }
    }
}

/**
 * Provides the collection of all network related items from the Deno / Web
 * Browser APIs. Any communication you need to make with a backend server
 * are handled via this namespace. If you need to build a backend server this
 * namespace will also provide it.
 * @namespace codemelted.codemelted_network
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Beacon_API
 * @see https://developer.mozilla.org/en-US/docs/Web/API/BroadcastChannel
 * @see https://developer.mozilla.org/en-US/docs/Web/API/EventSource
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/fetch
 * @see https://developer.mozilla.org/en-US/docs/Web/API/RequestInit
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage
 */
globalThis["codemelted_network"] = Object.freeze({
    /**
     * Sends an HTTP POST request containing a small amount of data to a web
     * server. It's intended to be used for sending analytics data to a web
     * server, and avoids some of the problems with legacy techniques for
     * sending analytics, such as the use of XMLHttpRequest.
     * @memberof codemelted.codemelted_network
     * @param {object} params The named parameters
     * @param {string} params.url The url hosting the POST
     * @param {BodyInit} [params.data] The data to send.
     * @throws {SyntaxError} This is only available on Web Browser runtime.
     */
    beacon: function({url, data}) {
        codemelted_json.tryType({type: "string", data: url});
        return codemelted_runtime.tryWeb().navigator.sendBeacon(url, data);
    },

    /**
     * Constructs a CBroadcastChannel object for posting messages between
     * pages within the same domain.
     * @memberof codemelted.codemelted_network
     * @param {object} params The named parameters
     * @param {string} params.name The name of the broadcast channel.
     * @param {COnMessageListener} params.onMessage The listener for received
     * messages.
     * @returns {CBroadcastChannel}
     * @throws {SyntaxError} if attempting to utilizing this object on
     * Deno runtime.
     */
    broadcastChannel: function({name, onMessage}) {
        codemelted_runtime.tryDeno();
        codemelted_json.tryType({type: "string", data: name});
        codemelted_json.tryType({type: "function",
            data: onMessage, count: 1});
        return new CBroadcastChannel(name, onMessage);
    },

    /**
     * Implements the ability to fetch a server's REST API endpoint to retrieve
     * and manage data. The actions for the REST API are controlled via the
     * specified action value with optional items to pass to the
     * endpoint. The result is a CFetchResponse wrapping the REST API endpoint
     * response to the request.
     * @memberof codemelted.codemelted_network
     * @param {object} params The named parameters
     * @param {string} params.action "get", "post", "put", "delete".
     * @param {string} params.url The server's hosting API endpoint.
     * @param {boolean} [params.adAuctionHeaders] See RequestInit reference.
     * @param {object} [params.body] See RequestInit reference.
     * @param {string} [params.cache] See RequestInit reference.
     * @param {string} [params.credentials] See RequestInit reference.
     * @param {object} [params.headers] See RequestInit reference.
     * @param {string} [params.integrity] See RequestInit reference.
     * @param {boolean} [params.keepalive] See RequestInit reference.
     * @param {string} [params.mode] See RequestInit reference.
     * @param {string} [params.priority] See RequestInit reference.
     * @param {string} [params.redirect] See RequestInit reference.
     * @param {string} [params.referrer] See RequestInit reference.
     * @param {string} [params.referrerPolicy] See RequestInit reference.
     * @param {AbortSignal} [params.signal] See RequestInit reference.
     * @see https://developer.mozilla.org/en-US/docs/Web/API/RequestInit
     * @returns {Promise<CFetchResponse>} The result of the fetch.
     */
    fetch: async function({
        action,
        url,
        adAuctionHeaders,
        body,
        cache,
        credentials,
        headers,
        integrity,
        keepalive,
        mode,
        priority,
        redirect,
        referrer,
        referrerPolicy,
        signal,
    }) {
        try {
            // Setup the request
            const request = {
                "method": action.toUpperCase()
            };
            if (adAuctionHeaders) {
                Object.defineProperty(
                    request,
                    "adAuctionHeaders",
                    adAuctionHeaders
                );
            }
            if (body) {
                Object.defineProperty(
                    request,
                    "body",
                    body
                );
            }
            if (cache) {
                Object.defineProperty(
                    request,
                    "cache",
                    cache
                );
            }
            if (credentials) {
                Object.defineProperty(
                    request,
                    "credentials",
                    credentials
                );
            }
            if (headers) {
                Object.defineProperty(
                    request,
                    "headers",
                    headers
                );
            }
            if (integrity) {
                Object.defineProperty(
                    request,
                    "integrity",
                    integrity
                );
            }
            if (keepalive) {
                Object.defineProperty(
                    request,
                    "keepalive",
                    keepalive
                );
            }
            if (mode) {
                Object.defineProperty(
                    request,
                    "mode",
                    mode
                );
            }
            if (priority) {
                Object.defineProperty(
                    request,
                    "priority",
                    priority
                );
            }
            if (redirect) {
                Object.defineProperty(
                    request,
                    "redirect",
                    redirect
                );
            }
            if (referrer) {
                Object.defineProperty(
                    request,
                    "referrer",
                    referrer
                );
            }
            if (referrerPolicy) {
                Object.defineProperty(
                    request,
                    "referrerPolicy",
                    referrerPolicy
                );
            }
            if (signal) {
                Object.defineProperty(
                    request,
                    "signal",
                    signal
                );
            }

            // Now go fetch the data
            const resp = await globalThis.fetch(url, request);
            const contentType = resp.headers.get("Content-Type");
            const status = resp.status;
            const statusText = resp.statusText;
            const data = contentType?.toLowerCase().includes("application/json")
                ? await resp.json()
                : contentType?.toLowerCase().includes("form-data")
                    ? await resp.formData()
                    : contentType?.toLowerCase().includes("application/octet-stream")
                        ? await resp.blob()
                        : contentType?.toLowerCase().includes("text/")
                            ? await resp.text()
                            : "";
            return new CFetchResponse(status, statusText, data);
        } catch (err) {
            return new CFetchResponse(
                418,
                `I'm a teapot. ${err.message}`,
                null
            );
        }

    },

    /**
     * Determines if a connection to the Internet exists. Will return null
     * on Deno runtime.
     * @memberof codemelted.codemelted_network
     * @readonly
     * @type {boolean?}
     */
    get online() {
        return codemelted_runtime.isWeb
            ? globalThis.navigator.onLine
            : null;
    },

    /**
     * Constructs a CEventSource object to open a dedicated connection to a
     * HTTP server to receive messages only.
     * @memberof codemelted.codemelted_network
     * @param {object} params The named parameters
     * @param {string} params.url The URL to open the connection to.
     * @param {boolean} [params.withCredentials = false] Whether to open
     * the connection with credentials.
     * @param {COnMessageListener} params.onMessage The listener for received
     * messages.
     * @return {CEventSource} The constructed object.
     */
    serverSentEvents: function({url, withCredentials = false, onMessage}) {
        return new CEventSource(url, withCredentials, onMessage);
    },

    /**
     * Constructs a CWindowMessenger object to allow for communication
     * between pages.
     * @memberof codemelted.codemelted_network
     * @param {object} params The named parameters
     * @param {COnWindowMessageListener} params.onMessage The listener for
     * received data.
     * @returns {CWindowMessenger} The window messenger.
     * @throws {SyntaxError} If you call this within a Deno runtime.
     */
    windowMessenger: function({onMessage}) {
        codemelted_runtime.tryWeb();
        codemelted_json.tryType({
            type: "function",
            data: onMessage,
            count: 2
        });
        return new CWindowMessenger(onMessage);
    },
});

// ----------------------------------------------------------------------------
// [runtime use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Optional parameter for the mailto scheme to facilitate translating the
 * more complicated URL.
 */
export class CMailToParams {
    /**
     * Formatted URL of the object
     * @returns {string}
     */
    toString() {
        let url = "";

        // Go format the mailto part of the url
        url += `${this.mailto};`;
        url = url.substring(0, url.length - 1);

        // Go format the cc part of the url
        let delimiter = "?";
        if (this.cc.length > 0) {
          url += `${delimiter}cc=`;
          delimiter = "&";
          for (const e in this.cc) {
            url += `${e};`;
          }
          url = url.substring(0, url.length - 1);
        }

        // Go format the bcc part of the url
        if (this.bcc.length > 0) {
          url += `${delimiter}bcc=`;
          delimiter = "&";
          for (const e in this.bcc) {
            url += `${e};`;
          }
          url = url.substring(0, url.length - 1);
        }

        // Go format the subject part
        if (this.subject.trim().length > 0) {
          url += `${delimiter}subject=${this.subject.trim()}`;
          delimiter = "&";
        }

        // Go format the body part
        if (this.body.trim().length > 0) {
          url += `${delimiter}body=${this.body.trim()}`;
          delimiter = "&";
        }

        return url;
    }

    /**
     * Constructor for the class.
     * @param {object} params The named parameters
     * @param {string} params.mailto Where to email the message.
     * @param {string[]} [params.cc=[]] Who to CC on the email.
     * @param {string[]} [params.bcc=[]] Who to BCC on the email.
     * @param {string} [params.subject=""] The subject of the email.
     * @param {string} [params.body=""] The body of the email.
     */
    constructor({
        mailto,
        cc = [],
        bcc = [],
        subject = "",
        body = ""
    }) {
        codemelted_json.checkType({type: "string", data: mailto});
        codemelted_json.checkType({type: "array", data: cc});
        codemelted_json.checkType({type: "array", data: bcc});
        codemelted_json.checkType({type: "string", data: subject});
        codemelted_json.checkType({type: "string", data: body});
        this.mailto = mailto;
        this.cc = cc;
        this.bcc = bcc;
        this.subject = subject;
        this.body = body;
    }
}

/**
 * The result of the codemelted_runtime.share function call.
 */
export class CShareResult {
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

    /** @type {number} */
    #status = 0;

    /**
     * Provides the status of the transaction. The codes are constants on this
     * object.
     * @readonly
     * @type {number}
     */
    get status() { return this.#status; }

    /** @type {string} */
    #message = "";

    /**
     * Provides the message associated with any status code that is not 0.
     * @readonly
     * @type {string}
     */
    get message() { return this.#message; }

    /**
     * Constructor for the class.
     * @param {any} ex The exception if one occurred or undefined if the share
     * was successful.
     */
    constructor(ex) {
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

/**
 * Binds a series of properties and utility methods that are specific to the
 * deno / web runtimes.
 * @namespace codemelted.codemelted_runtime
 * @see https://developer.mozilla.org/en-US/docs/Web/API/EventTarget
 * @see https://docs.deno.com/api/deno/
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Window
 */
globalThis["codemelted_runtime"] = Object.freeze({
    /**
     * Adds an event listener either to the global object or to the specified
     * event target.
     * @memberof codemelted.codemelted_runtime
     * @param {object} params The named parameters.
     * @param {string} params.type A case-sensitive string representing the
     * event type to listen for.
     * @param {EventListener} params.listener Callback function to handle the
     * event fired with optional receipt of an event object.
     * @param {EventTarget} [params.obj] The optional EventTarget to attach
     * the event vs. globalThis event listener.
     * @returns {void}
     */
    addEventListener: function({type, listener, obj}) {
        codemelted_json.tryType({type: "string", data: type});
        codemelted_json.tryType({type: "function", data: listener});
        if (!obj) {
            globalThis.addEventListener(type, listener);
        }
        else {
            obj.addEventListener(type, listener);
        }
    },

    /**
     * Gets the name of the browser your page is running.
     * @memberof codemelted.codemelted_runtime
     * @readonly
     * @type {string}
     */
    get browserName() {
        const browserName = this.isWeb
            ? globalThis.navigator.userAgent.toLowerCase()
            : "deno";
        if (browserName.includes("firefox/")) {
            return "firefox";
        } else if (browserName.includes("opr/")
                || browserName.includes("presto/")) {
            return "opera";
        } else if (browserName.includes("mobile/")
                || browserName.includes("version/")) {
            return "safari";
        } else if (browserName.includes("edg/")) {
            return "edge";
        } else if (browserName.includes("chrome/")) {
            return "chrome";
        }

        return browserName == "deno" ? "deno" : "unknown";
    },

    /**
     * Copies data to the system clipboard. Only available on the
     * Web Browser runtime.
     * @memberof codemelted.codemelted_runtime
     * @param {object} params The named parameters.
     * @param {string} params.data The data to copy to the clipboard.
     * @returns {Promise<void>} Of the copy action.
     * @throws {SyntaxError} If attempted on the Deno runtime.
     */
    copyToClipboard: function({data}) {
        return this.tryWeb().navigator.clipboard.writeText(data);
    },

    /**
     * Parses the environment for the given specified key.
     * @memberof codemelted.codemelted_runtime
     * @param {object} params The named parameters.
     * @param {string} params.key The items to search for.
     * @returns {string?} The value associated with the key or null if not
     * found.
     */
    environment: function({key}) {
        if (this.isDeno) {
            const data = this.tryDeno().env.get(key)
            return !data ? null : data;
        }

        const urlParams = new globalThis.URLSearchParams(
            globalThis.location.search
        );
        return urlParams.get(key);
    },

    /**
     * Gets the newline character specific to the operating system.
     * @memberof codemelted.codemelted_runtime
     * @readonly
     * @type {string}
     */
    get eol() {
        return this.osName === "windows" ? "\r\n" : "\n";
    },

    /**
     * Gets the hostname your page is running
     * @memberof codemelted.codemelted_runtime
     * @readonly
     * @type {string}
     */
    get hostname() {
        return this.isDeno
            ? this.tryDeno().hostname()
            : this.tryWeb().location.hostname;
    },

    /**
     * Gets the href of where your page is loaded.
     * @memberof codemelted.codemelted_runtime
     * @readonly
     * @type {string}
     */
    get href() {
        return this.isWeb
            ? this.tryWeb().location.href
            : "";
    },

    /**
     * Determines if the runtime is Deno.
     * @memberof codemelted.codemelted_runtime
     * @readonly
     * @type {boolean}
     */
    get isDeno() {
        return typeof globalThis.Deno === "undefined";
    },

    /**
     * Identifies if you are on desktop or not.
     * @memberof codemelted.codemelted_runtime
     * @readonly
     * @type {boolean}
     */
    get isDesktop() {
        return this.isDeno;
    },

    /**
     * Identifies if you are on mobile or not.
     * @memberof codemelted.codemelted_runtime
     * @readonly
     * @type {boolean}
     */
    get isMobile() {
        const osName = this.osName;
        return osName.includes("android") ||
            osName.includes("ios");
    },

    /**
     * Determines if the running page is an installed Progressive Web App.
     * @memberof codemelted.codemelted_runtime
     * @readonly
     * @type {boolean}
     */
    get isPWA() {
        if (this.isWeb) {
            const queries = [
                '(display-mode: fullscreen)',
                '(display-mode: standalone)',
                '(display-mode: minimal-ui),'
            ];
            let pwaDetected = false;
            for (const query in queries) {
                pwaDetected = pwaDetected || globalThis.matchMedia(query).matches;
            }
            return pwaDetected;
        }
        return false;
    },

    /**
     * Determines if the runtime is Web Browser.
     * @memberof codemelted.codemelted_runtime
     * @readonly
     * @type {boolean}
     */
    get isWeb() {
        return !this.isDeno;
    },

    /**
     * Loads a specified resource into a new or existing browsing context
     * (that is, a tab, a window, or an iframe) under a specified name. These
     * are based on the different scheme supported protocol items.
     * @memberof codemelted.codemelted_runtime
     * @param {object} params The named parameters.
     * @param {string} params.scheme Either "file:", "http://",
     * "https://", "mailto:", "tel:", or "sms:".
     * @param {boolean} [params.popupWindow = false] true to open a new
     * popup browser window. false to utilize the _target for browser
     * behavior.
     * @param {CMailToParams} [params.mailtoParams] Object to assist in the
     * mailto: scheme URL construction.
     * @param {string} [params.url] The url to utilize with the scheme.
     * @param {string} [params.target = "_blank"] The target to utilize when
     * opening the scheme. Only valid when not utilizing popupWindow.
     * @param {number} [params.width] The width to open the window with.
     * @param {number} [params.height] The height to open the window with.
     * @returns {Promise<Window | null>} The result of the transaction.
     */
    open: function({scheme, popupWindow = false, mailtoParams, url,
            target = "_blank", width, height}) {
        return new Promise((resolve, reject) => {
            try {
                let urlToLaunch = "";
                if (scheme === "file:" ||
                    scheme === "http://" ||
                    scheme === "https://" ||
                    scheme === "sms:" ||
                    scheme === "tel:") {
                  urlToLaunch = `${scheme}${url}`;
                } else if (scheme === "mailto:") {
                  urlToLaunch = mailtoParams != null
                      ? `mailto:${mailtoParams.toString()}`
                      : `mailto:${url}`;
                } else {
                    throw new SyntaxError("Invalid scheme specified");
                }

                let rtnval = null;
                if (popupWindow) {
                    const w = width ?? 900.0;
                    const h = height ?? 600.0;
                    const top = (this.tryWeb().screen.height - h) / 2;
                    const left = (this.tryWeb().screen.width - w) / 2;
                    const settings = "toolbar=no, location=no, " +
                        "directories=no, status=no, menubar=no, " +
                        "scrollbars=no, resizable=yes, copyhistory=no, " +
                        `width=${w}, height=${h}, top=${top}, left=${left}`;
                    rtnval = this.tryWeb().open(
                      urlToLaunch,
                      "_blank",
                      settings,
                    );
                  }

                  rtnval = this.tryWeb().open(urlToLaunch, target);
                  resolve(rtnval);
            } catch (err) {
                reject(err);
            }
        });
    },

    /**
     * Gets the name of the operating system your page is running.
     * @memberof codemelted.codemelted_runtime
     * @readonly
     * @type {string}
     */
    get osName() {
        const osName = this.isDeno
            ? this.tryDeno().build.os
            : this.tryWeb().navigator.userAgent.toLowerCase();

        if (osName.includes("android")) {
            return "android";
        } else if (osName.includes("ios") || osName.includes("iphone")
            || osName.includes("ipad")) {
            return "ios";
        } else if (osName.includes("linux")) {
            return "linux";
        } else if (osName.includes("mac")) {
            return "macos";
        } else if (osName.includes("windows")) {
            return "windows";
        }

        return "unknown";
    },

    /**
     * Will open a print dialog when running in a Web Browser.
     * @memberof codemelted.codemelted_runtime
     * @returns {void}
     * @throws {SyntaxError} if you attempt to call this in Deno runtime.
     */
    print: function() {
        this.tryWeb().print();
    },

    /**
     * Removes an event listener either to the global object or to the
     * specified event target.
     * @memberof codemelted.codemelted_runtime
     * @param {object} params The named parameters.
     * @param {string} params.type A case-sensitive string representing the
     * event type to listen for.
     * @param {EventListener} params.listener Callback function to handle the
     * event fired with optional receipt of an event object.
     * @param {EventTarget} [params.obj] The optional EventTarget to attach
     * the event vs. globalThis event listener.
     * @returns {void}
     */
    removeEventListener: function({type, listener, obj}) {
        codemelted_json.tryType({type: "string", data: type});
        codemelted_json.tryType({type: "function", data: listener});
        if (!obj) {
            globalThis.removeEventListener(type, listener);
        }
        else {
            obj.removeEventListener(type, listener);
        }
    },

    /**
     * Provides the ability to share items via the share services. You specify
     * options via the shareData object parameters. Only available on the web
     * browser runtime.
     * @memberof codemelted.codemelted_runtime
     * @param {object} params The named parameters.
     * @param {object} params.shareData The object specifying the data to
     * share.
     * @returns {Promise<CShareResult>} The result of the call.
     */
    share: async function({shareData}) {
        try {
            await this.tryWeb().navigator.share(shareData);
            return new CShareResult(undefined);
        } catch (err) {
            return new CShareResult(err);
        }
    },

    /**
     * Determines if we are running in a Deno Runtime or not.
     * @memberof codemelted.codemelted_runtime
     * @returns {Deno} namespace reference.
     * @throws {SyntaxError} If not running in a Deno Runtime.
     */
    tryDeno: function() {
        if (!this.isDeno) {
            throw new SyntaxError("Not Running in a Deno Runtime.");
        }
        return globalThis.Deno;
    },

    /**
     * Determines if we are running in a Web Browser environment or not.
     * @memberof codemelted.codemelted_runtime
     * @returns {Window} Reference to the browser window.
     * @throws {SyntaxError} If not running in a browser environment.
     */
    tryWeb: function() {
        if (!this.isDeno) {
            throw new SyntaxError("Not Running in a Web Runtime.");
        }
        return globalThis.window;
    },
});

// ----------------------------------------------------------------------------
// [storage use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Provides the ability to manage a key / value pair within the targeted
 * runtime environment. The storage methods of "local" and "session" are
 * supported on both Deno and Web Browsers. "cookie" method is only supported
 * on Web Browser and will result in a SyntaxError if called in a Deno
 * runtime.
 * @namespace codemelted.codemelted_storage
 * @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API
 */
globalThis["codemelted_storage"] = Object.freeze({
    /**
     * Clears the specified storage method.
     * @memberof codemelted.codemelted_storage
     * @param {object} params The named parameters.
     * @param {string} [params.method="local"] Values of cookie, local, or
     * session.
     * @returns {void}
     */
    clear: function({method = "local"}) {
        if (method === "local") {
            globalThis.localStorage.clear();
        } else if (method === "session") {
            globalThis.sessionStorage.clear();
        } else if (method === "cookie") {
            codemelted_runtime.tryWeb().document.cookie = "";
        }

        throw new SyntaxError("Invalid method specified");
    },

    /**
     * Gets data from the identified method via the specified key.
     * @memberof codemelted.codemelted_storage
     * @param {object} params The named parameters.
     * @param {string} [params.method="local"] Values of cookie, local, or
     * session.
     * @param {string} params.key The key field to retrieve.
     * @returns {string?} The associated with the key or null if not found.
     */
    getItem: function({method = "local", key}) {
        codemelted_json.tryType({type: "string", data: key});
        if (method === "local") {
            return globalThis.localStorage.getItem(key);
        } else if (method === "session") {
            return globalThis.sessionStorage.getItem(key);
        } else if (method === "cookie") {
            const name = `${key}=`;
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
    },

    /**
     * Total items stored in the identified method.
     * @memberof codemelted.codemelted_storage
     * @param {object} params The named parameters.
     * @param {string} [params.method="local"] Values of cookie, local, or
     * session.
     * @returns {number} The number of key / value pairs stored within the
     * storage method.
     */
    length: function({method = "local"}) {
        if (method === "local") {
            return globalThis.localStorage.length;
        } else if (method === "session") {
            return globalThis.localStorage.length;
        } else if (method === "cookie") {
            const ca = codemelted_runtime.tryWeb().document.cookie.split(";");
            return ca.length;
        }

        throw new SyntaxError("Invalid method specified");
    },

    /**
     * Gets the key from the index from the identified storage method.
     * @memberof codemelted.codemelted_storage
     * @param {object} params The named parameters.
     * @param {string} [params.method="local"] Values of cookie, local, or
     * session.
     * @param {number} params.index The index of where the key exists in
     * storage.
     * @returns {String?} The name of the key or null if the index goes
     * beyond the stored length.
     */
    key: function({method = "local", index}) {
        codemelted_json.tryType({type: "number", data: index});
        if (method === "local") {
            return globalThis.localStorage.key(index);
        } else if (method === "session") {
            return globalThis.sessionStorage.key(index);
        } else if (method === "cookie") {
            const ca = codemelted_runtime.tryWeb().document.cookie.split(";");
            if (ca.length >= index) {
                return null;
            }
            const key = ca[index].split("=");
            return key[0];
        }

        throw new SyntaxError("Invalid method specified");
    },

    /**
     * Removes an item by key from the identified storage method.
     * @memberof codemelted.codemelted_storage
     * @param {object} params The named parameters.
     * @param {string} [params.method="local"] Values of cookie, local, or
     * session.
     * @param {string} params.key The key field to remove.
     * @returns {void}
     */
    removeItem: function({method = "local", key}) {
        codemelted_json.tryType({type: "string", data: key});
        if (method === "local") {
            globalThis.localStorage.removeItem(key);
        } else if (method === "session") {
            globalThis.sessionStorage.removeItem(key);
        } else if (method === "cookie") {
            codemelted_runtime.tryWeb().document.cookie =
                `${key}=; expires=01 Jan 1970 00:00:00; path=/;`;
        }

        throw new SyntaxError("Invalid method specified");
    },

    /**
     * Sets a value by the identified key within the identified storage
     * method.
     * @memberof codemelted.codemelted_storage
     * @param {object} params The named parameters.
     * @param {string} [params.method="local"] Values of cookie, local, or
     * session.
     * @param {string} params.key The identified key to associate with
     * the value.
     * @param {string} params.value The value to set.
     * @returns {void}
     */
    setItem: function({method = "local", key, value}) {
        codemelted_json.tryType({type: "string", data: key});
        codemelted_json.tryType({type: "string", data: value});
        if (method === "local") {
            globalThis.localStorage.setItem(key, value);
        } else if (method === "session") {
            globalThis.sessionStorage.setItem(key, value);
        } else if (method === "cookie") {
            const d = new Date();
            d.setTime(d.getTime() + (365 * 24 * 60 * 60 * 1000));
            const expires = "expires="+ d.toUTCString();
            codemelted_runtime.tryWeb().document.cookie =
                `${key}=${value}; ${expires}; path=/`;
        }

        throw new SyntaxError("Invalid method specified");
    }
});

// ----------------------------------------------------------------------------
// [ui use case] --------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * UNDER DEVELOPMENT
 * @namespace codemelted.codemelted_ui
 */
globalThis["codemelted_ui"] = Object.freeze({
    //
});