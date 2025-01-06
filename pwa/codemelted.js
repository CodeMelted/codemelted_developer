// @ts-check
// ============================================================================
/**
 * @file The JavaScript implementation of the CodeMelted DEV | PWA Modules.
 * @author Mark Shaffer
 * @version 0.3.1 (Last Modified 2025-01-05) <br />
 * 0.3.1 (2025-01-05): <br />
 * - Fleshed out the Async I/O use cases. Not tested. <br />
 * - Brought in all previous prototype work into the finalized module <br />
 *   design. <br />
 * 0.3.0 (2024-12-28): <br />
 * - Completed the testing / documenting of the console namespace. <br />
 * - Completed testing / documenting of the disk use case. <br />
 * - Completed testing / documenting of the json use case. <br />
 * @license MIT <br />
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * <br /><br />
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * <br /><br />
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 * @see https://developer.codemelted.com (For references)
 */
// ============================================================================

// ----------------------------------------------------------------------------
// [Module Data Definitions] --------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * @typedef {object} CModuleEvent_t
 * @property {"data" | "error" | "status"} type Identifies the type of event
 * handled by the module.
 * @property {any} data The data that corresponds to the module event along
 * with the particular callback it is servicing.
 */

/**
 * The task to run as part of the different module async functions.
 * @callback CModuleEventListener_t
 * @param {CModuleEvent_t} [data] The data to process on the backend.
 * @returns {void}
 */

/**
 * Implements the Worker Pool of background processing worker objects.
 * @private
 */
class CWorkerPool {
  /**
   * Posts dynamic data to the background worker.
   * @param {any} data The data to transmit.
   * @returns {void}
   */
  postMessage(data) {
    this.currentIndex += 1;
    if (this.currentIndex >= this.workerPool.length) {
      this.currentIndex = 0;
    }
    this.workerPool[this.currentIndex].postMessage(data);
  }

  /**
   * Terminates the dedicated background worker.
   * @returns {void}
   */
  terminate() {
    // this.#worker?.terminate();
  }

  /**
   * Constructor for the worker.
   * @param {CModuleEventListener_t} onDataReceived The callback for received data.
   * @param {string} url The URL of the dedicated worker.
   */
  constructor(onDataReceived, url) {
    this.currentIndex = 0;
    this.workerPool = [];
    for (let x = 0; x < worker.hardwareConcurrency; x++) {
      const worker = new Worker(url, {type: "module"});
      worker.onerror = (e) => {
        onDataReceived({type: "error", data: e.error});
      }
      worker.onmessageerror = (e) => {
        onDataReceived({type: "error", data: e.data});
      }
      worker.onmessage = (e) => {
        onDataReceived({type: "data", data: e.data});
      }
      this.workerPool.push(worker);
    }
  }
}

/**
 * Holds the common definitions to support the overall module implementation
 * and runtimes.
 * @private
 */
class ModuleDataDefinition {
  /** @type {string} */
  static error = ""

  /** @type {number} */
  static logLevel = 2;

  /** @type {COnLogEventListener_t?} */
  static onLogEvent = null;

  /**
   * Creates a log record object.
   * @param {number} level The log level of the log event
   * @param {any} data The data associated with the event.
   * @returns {CLogRecord_t}
   */
  static createLogRecord(level, data) {
    return {
      time: new Date(),
      level: level,
      data: data,
      stack: json.checkType({type: Error, data: data})
        ? data.stack
        : null,
      toString: function() {
        const levelStr = this.level === 0
          ? "debug"
          : this.level === 1
            ? "info"
            : this.level === 2
              ? "warning"
              : "error";
        let msg = `${this.time.toISOString()} [${levelStr}]: ${this.data}`;
        msg = this.stack != null ? `${msg}\n${this.stack}` : msg;
        return msg;
      }
    }
  }

  /**
   * Tracks the module allocated objects for later cleanup.
   * @type {object}
   */
  static objectTracker = {};

  /**
   * The current id of an allocated module resource.
   * @type {number}
   */
  static #trackingId = 0;

