// @ts-check
// ============================================================================
/**
 * @file The JavaScript implementation of the CodeMelted DEV | PWA Modules.
 * @author Mark Shaffer
 * @version 0.3.1 (Last Modified 2025-01-05) <br />
 * 0.3.1 (2025-01-05): <br />
 * - Fleshed out the Async I/O use cases. Not tested. <br />
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
 * Holds the common definitions to support the overall module implementation
 * and runtimes.
 * @private
 */
class ModuleDataDefinition {
  /** @type {string} */
  static error = ""

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
}

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
   * @param {string[]} [params.choices = []] The choices to select from.
   * @returns {number} The index of the chosen item.
   */
  choose: function({message = "CHOOSE", choices = []} = {}) {
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
   * @param {string} [params.src] The source item to copy.
   * @param {string} [params.dest] The destination of where to copy the item.
   * @returns {boolean} true if carried out, false otherwise. Check strerror
   * for details of failure.
   */
  cp: function({src, dest} = {}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: src});
      json.tryType({type: "string", data: dest});
      // @ts-ignore checks are done above.
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
   * @param {string} [params.filename] The path to a directory or file.
   * @returns {Deno.FileInfo?} The file information or null if it does not
   * exist.
   */
  exists: function({filename} = {}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: filename});
      // @ts-ignore check handled above.
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
   * @param {string} [params.filename] The directory to list.
   * @returns {Deno.FileInfo[]?} Array of files found.
   */
  ls: function({filename} = {}) {
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: filename});
      // @ts-ignore check handled above.
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
   * @param {string} [params.filename] The source item to create.
   * @returns {boolean}
   */
  mkdir: function({filename} = {}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: filename});
      // @ts-ignore check handled above.
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
   * @param {string} [params.src] The source item to move.
   * @param {string} [params.dest] The destination of where to move the item.
   * @returns {boolean} true if carried out, false otherwise. Check strerror
   * for details of failure.
   */
  mv: function({src, dest} = {}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: src});
      json.tryType({type: "string", data: dest});
      // @ts-ignore Check handled above.
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
   * @param {string} [params.filename] The source item to remove.
   * @returns {boolean} true if carried out, false otherwise. Check strerror
   * for details of failure.
   */
  rm: function({filename} = {}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: filename});
      // @ts-ignore error checked above.
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
   * Reads an entire file from disk.
   * @memberof file
   * @param {object} params
   * @param {string} [params.filename] The file to open
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
  } = {}) {
    return new Promise((resolve, reject) => {
      ModuleDataDefinition.handleError();
      try {
        if (runtime.isDeno) {
          const deno = runtime.tryDeno();
          json.tryType({type: "string", data: filename});
          json.tryType({type: "boolean", data: isTextFile});
          if (isTextFile) {
            // @ts-ignore: checked via tryType call
            resolve(deno.readTextFileSync(filename));
          } else {
            // @ts-ignore: checked via tryType call
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
   * @param {string} [params.filename] What / where to save the file.
   * For the web target this will default to the download directory.
   * @param {string | Uint8Array} [params.data] The data to save to the file.
   * @param {boolean} [params.append = false] Whether to append the data or
   * create a new file. Only valid on deno runtime.
   * @returns {Promise<void>} true if successful, false otherwise. Check
   * codemelted.strerror if false is returned to know why.
   */
  writeEntireFile({
    filename,
    data,
    append = false,
  } = {}) {
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
   * @param {string} [params.data] The object to check for the key.
   * @returns {boolean} true if a truthy string, false otherwise.
   */
  asBool: function({data} = {}) {
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
   * @param {string} [params.data] The object to check for the key.
   * @returns {number?}
   */
  asDouble: function({data} = {}) {
    const convertedValue = parseFloat(data ?? "wrong");
    return !isNaN(convertedValue) ? convertedValue : null;
  },

  /**
   * Converts a string to a integer number
   * @memberof json
   * @param {object} params
   * @param {string} [params.data] The object to check for the key.
   * @returns {number?}
   */
  asInt: function({data} = {}) {
    const convertedValue = parseInt(data ?? "wrong");
    return !isNaN(convertedValue) ? convertedValue : null;
  },

  /**
   * Determines if the specified object has the specified property.
   * @memberof json
   * @param {object} params
   * @param {object} [params.obj] The object to check for the key.
   * @param {string} [params.key] The property to check for.
   * @returns {boolean} true if property was found, false otherwise.
   */
  checkHasProperty: function({obj, key} = {}) {
    try {
      // @ts-ignore Handled by try catch
      return Object.hasOwn(obj, key);
    } catch (err) {
      // @ts-ignore Expected to be an Error type
      throw new SyntaxError(err?.message);
    }
  },

  /**
   * Utility to check parameters of a function to ensure they are of an
   * expected type.
   * @memberof json
   * @param {object} params
   * @param {string | any} [params.type] The specified type to check the data
   * against.
   * @param {any} [params.data] The parameter to be checked.
   * @param {number | undefined} [params.count] Checks the data parameter
   * function signature to ensure the appropriate number of parameters are
   * specified.
   * @returns {boolean} true if it meets the expectations, false otherwise.
   */
  checkType: function({type, data, count = undefined} = {}) {
    try {
      const isExpectedType = typeof type !== "string"
      ? (data instanceof type)
      // deno-lint-ignore valid-typeof
      : typeof data === type;
    return typeof count === "number"
      ? isExpectedType && data.length === count
      : isExpectedType;
    } catch (err) {
      // @ts-ignore expected to be a Error
      throw new SyntaxError(err?.message);
    }
  },

  /**
   * Checks for a valid URL.
   * @memberof json
   * @param {object} params
   * @param {string} [params.data] String to parse to see if it is a valid
   * URL.
   * @returns {boolean} true if valid, false otherwise.
   */
  checkValidUrl: function({data} = {}) {
    ModuleDataDefinition.handleError();
    let url = undefined;
    try {
      // @ts-ignore Weirdness when doing named parameters.
      url = new URL(data);
    }
    catch (err) {
      url = undefined;
      ModuleDataDefinition.handleError(err);
    }
    // @ts-ignore Also ignore to allow the checkType to do its thing.
    return this.checkType({type: URL, data: url});
  },

  /**
   * Creates a new JSON compliant array with the ability to copy data.
   * @memberof json
   * @param {object} params
   * @param {Array<any>} [params.data] An array to make a copy.
   * @returns {Array<any>}
   */
  createArray: function({data} = {}) {
    return this.checkType({type: Array, data: data})
      // @ts-ignore Data type is as expected.
      ? Array.from(data)
      : [];
  },

  /**
   * Creates a new JSON compliant object with the ability to copy data.
   * @memberof json
   * @param {object} params
   * @param {object} [params.data] An array to make a copy.
   * @returns {object}
   */
  createObject: function({data} = {}) {
    return this.checkType({type: "object", data: data})
      ? Object.assign({}, data)
      : {};
  },

  /**
   * Converts a string to a JavaScript object.
   * @memberof json
   * @param {object} params
   * @param {string} [params.data] The data to parse.
   * @returns {object | null} Object or null if the parse failed.
   */
  parse: function({data} = {}) {
    ModuleDataDefinition.handleError();
    try {
      // @ts-ignore Named parameter weirdness.
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
   * @param {object} [params.data] An object with valid JSON attributes.
   * @returns {string | null} The string representation or null if the
   * stringify failed.
   */
  stringify: function({data} = {}) {
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
   * @param {object} [params.obj] The object to check for the key.
   * @param {string} [params.key] The property to check for.
   * @returns {void}
   * @throws {SyntaxError} if the property is not found.
   */
  tryHasProperty: function({obj, key} = {}) {
    if (!this.checkHasProperty({obj: obj, key: key})) {
      throw new SyntaxError("obj does not have the specified property");
    }
  },

  /**
   * Utility to check parameters of a function to ensure they are of an
   * expected type.
   * @memberof json
   * @param {object} params
   * @param {any} [params.type] The specified type to check the data
   * against.
   * @param {any} [params.data] The parameter to be checked.
   * @param {number} [params.count] Checks the data parameter function
   * signature to ensure the appropriate number of parameters are
   * specified.
   * @returns {void}
   * @throws {SyntaxError} if the type was not as expected
   */
  tryType: function({type, data, count = undefined} = {}) {
    if (!this.checkType({type: type, data: data, count: count})) {
      throw new SyntaxError("data is not of expected type.");
    }
  },

  /**
   * Checks for a valid URL.
   * @memberof json
   * @param {object} params
   * @param {string} [params.data] String to parse to see if it is a valid
   * URL.
   * @returns {void}
   * @throws {SyntaxError} If v is not a valid url.
   */
  tryValidUrl: function({data} = {}) {
    if (!this.checkValidUrl({data: data})) {
      throw new SyntaxError("data is not a valid url");
    }
  },
});

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
   * @param {number} [params.pid] The process id of a computer running
   * process to terminate.
   * @param {Deno.Signal} [params.signo] The type of signal to terminate with
   * @returns {boolean} if process was found to kill. false otherwise.
   */
  kill: function({pid, signo = "SIGTERM"} = {}) {
    ModuleDataDefinition.handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "number", data: pid});
      json.tryType({type: "string", data: signo});
      // @ts-ignore tryType validates the type.
      if (pid < 0) {
        throw new SyntaxError("pid must be greater than 0");
      }
      // @ts-ignore tryType validates the type.
      const p = ModuleDataDefinition.deallocateTrackingId(pid);
      if (json.checkType({type: Deno.ChildProcess, data: p})) {
        p.kill(signo);
      } else {
          // @ts-ignore tryType validates the type.
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
   * @param {number} [params.pid] The pid to send a message.
   * @param {string} [params.data] The data to send.
   * @param {boolean} [params.appendReturn = false] Whether to append a
   * return keystroke.
   * @returns {boolean} if process was found and message was sent. False
   * otherwise.
   */
  postMessage: function({pid, data, appendReturn = false} = {}) {
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
   * @param {string} [params.command] The command to run as an attached
   * process.
   * @param {string[]} [params.args] Optional arguments to kickoff with the
   * command.
   * @param {CModuleEventListener_t} [params.listener] The module event
   * listener for stdout / stderr output from the spawned process.
   * @returns {number} The pid that was created via the module or -1 if an
   * error occurred.
   */
  spawn: function({command, args, listener} = {}) {
    try {
      const deno = runtime.tryDeno();
      json.tryType({type: "string", data: command});
      json.tryType({type: Array, data: args});
      json.tryType({type: "function", data: listener, count: 1})
      // @ts-ignore typeCheck validates this.
      const cmd = new deno.Command(command, {
        args: args ?? [],
        stdin: "piped",
        stdout: "piped",
      });
      const p = cmd.spawn();
      // @ts-ignore tryType validates the type.
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
   * Determines if the runtime is Deno.
   * @memberof runtime
   * @readonly
   * @type {boolean}
   */
  get isDeno() {
    return typeof globalThis.Deno != "undefined";
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
   * @param {CTask_t} [params.task] The task callback to schedule.
   * @param {any} [params.data] The optional data to if the task requires it
   * for processing.
   * @param {number} [params.delay] An optional delay to schedule the task in
   * the future.
   */
  run: function({task, data, delay = 0} = {}) {
    return new Promise((resolve, reject) => {
      try {
        json.tryType({type: "function", data: task, count: 1});
        json.tryType({type: "number", data: delay});
        // @ts-ignore delay checked with tryType.
        if (delay < 0) {
          throw new SyntaxError("delay must be greater than 0");
        }
        setTimeout(() => {
          // @ts-ignore task checked with tryType.
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
   * @param {CTask_t} [params.task] The task to repeat on a timer.
   * @param {number} [params.interval] How often in milliseconds to schedule
   * the task.
   * @returns {number} timerId of the scheduled timer.
   */
  startTimer: function({task, interval} = {}) {
    json.tryType({type: "function", data: task, count: 1});
    json.tryType({type: "number", data: interval});
    // @ts-ignore Checked with tryType
    if (interval < 0) {
      throw new SyntaxError("interval must be greater than 0");
    }
    // @ts-ignore Checked with the tryType
    const id = setInterval(() => task(), interval);
    return ModuleDataDefinition.allocateTrackingId(id);
  },

  /**
   * Stops a scheduled timer.
   * @memberof task
   * @param {object} params
   * @param {number} [params.timerId] The id of the scheduled timer.
   * @returns {void}
   */
  stopTimer: function({timerId} = {}) {
    json.tryType({type: "number", data: timerId});
    // @ts-ignore tryType validates the timerId.
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
   * @param {number} [params.delay] The specified delay in milliseconds.
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
// [Worker Use Case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace worker
 */
const worker = Object.freeze({

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