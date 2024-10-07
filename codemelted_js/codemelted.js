// @ts-check
// ============================================================================
/**
 * @file The JavaScript implementation of the CodeMelted - Developer use
 * cases.
 * @author Mark Shaffer
 * @version 0.2.0 (Last Modified 2024-10-07) <br />
 * - 0.2.0 (2024-10-07): Completed codemelted.disk <br />
 * - 0.1.0 (2024-10-04): Completed codemelted.console <br />
 * @license MIT
 * @see https://developer.codemelted.com/codemelted_js
 */
// ============================================================================

// ----------------------------------------------------------------------------
// [Common Data Definitions] --------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Identifies why a use case transaction failed.
 * @private
 * @type {string}
 */
let _strerror = "";

/**
 * Resets the failure reason for each use case transaction.
 * @private
 * @param {any} err The error to handle and set.
 * @returns {void}
 */
function handleError(err = undefined) {
  if (err) {
    if (err instanceof Error) {
      _strerror = err.message;
    } else if ("toString" in err) {
      _strerror = err.toString();
    } else if (json.checkType("string", err)) {
      _strerror = err;
    } else {
      _strerror = "unknown";
    }
  } else {
    _strerror = "";
  }
}

// ----------------------------------------------------------------------------
// [Async IO Use Case] --------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace async
 */
const _async = Object.freeze({

});

// ----------------------------------------------------------------------------
// [Audio Use Case] -----------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace audio
 */
const _audio = Object.freeze({

});

// ----------------------------------------------------------------------------
// [Console Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Provides the console use case function to gather data via a
 * terminal. The actions correspond to the type of input / output
 * that will be interacted with via STDIN and STDOUT.
 * @namespace console
 * @see https://developer.codemelted.com/use_cases/console.html
 */