  /**
   * Takes an object created by the module and adds it for tracking.
   * @param {any} obj The object to be tracked
   * @returns {number} The new tracking id to utilize with the module.
   */
  static allocateTrackingId(obj) {
    ModuleDataDefinition.#trackingId += 1;
    // @ts-ignore Deno can't handle a hash tracked with numbers but it is valid.
    ModuleDataDefinition.objectTracker[ModuleDataDefinition.#trackingId] = obj;
    return ModuleDataDefinition.#trackingId;
  }

  /**
   * Removes the tracked object.
   * @param {number} trackingId The tracking id to retrieve.
   * @returns {any} The object tracked and removed from the module tracking.
   */
  static deallocateTrackingId(trackingId) {
    // @ts-ignore Deno can't figure out object properties for valid javascript.
    const obj = ModuleDataDefinition.objectTracker[trackingId];
    if (obj) {
    // @ts-ignore Deno can't figure out object properties for valid javascript.
      delete ModuleDataDefinition.objectTracker[trackingId];
    }
    return obj;
  }

  /**
   * Resets the failure reason for each use case transaction.
   * @param {any} err The error to handle and set.
   * @returns {void}
   */
  static handleError(err = undefined) {
    if (err) {
      if (err instanceof Error) {
        ModuleDataDefinition.error = err.message;
      } else if ("toString" in err) {
        ModuleDataDefinition.error = err.toString();
      } else if (json.checkType({type: "string", data: err})) {
        ModuleDataDefinition.error = err;
      } else {
        ModuleDataDefinition.error = "unknown";
      }
    } else {
      ModuleDataDefinition.error = "";
    }
  }

  /** @type {CWorkerPool | undefined} */
  static workerPool = undefined;
}

// ----------------------------------------------------------------------------
// [Audio Use Case] -----------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: To Be Developed.

// ----------------------------------------------------------------------------
// [Console Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Provides the console use case function to gather data via a
 * terminal. The actions correspond to the type of input / output
 * that will be interacted with via STDIN and STDOUT.
 * @namespace console
 */
const console = Object.freeze({
  /**
   * Alerts a message to STDOUT with a [Enter] to halt execution.
   * @memberof console
   * @param {object} params
   * @param {string} [params.message = ""] The message to display to STDOUT.
   * Not specifying will simple pause until [ENTER] is pressed.
   * @returns {void}
   */
  alert: function({message = ""} = {}) {
    runtime.tryDeno();
    json.tryType({type: "string", data: message});
    globalThis.alert(message);
  },

  /**
   * Prompts a [y/N] to STDOUT with the message as a question.
   * @memberof console
   * @param {object} params
   * @param {string} [params.message = "CONFIRM"] The message to display to STDOUT.
   * @returns {boolean} true if y selected, false otherwise.
   */
  confirm: function({message = "CONFIRM"} = {}) {
    runtime.tryDeno();
    json.tryType({type: "string", data: message});
    return globalThis.confirm(message);
  },

  /**
   * Prompts a list of choices for the user to select from.
   * @memberof console
   * @param {object} params
   * @param {string} [params.message = "CHOOSE"] The message to display to STDOUT.
   * @param {string[]} params.choices The choices to select from.
   * @returns {number} The index of the chosen item.
   */
  choose: function({message = "CHOOSE", choices = []}) {
    runtime.tryDeno();
    json.tryType({type: "string", data: message});
    json.tryType({type: Array, data: choices});
    if (message === "" || choices.length === 0) {
      throw new SyntaxError("Parameters were not set!");
    }

    let answer = -1;
    do {
      globalThis.console.log();
      globalThis.console.log("-".repeat(message.length));
      globalThis.console.log(message);
      globalThis.console.log("-".repeat(message.length));
      globalThis.console.log();
      choices.forEach((v, index) => {
        globalThis.console.log(`${index}. ${v}`);
      });
      globalThis.console.log();
      answer = parseInt(globalThis.prompt(
        `Make a Selection [0 - ${choices.length - 1}]:`
      ) ?? "-1");
      if (isNaN(answer) || answer >= choices.length) {
        globalThis.console.log(
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
   * @memberof console
   * @param {object} params
   * @param {string} [params.message = "PASSWORD"] The message to display
   * to STDOUT.
   * @returns {string} The typed password.
   */
  password: function({message = "PASSWORD"} = {}) {
    // Setup our variables
    const deno = runtime.tryDeno();
    json.tryType({type: "string", data: message});
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
    answer = answer.replaceAll("\r", "");
    answer = answer.replaceAll("\n", "");
    return answer;
  },

  /**
   * Prompts to STDOUT and returns the typed message via STDIN.
   * @memberof console
   * @param {object} params
   * @param {string} [params.message = "PROMPT"] The message to display to
   * STDOUT.
   * @returns {string?} The result typed.
   */
  prompt: function({message = "PROMPT:"} = {}) {
    runtime.tryDeno();
    json.tryType({type: "string", data: message});
    return globalThis.prompt(message);
  },

  /**
   * Write a message to STDOUT.
   * @memberof console
   * @param {object} params
   * @param {string} [params.message = ""] The message to display to STDOUT.
   * @returns {void}
   */
  writeln: function({message = ""} = {}) {
    runtime.tryDeno();
    json.tryType({type: "string", data: message});
    globalThis.console.log(message);
  },
});

// ----------------------------------------------------------------------------
// [Database Use Case] --------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: To Be Developed.

// ----------------------------------------------------------------------------
// [Dialog Use Case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: To Be Developed.

// ----------------------------------------------------------------------------
// [Disk Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Provides the ability to manage items on disk. This includes file /
 * directory manipulation, queryable properties, and reading / writing entire
 * files.
 * @namespace disk
 * @see https://codemelted.com/developer/use_cases/disk.html
 */
const disk = Object.freeze({
  /**
   * Copies a file / directory from its currently source location to the
   * specified destination.
   * @memberof disk
   * @param {object} params
   * @param {string} params.src The source item to copy.
   * @param {string} params.dest The destination of where to copy the item.
   * @returns {boolean} true if carried out, false otherwise. Check strerror
   * for details of failure.
   */
  cp: function({src, dest}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: src});
      json.tryType({type: "string", data: dest});
      deno.copyFileSync(src, dest);
      return true;
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      ModuleDataDefinition.handleError(err);
      return false;
    }
  },

  /**
   * Determines if the specified item exists.
   * @memberof disk
   * @param {object} params
   * @param {string} params.filename The path to a directory or file.
   * @returns {Deno.FileInfo?} The file information or null if it does not
   * exist.
   */
  exists: function({filename}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: filename});
      return deno.statSync(filename);
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      ModuleDataDefinition.handleError(err);
      return null;
    }
  },

  /**
   * Identifies the user's home directory on disk. Null is returned if it
   * cannot be found or running on web environment. Check codemelted.strerror
   * if you did not expect null.
   * @memberof disk
   * @readonly
   * @type {string?}
   */
  get homePath() {
    ModuleDataDefinition.handleError();
    try {
      return runtime.tryDeno().env.get("HOME")
        || runtime.tryDeno().env.get("USERPROFILE")
        || null;
    } catch (err) {
      ModuleDataDefinition.handleError(err);
      return null;
    }
  },

  /**
   * List the files in the specified source location.
   * @memberof disk
   * @param {object} params
   * @param {string} params.filename The directory to list.
   * @returns {Deno.FileInfo[]?} Array of files found.
   */
  ls: function({filename}) {
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: filename});
      const dirList = deno.readDirSync(filename);
      const fileInfoList = [];
      for (const dirEntry of dirList) {
        const fileInfo = deno.lstatSync(
          `${filename}/${dirEntry.name}`
        );
        fileInfoList.push(fileInfo);
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
   * @memberof disk
   * @param {object} params
   * @param {string} params.filename The source item to create.
   * @returns {boolean}
   */
  mkdir: function({filename}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: filename});
      deno.mkdirSync(filename);
      return true;
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      ModuleDataDefinition.handleError(err);
      return false;
    }
  },

  /**
   * Moves a file / directory from its currently source location to the
   * specified destination.
   * @memberof disk
   * @param {object} params
   * @param {string} params.src The source item to move.
   * @param {string} params.dest The destination of where to move the item.
   * @returns {boolean} true if carried out, false otherwise. Check strerror
   * for details of failure.
   */
  mv: function({src, dest}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: src});
      json.tryType({type: "string", data: dest});
      deno.renameSync(src, dest);
      return true;
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      ModuleDataDefinition.handleError(err);
      return false;
    }
  },

  /**
   * Identifies the path separator for files on disk.
   * @memberof disk
   * @readonly
   * @type {string}
   */
  get pathSeparator() {
    return runtime.osName === "windows"
      ? "\\"
      : "/"
  },

  /**
   * Removes a file or directory at the specified location.
   * @memberof disk
   * @param {object} params
   * @param {string} params.filename The source item to remove.
   * @returns {boolean} true if carried out, false otherwise. Check strerror
   * for details of failure.
   */
  rm: function({filename}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: filename});
      deno.removeSync(filename, {recursive: true});
      return true;
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      ModuleDataDefinition.handleError(err);
      return false;
    }
  },

  /**
   * Identifies the temp directory on disk. Null is returned if it cannot be
   * found or running on web environment. Check codemelted.strerror if you
   * did not expect null.
   * @memberof disk
   * @readonly
   * @type {string?}
   */
  get tempPath() {
    ModuleDataDefinition.handleError();
    try {
      return runtime.tryDeno().env.get("TMPDIR")
        || runtime.tryDeno().env.get("TMP")
        || runtime.tryDeno().env.get("TEMP")
        || "/tmp";
    } catch (err) {
      ModuleDataDefinition.handleError(err);
      return null;
    }
  },
});

