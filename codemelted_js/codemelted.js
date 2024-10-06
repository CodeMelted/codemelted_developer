// @ts-check
// ============================================================================
/**
 * @file The JavaScript implementation CodeMelted - Developer use cases.
 * @author Mark Shaffer
 * @version 0.1.0
 * @license MIT
 * @see https://developer.codemelted.com/codemelted_js
 */
// ============================================================================

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
   * @param {object} params The named parameters.
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
   * @param {object} params The named parameters.
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
   * @param {object} params The named parameters.
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
   * @param {object} params The named parameters.
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
   * @param {object} params The named parameters.
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
   * @param {object} params The named parameters.
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
 * TBD
 * @private
 * @namespace disk
 */
const _disk = Object.freeze({

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
   * @memberof json
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
   * @memberof json
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
    return this.checkType({ type: URL, data: url });
  },

  /**
   * Converts a string to a JavaScript object.
   * @memberof json
   * @param {object} params The named parameters.
   * @param {string} params.data The data to parse.
   * @returns {object | null} Object or null if the parse failed.
   */
  parse: function({ data }) {
    try {
      return JSON.parse(data);
    }
    catch (_ex) {
      return null;
    }
  },

  /**
   * Converts a JavaScript object into a string.
   * @memberof json
   * @param {object} params The named parameters.
   * @param {object} params.data An object with valid JSON attributes.
   * @returns {string | null} The string representation or null if the
   * stringify failed.
   */
  stringify: function({ data }) {
    try {
      return JSON.stringify(data);
    }
    catch (_ex) {
      return null;
    }
  },

  /**
   * Determines if the specified object has the specified property.
   * @memberof json
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
   * @memberof json
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
      throw new SyntaxError(`${data} parameter is not of type ${type} ` +
        `or does not contain expected ${count} for function`
      );
    }
  },

  /**
   * Checks for a valid URL.
   * @memberof json
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
    if (!this.isDeno) {
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
  // /** @type {async} */
  // async: async,

  // /** @type {audio} */
  // audio: audio,

  /** @type {console} */
  console: console,

  // /** @type {db} */
  // db: db,

  // /** @type {disk} */
  // disk: disk,

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