const console = Object.freeze({
  /**
   * Alerts a message to STDOUT with a [Enter] to halt execution.
   * @memberof console
   * @param {string} [message = ""] The message to display to STDOUT.
   * Not specifying will simple pause until [ENTER] is pressed.
   * @returns {void}
   */
  alert: function(message = "") {
    runtime.tryDeno();
    json.tryType("string", message);
    globalThis.alert(message);
  },

  /**
   * Prompts a [y/N] to STDOUT with the message as a question.
   * @memberof console
   * @param {string} [message = "CONFIRM"] The message to display to STDOUT.
   * @returns {boolean} true if y selected, false otherwise.
   */
  confirm: function(message = "CONFIRM") {
    runtime.tryDeno();
    json.tryType("string", message);
    return globalThis.confirm(message);
  },

  /**
   * Prompts a list of choices for the user to select from.
   * @memberof console
   * @param {string} [message = "CHOOSE"] The message to display to STDOUT.
   * @param {string[]} [choices = []] The choices to select from.
   * @returns {number} The index of the chosen item.
   */
  choose: function(message = "CHOOSE", choices = []) {
    runtime.tryDeno();
    json.tryType("string", message);
    json.tryType(Array, choices);
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
   * @param {string} [message = "PASSWORD"] The message to display
   * to STDOUT.
   * @returns {string} The typed password.
   */
  password: function(message = "PASSWORD") {
    // Setup our variables
    const deno = runtime.tryDeno();
    json.tryType("string", message);
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
   * @param {string} [message = "PROMPT"] The message to display to
   * STDOUT.
   * @returns {string?} The result typed.
   */
  prompt: function(message = "PROMPT:") {
    runtime.tryDeno();
    json.tryType("string", message);
    return globalThis.prompt(message);
  },

  /**
   * Write a message to STDOUT.
   * @memberof console
   * @param {string} [message = ""] The message to display to STDOUT.
   * @returns {void}
   */
  writeln: function(message = "") {
    runtime.tryDeno();
    json.tryType("string", message);
    globalThis.console.log(message);
  },
});

// ----------------------------------------------------------------------------
// [Database Use Case] --------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace db
 */
const _db = Object.freeze({

});

// ----------------------------------------------------------------------------
// [Disk Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Provides the ability to manage items on disk. This includes file
 * manipulation, reading / writing files, and opening files for additional
 * work.
 * @namespace disk
 * @see https://developer.codemelted.com/use_cases/disk.html
 */
const disk = Object.freeze({
  /**
   * Copies a file / directory from its currently source location to the
   * specified destination.
   * @memberof disk
   * @param {string} src The source item to copy.
   * @param {string} dest The destination of where to copy the item.
   * @returns {boolean} true if carried out, false otherwise. Check strerror
   * for details of failure.
   */
  cp: function(src, dest) {
    handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType("string", src);
      json.tryType("string", dest);
      deno.copyFileSync(src, dest);
      return true;
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      handleError(err);
      return false;
    }
  },

  /**
   * Determines if the specified item exists.
   * @memberof disk
   * @param {string} filename The path to a directory or filename.
   * @returns {Deno.FileInfo?} The file information or null if it does not
   * exist.
   */
  exists: function(filename) {
    handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType("string", filename);
      return deno.statSync(filename);
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      handleError(err);
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
    handleError();
    try {
      return runtime.tryDeno().env.get("HOME")
        || runtime.tryDeno().env.get("USERPROFILE")
        || null;
    } catch (err) {
      handleError(err);
      return null;
    }
  },

  /**
   * List the files in the specified source location.
   * @memberof codemelted.codemelted_disk
   * @param {string} path The path to list.
   * @returns {Deno.FileInfo[]?} Array of files found.
   */
  ls: function(path) {
    try {
      const deno = runtime.tryDeno();
      json.tryType("string", path);
      const dirList = deno.readDirSync(path);
      const fileInfoList = [];
      for (const dirEntry of dirList) {
        const fileInfo = deno.lstatSync(
          `${path}/${dirEntry.name}`
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
   * @param {string} path The source item to create.
   * @returns {boolean}
   */
  mkdir: function(path) {
    handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType("string", path);
      deno.mkdirSync(path);
      return true;
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      handleError(err);
      return false;
    }
  },

  /**
   * Moves a file / directory from its currently source location to the
   * specified destination.
   * @memberof disk
   * @param {string} src The source item to move.
   * @param {string} dest The destination of where to move the item.
   * @returns {boolean} true if carried out, false otherwise. Check strerror
   * for details of failure.
   */
  mv: function(src, dest) {
    handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType("string", src);
      json.tryType("string", dest);
      deno.renameSync(src, dest);
      return true;
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      handleError(err);
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
   * Reads an entire file from disk.
   * @memberof disk
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
      handleError();
      try {
        if (runtime.isDeno) {
          const deno = runtime.tryDeno();
          json.tryType("string", filename);
          json.tryType("boolean", isTextFile);
          if (isTextFile) {
            // @ts-ignore: checked via tryType call
            resolve(deno.readTextFileSync(filename));
          } else {
            // @ts-ignore: checked via tryType call
            resolve(deno.readFileSync(filename));
          }
        } else {
          json.tryType("string", accept);
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
        handleError(err);
        reject(err);
      }
    });
  },

  /**
   * Removes a file or directory at the specified location.
   * @memberof disk
   * @param {string} filename The source item to remove.
   * @returns {boolean} true if carried out, false otherwise. Check strerror
   * for details of failure.
   */
  rm: function(filename) {
    handleError();
    try {
      const deno = runtime.tryDeno();
      json.tryType("string", filename);
      deno.removeSync(filename, {recursive: true});
      return true;
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      handleError(err);
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
    handleError();
    try {
      return runtime.tryDeno().env.get("TMPDIR")
        || runtime.tryDeno().env.get("TMP")
        || runtime.tryDeno().env.get("TEMP")
        || "/tmp";
    } catch (err) {
      handleError(err);
      return null;
    }
  },

  /**
   * Writes an entire file to disk.
   * @memberof disk
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
      handleError();
      try {
        json.tryType("string", filename);

        if (runtime.isDeno) {
          const deno = runtime.tryDeno();
          json.tryType("boolean", append);

          if (json.checkType("string", data)) {
            // @ts-ignore: checked via tryType call
            deno.writeTextFileSync(filename, data, append);
          } else if (json.checkType(Uint8Array, data)) {
            // @ts-ignore: checked via tryType call
            deno.writeFileSync(filename, data, append);
          } else {
            throw new SyntaxError("data is not of an expected type");
          }

          resolve();
        } else {
          let blobURL = undefined;
          if (json.checkType("string", data)) {
            // @ts-ignore: checked via checkType above
            const buffer = new TextEncoder().encode(data);
            const blob = new Blob([buffer]);
            blobURL = URL.createObjectURL(blob);
          } else if (json.checkType(Uint8Array, data)) {
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
        handleError(err);
        reject(err);
      }
    });
  },
});

// ----------------------------------------------------------------------------
// [Game Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace game
 */
const _game = Object.freeze({

});

// ----------------------------------------------------------------------------
// [Firebase Use Case] --------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace firebase
 */
const _firebase = Object.freeze({

});

// ----------------------------------------------------------------------------
// [Hardware Use Case] --------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace hw
 */
const _hw = Object.freeze({

});

// ----------------------------------------------------------------------------
// [JSON Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * Defines a set of utility methods for performing data conversions for JSON
 * along with data validation.
 * @private
 * @namespace json
 */
const json = Object.freeze({
  /**
   * Determines if the specified object has the specified property.
   * @memberof json
   * @param {object} obj The object to check for the key.
   * @param {string} key The property to check for.
   * @returns {boolean} true if property was found, false otherwise.
   */
  checkHasProperty: function(obj, key) {
    return Object.hasOwn(obj, key);
  },

  /**
   * Utility to check parameters of a function to ensure they are of an
   * expected type.
   * @memberof json
   * @param {string | any} type The specified type to check the data
   * against.
   * @param {any} data The parameter to be checked.
   * @param {number} [count] Checks the data parameter function
   * signature to ensure the appropriate number of parameters are
   * specified.
   * @returns {boolean} true if it meets the expectations, false otherwise.
   */
  checkType: function(type, data, count = undefined) {
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
   * @memberof json
   * @param {string} data String to parse to see if it is a valid URL.
   * @returns {boolean} true if valid, false otherwise.
   */
  checkValidUrl: function(data) {
    handleError();
    let url = undefined;
    try {
      url = new URL(data);
    }
    catch (err) {
      url = undefined;
      handleError(err);
    }
    return this.checkType(URL, url);
  },

  /**
   * Converts a string to a JavaScript object.
   * @memberof json
   * @param {string} data The data to parse.
   * @returns {object | null} Object or null if the parse failed.
   */
  parse: function(data) {
    handleError();
    try {
      return JSON.parse(data);
    }
    catch (err) {
      handleError(err);
      return null;
    }
  },

  /**
   * Converts a JavaScript object into a string.
   * @memberof json
   * @param {object} data An object with valid JSON attributes.
   * @returns {string | null} The string representation or null if the
   * stringify failed.
   */
  stringify: function(data) {
    handleError();
    try {
      return JSON.stringify(data);
    }
    catch (err) {
      handleError(err);
      return null;
    }
  },

  /**
   * Determines if the specified object has the specified property.
   * @memberof json
   * @param {object} obj The object to check for the key.
   * @param {string} key The property to check for.
   * @returns {void}
   * @throws {SyntaxError} if the property is not found.
   */
  tryHasProperty: function(obj, key) {
    if (!this.checkHasProperty(obj, key)) {
      throw new SyntaxError("obj does not have the specified property");
    }
  },

  /**
   * Utility to check parameters of a function to ensure they are of an
   * expected type.
   * @memberof json
   * @param {string | any} type he specified type to check the data
   * against.
   * @param {any} data The parameter to be checked.
   * @param {number} [count] Checks the data parameter function
   * signature to ensure the appropriate number of parameters are
   * specified.
   * @returns {void}
   * @throws {SyntaxError} if the type was not as expected
   */
  tryType: function(type, data, count = undefined) {
    if (!this.checkType(type, data, count)) {
      throw new SyntaxError("data is not of expected type.");
    }
  },

  /**
   * Checks for a valid URL.
   * @memberof json
   * @param {string} data String to parse to see if it is a valid URL.
   * @returns {void}
   * @throws {SyntaxError} If v is not a valid url.
   */
  tryValidUrl: function(data) {
    if (!this.checkValidUrl(data)) {
      throw new SyntaxError("data is not a valid url");
    }
  },
});

// ----------------------------------------------------------------------------
// [Logger Use Case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace logger
 */
const _logger = Object.freeze({

});

// ----------------------------------------------------------------------------
// [Math Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace math
 */
const _math = Object.freeze({

});

// ----------------------------------------------------------------------------
// [Memory Use Case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace memory
 */
const _memory = Object.freeze({

});

// ----------------------------------------------------------------------------
// [Network Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace network
 */
const _network = Object.freeze({

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
// [Storage Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace storage
 */
const _storage = Object.freeze({

});

// ----------------------------------------------------------------------------
// [User Interface Use Case] --------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * TBD
 * @private
 * @namespace ui
 */
const _ui = Object.freeze({

  /**
   * Determines if the UI is under an iFrame or not.
   * @memberof ui
   * @readonly
   * @type {boolean}
   */
  get inIframe() {
    handleError();
    try {
      const w = runtime.tryWeb();
      // @ts-ignore: globalThis will have a Window object
      return w.self !== w.top;
    } catch (err) {
      if (err instanceof SyntaxError) {
        handleError(err);
        return false;
      }
      return true;
    }
  }
});

// ----------------------------------------------------------------------------
// [Public API] ---------------------------------------------------------------
// ----------------------------------------------------------------------------

/**
 * This module is the implementation of the CodeMelted - Developer use cases.
 * It will target the Deno and Web Browser runtimes with eventual support for
 * some of the use cases within a NodeJS environment. The use cases will be
 * organized as exported default public functions. This will also serve as
 * the backbone to the CodeMelted - Flutter module when it is utilized for a
 * web target.
 * @module codemelted
 */
export default Object.freeze({
  /**
   * A reason for a failure of a transaction that has an indicator for
   * either success / failure. NOTE: Module violations will result in
   * SyntaxError meaning they will not be reported via this mechanism.
   * @type {string}
   */
  strerror: _strerror,

  // /** @type {async} */
  // async: async,

  // /** @type {audio} */
  // audio: audio,

  /** @type {console} */
  console: console,

  // /** @type {db} */
  // db: db,

  /** @type {disk} */
  disk: disk,

  // /** @type {game} */
  // game: game,

  // /** @type {firebase} */
  // firebase: firebase,

  // /** @type {hw} */
  // hw: hw,

  // /** @type {json} */
  // json: json,

  // /** @type {logger} */
  // logger: logger,

  // /** @type {math} */
  // math: math,

  // /** @type {memory} */
  // memory: memory,

  // /** @type {network} */
  // network: network,

  // /** @type {runtime} */
  // runtime: runtime,

  // /** @type {storage} */
  // storage: storage,

  // /** @type {ui} */
  // ui: ui,
});