// ----------------------------------------------------------------------------
// [File Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace file
 */
const file = Object.freeze({
  /**
   * Gets the newline character specific to the operating system.
   * @memberof file
   * @readonly
   * @type {string}
   */
  get eol() {
    return runtime.osName === "windows" ? "\r\n" : "\n";
  },

  /**
   * Reads an entire file from disk.
   * @memberof file
   * @param {object} params
   * @param {string} params.filename The file to open
   * @param {boolean} [params.isTextFile = true] True if text file, false if
   * a Uint8Array data.
   * @param {string} [params.accept = ""] A comma separated list of accepted files
   * on an open dialog. Specifying nothing will yield all files. NOTE: This
   * is only available on web target.
   * @returns {Promise<string | Uint8Array>} Expected data object or
   * null. Check strerror for details of null.
   */
  readEntireFile: function({
    filename,
    isTextFile = true,
    accept = "",
  }) {
    return new Promise((resolve, reject) => {
      ModuleDataDefinition.handleError();
      try {
        if (runtime.isDeno) {
          const deno = runtime.tryDeno();
          json.tryType({type: "string", data: filename});
          json.tryType({type: "boolean", data: isTextFile});
          if (isTextFile) {
            resolve(deno.readTextFileSync(filename));
          } else {
            resolve(deno.readFileSync(filename));
          }
        } else {
          json.tryType({type: "string", data: accept});
          // @ts-ignore: globalThis will have a document object
          const input = globalThis.document.createElement("input");
          input.type = "file";
          input.accept = accept;
          input.onchange = async () => {
            let file = undefined;
            if (input.files != null) {
              file = input.files[0];
              if (isTextFile) {
                const buffer = await file.arrayBuffer();
                const decoder = new TextDecoder();
                resolve(decoder.decode(buffer));
              } else {
                const bytes = await file.bytes();
                resolve(bytes);
              }
            }
          };
          input.click();
        }
      } catch (err) {
        if (err instanceof SyntaxError) {
          throw err;
        }
        ModuleDataDefinition.handleError(err);
        reject(err);
      }
    });
  },

  /**
   * Writes an entire file to disk.
   * @memberof file
   * @param {object} params
   * @param {string} params.filename What / where to save the file.
   * For the web target this will default to the download directory.
   * @param {string | Uint8Array} params.data The data to save to the file.
   * @param {boolean} [params.append = false] Whether to append the data or
   * create a new file. Only valid on deno runtime.
   * @returns {Promise<void>} true if successful, false otherwise. Check
   * codemelted.strerror if false is returned to know why.
   */
  writeEntireFile({
    filename,
    data,
    append = false,
  }) {
    return new Promise((resolve, reject) => {
      ModuleDataDefinition.handleError();
      try {
        json.tryType({type: "string", data: filename});

        if (runtime.isDeno) {
          const deno = runtime.tryDeno();
          json.tryType({type: "boolean", data: append});
          if (json.checkType({type: "string", data: data})) {
            // @ts-ignore: checked via tryType call
            deno.writeTextFileSync(filename, data, append);
          } else if (json.checkType({type: Uint8Array, data: data})) {
            // @ts-ignore: checked via tryType call
            deno.writeFileSync(filename, data, append);
          } else {
            throw new SyntaxError("data is not of an expected type");
          }

          resolve();
        } else {
          let blobURL = undefined;
          if (json.checkType({type: "string", data: data})) {
            // @ts-ignore: checked via checkType above
            const buffer = new TextEncoder().encode(data);
            const blob = new Blob([buffer]);
            blobURL = URL.createObjectURL(blob);
          } else if (json.checkType({type: Uint8Array, data: data})) {
            // @ts-ignore: checked via checkType above
            const blob = new Blob([data]);
            blobURL = URL.createObjectURL(blob);
          } else {
            throw new SyntaxError("data is not of an expected type");
          }

          // Create the `<a download>` element and append it invisibly.
          // @ts-ignore: globalThis will have a document object
          const a = globalThis.document.createElement('a');
          a.href = blobURL;
          // @ts-ignore: checked via tryType call
          a.download = filename;
          a.style.display = 'none';
          // @ts-ignore: globalThis will have a document object
          globalThis.document.body.append(a);

          // Programmatically click the element.
          a.click();

          // Revoke the blob URL and remove the element.
          setTimeout(() => {
            URL.revokeObjectURL(blobURL);
            a.remove();
            resolve();
          }, 500);
        }
      } catch (err) {
        if (err instanceof SyntaxError) {
          throw err;
        }
        ModuleDataDefinition.handleError(err);
        reject(err);
      }
    });
  },
});

// ----------------------------------------------------------------------------
// [Hardware Use Case] --------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: To Be Developed.

// ----------------------------------------------------------------------------
// [JSON Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Defines a set of utility methods for performing data conversions for JSON
 * along with data validation.
 * @namespace json
 */
const json = Object.freeze({
  /**
   * Converts a string to a boolean
   * @memberof json
   * @param {object} params
   * @param {string} params.data The object to check for the key.
   * @returns {boolean} true if a truthy string, false otherwise.
   */
  asBool: function({data}) {
    try {
      const trueStrings = [
        "true",
        "1",
        "t",
        "y",
        "yes",
        "yeah",
        "yup",
        "certainly",
        "uh-huh"
      ];

      const compareStr = String(data);
      return trueStrings.includes(compareStr.toLowerCase());
    } catch (_err) {
      return false;
    }
  },

  /**
   * Converts a string to a integer number
   * @memberof json
   * @param {object} params
   * @param {string} params.data The object to check for the key.
   * @returns {number?}
   */
  asDouble: function({data}) {
    const convertedValue = parseFloat(data ?? "wrong");
    return !isNaN(convertedValue) ? convertedValue : null;
  },

  /**
   * Converts a string to a integer number
   * @memberof json
   * @param {object} params
   * @param {string} params.data The object to check for the key.
   * @returns {number?}
   */
  asInt: function({data}) {
    const convertedValue = parseInt(data ?? "wrong");
    return !isNaN(convertedValue) ? convertedValue : null;
  },

  /**
   * Determines if the specified object has the specified property.
   * @memberof json
   * @param {object} params
   * @param {object} params.obj The object to check for the key.
   * @param {string} params.key The property to check for.
   * @returns {boolean} true if property was found, false otherwise.
   */
  checkHasProperty: function({obj, key}) {
    try {
      return Object.hasOwn(obj, key);
    } catch (err) {
      throw new SyntaxError(`${err}`);
    }
  },

  /**
   * Utility to check parameters of a function to ensure they are of an
   * expected type.
   * @memberof json
   * @param {object} params
   * @param {string | any} params.type The specified type to check the data
   * against.
   * @param {any} params.data The parameter to be checked.
   * @param {number | undefined} [params.count] Checks the data parameter
   * function signature to ensure the appropriate number of parameters are
   * specified.
   * @returns {boolean} true if it meets the expectations, false otherwise.
   */
  checkType: function({type, data, count = undefined}) {
    try {
      const isExpectedType = typeof type !== "string"
      ? (data instanceof type)
      // deno-lint-ignore valid-typeof
      : typeof data === type;
    return typeof count === "number"
      ? isExpectedType && data.length === count
      : isExpectedType;
    } catch (err) {
      throw new SyntaxError(`${err}`);
    }
  },

  /**
   * Checks for a valid URL.
   * @memberof json
   * @param {object} params
   * @param {string} params.data String to parse to see if it is a valid URL.
   * @returns {boolean} true if valid, false otherwise.
   */
  checkValidUrl: function({data}) {
    ModuleDataDefinition.handleError();
    let url = undefined;
    try {
      url = new URL(data);
    }
    catch (err) {
      url = undefined;
      ModuleDataDefinition.handleError(err);
    }

    return this.checkType({type: URL, data: url});
  },

  /**
   * Creates a new JSON compliant array with the ability to copy data.
   * @memberof json
   * @param {object} params
   * @param {Array<any>} params.data An array to make a copy.
   * @returns {Array<any>}
   */
  createArray: function({data}) {
    return this.checkType({type: Array, data: data})
      ? Array.from(data)
      : [];
  },

  /**
   * Creates a new JSON compliant object with the ability to copy data.
   * @memberof json
   * @param {object} params
   * @param {object} params.data An array to make a copy.
   * @returns {object}
   */
  createObject: function({data}) {
    return this.checkType({type: "object", data: data})
      ? Object.assign({}, data)
      : {};
  },

  /**
   * Converts a string to a JavaScript object.
   * @memberof json
   * @param {object} params
   * @param {string} params.data The data to parse.
   * @returns {object | null} Object or null if the parse failed.
   */
  parse: function({data}) {
    ModuleDataDefinition.handleError();
    try {
      return JSON.parse(data);
    }
    catch (err) {
      ModuleDataDefinition.handleError(err);
      return null;
    }
  },

  /**
   * Converts a JavaScript object into a string.
   * @memberof json
   * @param {object} params
   * @param {object} params.data An object with valid JSON attributes.
   * @returns {string | null} The string representation or null if the
   * stringify failed.
   */
  stringify: function({data}) {
    ModuleDataDefinition.handleError();
    try {
      return JSON.stringify(data);
    }
    catch (err) {
      ModuleDataDefinition.handleError(err);
      return null;
    }
  },

  /**
   * Determines if the specified object has the specified property.
   * @memberof json
   * @param {object} params
   * @param {object} params.obj The object to check for the key.
   * @param {string} params.key The property to check for.
   * @returns {void}
   * @throws {SyntaxError} if the property is not found.
   */
  tryHasProperty: function({obj, key}) {
    if (!this.checkHasProperty({obj: obj, key: key})) {
      throw new SyntaxError("obj does not have the specified property");
    }
  },

  /**
   * Utility to check parameters of a function to ensure they are of an
   * expected type.
   * @memberof json
   * @param {object} params
   * @param {string | any} params.type The specified type to check the data
   * against.
   * @param {any} params.data The parameter to be checked.
   * @param {number} [params.count] Checks the data parameter function
   * signature to ensure the appropriate number of parameters are
   * specified.
   * @returns {void}
   * @throws {SyntaxError} if the type was not as expected
   */
  tryType: function({type, data, count = undefined}) {
    if (!this.checkType({type: type, data: data, count: count})) {
      throw new SyntaxError("data is not of expected type.");
    }
  },

  /**
   * Checks for a valid URL.
   * @memberof json
   * @param {object} params
   * @param {string} params.data String to parse to see if it is a valid
   * URL.
   * @returns {void}
   * @throws {SyntaxError} If v is not a valid url.
   */
  tryValidUrl: function({data}) {
    if (!this.checkValidUrl({data: data})) {
      throw new SyntaxError("data is not a valid url");
    }
  },
});

// ----------------------------------------------------------------------------
// [Logger Use Case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * The formatted log record when an item is logged.
 * @typedef {object} CLogRecord_t
 * @property {Date} time The time the event was encountered.
 * @property {number} level The level of the event.
 * @property {any} data The data associated with the event.
 * @property {string?} stack Stack trace of where the error occurred.
 * @property {function} toString Translates a string representation of the
 * event.
 */

/**
 * Handler to support post processing of a logged event.
 * @callback COnLogEventListener_t
 * @param {CLogRecord_t} record The recorded log event for post processing.
 * @returns {void}
 */

/**
 * Defines a set of utility methods for performing data conversions for JSON
 * along with data validation.
 * @private
 * @namespace logger
 */
const _logger = Object.freeze({
  /**
   * debug log level.
   * @memberof logger
   * @readonly
   * @type {number}
   */
  get debugLevel() { return 0; },

  /**
   * info log level.
   * @memberof logger
   * @readonly
   * @type {number}
   */
  get infoLevel() { return 1; },

  /**
   * warning log level.
   * @memberof logger
   * @readonly
   * @type {number}
   */
  get warningLevel() { return 2; },

  /**
   * error log level.
   * @memberof logger
   * @readonly
   * @type {number}
   */
  get errorLevel() { return 3; },

  /**
   * off log level.
   * @memberof logger
   * @readonly
   * @type {number}
   */
  get offLevel() { return 4; },

  /**
   * The current log level for the module as set by the namespaced
   * constants.
   * @memberof logger
   * @type {number}
   */
  set level(v) {
    json.checkType({type: "number", data: v});
    if (v < this.debugLevel || v > this.offLevel) {
      throw new SyntaxError("level not set in valid range");
    }
    ModuleDataDefinition.logLevel = v;
  },
  get level() { return ModuleDataDefinition.logLevel; },

  /**
   * Sets / gets the listener for post processing of log events once they
   * are handled by the module.
   * @memberof codemelted.codemelted_logger
   * @type {COnLogEventListener?}
   */
  set onLogEvent(v) {
    if (v) {
      json.checkType({type: "function", data: v, count: 1});
    }
    ModuleDataDefinition.onLogEvent = v == undefined ? null : v;
  },
  get onLogEvent() { return  ModuleDataDefinition.onLogEvent; },

  /**
   * Will log debug level messages via the module.
   * @memberof codemelted.codemelted_logger
   * @param {object} params The named parameters
   * @param {any} params.data The data to log.
   * @returns {void}
   */
  debug: function({data}) {
    if (this.level <= this.debugLevel && this.level != this.offLevel) {
      const record = ModuleDataDefinition.createLogRecord(
        this.debugLevel, data
      );
      globalThis.console.log(data.toString());
      if (this.onLogEvent) {
        this.onLogEvent(record);
      }
    }
  },

  /**
   * Will log info level messages via the module.
   * @memberof logger
   * @param {object} params The named parameters
   * @param {any} params.data The data to log.
   * @returns {void}
   */
  info: function({data}) {
    if (this.level <= this.infoLevel && this.level != this.offLevel) {
      const record = ModuleDataDefinition.createLogRecord(
        this.infoLevel, data
      );
      globalThis.console.info(data);
      if (this.onLogEvent) {
        this.onLogEvent(record);
      }
    }
  },

  /**
   * Will log warning level messages via the module.
   * @memberof logger
   * @param {object} params The named parameters
   * @param {any} params.data The data to log.
   * @returns {void}
   */
  warning: function({data}) {
    if (this.level <= this.warningLevel && this.level != this.offLevel) {
      const record = ModuleDataDefinition.createLogRecord(
        this.warningLevel, data
      );
      globalThis.console.warn(data);
      if (this.onLogEvent) {
        this.onLogEvent(record);
      }
    }
  },

  /**
   * Will log error level messages via the module.
   * @memberof logger
   * @param {object} params The named parameters
   * @param {any} params.data The data to log.
   * @returns {void}
   */
  error: function({data}) {
    if (this.level <= this.errorLevel && this.level != this.offLevel) {
      const record = ModuleDataDefinition.createLogRecord(
        this.errorLevel, data
      );
      globalThis.console.error(data.toString());
      if (this.onLogEvent) {
        this.onLogEvent(record);
      }
    }
  },
});

// ----------------------------------------------------------------------------
// [Monitor Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: To Be Developed.


// ----------------------------------------------------------------------------
// [Network Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * The result of a network.fetch() call
 * @typedef {object} CFetchResponse_t
 * @property {any} data The data if any that is attached with the response
 * @property {number} status The HTTP response code.
 * @property {string} statusText A string associated with the response code.
 * @property {Blob?} asBlob Treats the data as a Blob or null if it is not
 * a blob.
 * @property {FormData?} asFormData Treats the data as a FormData object or
 * null if it is not a FormData object.
 * @property {object?} asObject Treats the data as a parsed JSON object or
 * null if it is not a JSON object type.
 */

/**
 * TBD
 * @private
 * @namespace network
 */
const _network = Object.freeze({
  /**
   * Sends an HTTP POST request containing a small amount of data to a web
   * server. It's intended to be used for sending analytics data to a web
   * server, and avoids some of the problems with legacy techniques for
   * sending analytics, such as the use of XMLHttpRequest.
   * @memberof network
   * @param {object} params The named parameters
   * @param {string} params.url The url hosting the POST
   * @param {BodyInit} [params.data] The data to send.
   * @throws {SyntaxError} This is only available on Web Browser runtime.
   */
  beacon: function({url, data}) {
    json.tryType({type: "string", data: url});
    // @ts-ignore Window object does have document in WEB.
    return runtime.tryWeb().navigator.sendBeacon(url, data);
  },

  /**
   * Implements the ability to fetch a server's REST API endpoint to retrieve
   * and manage data. The actions for the REST API are controlled via the
   * specified action value with optional items to pass to the
   * endpoint. The result is a CFetchResponse wrapping the REST API endpoint
   * response to the request.
   * @memberof network
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
   * @returns {Promise<CFetchResponse_t>} The result of the fetch.
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
      const request = { "method": action.toUpperCase() };
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
      return {
        data: data,
        status: status,
        statusText: statusText,
        asBlob: json.checkType({type: Blob, data: data})
          ? data
          : null,
        asFormData: json.checkType({type: FormData, data: data})
          ? data
          : null,
        asObject: json.checkType({type: "object", data: data})
          ? data
          : null
      }
    } catch (err) {
      return {
        data: null,
        status: 418,
        statusText: `I'm a teapot. ${err}`,
        asBlob: null,
        asFormData: null,
        asObject: null,
      }
    }
  },

  /**
   * Gets the hostname your page is running
   * @memberof network
   * @readonly
   * @type {string}
   */
  get hostname() {
    return runtime.isDeno
      ? runtime.tryDeno().hostname()
      : runtime.tryWeb().location.hostname;
  },

  /**
   * Gets the href of where your page is loaded.
   * @memberof network
   * @readonly
   * @type {string}
   */
  get href() {
    return runtime.isWeb
      ? runtime.tryWeb().location.href
      : "";
  },

  /**
   * Determines if a connection to the Internet exists. Will return null
   * on Deno runtime.
   * @memberof network
   * @readonly
   * @type {boolean?}
   */
  get online() {
    return runtime.isWeb
      // @ts-ignore Window object does have document in WEB.
      ? globalThis.navigator.onLine
      : null;
  },
});

// ----------------------------------------------------------------------------
// [NPU Use Case] -------------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: To Be Developed.

// ----------------------------------------------------------------------------
// [Process Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Class wrapper for a created process via the Deno runtime.
 * @private
 */
class CDenoProcessHandler {
  /**
   * Writes a message to the attached process.
   * @param {string} data The data to send to the attached process.
   */
  postMessage(data) {
    const buffer = this.encoder.encode(data);
    this.process.stdin.getWriter().write(buffer);
  }

  /**
   * Kills the held process with the specified signal.
   * @param {Deno.Signal} signo The signal to terminate the process with.
   * @returns {void}
   */
  kill(signo) {
    clearInterval(this.timerId);
    this.process.kill(signo);
  }

  /**
   * Constructor for the handler.
   * @param {Deno.ChildProcess} process The process that was created.
   * @param {CModuleEventListener_t} listener The listener for the process
   * data.
   */
  constructor(process, listener) {
    this.process = process;
    this.encoder = new TextEncoder();
    this.decoder = new TextDecoder();
    this.timerId = setInterval(async () => {
      const outDataChunk = await this.process.stdout.getReader().read();
      const errDataChunk = await this.process.stderr.getReader().read();
      let dataChunk = "";
      if (outDataChunk.value) {
        dataChunk += this.decoder.decode(outDataChunk.value);
      }
      if (errDataChunk) {
        dataChunk += this.decoder.decode(errDataChunk.value);
      }
      if (dataChunk) {
        listener({
          type: "data",
          data: dataChunk
        });
      }
    }, 250);
  }
}

/**
 * Namespace that provides the ability to spawn a process of a external
 * command with the ability to communicate via STDIN / STDOUT / STDERR with
 * said process. Also provides the ability to kill operating system running
 * processes not kicked off by this namespace.
 * @private
 * @namespace process
 */
const process = Object.freeze({
  /**
   * Will attempt to kill a running computer operating system process. This
   * could be an application kicked off by your application or a general
   * running service.
   * @memberof process
   * @param {object} params
   * @param {number} params.pid The process id of a computer running
   * process to terminate.
   * @param {Deno.Signal} [params.signo = "SIGTERM"] The type of signal to terminate with
   * @returns {boolean} if process was found to kill. false otherwise.
   */
  kill: function({pid, signo = "SIGTERM"}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "number", data: pid});
      json.tryType({type: "string", data: signo});
      if (pid < 0) {
        throw new SyntaxError("pid must be greater than 0");
      }
      const p = ModuleDataDefinition.deallocateTrackingId(pid);
      if (json.checkType({type: Deno.ChildProcess, data: p})) {
        p.kill(signo);
      } else {
        deno.kill(pid, signo);
      }
      return true;
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      ModuleDataDefinition.handleError(err);
      return false;
    }
  },

  /**
   * Sends a message to an attached process via stdin
   * @memberof process
   * @param {object} params
   * @param {number} params.pid The pid to send a message.
   * @param {string} params.data The data to send.
   * @param {boolean} [params.appendReturn = false] Whether to append a
   * return keystroke.
   * @returns {boolean} if process was found and message was sent. False
   * otherwise.
   */
  postMessage: function({pid, data, appendReturn = false}) {
    try {
      runtime.tryDeno();
      json.tryType({type: "number", data: pid});
      json.tryType({type: "string", data: data});
      json.tryType({type: "boolean", data: appendReturn});

      // @ts-ignore tryType checks the type.
      const p = ModuleDataDefinition.objectTracker[pid];
      json.tryType({type: CDenoProcessHandler, data: p});
      p.postMessage(data);
      return true;

    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      ModuleDataDefinition.handleError(err);
      return false;
    }
  },

  /**
   * Spawns an external command as an attached process allowing for
   * bi-directional communication via stdin, stdout, and stderr.
   * @memberof process
   * @param {object} params
   * @param {string} params.command The command to run as an attached
   * process.
   * @param {string[]} [params.args = []] Optional arguments to kickoff with the
   * command.
   * @param {CModuleEventListener_t} params.listener The module event
   * listener for stdout / stderr output from the spawned process.
   * @returns {number} The pid that was created via the module or -1 if an
   * error occurred.
   */
  spawn: function({command, args = [], listener}) {
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: command});
      json.tryType({type: Array, data: args});
      json.tryType({type: "function", data: listener, count: 1})
      const cmd = new deno.Command(command, {
        args: args,
        stdin: "piped",
        stdout: "piped",
      });
      const p = cmd.spawn();
      const obj = new CDenoProcessHandler(p, listener);
      return ModuleDataDefinition.allocateTrackingId(obj);
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      ModuleDataDefinition.handleError(err);
      return -1;
    }
  }
});

// ----------------------------------------------------------------------------
// [Runtime Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Exposes a series of properties and utility methods that are specific to the
 * deno / web runtimes.
 * @private
 * @namespace runtime
 */
const runtime = Object.freeze({
  /**
   * Adds an event listener either to the global object or to the specified
   * event target.
   * @memberof runtime
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
    json.tryType({type: "string", data: type});
    json.tryType({type: "function", data: listener});
    if (!obj) {
      globalThis.addEventListener(type, listener);
    }
    else {
      obj.addEventListener(type, listener);
    }
  },

  /**
   * Gets the name of the browser your page is running.
   * @memberof runtime
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
   * Parses the environment for the given specified key.
   * @memberof runtime
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
   * Determines if the runtime is Deno.
   * @memberof runtime
   * @readonly
   * @type {boolean}
   */
  get isDeno() {
    return typeof globalThis.Deno != "undefined";
  },

  /**
   * Identifies if you are on desktop or not.
   * @memberof runtime
   * @readonly
   * @type {boolean}
   */
  get isDesktop() {
    return this.isDeno;
  },

  /**
   * Identifies if you are on mobile or not.
   * @memberof runtime
   * @readonly
   * @type {boolean}
   */
  get isMobile() {
    const osName = this.osName;
    return osName.includes("android") ||
      osName.includes("ios");
  },

  /**
   * Determines if the runtime is Web Browser.
   * @memberof runtime
   * @readonly
   * @type {boolean}
   */
  get isWeb() {
    return !this.isDeno;
  },

  /**
   * Gets the name of the operating system your page is running.
   * @memberof runtime
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
   * Removes an event listener either to the global object or to the
   * specified event target.
   * @memberof runtime
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
    json.tryType({type: "string", data: type});
    json.tryType({type: "function", data: listener});
    if (!obj) {
      globalThis.removeEventListener(type, listener);
    }
    else {
      obj.removeEventListener(type, listener);
    }
  },

  /**
   * Determines if we are running in a Deno Runtime or not.
   * @memberof runtime
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
   * @memberof runtime
   * @returns {Window} Reference to the browser window.
   * @throws {SyntaxError} If not running in a browser environment.
   */
  tryWeb: function() {
    if (!this.isWeb) {
      throw new SyntaxError("Not Running in a Web Runtime.");
    }
    return globalThis.window;
  },
});

// ----------------------------------------------------------------------------
// [Setup Use Case] -----------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: To Be Developed.

// ----------------------------------------------------------------------------
// [SPA Use Case] -------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace spa
 */
const _spa = Object.freeze({
  /**
   * Copies data to the system clipboard. Only available on the
   * Web Browser runtime.
   * @memberof spa
   * @param {object} params The named parameters.
   * @param {string} params.data The data to copy to the clipboard.
   * @returns {Promise<void>} Of the copy action.
   * @throws {SyntaxError} If attempted on the Deno runtime.
   */
  copyToClipboard: function({data}) {
    // @ts-ignore Window object does have document in WEB.
    return runtime.tryWeb().navigator.clipboard.writeText(data);
  },

  /**
   * Supports the spa.open function for the mailto schema.
   * @memberof spa
   * @param {object} params The named parameters
   * @param {string} params.mailto Where to email the message.
   * @param {string[]} [params.cc=[]] Who to CC on the email.
   * @param {string[]} [params.bcc=[]] Who to BCC on the email.
   * @param {string} [params.subject=""] The subject of the email.
   * @param {string} [params.body=""] The body of the email.
   * @returns {string} url representing the mailto schema.
   */
  formatMailToParams: function({
    mailto,
    cc = [],
    bcc = [],
    subject = "",
    body = ""
  }) {
    json.tryType({type: "string", data: mailto});
    json.tryType({type: "array", data: cc});
    json.tryType({type: "array", data: bcc});
    json.tryType({type: "string", data: subject});
    json.tryType({type: "string", data: body});

    let url = "";

    // Go format the mailto part of the url
    url += `${mailto};`;
    url = url.substring(0, url.length - 1);

    // Go format the cc part of the url
    let delimiter = "?";
    if (cc.length > 0) {
      url += `${delimiter}cc=`;
      delimiter = "&";
      for (const e in cc) {
        url += `${e};`;
      }
      url = url.substring(0, url.length - 1);
    }

    // Go format the bcc part of the url
    if (bcc.length > 0) {
      url += `${delimiter}bcc=`;
      delimiter = "&";
      for (const e in bcc) {
        url += `${e};`;
      }
      url = url.substring(0, url.length - 1);
    }

    // Go format the subject part
    if (subject.trim().length > 0) {
      url += `${delimiter}subject=${subject.trim()}`;
      delimiter = "&";
    }

    // Go format the body part
    if (body.trim().length > 0) {
      url += `${delimiter}body=${body.trim()}`;
      delimiter = "&";
    }

    return url;
  },

  /**
   * Determines if the UI is under an iFrame or not.
   * @memberof spa
   * @readonly
   * @type {boolean}
   */
  get inFrame() {
    ModuleDataDefinition.handleError();
    try {
      const w = runtime.tryWeb();
      // @ts-ignore: globalThis will have a Window object
      return w.self !== w.top;
    } catch (err) {
      if (err instanceof SyntaxError) {
        ModuleDataDefinition.handleError(err);
        return false;
      }
      return true;
    }
  },

  /**
   * Determines if the running page is an installed Progressive Web App.
   * @memberof spa
   * @readonly
   * @type {boolean}
   */
  get isPWA() {
    if (runtime.isWeb) {
      const queries = [
        '(display-mode: fullscreen)',
        '(display-mode: standalone)',
        '(display-mode: minimal-ui),'
      ];
      let pwaDetected = false;
      for (const query in queries) {
        // @ts-ignore Window object does have document in WEB.
        pwaDetected = pwaDetected || globalThis.matchMedia(query).matches;
      }
      return pwaDetected;
    }
    return false;
  },

  /**
   * Loads a specified resource into a new or existing browsing context
   * (that is, a tab, a window, or an iframe) under a specified name. These
   * are based on the different scheme supported protocol items.
   * @memberof runtime
   * @param {object} params The named parameters.
   * @param {string} params.scheme Either "file:", "http://",
   * "https://", "mailto:", "tel:", or "sms:".
   * @param {boolean} [params.popupWindow = false] true to open a new
   * popup browser window. false to utilize the _target for browser
   * behavior.
   * @param {string} [params.mailtoParams] Object to assist in the
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
          // @ts-ignore Window object does have document in WEB.
          const top = (runtime.tryWeb().screen.height - h) / 2;
          // @ts-ignore Window object does have document in WEB.
          const left = (runtime.tryWeb().screen.width - w) / 2;
          const settings = "toolbar=no, location=no, " +
              "directories=no, status=no, menubar=no, " +
              "scrollbars=no, resizable=yes, copyhistory=no, " +
              `width=${w}, height=${h}, top=${top}, left=${left}`;
          // @ts-ignore Window object does have document in WEB.
          rtnval = runtime.tryWeb().open(
            urlToLaunch,
            "_blank",
            settings,
          );
        }

        // @ts-ignore Window object does have document in WEB.
        rtnval = runtime.tryWeb().open(urlToLaunch, target);
        resolve(rtnval);
      } catch (err) {
        reject(err);
      }
    });
  },

  /**
   * Will open a print dialog when running in a Web Browser.
   * @memberof spa
   * @returns {void}
   * @throws {SyntaxError} if you attempt to call this in Deno runtime.
   */
  print: function() {
      // @ts-ignore Window object does have document in WEB.
    runtime.tryWeb().print();
  },

  /**
   * Provides the ability to share items via the share services. You specify
   * options via the data object parameters. Only available on the web
   * browser runtime.
   * @memberof spa
   * @param {object} params
   * @param {object} params.data The object specifying the data to share.
   * @returns {Promise<boolean>} The result of the call whether successful
   * or not.
   * @see https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share
   */
  share: async function({data}) {
    try {
      json.tryType({type: "object", data: data});
      // @ts-ignore Window object does have document in WEB.
      await runtime.tryWeb().navigator.share(data);
      return true;
    } catch (err) {
      ModuleDataDefinition.handleError(err);
      return false;
    }
  }
});

// ----------------------------------------------------------------------------
// [Storage Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Provides the ability to manage a key / value pair within the targeted
 * runtime environment. The storage methods of "local" and "session" are
 * supported on both Deno and Web Browsers. "cookie" method is only supported
 * on Web Browser and will result in a SyntaxError if called in a Deno
 * runtime.
 * @private
 * @namespace storage
 */
const _storage = Object.freeze({
  /**
   * Clears the specified storage method.
   * @memberof storage
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
      // @ts-ignore Window object does have document in WEB.
      runtime.tryWeb().document.cookie = "";
    }

    throw new SyntaxError("Invalid method specified");
  },

  /**
   * Gets data from the identified method via the specified key.
   * @memberof storage
   * @param {object} params The named parameters.
   * @param {string} [params.method="local"] Values of cookie, local, or
   * session.
   * @param {string} params.key The key field to retrieve.
   * @returns {string?} The associated with the key or null if not found.
   */
  getItem: function({method = "local", key}) {
    json.tryType({type: "string", data: key});
    if (method === "local") {
      return globalThis.localStorage.getItem(key);
    } else if (method === "session") {
      return globalThis.sessionStorage.getItem(key);
    } else if (method === "cookie") {
      const name = `${key}=`;
      // @ts-ignore Window object does have document in WEB.
      const ca = runtime.tryWeb().document.cookie.split(';');
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
   * @memberof storage
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
      // @ts-ignore Window object does have document in WEB.
      const ca = runtime.tryWeb().document.cookie.split(";");
      return ca.length;
    }

    throw new SyntaxError("Invalid method specified");
  },

  /**
   * Gets the key from the index from the identified storage method.
   * @memberof storage
   * @param {object} params The named parameters.
   * @param {string} [params.method="local"] Values of cookie, local, or
   * session.
   * @param {number} params.index The index of where the key exists in
   * storage.
   * @returns {String?} The name of the key or null if the index goes
   * beyond the stored length.
   */
  key: function({method = "local", index}) {
    json.tryType({type: "number", data: index});
    if (method === "local") {
      return globalThis.localStorage.key(index);
    } else if (method === "session") {
      return globalThis.sessionStorage.key(index);
    } else if (method === "cookie") {
      // @ts-ignore Window object does have document in WEB.
      const ca = runtime.tryWeb().document.cookie.split(";");
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
   * @memberof storage
   * @param {object} params The named parameters.
   * @param {string} [params.method="local"] Values of cookie, local, or
   * session.
   * @param {string} params.key The key field to remove.
   * @returns {void}
   */
  removeItem: function({method = "local", key}) {
    json.tryType({type: "string", data: key});
    if (method === "local") {
      globalThis.localStorage.removeItem(key);
    } else if (method === "session") {
      globalThis.sessionStorage.removeItem(key);
    } else if (method === "cookie") {
      // @ts-ignore Window object does have document in WEB.
      runtime.tryWeb().document.cookie =
        `${key}=; expires=01 Jan 1970 00:00:00; path=/;`;
    }

    throw new SyntaxError("Invalid method specified");
  },

  /**
   * Sets a value by the identified key within the identified storage
   * method.
   * @memberof storage
   * @param {object} params The named parameters.
   * @param {string} [params.method="local"] Values of cookie, local, or
   * session.
   * @param {string} params.key The identified key to associate with
   * the value.
   * @param {string} params.value The value to set.
   * @returns {void}
   */
  setItem: function({method = "local", key, value}) {
    json.tryType({type: "string", data: key});
    json.tryType({type: "string", data: value});
    if (method === "local") {
      globalThis.localStorage.setItem(key, value);
    } else if (method === "session") {
      globalThis.sessionStorage.setItem(key, value);
    } else if (method === "cookie") {
      const d = new Date();
      d.setTime(d.getTime() + (365 * 24 * 60 * 60 * 1000));
      const expires = "expires="+ d.toUTCString();
      // @ts-ignore Window object does have document in WEB.
      runtime.tryWeb().document.cookie =
        `${key}=${value}; ${expires}; path=/`;
    }

    throw new SyntaxError("Invalid method specified");
  }
});

// ----------------------------------------------------------------------------
// [Task Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * The task to run as part of the different module async functions.
 * @callback CTask_t
 * @param {any} [data] The data to process on the backend.
 * @returns {any} The calculated answer to the task if any.
 */

/**
 * Provides the ability to kick-off one off tasks on the main thread allowing
 * for work to be broken apart on the event queue.
 * @private
 * @namespace task
 */
const task = Object.freeze({
  /**
   * Will process a one off asynchronous task on the main thread.
   * @memberof task
   * @param {object} params
   * @param {CTask_t} params.task The task callback to schedule.
   * @param {any} params.data The optional data to if the task requires it
   * for processing.
   * @param {number} [params.delay] An optional delay to schedule the task in
   * the future.
   */
  run: function({task, data, delay = 0}) {
    return new Promise((resolve, reject) => {
      try {
        json.tryType({type: "function", data: task, count: 1});
        json.tryType({type: "number", data: delay});
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
   * @memberof task
   * @param {object} params
   * @param {CTask_t} params.task The task to repeat on a timer.
   * @param {number} params.interval How often in milliseconds to schedule
   * the task.
   * @returns {number} timerId of the scheduled timer.
   */
  startTimer: function({task, interval}) {
    json.tryType({type: "function", data: task, count: 1});
    json.tryType({type: "number", data: interval});
    if (interval < 0) {
      throw new SyntaxError("interval must be greater than 0");
    }
    const id = setInterval(() => task(), interval);
    return ModuleDataDefinition.allocateTrackingId(id);
  },

  /**
   * Stops a scheduled timer.
   * @memberof task
   * @param {object} params
   * @param {number} params.timerId The id of the scheduled timer.
   * @returns {void}
   */
  stopTimer: function({timerId}) {
    json.tryType({type: "number", data: timerId});
    const id = ModuleDataDefinition.deallocateTrackingId(timerId);
    if (id) {
      clearInterval(id);
    }
  },

  /**
   * Will sleep an asynchronous task for the specified delay in
   * milliseconds.
   * @memberof codemelted.codemelted_async
   * @param {object} params The named parameters.
   * @param {number} [params.delay = 0] The specified delay in milliseconds.
   * @returns {Promise<void>}
   */
  sleep: function({delay = 0} = {}) {
    return new Promise((resolve, reject) => {
      try {
        json.tryType({type: "number", data: delay});
        if (delay < 0) {
          throw new SyntaxError("delay must be greater than 0");
        }
        setTimeout(() => resolve(), delay);
      } catch (err) {
        reject(err);
      }
    });
  },
});

// ----------------------------------------------------------------------------
// [Theme Use Case] -----------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: To Be Developed.

// ----------------------------------------------------------------------------
// [Widget Use Case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

// TODO: To Be Developed.

// ----------------------------------------------------------------------------
// [Worker Use Case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Implements a worker pool in the background to process data chunks without
 * locking up the main thread. The workerUrl represents the background worker
 * that will process the data spread over the available hardwareConcurrency.
 * @private
 * @namespace worker
 */
const worker = Object.freeze({
  /**
   * Identifies the number of processors to facilitate dedicated workers.
   * @memberof worker
   * @readonly
   * @type {number}
   */
  get hardwareConcurrency() {
    return globalThis.navigator.hardwareConcurrency;
  },

  /**
   * Will post a message to the worker pool to process. NOTE: You have full
   * control of what the message looks like to know when it is completed
   * processing via the onMessageReceived.
   * @memberof worker
   * @param {object} params
   * @param {any} params.data The data to process in the background.
   * @returns {void}
   */
  postMessage: function({data}) {
    if (!ModuleDataDefinition.workerPool) {
      throw new SyntaxError("Worker pool was never started");
    }
    ModuleDataDefinition.workerPool.postMessage(data);
  },

  /**
   * Starts a background worker pool for processing events in the background
   * represented by the workerUrl.
   * @memberof worker
   * @param {object} params The named parameters.
   * @param {CModuleEventListener_t} params.onDataReceived The listener
   * for received data from the worker pool
   * @param {string} params.workerUrl The url to the dedicated worker.
   * @returns {void}
   */
  start: function({onDataReceived, workerUrl}) {
    json.checkType({type: "function", data: onDataReceived, count: 1});
    json.checkType({type: "string", data: workerUrl});
    if (ModuleDataDefinition.workerPool) {
      throw new SyntaxError(
        "You must terminate worker pool before starting a new one."
      );
    }
    ModuleDataDefinition.workerPool = new CWorkerPool(
      onDataReceived, workerUrl
    );
  },

  /**
   * Terminates a started worker pool.
   * @memberof worker
   * @returns {void}
   */
  terminate: function() {
    if (!ModuleDataDefinition.workerPool) {
      throw new SyntaxError("Worker pool was never started");
    }
    ModuleDataDefinition.workerPool.terminate();
    ModuleDataDefinition.workerPool = undefined;
  },
});

// ----------------------------------------------------------------------------
// [Public API] ---------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * This module is the implementation of the CodeMelted DEV module use cases.
 * It will target the Deno and Web Browser runtimes with limited support for
 * within a NodeJS environment. The use cases will be organized as exported
 * default public functions. This will also serve as the backbone to
 * codemelted.dart module where a direct the Flutter implementation for a
 * use case does not make sense to duplicate compared to the codemelted.js
 * module.
 * @module codemelted
 */
export default Object.freeze({
  /**
   * A reason for a failure of a transaction that has an indicator for
   * either success / failure. NOTE: Module violations will result in
   * SyntaxError meaning they will not be reported via this mechanism.
   * @type {string}
   */
  error: ModuleDataDefinition.error,

  /** @type {console} */
  console: console,

  /** @type {disk} */
  disk: disk,

  /**
   * @private
   * @type {file}
   */
  file: file,

  /** @type {json} */
  json: json,

  /**
   * @private
   * @type {process}
   */
  process: process,

  // /** @type {runtime} */
  // runtime: runtime,

  /** @type {task} */
  task: task,

  /** @type {worker} */
  worker: worker,
});