// @ts-check
// ============================================================================
/**
 * @file The implementation of the codemelted.js Module. It is meant as an all
 * purpose ES6 module with a collection of functions that can target multiple
 * JavaScript runtimes. Each public facing function documents which runtimes
 * it supports.
 * @author Mark Shaffer
 * @version 0.0.0 (Last Modified 2025-mm-dd)
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
 */

// ============================================================================
// [MODULE DATA DEFINITION] ===================================================
// ============================================================================

/**
 * Error thrown when the module is not used as intended providing the error
 * for a developer to fix their code.
 * @constant {SyntaxError}
 */
const API_MISUSE = new SyntaxError(
  "codemelted.js module logic was not used properly!"
);

/**
 * Identifies a piece of logic that is not implemented within the
 * codemelted.js module. This identifies future implementation logic or
 * represents a base class element not utilized in a child.
 * @constant {SyntaxError}
 */
const API_NOT_IMPLEMENTED = new SyntaxError(
  "NOT IMPLEMENTED LOGIC. DO NOT CALL!"
);

/**
 * Error thrown when the parameters specified to a codemelted.js module
 * function are not of an expected type.
 * @constant {SyntaxError}
 */
const API_TYPE_VIOLATION = new SyntaxError(
  "codemelted.js module encountered a parameter of an unexpected type!"
);

/**
 * Error thrown when the codemelted.js module function is called on an
 * unsupported runtime.
 * @constant {SyntaxError}
 */
const API_UNSUPPORTED_RUNTIME = new SyntaxError(
  "codemelted.js module function called on an unsupported JavaScript runtime!"
);

/**
 * The event handler utilized within a given JavaScript runtime. This
 * represents a global event handler that should suffice any JavaScript
 * event callback.
 * @callback CEventHandler
 * @param {Event} e The event object that was triggered
 * @returns {void}
 */

/**
 * Defines the "rules" for objects that will setup a protocol that directly
 * exchanges data with an external item, will continuously run until
 * terminated, requires the ability to know it is running, and get any errors
 * that have occurred during its run.
 */
export class CProtocolHandler {
  /** @type {string} */
  #id = "";

  /**
   * Gets the latest data received from the protocol.
   * @param {string} [request] Optional request string to add additional
   * queries from the protocol.
   * @returns {Promise<CResult>}
   */
  async get_message(request="") { throw API_NOT_IMPLEMENTED; }

  /**
   * The identification of the protocol.
   * @readonly
   * @type {string}
   */
  get id() { return this.#id; }

  /**
   * Determines if the protocol is running or has been terminated.
   * @readonly
   * @type {boolean}
   */
  get is_running() { throw API_NOT_IMPLEMENTED; }

  /**
   * Posts a given message to the given implementing protocol.
   * @param {any} data
   * @returns {Promise<CResult>}
   */
  async post_message(data) { throw API_NOT_IMPLEMENTED; }

  /**
   * Terminates the given protocol.
   * @returns {void}
   */
  terminate() { throw API_NOT_IMPLEMENTED; }

  /**
   * Constructor for the class.
   * @param {string} id Identification for the protocol for debugging
   * purposes.
   */
  constructor(id) {
    this.#id = id;
  }
}

/**
 * Support object for the [CProtocolHandler] and any other object to provide
 * a result where either the value or the error can be signaled for later
 * checking by a user.
 */
class CResult {
  /** @type {any} */
  #error = null;

  /** @type {any} */
  #value = undefined;

  /**
   * Holds any error message associated with a failed transaction request.
   * @readonly
   * @type {any}
   */
  get error() { return this.#error; }

  /**
   * Signals whether an error was captured or not.
   * @readonly
   * @type {boolean}
   */
  get is_error() {
    if (this.error instanceof Error) {
      return true;
    }
    return this.error != null && this.error.length > 0; }

  /**
   * Signals the transaction completed with no errors.
   * @readonly
   * @type {boolean}
   */
  get is_ok() { return !this.is_error; }

  /**
   * Hold the value of the given result or nothing if the [CResult] is being
   * used to signal there was no error.
   * @readonly
   * @type {any}
   */
  get value() { return this.#value; }

  /**
   * Constructor for the class.
   * @param {object} params The named parameters for the object.
   * @param {any} [params.value] The value associated with the result
   * @param {any} [params.error] The error associated with the
   * result.
   */
  constructor({value, error = null} = {}) {
    this.#value = value;
    this.#error = error;
  }
}

// ============================================================================
// [ASYNC UC IMPLEMENTATION] ==================================================
// ============================================================================

/**
 * The task to run as part of the [asyncTask] call.
 * @callback CTaskCB
 * @param {any} [data] Optional data to pass to the task.
 * @returns {any} The result of the task completing.
 */

/**
 * The task to run as part of the [asyncTimer] function call.
 * @callback CTimerCB
 * @returns {void}
 */

/**
 * The result object from the [async_timer] call to allow for stopping the
 * running timer in the future.
 */
export class CTimerResult {
  /** @type {number} */
  #id = -1;

  /**
   * Determines if the timer is still running.
   * @readonly
   * @type {boolean}
   */
  get is_running() { return this.#id !== -1; }

  /**
   * Stops the running timer.
   * @returns {void}
   * @throws {API_MISUSE} When called on an already terminated
   * timer.
   */
  stop() {
    if (!this.is_running) {
      throw API_MISUSE;
    }
    clearInterval(this.#id);
    this.#id = -1;
  }

  /**
   * Constructor for the object.
   * @param {CTimerCB} task
   * @param {number} interval
   */
  constructor(task, interval) {
    this.#id = setInterval(task, interval);
  }
}

/**
 * Will put a currently running async task to sleep for a specified delay in
 * milliseconds.
 * @param {number} delay The delay in milliseconds to wait before processing
 * the next asynchronous task.
 * @returns {Promise<void>} The promise to await on for the delay.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // Sleep asynchronous task for 1 second.
 * await async_sleep(1000);
 */
export function async_sleep(delay) {
  json_check_type({type: "number", data: delay, shouldThrow: true });
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve();
    }, delay);
  });
}

/**
 * Will execute an asynchronous task with the ability to delay it into the
 * future and return a result if necessary.
 * @param {object} params The named parameters.
 * @param {CTaskCB} params.task The task to run.
 * @param {any} [params.data] The optional data to pass to the task.
 * @param {number} [params.delay=0] The delay to schedule the task in the
 * future.
 * @returns {Promise<CResult>} A future promise with the result of the
 * task.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function async_task({task, data, delay = 0}) {
  json_check_type({type: "function", data: task, shouldThrow: true});
  json_check_type({type: "number", data: delay, shouldThrow: true});
  return new Promise((resolve) => {
    try {
      setTimeout(() => {
        let answer = task(data);
        resolve(new CResult(answer));
      }, delay);
    } catch (err) {
      resolve(new CResult({error: err}));
    }
  });
}

/**
 * Creates an asynchronous repeating task on the main thread.
 * @param {object} params The named parameters.
 * @param {CTimerCB} params.task The task to run on the specified interval.
 * @param {number} params.interval The interval in milliseconds to repeat
 * the given task.
 * @returns {CTimerResult} The timer that runs the task on the specified
 * interval.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function async_timer({task, interval}) {
  json_check_type({
    type: "function",
    data: task,
    count: 0,
    shouldThrow: true
  });
  json_check_type({type: "number", data: interval, shouldThrow: true});
  return new CTimerResult(task, interval);
}

/**
 * <mark>IN DEVELOPMENT! DON'T USE!!</mark
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function async_worker() {
  throw API_NOT_IMPLEMENTED;
}

// ============================================================================
// [CONSOLE UC IMPLEMENTATION] ================================================
// ============================================================================

/**
 * Writes an alert message (via STDOUT) to the user awaiting an enter key
 * press via STDIN.
 * @param {string} [message=""] The message to prompt out or "ALERT".
 * @returns {void}
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function console_alert(message = "") {
  json_check_type({type: "string", data: message, shouldThrow: true});
  if (runtime_is_deno()) {
    globalThis.alert(message);
  } else if (runtime_is_nodejs()) {
    throw API_NOT_IMPLEMENTED;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Prompts (via STDOUT) for a user to make a choice (via STDIN) between an
 * array of choices
 * @param {object} params The named parameters.
 * @param {string} [params.message=""] The message to write to STDOUT.
 * @param {string[]} params.choices The choices to choose from
 * written to STDOUT.
 * @returns {number} The index of the selection in [params.choices].
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function console_choose({message = "", choices}) {
  json_check_type({type: "string", data: message, shouldThrow: true});
  json_check_type({type: Array, data: choices, shouldThrow: true});
  if (runtime_is_deno()) {
    const prompt = message.trim().length > 0
      ? message
      : "CHOOSE";
    let answer = -1;
    do {
      globalThis.console.log();
      globalThis.console.log("-".repeat(prompt.length));
      globalThis.console.log(prompt);
      globalThis.console.log("-".repeat(prompt.length));
      choices.forEach((v, index) => {
          console.log(`${index}. ${v}`);
      });
      const choice = globalThis.prompt(
        `Make a Selection [0 = ${choices.length - 1}]:`
      ) ?? "";
      answer = parseInt(choice);
      if (isNaN(answer) || answer >= choices.length) {
        console.log(
          "ERROR: Entered value was invalid. Please try again."
        );
        answer = -1;
      }
    } while (answer === -1);
    return answer;
  } else if (runtime_is_nodejs()) {
    throw API_NOT_IMPLEMENTED;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Prompts (via STDOUT) for a user confirmation (via STDIN).
 * @param {string} [message=""] The confirmation you are looking for.
 * @returns {boolean} The choice made.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function console_confirm(message = "") {
  json_check_type({type: "string", data: message, shouldThrow: true});
  if (runtime_is_deno()) {
    const prompt = message.trim().length > 0
      ? message
      : "CONFIRM";
    return globalThis.confirm(prompt);
  } else if (runtime_is_nodejs()) {
    throw API_NOT_IMPLEMENTED;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Prompts (via STDOUT) for a user to enter their password via STDIN.
 * @param {string} [message=""] The custom prompt to write out to STDOUT.
 * @returns {string} the password entered via STDIN.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function console_password(message = "") {
  json_check_type({type: "string", data: message, shouldThrow: true});
  if (runtime_is_deno()) {
    const prompt = message.trim().length > 0
      ? message
      : "PASSWORD";
    globalThis.Deno.stdin.setRaw(true);
    const buf = new Uint8Array(1);
    const decoder = new TextDecoder();
    let answer = "";
    let done = false;
    console.log(`${prompt}:`);
    do {
      const nread = globalThis.Deno.stdin.readSync(buf) ?? 0;
      if (nread === null) {
        done = true;
      } else if (buf && buf[0] === 0x03) {
        done = true;
      } else if (buf && buf[0] === 13) {
        done = true;
      }
      const text = decoder.decode(buf.subarray(0, nread));
      answer += text;
    } while (!done);
    globalThis.Deno.stdin.setRaw(false);
    return answer;
  } else if (runtime_is_nodejs()) {
    throw API_NOT_IMPLEMENTED;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Write a prompt to STDOUT to receive an answer via STDIN.
 * @param {string} [message=""] The custom prompt message for STDOUT.
 * @returns {string} The typed in answer received via STDIN.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function console_prompt(message = "") {
  json_check_type({type: "string", data: message, shouldThrow: true});
  if (runtime_is_deno()) {
    const prompt = message.trim().length > 0
      ? message
      : "PROMPT";
    const answer = globalThis.prompt(`${prompt}:`);
    return answer != null ? answer : "";
  } else if (runtime_is_nodejs()) {
    throw API_NOT_IMPLEMENTED;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Writes the given message to STDOUT.
 * @param {string} [message=""] The message to write or a blank line.
 * @returns {void}
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" check><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function console_writeln(message = "") {
  json_check_type({type: "string", data: message, shouldThrow: true});
  if (runtime_is_deno() || runtime_is_nodejs()) {
    globalThis.console.log(message);
  }
  throw API_UNSUPPORTED_RUNTIME;
}

// TODO: NodeJS Console?

// ============================================================================
// [DB UC IMPLEMENTATION] =====================================================
// ============================================================================

/**
 * <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function db_exists() {
  // TODO: IndexDB for browser / worker
  //       DenoKV for Deno
  //       Possibly Sqlite for NodeJS. If no third party items involved.
  throw API_NOT_IMPLEMENTED;
}

/**
 * <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function db_manage() {
  // TODO: IndexDB for browser / worker
  //       DenoKV for Deno
  //       Possibly Sqlite for NodeJS. If no third party items involved.
  throw API_NOT_IMPLEMENTED;
}

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function db_query() {
  // TODO: IndexDB for browser / worker
  //       DenoKV for Deno
  //       Possibly Sqlite for NodeJS. If no third party items involved.
  throw API_NOT_IMPLEMENTED;
}

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function db_update() {
  // TODO: IndexDB for browser / worker
  //       DenoKV for Deno
  //       Possibly Sqlite for NodeJS. If no third party items involved.
  throw API_NOT_IMPLEMENTED;
}

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function db_version() {
  // TODO: IndexDB for browser / worker
  //       DenoKV for Deno
  //       Possibly Sqlite for NodeJS. If no third party items involved.
  throw API_NOT_IMPLEMENTED;
}

// ============================================================================
// [DISK UC IMPLEMENTATION] ===================================================
// ============================================================================

/**
 * Provides information about a file returned. This serves as a higher
 * abstraction for Deno / NodeJS runtimes that retrieve this type of
 * information.
 * @see https://docs.deno.com/api/deno/~/Deno.FileInfo
 */
export class CFileInfo {
  /** @type {string} */
  #filename;

  /** @type {any} */
  #metadata;

  /**
   * The name of the file / directory on disk.
   * @readonly
   * @type {string}
   */
  get filename() {
    return this.#filename;
  }

  /**
   * True if this is info for a regular file.
   * @readonly
   * @type {boolean}
   */
  get isFile() {
    // @ts-ignore Will exist in Deno runtime
    return this.#metadata.isFile;
  }

  /**
   * True if this is info for a regular directory.
   * @readonly
   * @type {boolean}
   */
  get isDirectory() {
    // @ts-ignore Will exist in Deno runtime
    return this.#metadata.isDirectory;
  }

  /**
   * True if this is info for a symlink.
   * @readonly
   * @type {boolean}
   */
  get isSymlink() {
    // @ts-ignore Will exist in Deno runtime
    return this.#metadata.isSymlink;
  }

  /**
   * The size of the file, in bytes.
   * @readonly
   * @type {number}
   */
  get size() {
    // @ts-ignore Will exist in Deno runtime
    return this.#metadata.size;
  }

  /**
   * The last modification time of the file. This corresponds to the mtime
   * field from stat on Linux/Mac OS and ftLastWriteTime on Windows. This
   * may not be available on all platforms.
   * @readonly
   * @type {number?}
   */
  get ntime() {
    // @ts-ignore Will exist in Deno runtime
    return this.#metadata.ntime;
  }

  /**
   * The last access time of the file. This corresponds to the atime field
   * from stat on Unix and ftLastAccessTime on Windows. This may not be
   * available on all platforms.
   * @readonly
   * @type {Date?}
   */
  get atime() {
    // @ts-ignore Will exist in Deno runtime
    return this.#metadata.atime;
  }

  /**
  * The creation time of the file. This corresponds to the birthtime field
  * from stat on Mac/BSD and ftCreationTime on Windows. This may not be
  * available on all platforms.
   * @readonly
   * @type {Date?}
   */
  get birthtime() {
    // @ts-ignore Will exist in Deno runtime
    return this.#metadata.birthtime;
  }

  /**
   * The last change time of the file. This corresponds to the ctime field
   * from stat on Mac/BSD and ChangeTime on Windows. This may not be
   * available on all platforms.
   * @readonly
   * @type {Date?}
   */
  get ctime() {
    // @ts-ignore Will exist in Deno runtime
    return this.#metadata.ctime;
  }

  /**
   * ID of the device containing the file.
   * @readonly
   * @type {number?}
   */
  get dev() {
    // @ts-ignore Will exist in Deno runtime
    return this.#metadata.dev;
  }

  /**
   * Inode number.
   * @readonly
   * @type {number?}
   */
  get ino() {
    // @ts-ignore Will exist in Deno runtime
    return this.#metadata.ino;
  }

  /**
   * Constructor for the object.
   * @param {string} filename The item on disk that was looked up.
   * @param {any} metadata The Deno / NodeJS representation of a file /
   * directory on disk.
   */
  constructor(filename, metadata) {
    this.#filename = filename;
    this.#metadata = metadata;
  }
}

/**
 * Copies a file / directory from its currently source location to the
 * specified destination.
 * @param {string} src The source item to copy.
 * @param {string} dest The destination of where to copy the item.
 * @returns {CResult} Identifying success or a reason why copy failed.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" uncheck><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" uncheck><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function disk_cp(src, dest) {
  json_check_type({type: "string", data: src, shouldThrow: true});
  json_check_type({type: "string", data: dest, shouldThrow: true});
  if (runtime_is_deno()) {
    try {
      // @ts-ignore Will exist in Deno runtime.
      globalThis.copyFileSync(src, dest);
      return new CResult();
    } catch (err) {
      return new CResult({error: err});
    }
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Determines if the specified item (filename or directory) exists.
 * @param {string} filename The source item to copy.
 * @returns {CFileInfo?} Identifying success (exists) or null if not found.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" uncheck><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" uncheck><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function disk_exists(filename) {
  json_check_type({type: "string", data: filename, shouldThrow: true});
  if (runtime_is_deno()) {
    try {
      // @ts-ignore Will exist in Deno runtime.
      const metadata = globalThis.statSync(filename);
      return new CFileInfo(filename, metadata);
    } catch (err) {
      return null;
    }
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * List the files in the specified source location.
 * @param {string} path The directory to list.
 * @returns {CFileInfo[]?} Identifying success (exists) or null if not found.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" uncheck><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" uncheck><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function disk_ls(path) {
  json_check_type({type: "string", data: path, shouldThrow: true});
  if (runtime_is_deno()) {
    try {
      // @ts-ignore Will exist in Deno Runtime.
      const dirList = globalThis.readDirSync(path);
      const fileInfoList = [];
      for (const dirEntry of dirList) {
        const filename = `${path}/${dirEntry.name}`;
        // @ts-ignore Will exist in Deno Runtime.
        const metadata = globalThis.lstatSync(filename);
        fileInfoList.push(new CFileInfo(filename, metadata ));
      }
      return fileInfoList;
    } catch (err) {
      return null;
    }
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Makes a directory at the specified location.
 * @param {string} path The directory to create.
 * @returns {CResult} Identifying success (created) or an error specifying why
 * the creation failed.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" uncheck><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" uncheck><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function disk_mkdir(path) {
  json_check_type({type: "string", data: path, shouldThrow: true});
  if (runtime_is_deno()) {
    try {
      // @ts-ignore Will exist in the Deno Runtime.
      globalThis.mkdirSync(path);
      return new CResult();
    } catch (err) {
      return new CResult({error: err});
    }
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Moves a file / directory from its currently source location to the
 * specified destination.
 * @param {string} src The source item to move.
 * @param {string} dest The destination of where to move the item.
 * @returns {CResult} Identifying success or a reason why move failed.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" uncheck><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" uncheck><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function disk_mv(src, dest) {
  json_check_type({type: "string", data: src, shouldThrow: true});
  json_check_type({type: "string", data: dest, shouldThrow: true});
  if (runtime_is_deno()) {
    try {
      // @ts-ignore Will exist in Deno runtime.
      globalThis.renameSync(src, dest);
      return new CResult();
    } catch (err) {
      return new CResult({error: err});
    }
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Provides the mechanism to read a file from the host operating system disk
 * and return it as binary or string data.
 * @param {object} params The named parameters
 * @param {string} [params.filename] Filename to provide when using deno or
 * nodejs runtimes to open a file.
 * @param {string} [params.accept=""] The accept string to apply on the file
 * open dialog when the runtime is browser.
 * @param {boolean} [params.isTextFile=false] Identifies whether to retrieve
 * the data as Uint8Array or as a string.
 * @returns {Promise<CResult>} The result containing the requested data or
 * reason for failure.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" check><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" uncheck><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function disk_read_file({filename, accept="", isTextFile=false}) {
  json_check_type({type: "string", data: accept, shouldThrow: true});
  json_check_type({type: "boolean", data: isTextFile, shouldThrow: true});
  if (runtime_is_browser()) {
    return new Promise((resolve) => {
      try {
        // @ts-ignore document will exist in browser context.
        const input = globalThis.document.createElement("input");
        input.type = "file";
        input.accept = accept;
        input.oncancel = () => {
          resolve(new CResult({error: "File open was cancelled"}));
        }
        input.onchange = async () => {
          if (input.files != null && input.files.length > 0) {
            let file = input.files[0];
            if (isTextFile) {
              const buffer = await file.arrayBuffer();
              const decoder = new TextDecoder();
              const data = decoder.decode(buffer);
              resolve(new CResult({value: data}));
            } else {
              const buffer = await file.arrayBuffer();
              const array = new Uint8Array(buffer);
              const data = Array.from(array);
              resolve(new CResult({value: data}));
            }
          } else {
            resolve(new CResult({error: "Failed to read the specified file"}));
          }
        }
        input.click();
      } catch (err) {
        resolve(new CResult({error: err}));
      }
    });
  } else if (runtime_is_deno()) {
    return new Promise((resolve) => {
      try {
        const data = isTextFile
          // @ts-ignore Will exist in the Deno runtime.
          ? globalThis.readTextFileSync(filename)
          // @ts-ignore Will exist in the Deno runtime.
          : globalThis.readFileSync(filename);
        resolve(new CResult({value: data}));
      } catch (err) {
        resolve(new CResult({error: err}));
      }
    });
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Removes a file or directory at the specified location.
 * @param {string} filename The item to remove
 * @returns {CResult} Identifying success or a reason why removal failed.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" uncheck><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" uncheck><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function disk_rm(filename) {
  json_check_type({type: "string", data: filename, shouldThrow: true});
  if (runtime_is_deno()) {
    try {
      // @ts-ignore Will exist in the Deno Runtime.
      globalThis.removeSync(filename);
      return new CResult();
    } catch (err) {
      return new CResult({error: err});
    }
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Saves an entire file to the host operating system disk. For browser runtime
 * this will get saved to the download folder of the given operating system.
 * @param {object} params The named parameters
 * @param {string} params.filename The path and filename on disk.
 * @param {string | Uint8Array} params.data The data to save to disk.
 * @param {boolean} [params.append=false] Whether to append data to an
 * existing file or not. Only valid for Deno / NodeJS runtimes.
 * @returns {Promise<CResult>} Signaling success or capturing the reason for
 * failure.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" check><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" uncheck><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function disk_write_file({filename, data, append=false}) {
  json_check_type({type: "string", data: filename, shouldThrow: true});
  if (filename.length === 0) {
    throw API_MISUSE;
  }
  const isValidData = json_check_type({type: "string", data: data})
    || json_check_type({type: Uint8Array, data: data});
  if (!isValidData) {
    throw API_TYPE_VIOLATION;
  }
  if (runtime_is_browser()) {
    return new Promise((resolve) => {
      try {
        // Fallback if the File System Access API is not supported…
        // Create the blob URL.
        let blob = json_check_type({type: "string", data: data})
          ? new Blob([data], { type: "text/plain" })
          : json_check_type({type: Uint8Array, data: data})
            ? new Blob([data], { type: 'application/octet-stream' })
            : data;

        // @ts-ignore This will be fully converted to a blob.
        const blobURL = URL.createObjectURL(blob);

        // @ts-ignore Will exist in browser context
        const a = globalThis.document.createElement('a');
        a.href = blobURL;
        a.download = filename;
        a.style.display = 'none';

        // @ts-ignore Will exist in browser context
        globalThis.document.body.append(a);
        a.click();
        // Revoke the blob URL and remove the element.
        setTimeout(() => {
          URL.revokeObjectURL(blobURL);
          a.remove();
          resolve(new CResult());
        }, 1000);
      } catch (err) {
        resolve(new CResult({error: err}));
      }
    });
  } else if (runtime_is_deno()) {
    return new Promise((resolve) => {
      try {
        if (json_check_type({type: "string", data: data})) {
          // @ts-ignore Will exist in Deno runtime.
          globalThis.writeTextFileSync(filename, data, append);
        } else {
          // @ts-ignore Will exist in Deno runtime.
          globalThis.writeFileSync(filename, data, append);
        }
        resolve(new CResult());
      } catch (err) {
        resolve(new CResult({error: err}));
      }
    });
  }
  throw API_UNSUPPORTED_RUNTIME;
}

// ============================================================================
// [HW UC IMPLEMENTATION] =====================================================
// ============================================================================

/**
 * Represents the geodetic data captured from the [COrientationProtocol]
 * object when created via the [hw_request_orientation] function call.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/GeolocationCoordinates
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/deviceorientation_event
 */
export class CGeodeticData {
  /** @type {Date} */
  #timestamp = new Date();
  /** @type {number} */
  #latitude = NaN;
  /** @type {number} */
  #longitude = NaN;
  /** @type {number?} */
  #altitude = null;
  /** @type {number?} */
  #heading = null;
  /** @type {number?} */
  #speed = null;
  /** @type {number?} */
  #alpha = null;
  /** @type {number?} */
  #beta = null;
  /** @type {number?} */
  #gamma = null;

  /**
   * The time the orientation data was last updated.
   * @readonly
   * @type {Date}
   */
  get timestamp() { return this.#timestamp; }

  /**
   * Returns a double representing the position's latitude in decimal
   * degrees.
   * @readonly
   * @type {number}
   */
  get latitude() { return this.#latitude; }

  /**
   * Returns a double representing the position's longitude in decimal
   * degrees.
   * @readonly
   * @type {number}
   */
  get longitude() { return this.#longitude; }

  /**
   * Returns a double representing the position's altitude in meters,
   * relative to sea level. This value can be null if the implementation
   * cannot provide the data.
   * @readonly
   * @type {number?}
   */
  get altitude() { return this.#altitude; }

  /**
   * Returns a double representing the direction towards which the
   * device is facing. This value, specified in degrees, indicates how
   * far off from heading true north the device is. 0 degrees represents
   * true north, and the direction is determined clockwise (which means
   * that east is 90 degrees and west is 270 degrees). If speed is 0,
   * heading is NaN. If the device is unable to provide heading
   * information, this value is null.
   * @readonly
   * @type {number?}
   */
  get heading() { return this.#heading; }

  /**
   * Returns a double representing the velocity of the device in meters
   * per second. This value can be null.
   * @readonly
   * @type {number?}
   */
  get speed() { return this.#speed; }

  /**
   * A number representing the motion of the device around the z axis,
   * express in degrees with values ranging from 0 (inclusive) to
   * 360 (exclusive).
   * @readonly
   * @type {number?}
   */
  get alpha() { return this.#alpha; }

  /**
   * A number representing the motion of the device around the x axis,
   * expressed in degrees with values ranging from -180 (inclusive) to
   * 180 (exclusive). This represents the front to back motion of the
   * device.
   * @readonly
   * @type {number?}
   */
  get beta() { return this.#beta; }

  /**
   * A number representing the motion of the device around the y axis,
   * expressed in degrees with values ranging from -90 (inclusive) to 90
   * (exclusive). This represents the left to right motion of the device.
   * @readonly
   * @type {number?}
   */
  get gamma() { return this.#gamma; }

  /**
   * Processes a device orientation event to get the particular device's
   * orientation in 3D space.
   * @param {DeviceOrientationEvent} data The event object to process.
   * @returns {void}
   */
  updateDeviceOrientation(data) {
    // @ts-ignore DeviceOrientationEvent part of browser runtime.
    if (json_check_type({type: DeviceOrientationEvent, data: data})) {
      this.#timestamp = new Date();
      this.#alpha = data.alpha ?? NaN;
      this.#beta = data.beta ?? NaN;
      this.#gamma = data.gamma ?? NaN;
    }
  }

  /**
   * Processes the current WGS84 geo location information for the devices
   * position in the world.
   * @param {GeolocationCoordinates} data The data to process.
   * @returns {void}
   */
  updateGeolocation(data) {
    // @ts-ignore Object exists in browser runtime.
    if (json_check_type({type: GeolocationCoordinates, data: data})) {
      this.#timestamp = new Date();
      this.#latitude = data.latitude;
      this.#longitude = data.longitude;
      this.#altitude = data.altitude;
      this.#heading = data.heading;
      this.#speed = data.speed;
    }
  }

  /**
   * Default constructor
   */
  constructor() { }
}

/**
 * Implements the orientation protocol to determine your application's
 * position in 3D space based on the sensors on the device.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Window/deviceorientation_event
 * @extends {CProtocolHandler}
 */
export class COrientationProtocol extends CProtocolHandler {
  /** @type {CGeodeticData} */
  #data = new CGeodeticData();
  #onDeviceOrientation;
  #watchId;
  /** @type {string?} */
  #errorRx = null;

  /**
   * Will retrieve the latest [CGeodeticData] object from the returned
   * [CResult] object.
   * @override
   */
  async get_message(request="") {
    if (this.#errorRx) {
      const result = new CResult({
        error: this.#errorRx
      });
      this.#errorRx = null;
      return result;
    }
    return new CResult({
      value: Object.assign({}, this.#data),
    });
  }

  /**
   * @inheritdoc
   * @override
   */
  get is_running() {
    return this.#watchId != -1;
  }

  /**
   * NOT USED. WILL THROW EXCEPTION.
   * @override
   * @param {any} data
   * @returns {Promise<CResult>}
   */
  post_message(data) { throw API_NOT_IMPLEMENTED; }

  /**
   * @inheritdoc
   * @override
   */
  terminate() {
    if (!this.is_running) {
      throw API_MISUSE;
    }
    // @ts-ignore Object exists in browser runtime.
    globalThis.navigator.geolocation.clearWatch(this.#watchId);
    this.#watchId = -1;
    // @ts-ignore Object exists in browser runtime.
    globalThis.removeEventListener(
      "deviceorientation",
      this.#onDeviceOrientation
    );
  }

  /**
   * Constructor for the protocol.
   * @see https://developer.mozilla.org/en-US/docs/Web/API/Geolocation/getCurrentPosition
   * @param {object} [options] Optional options for fine tuning the
   * watch of geolocation changes.
   */
  constructor(options) {
    super("COrientationProtocol");

    // Setup to listen for device orientation changes.
    // @ts-ignore Object exists in browser runtime.
    this.#onDeviceOrientation = (/** @type {DeviceOrientationEvent} */ e) => {
      this.#data.updateDeviceOrientation(e);
    };
    // @ts-ignore Object exists in browser runtime.
    globalThis.addEventListener(
      "deviceorientation",
      this.#onDeviceOrientation
    );

    // Setup listening for geolocation updates
    // @ts-ignore Property exists in browser runtime.
    this.#watchId = globalThis.navigator.geolocation.watchPosition(
      // @ts-ignore Object exists in browser runtime.
      (/** @type {GeolocationPosition} */ position) => {
        this.#data.updateGeolocation(position.coords);
      },
      // @ts-ignore Object exists in browser runtime.
      (/** @type {GeolocationError} */ err) => {
        this.#errorRx = err.message;
      },
      options
    )
  }
}

/**
 * The data that supports a [CSerialPortProtocol::get_message] or
 * [CSerialPortProtocol::post_message] function calls to communicate with the
 * connected serial port.
 * @typedef {object} CSerialPortPostRequest
 * @property {string} request The {@link SERIAL_PORT_DATA_REQUEST} to either
 * read or write to the serial port via the [CSerialPortProtocol].
 * @property {any} data The data associated with the request.
 */

/**
 * Object created from the [hw_request_serial_port] function call opening a
 * connection to the requested serial port connected to the host computer.
 * With the opened serial port, utilize the [CSerialPort::get_message] and
 * [CSerialPort::post_message] to interact with the port until it is
 * [CSerialPort::terminate].
 * @extends {CProtocolHandler}
 */
export class CSerialPortProtocol extends CProtocolHandler {
  /** @type {SerialPort} */
  #port;

  /**
   * Reads the requested data from the currently connected serial port.
   * @override
   * @param {string} request The {@link SERIAL_PORT_DATA_REQUEST} to read the current
   * state of the serial port or actual data. The supported items to query are
   * ClearToSend, CarrierDetect, DataSetReady, RingIndicator, and DataBytes.
   * @returns {Promise<CResult>} holding the data associated with the request.
   * A rejected promise is the result of an API violation.
   */
  async get_message(request) {
    try {
      if (!this.is_running) {
        throw API_MISUSE;
      }
      let resp = null;
      let data = null;
      switch (request) {
        case SERIAL_PORT_DATA_REQUEST.ClearToSend:
          resp = await this.#port.getSignals();
          data = resp["clearToSend"];
          break;
        case SERIAL_PORT_DATA_REQUEST.CarrierDetect:
          resp = await this.#port.getSignals();
          data = resp["dataCarrierDetect"];
          break;
        case SERIAL_PORT_DATA_REQUEST.DataSetReady:
          resp = await this.#port.getSignals();
          data = resp["dataSetReady"];
          break;
        case SERIAL_PORT_DATA_REQUEST.RingIndicator:
          resp = await this.#port.getSignals();
          data = resp["ringIndicator"];
          break;
        case SERIAL_PORT_DATA_REQUEST.DataBytes:
          if (!this.#port.readable) {
            return new CResult({
              error: "Serial port was unreadable at this time"
            });
          }
          const reader = this.#port.readable.getReader();
          const { value, done } = await reader.read();
          data = value;
          reader.releaseLock();
          break;
        default:
          throw API_MISUSE;
      }
      return new CResult({value: data});
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      return new CResult({error: err});
    }
  }

  /**
   * @inheritdoc
   * @override
   */
  get is_running() {
    return this.#port.connected;
  }

  /**
   * Will process the data request and perform the requested transaction with
   * the connected serial port returning a result of if it was successfully
   * carried out.
   * @override
   * @param {CSerialPortPostRequest} data The request to make to the connected
   * serial port with associated data.
   * @return {Promise<CResult>} The result of the posted data to the port.
   * A rejected promise is the result of an API violation.
   */
  async post_message(data) {
    try {
      json_check_type({type: "object", data: data, shouldThrow: true});
      let request = data.request;
      switch (request) {
        case SERIAL_PORT_DATA_REQUEST.DataTerminalReady:
          json_check_type({
            type: "boolean",
            data: data.data,
            shouldThrow: true
          });
          await this.#port.setSignals("dataTerminalReady", data.data);
          break;
        case SERIAL_PORT_DATA_REQUEST.RequestToSend:
          json_check_type({
            type: "boolean",
            data: data.data,
            shouldThrow: true
          });
          await this.#port.setSignals("requestToSend", data.data);
          break;
        case SERIAL_PORT_DATA_REQUEST.Break:
          json_check_type({
            type: "boolean",
            data: data.data,
            shouldThrow: true
          });
          await this.#port.setSignals("break", data.data);
          break;
        case SERIAL_PORT_DATA_REQUEST.DataBytes:
          json_check_type({
            type: Uint8Array,
            data: data.data,
            shouldThrow: true
          });
          const writer = this.#port.writable.getWriter();
          await writer.write(data.data);
          writer.releaseLock();
          break;
        default:
          throw API_MISUSE;
      }
      return new CResult();
    } catch (err) {
      if (err instanceof SyntaxError) {
        throw err;
      }
      return new CResult({error: err});
    }
  }

  /**
   * @inheritdoc
   * @override
   */
  terminate() {
    if (!this.is_running) {
      throw API_MISUSE;
    }
    this.#port.close();
  }

  /**
   * Constructor for the class.
   * @param {SerialPort} port The port that we are connecting to.
   */
  constructor(port) {
    super(
      `CSerialPort_${port.getInfo().usbVendorId}` +
      `_${[port.getInfo().usbProductId]}`
    );
    this.#port = port;
  }
}

/**
 * Defined to support proper typing in the JSDocs when type checking in a
 * TypeScript environment.
 * NOTE: Defined to support proper typing in the JSDocs when type checking in a
 *       TypeScript environment.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/DeviceOrientationEvent
 * @typedef {object} DeviceOrientationEvent
 * @property {boolean} absolute A boolean that indicates whether or not the
 * device is providing orientation data absolutely.
 * @property {number?} alpha A number representing the motion of the device
 * around the z axis, express in degrees with values ranging from 0
 * (inclusive) to 360 (exclusive).
 * @property {number?} beta A number representing the motion of the device
 * around the x axis, express in degrees with values ranging from -180
 * (inclusive) to 180 (exclusive). This represents a front to back motion of
 *  the device.
 * @property {number?} gamma A number representing the motion of the device
 * around the y axis, express in degrees with values ranging from -90
 * (inclusive) to 90 (exclusive). This represents a left to right motion of
 * the device.
 */

/**
 * The GeolocationCoordinates interface represents the position and altitude
 * of the device on Earth, as well as the accuracy with which these properties
 * are calculated. The geographic position information is provided in terms of
 * World Geodetic System coordinates (WGS84).
 * NOTE: Defined to support proper typing in the JSDocs when type checking in a
 *       TypeScript environment.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/GeolocationCoordinates
 * @typedef {object} GeolocationCoordinates
 * @property {number} latitude Returns a double representing the position's
 * latitude in decimal degrees.
 * @property {number} longitude Returns a double representing the position's
 * longitude in decimal degrees.
 * @property {number | null} altitude Returns a double representing the
 * position's altitude in meters, relative to nominal sea level. This value
 * can be null if the implementation cannot provide the data.
 * @property {number} accuracy Returns a double representing the accuracy of
 * the latitude and longitude properties, expressed in meters.
 * @property {number | null} altitudeAccuracy Returns a double representing
 * the accuracy of the altitude expressed in meters. This value can be null
 * if the implementation cannot provide the data.
 * @property {number | null} heading Returns a double representing the
 * direction towards which the device is facing. This value, specified in
 * degrees, indicates how far off from heading true north the device is. 0
 * degrees represents true north, and the direction is determined clockwise
 * (which means that east is 90 degrees and west is 270 degrees). If speed is
 * 0 or the device is unable to provide heading information, heading is null.
 * @property {number | null} speed Returns a double representing the velocity
 * of the device in meters per second. This value can be null.
 */

/**
 * The SerialPort interface of the Web Serial API provides access to a serial
 * port on the host device.
 * NOTE: Defined to support proper typing in the JSDocs when type checking in a
 *       TypeScript environment.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/SerialPort
 * @typedef {object} SerialPort
 * @property {boolean} connected Returns a boolean value that indicates
 * whether the port is logically connected to the device.
 * @property {ReadableStream} readable Returns a ReadableStream for receiving
 * data from the device connected to the port.
 * @property {WritableStream} writable Returns a WritableStream for sending
 * data to the device connected to the port.
 * @property {function} forget Returns a Promise that resolves when access
 * to the serial port is revoked. Calling this "forgets" the device, resetting
 * any previously-set permissions so the calling site can no longer
 * communicate with the port.
 * @property {function} getInfo Returns an object containing identifying
 * information for the device available via the port.
 * @property {function} open Returns a Promise that resolves when the port
 * is opened. By default the port is opened with 8 data bits, 1 stop bit and
 * no parity checking.
 * @property {function} setSignals Sets control signals on the port and
 * returns a Promise that resolves when they are set.
 * @property {function} getSignals Returns a Promise that resolves with an
 * object containing the current state of the port's control signals.
 * @property {function} close Returns a Promise that resolves when the port
 * closes.
 */

/**
 * Provides the support to the [CSerialPort::get_message] and
 * [CSerialPort::post_message] calls to interact with the connect serial
 * port hardware.
 * @enum {object} SERIAL_PORT_DATA_REQUEST
 * @property {string} Break Line control status of the
 * [CSerialPortProtocol].
 * @property {string} CarrierDetect Line control status of the
 * [CSerialPortProtocol].
 * @property {string} ClearToSend Line control status of the
 * [CSerialPortProtocol].
 * @property {string} DataSetReady Line control status of the
 * [CSerialPortProtocol].
 * @property {string} DataTerminalReady Line control status of the
 * [CSerialPortProtocol].
 * @property {string} RequestToSend Line control status of the
 * [CSerialPortProtocol].
 * @property {string} RingIndicator Line control status of the
 * [CSerialPortProtocol].
 * @property {string} DataBytes Read / Write from the [CSerialPortProtocol].
 */
export const SERIAL_PORT_DATA_REQUEST = Object.freeze({
  Break: "Break",
  CarrierDetect: "CarrierDetect",
  ClearToSend: "ClearToSend",
  DataSetReady: "DataSetReady",
  DataTerminalReady: "DataTerminalReady",
  RequestToSend: "RequestToSend",
  RingIndicator: "RingIndicator",
  DataBytes: "DataBytes",
});

/**
 * Determines if the JavaScript runtime support connecting to external devices
 * via bluetooth protocol.
 * @returns {boolean} Indication of runtime support.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function hw_bluetooth_supported() {
  return "navigator" in globalThis && "bluetooth" in globalThis.navigator;
}

/**
 * Determines if the JavaScript runtime support connecting to Musical
 * Instrument Digital Interface (MIDI) Devices.
 * @returns {boolean} Indication of runtime support.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function hw_midi_supported() {
  return "navigator" in globalThis
    && "requestMIDIAccess" in globalThis.navigator;
}

/**
 * Determines if the JavaScript runtime will support the ability to retrieve
 * device orientation.
 * @returns {boolean} Indication of runtime support.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function hw_orientation_supported() {
  return "navigator" in globalThis && "geolocation" in globalThis.navigator;
}

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function hw_request_bluetooth() {
  // TODO: Develop actual protocol against CProtocolHandler
  throw API_NOT_IMPLEMENTED;
}

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function hw_request_midi() {
  // TODO: Develop actual protocol against CProtocolHandler
  throw API_NOT_IMPLEMENTED;
}

/**
 * Requests a device orientation protocol to retrieve the devices current
 * geodetic orientation in 3D space.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Geolocation/getCurrentPosition#options
 * @param {object} [options] The options for tuning the protocol to
 * watch for geolocation position updates.
 * @return {COrientationProtocol} The protocol that handles device
 * orientation changes until terminated.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function hw_request_orientation(options) {
  if (!hw_orientation_supported()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  return new COrientationProtocol(options)
}

/**
 * Provides the mechanism to request permission to connect to an attached
 * serial port device.
 * @returns {Promise<CSerialPortProtocol?>} The requested connected serial
 * port or null if request was canceled or could not be connected.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // Determine if serial port processing is supported.
 * const supported = hw_serial_ports_supported();
 * if (supported) {
 *    const port = await hw_request_serial_port();
 *    if (port) {
 *      // Do something with port
 *    }
 * }
 */
export async function hw_request_serial_port() {
  if (!hw_serial_port_supported()) {
    throw API_UNSUPPORTED_RUNTIME;
  }

  try {
    // @ts-ignore This is available in some web browsers
    const port = await globalThis.navigator.serial.requestPort();
    return new CSerialPortProtocol(port);
  } catch (err) {
    return null;
  }
}

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function hw_request_usb() {
  // TODO: Develop actual protocol against CProtocolHandler
  throw API_NOT_IMPLEMENTED;
}

/**
 * Determines if the JavaScript runtime will provide the ability to connect
 * with serial ports.
 * @returns {boolean} true if available, false otherwise.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // Determine if serial port processing is supported.
 * const supported = hw_serial_ports_supported();
 * if (supported) {
 *    const port = await hw_request_serial_port();
 *    if (port) {
 *      // Do something with port!
 *    }
 * }
 */
export function hw_serial_port_supported() {
  return "navigator" in globalThis && "serial" in globalThis.navigator;
}

/**
 * Determines if the JavaScript runtime supports connecting to a usb device.
 * @returns {boolean} Indication of runtime support.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function hw_usb_supported() {
  return "navigator" in globalThis && "usb" in globalThis.navigator;
}

// ============================================================================
// [JSON UC IMPLEMENTATION] ===================================================
// ============================================================================

/**
 * Decodes a string of data which has been encoded using Base64 encoding.
 * @param {string} data Base64 encoded string.
 * @returns {string | null} The decoded string or null if the encoding
 * failed.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function json_atob(data) {
  json_check_type({type: "string", data: data, shouldThrow: true});
  try {
    return globalThis.atob(data);
  } catch (err) {
    return null;
  }
}

/**
 * Creates a Base64-encoded ASCII string from a binary string (i.e., a string
 * in which each character in the string is treated as a byte of binary data).
 * @param {string} data The binary string.
 * @returns {string | null} The base64 encoded string or null if the encoding
 * failed.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function json_btoa(data) {
  json_check_type({type: "string", data: data, shouldThrow: true});
  try {
    return globalThis.btoa(data);
  } catch (err) {
    return null;
  }
}

/**
 * Creates a JavaScript compliant JSON array with ability to copy data from
 * a previous array.
 * @param {any[]} [data] An optional array of data to copy
 * @returns {any[]} The newly created array with optional data.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function json_create_array(data) {
  if (json_check_type({type: Array, data: data})) {
    let stringified = json_stringify(data);
    if (stringified) {
      return json_parse(stringified) ?? [];
    }
  }
  return [];
}

/**
 * Creates a JavaScript compliant JSON object with ability to copy data from
 * a previous array.
 * @param {object} [data] An optional object of data to copy
 * @returns {object} The newly created object with optional data.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function json_create_object(data) {
  if (json_check_type({type: "object", data})) {
    return Object.assign({}, data);
  }
  return {};
}

/**
 * Utility to check parameters of a function to ensure they are of an
 * expected type.
 * @param {object} params
 * @param {string | any} params.type
 * @param {any} params.data The parameter to be checked.
 * @param {number} [params.count] Checks the v parameter function signature
 * to ensure the appropriate number of parameters are specified.
 * @param {boolean} [params.shouldThrow=false] Whether to throw instead of
 * returning a value upon failure.
 * @returns {boolean} true if it meets the expectations, false otherwise.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function json_check_type({
  type,
  data,
  count = undefined,
  shouldThrow = false
}) {
  try {
    const isExpectedType = typeof type !== "string"
      ? (data instanceof type)
      : typeof data === type;
    let valid = typeof count === "number"
      ? isExpectedType && data.length === count
      : isExpectedType;
    if (shouldThrow && !valid) {
      throw API_TYPE_VIOLATION;
    }
    return valid;
  } catch (err) {
    throw API_MISUSE;
  }
}

/**
 * Determines if the specified object has the specified property.
 * @param {object} params
 * @param {object} params.data The object to check.
 * @param {string} params.key The property to find.
 * @param {boolean} [params.shouldThrow=false] Whether to throw instead of
 * returning a value upon failure.
 * @returns {boolean} true if property was found, false otherwise.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function json_has_key({data, key, shouldThrow = false}) {
  json_check_type({type: "object", data: data, shouldThrow: true});
  json_check_type({type: "string", data: key, shouldThrow: true});
  var hasKey = Object.hasOwn(data, key);
  if (shouldThrow && !hasKey) {
    throw API_TYPE_VIOLATION;
  }
  return hasKey;
}

/**
 * Converts a string to a supported JSON data type.
 * @param {string} data The data to parse.
 * @returns {any | null} The JSON data type or null if the parsing fails.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function json_parse(data) {
  try {
    return JSON.parse(data);
  } catch (ex) {
    return null;
  }
}

/**
 * Converts a JSON supported data type into a string.
 * @param {any} data The data to convert.
 * @returns {string | null} The string representation or null if the
 * stringify failed.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function json_stringify(data) {
  try {
    return JSON.stringify(data);
  } catch (ex) {
    return null;
  }
}

/**
 * Checks for a valid URL.
 * @param {object} params
 * @param {string} params.data String to parse to see if it is a valid URL.
 * @param {boolean} [params.shouldThrow=false] Whether to throw instead of
 * returning a value upon failure.
 * @returns {boolean} true if valid, false otherwise.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function json_valid_url({data, shouldThrow = false}) {
  json_check_type({type: "string", data: data, shouldThrow: true});
  let url = undefined;
  try {
    url = new URL(data);
  } catch (_err) {
    url = undefined;
  }
  let valid = json_check_type({type: URL, data: url});
  if (shouldThrow && !valid) {
    throw API_TYPE_VIOLATION;
  }
  return valid;
}

// ============================================================================
// [LOGGER UC IMPLEMENTATION] =================================================
// ============================================================================

/**
 * A log handler for further processing of a logged event.
 * @callback CLogHandler
 * @param {CLogRecord} record The record logged.
 * @returns {void}
 */

/**
 * Holds the logger configuration information for log level and labels.
 * @enum {object}
 * @property {object} debug   level (0) / label "DEBUG"
 * @property {object} info    level (1) / label "INFO"
 * @property {object} warning level (2) / label "WARNING"
 * @property {object} error   level (3) / label "ERROR"
 * @property {object} off     level (4) / label "OFF"
 */
export const LOGGER = Object.freeze({
  debug:   { level: 0, label: "DEBUG"   },
  info:    { level: 1, label: "INFO"    },
  warning: { level: 2, label: "WARNING" },
  error:   { level: 3, label: "ERROR"   },
  off:     { level: 4, label: "OFF"     },
});

/**
 * The log record processed via the [CLogHandler] post logging event.
 */
export class CLogRecord {
  /** @type {Date} */
  #time = new Date();
  /** @type {LOGGER} */
  #level;
  /** @type {any} */
  #data = undefined;

  /**
   * The time the logged event was created.
   * @readonly
   * @type {Date}
   */
  get time() { return this.#time; }

  /**
   * The [CLogLevel] representation of the log level.
   * @readonly
   * @type {LOGGER}
   */
  get level() { return this.#level; }

  /**
   * The data associated with the log event.
   * @readonly
   * @type {any}
   */
  get data() { return this.#data; }

  /**
   * Constructor for the class.
   * @param {LOGGER} level object information.
   * @param {any} data The data to log.
   */
  constructor(level, data) {
    this.#level = level;
    this.#data = data;
  }
}

/**
 * Holds the logger level object for module logging.
 * @private
 * @type {object} One of the {@link LOGGER} settings.
 */
let _loggerLevel = LOGGER.error;

/**
 * Holds the logger handler for post logging events.
 * @private
 * @type {CLogHandler?}
 */
let _loggerHandler = null;

/**
 * Sets the logger handler for post logging processing.
 * @param {CLogHandler | null} handler The handler to utilize.
 * @returns {void}
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function logger_handler(handler) {
  if (json_check_type({type: "function", data: handler, count: 1})) {
    _loggerHandler = handler;
  } else if (handler === null) {
    _loggerHandler = handler;
  } else {
    throw API_TYPE_VIOLATION;
  }
}

/**
 * Sets / retrieves the current module log level.
 * @param {object | undefined} [level] The optional log level to set based on
 * the [CLogLevel] object configuration.
 * @returns {string} The string representation of the log level.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function logger_level(level) {
  if (level) {
    json_check_type({type: "object", data: level, shouldThrow: true});
    json_has_key({data: level, key: "level", shouldThrow: true});
    json_has_key({data: level, key: "label", shouldThrow: true});
    _loggerLevel = level;
  }
  // @ts-ignore Property exists on the struct.
  return _loggerLevel.label;
}

/**
 * Logs an event with the module logger.
 * @param {object} params The named parameters.
 * @param {LOGGER} params.level The log level for the logged event.
 * @param {any} params.data The data to log with the event.
 * @returns {void}
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function logger_log({level, data}) {
  json_check_type({type: "object", data: level, shouldThrow: true});
  if (!data) {
    throw API_TYPE_VIOLATION;
  }
  // Check to see if our logging is on or off.
  // @ts-ignore Property exists on the struct.
  if (_loggerLevel.label == "OFF") {
    return;
  }

  // It's on, go create the log record and go log some stuff.
  const record = new CLogRecord(level, data);
  // @ts-ignore Property exists on the struct.
  if (record.level.level >= _loggerLevel.level) {
    // @ts-ignore Property exists on the struct.
    switch (record.level.label) {
      case "DEBUG":
      case "INFO":
        console.info(
          record.time.toISOString(),
          // @ts-ignore Property exists on the struct.
          record.level.label,
          record.data
        );
      case "WARNING":
        console.warn(
          record.time.toISOString(),
          // @ts-ignore Property exists on the struct.
          record.level.label,
          record.data
        );
        break;
      case "ERROR":
        console.error(
          record.time.toISOString(),
          // @ts-ignore Property exists on the struct.
          record.level.label,
          record.data
        );
        break;
    }

    if (_loggerHandler) {
      _loggerHandler(record);
    }
  }
}

// ============================================================================
// [MONITOR UC IMPLEMENTATION] ================================================
// ============================================================================

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function monitor_performance() {
  // TODO: Deno performance monitor for sure.
  //       Will need to check if NodeJS exposes anything
  //       Also need to see if any other monitors make sense. See Rust.
  throw API_NOT_IMPLEMENTED;
}

// ============================================================================
// [NETWORK UC IMPLEMENTATION] ================================================
// ============================================================================

/**
 * The BroadcastChannel interface represents a named channel that any browsing
 * context of a given origin can subscribe to. It allows communication between
 * different documents (in different windows, tabs, frames or iframes) of the
 * same origin.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Broadcast_Channel_API
 * @extends {CProtocolHandler}
 */
export class CBroadcastChannelProtocol extends CProtocolHandler {
  /** @type {BroadcastChannel} */
  #channel

  /** @type {MessageEvent[]} */
  #rxData = [];

  /** @type {MessageEvent[]} */
  #rxError = [];

  /**
   * Gets the latest data received from the protocol.
   * @override
   * @param {string} [request=""] NOT USED.
   * @returns {Promise<CResult>} The result containing the given information.
   * Errors are processed first if they have been received.
   */
  async get_message(request="") {
    if (!this.is_running) {
      throw API_MISUSE;
    }
    return new Promise((resolve) => {
      setTimeout(() => {
        if (this.#rxError.length > 0) {
          resolve(new CResult({error: this.#rxError.shift()}));
        } else {
          if (this.#rxData.length > 0) {
            resolve(new CResult({value: this.#rxData.shift()}));
          } else {
            resolve(new CResult());
          }
        }
      });
    });
  }

  /**
   * @override
   * @inheritdoc
   */
  get is_running() {
    return this.#channel.onmessage !=null
      && this.#channel.onmessageerror != null;
  }

  /**
   * Sends a message, which can be of any kind of Object, to each listener
   * in any browsing context with the same origin. The message is transmitted
   * as a message event targeted at each BroadcastChannel bound to the
   * channel.
   * @override
   * @param {any} data Data to be sent to the other window. The data is
   * serialized using the structured clone algorithm. This means you can
   * pass a broad variety of data objects safely to the destination window
   * without having to serialize them yourself.
   * @returns {Promise<CResult>} The result of the transmission.
   */
  async post_message(data) {
    if (!this.is_running) {
      throw API_MISUSE;
    }
    try {
      this.#channel.postMessage(data);
      return new CResult();
    } catch (err) {
      return new CResult({error: err});
    }
  }

  /**
   * @override
   * @inheritdoc
   */
  terminate() {
    if (!this.is_running) {
      throw API_MISUSE;
    }
    // Close the connection and clear the channel items.
    this.#channel.onmessage = null;
    this.#channel.onmessageerror = null;
    this.#channel.close();
    this.#rxData.length = 0;
    this.#rxError.length = 0;
  }

  /**
   * Constructor for the class.
   * @param {string} url The URL to open a connection to broadcast data to
   * other listeners.
   */
  constructor(url) {
    super(`CBroadcastChannelProtocol-${url}`);
    this.#channel = new globalThis.BroadcastChannel(url);
    this.#channel.onmessage = (evt) => {
      setTimeout(() => {
        this.#rxData.push(evt);
      });
    };
    this.#channel.onmessageerror = (evt) => {
      setTimeout(() => {
        this.#rxError.push(evt);
      });
    };
  }
}

/**
 * Opens a persistent connection to an HTTP server, which sends events in
 * text/event-stream format. The connection remains open until terminate is
 * called.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/EventSource
 * @extends {CProtocolHandler}
 */
export class CEventSourceProtocol extends CProtocolHandler {
  /**
   * Supports the [CEventSourceProtocol.state] function.
   * @constant {number}
   */
  static get CONNECTING() { return  0; }

  /**
   * Supports the [CEventSourceProtocol.state] function.
   * @constant {number}
   */
  static get OPEN() { return  1; }

  /**
   * Supports the [CEventSourceProtocol.state] function.
   * @constant {number}
   */
  static get CLOSED() { return  2; }

  /** @type {EventSource} */
  #sse

  /** @type {MessageEvent[]} */
  #rxData = [];

  /** @type {Event[]} */
  #rxError = [];

  /**
   * Retrieves the current state of the [CEventSourceProtocol]. -1 returns
   * if protocol has been terminated.
   * @readonly
   * @type {number}
   */
  get state() {
    return this.is_running ?
      this.#sse.readyState
      : -1;
  }

  /**
   * Gets the latest data received from the protocol.
   * @override
   * @param {string} [request=""] NOT USED.
   * @returns {Promise<CResult>} The result containing the given information.
   * Errors are processed first if they have been received.
   */
  async get_message(request="") {
    if (!this.is_running) {
      throw API_MISUSE;
    }
    return new Promise((resolve) => {
      setTimeout(() => {
        if (this.#rxError.length > 0) {
          resolve(new CResult({error: this.#rxError.shift()}));
        } else {
          if (this.#rxData.length > 0) {
            resolve(new CResult({value: this.#rxData.shift()}));
          } else {
            resolve(new CResult());
          }
        }
      });
    });
  }

  /**
   * @override
   * @inheritdoc
   */
  get is_running() {
    return this.#sse.onmessage !=null
      && this.#sse.onerror != null;
  }

  /**
   * NOT USED. DON'T CALL.
   * @override
   * @param {any} data
   * @returns {Promise<CResult>}
   */
  async post_message(data) { throw API_NOT_IMPLEMENTED; }

  /**
   * @override
   * @inheritdoc
   */
  terminate() {
    if (!this.is_running) {
      throw API_MISUSE;
    }
    // Close the connection and clear the channel items.
    this.#sse.close();
    this.#sse.onerror = null;
    this.#sse.onmessage = null;
    this.#rxData.length = 0;
    this.#rxError.length = 0;
  }

  /**
   * Constructor for the protocol
   * @param {string} url The URL to connect to receive events.
   */
  constructor(url) {
    super(`CEventSourceProtocol-${url}`);
    this.#sse = new globalThis.EventSource(url);
    this.#sse.onerror = (evt) => {
      setTimeout(() => {
        this.#rxError.push(evt);
      });
    }
    this.#sse.onmessage = (evt) => {
      setTimeout(() => {
        this.#rxData.push(evt);
      });
    }
  }
}

/**
 * The result object from a [network_fetch] call containing any data from the
 * call along with the HTTP Status Code of the transaction.
 */
export class CFetchResult extends CResult {
  /** @type {number} */
  #status = -1;

  /**
   * Will get the data if it is a Uint8Array or null if not that object type.
   * @readonly
   * @type {Uint8Array?}
   */
  get asBinary() {
    return json_check_type({type: Uint8Array, data: this.value})
      ? this.value
      : null;
  }

  /**
   * Will get the data if it is a Blob or null if not that object type.
   * @readonly
   * @type {Blob?}
   */
  get asBlob() {
    return json_check_type({type: Blob, data: this.value})
      ? this.value
      : null;
  }

  /**
   * Will get the value if it is a FormData or null if not that object
   * type.
   * @readonly
   * @type {FormData?}
   */
  get asFormData() {
    return json_check_type({type: FormData, data: this.value})
      ? this.value
      : null;
  }

  /**
   * Will get the value if it is a Object or null if not that object
   * type.
   * @readonly
   * @type {object?}
   */
  get asObject() {
    return json_check_type({type: "object", data: this.value})
      ? this.value
      : null;
  }

  /**
   * Will get the value if it is a string or null if not that object
   * type.
   * @readonly
   * @type {string?}
   */
  get asString() {
    return json_check_type({type: "string", data: this.value})
      ? this.value
      : null;
  }

  /**
   * Provides additional check of status code along with super property.
   * @override
   */
  get is_error() {
    return super.is_error || this.status < 200 || this.status > 299;
  }

  /**
   * The HTTP Status Code
   * @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status
   * @readonly
   * @type {number}
   */
  get status() { return this.#status; }

  /**
   * Constructor for the class.
   * @param {object} params
   * @param {number} params.status
   * @param {any} [params.data]
   * @param {any} [params.error]
   */
  constructor({status, data, error=null}) {
    super({value: data, error: error});
    this.#status = status;
  }
}

/**
 * Provides the ability to connect to different server protocols.
 * @enum {object}
 * @property {string} BroadcastChannel The Broadcast Channel API allows basic
 * communication between browsing contexts (that is, windows, tabs, frames,
 * or iframes) and workers on the same origin.
 * @property {string} EventSource An EventSource instance opens a persistent
 * connection to an HTTP server, which sends events in text/event-stream
 * format.
 * @property {string} WebSocket  provides the API for creating and managing a
 * WebSocket connection to a server, as well as for sending and receiving
 * data on the connection.
 */
export const CONNECT_REQUEST = Object.freeze({
  BroadcastChannel: "broadcast_channel",
  EventSource: "event_source",
  WebSocket: "web_socket",
});

/**
 * Handles REST API requests from the [network_serve] function call.
 * @callback CNetworkServeCB
 * @param {Request} req The request being received.
 * @returns {Response} The response to the request.
 */

/**
 * Wrapper for the [Deno.HttpServer] object providing the return to the
 * [network_serve] call.
 * @see https://docs.deno.com/api/deno/~/Deno.HttpServer
 */
export class CHttpServer {
  /** @type {any} */
  #server;

  /**
   * The binding information of the server.
   * @readonly
   * @type {object}
   */
  get addr() {
    // @ts-ignore Will have an addr property.
    return this.#server.addr;
  }

  /**
   * Make the server block the event loop from finishing. Note: the server
   * blocks the event loop from finishing by default. This method is only
   * meaningful after .unblock() is called.
   */
  block() {
    // @ts-ignore Will have a ref() method.
    this.#server.ref();
  }

  /**
   * Make the server not block the event loop from finishing.
   */
  unblock() {
    // @ts-ignore Will have an unref() method.
    this.#server.unref();
  }

  /**
   * Gracefully close the server. No more new connections will be accepted,
   * while pending requests will be allowed to finish.
   * @returns {Promise<CResult>}
   */
  async shutdown() {
    try {
      // @ts-ignore Will have a shutdown() method.
      await this.#server.shutdown();
      return new CResult();
    } catch (err) {
      return new CResult({error: err});
    }
  }

  /**
   * Constructor for the object.
   * @param {any} server The Deno.HttpServer created and wrapped.
   */
  constructor(server) {
    this.#server = server;
  }
}

/**
 * Provides the API for creating and managing a WebSocket connection to a
 * server, as well as for sending and receiving data on the connection.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/WebSocket
 * @extends {CProtocolHandler}
 */
export class CWebSocketProtocol extends CProtocolHandler {
  /**
   * Supports the [CWebSocketProtocol.state] function.
   * @constant {number}
   */
  static get CONNECTING() { return  0; }

  /**
   * Supports the [CWebSocketProtocol.state] function.
   * @constant {number}
   */
  static get OPEN() { return  1; }

  /**
   * Supports the [CWebSocketProtocol.state] function.
   * @constant {number}
   */
  static get CLOSING() { return  2; }

  /**
   * Supports the [CWebSocketProtocol.state] function.
   * @constant {number}
   */
  static get CLOSED() { return  3; }

  /** @type {boolean} */
  #isServer;

  /** @type {string | null} */
  #url = null;

  /** @type {any} */
  #socket

  /** @type {MessageEvent[]} */
  #rxData = [];

  /** @type {Event[]} */
  #rxError = [];

  /**
   * Identifies if this protocol represents a server or client Web Socket.
   * Clients will automatically reconnect on fail [post_message] calls.
   * Servers will not requiring a [terminate] call.
   * @readonly
   * @type {boolean}
   */
  get isServer() { return this.#isServer; }

  /**
   * Retrieves the current state of the [CWebSocketProtocol]. -1 returns
   * if protocol has been terminated.
   * @readonly
   * @type {number}
   */
  get state() {
    return this.is_running ?
      this.#socket.readyState
      : -1;
  }

  /**
   * Gets the latest data received from the protocol.
   * @override
   * @param {string} [request=""] NOT USED.
   * @returns {Promise<CResult>} The result containing the given information.
   * Errors are processed first if they have been received.
   */
  async get_message(request="") {
    if (!this.is_running) {
      throw API_MISUSE;
    }
    return new Promise((resolve) => {
      setTimeout(() => {
        if (this.#rxError.length > 0) {
          resolve(new CResult({error: this.#rxError.shift()}));
        } else {
          if (this.#rxData.length > 0) {
            resolve(new CResult({value: this.#rxData.shift()}));
          } else {
            resolve(new CResult());
          }
        }
      });
    });
  }

  /**
   * @override
   * @inheritdoc
   */
  get is_running() {
    return this.#socket.onmessage !=null
      && this.#socket.onerror != null;
  }

  /**
   * Enqueues the specified data to be transmitted to the server over the
   * WebSocket connection, increasing the value of bufferedAmount by the
   * number of bytes needed to contain the data. If the data can't be sent
   * (for example, because it needs to be buffered but the buffer is full),
   * the socket is closed automatically.
   * @see https://developer.mozilla.org/en-US/docs/Web/API/WebSocket/send#data
   * @override
   * @param {string | ArrayBuffer | Blob } data Data to send to the server for
   * further processing.
   * @returns {Promise<CResult>} The result of the transmission. A failure
   * will result in a disconnect and reconnect of the underlying protocol
   * socket.
   */
  async post_message(data) {
    if (!this.is_running) {
      throw API_MISUSE;
    }
    try {
      this.#socket.send(data);
      return new CResult();
    } catch (err) {
      // We had an issue with the connection, go re-establish the socket if
      // we are a client.
      if (!this.#isServer) {
        this.#closeSocket();
        this.#connectSocket();
      }
      return new CResult({error: err});
    }
  }

  /**
   * @override
   * @inheritdoc
   */
  terminate() {
    if (!this.is_running) {
      throw API_MISUSE;
    }
    this.#closeSocket();
  }

  /**
   * Constructs the given protocol connecting it to the server at url.
   * @param {object} params The named parameters
   * @param {string} [params.url] The url to connect to a server.
   * @param {any} [params.socket] A socket as a result of the
   * [network_upgrade_websocket] call.
   */
  constructor({url, socket}) {
    super(`CWebSocketProtocol-${url ?? 'server'}`);
    if (url) {
      this.#isServer = false;
      this.#url = url;
      this.#connectSocket();
    } else {
      this.#isServer = true;
      this.#socket = socket;
      this.#socket.onmessage = (/** @type {MessageEvent<any>} */ evt) => {
        setTimeout(() => {
          this.#rxData.push(evt);
        });
      }
      this.#socket.onerror = (/** @type {Event} */ evt) => {
        setTimeout(() => {
          this.#rxError.push(evt);
        });
      }
    }
  }

  /**
   * Handles creating a web socket to connect to a server.
   */
  #connectSocket() {
    // @ts-ignore URL will not be null.
    this.#socket = new globalThis.WebSocket(this.#url);
    this.#socket.onmessage = (/** @type {MessageEvent<any>} */ evt) => {
      setTimeout(() => {
        this.#rxData.push(evt);
      });
    }
    this.#socket.onerror = (/** @type {Event} */ evt) => {
      setTimeout(() => {
        this.#rxError.push(evt);
      });
    }
  }

  /**
   * Closes the socket.
   */
  #closeSocket() {
    this.#socket.close();
    this.#socket.onmessage = null;
    this.#socket.onerror = null;
    this.#rxData.length = 0;
    this.#rxError.length = 0;
  }
}

/**
 * Sends an HTTP POST request containing a small amount of data to a web
 * server.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Navigator/sendBeacon
 * @param {object} params The named parameters
 * @param {string} params.url Where to send the beacon.
 * @param {any | null} [params.data] The data to send with the beacon.
 * @returns {boolean} true if queued up by user agent, false otherwise.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function network_beacon({url, data}) {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  // @ts-ignore Will exist in a browser context.
  return globalThis.navigator.sendBeacon(url, data);
}

/**
 * Provides the ability to create client side protocols to send / receive
 * data with other items within the network / Internet.
 * @param {object} params The named parameters.
 * @param {string} params.request The {@link CONNECT_REQUEST} protocol to
 * connect.
 * @param {string} params.url The server hosting the protocol to connect.
 * @returns {CBroadcastChannelProtocol | CEventSourceProtocol
 *  | CWebSocketProtocol } The protocol to communicate with the connected
 * server.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function network_connect({request, url}) {
  switch (request) {
    case CONNECT_REQUEST.BroadcastChannel:
      return new CBroadcastChannelProtocol(url);
    case CONNECT_REQUEST.EventSource:
      return new CEventSourceProtocol(url);
    case CONNECT_REQUEST.WebSocket:
      return new CWebSocketProtocol({url: url});
    default:
      throw API_MISUSE;
  }
}

/**
 * Provides the ability to make requests from a hosted server REST API.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/RequestInit
 * @param {object} params The named parameters
 * @param {string} params.url The URL to the server REST API to communicate.
 * @param {object} params.options The data to configure / go along with the
 * request. See the attached URL for detailed
 * @returns {Promise<CFetchResult>} The result of the request.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export async function network_fetch({url, options}) {
  try {
    const resp = await globalThis.fetch(url, options);
      const contentType = resp.headers.get("Content-Type") ?? "";
      const status = resp.status;
      const data = contentType.includes("application/json")
          ? await resp.json()
          : contentType.includes("form-data")
          ? await resp.formData()
          : contentType.includes("application/octet-stream")
          ? await resp.blob()
          : contentType.includes("text/")
          ? await resp.text()
          : "";
      return new CFetchResult({status: status, data: data});
  } catch (err) {
    return new CFetchResult({status: 418, error: err});
  }
}

/**
 * Creates a HTTP Server REST API endpoint within a Deno Runtime.
 * @see https://docs.deno.com/api/deno/~/Deno.TlsCertifiedKeyPem
 * @param {object} params The named parameters.
 * @param {CNetworkServeCB} params.handler The callback to determine what to
 * do with the request and communicate a response.
 * @param {string} [params.hostname="0.0.0.0"] The binding address of the
 * REST API.
 * @param {number} [params.port=8000] The binding port of the REST API.
 * @param {string} [params.key] Private key in PEM format. RSA, EC, and PKCS8-format keys
 * are supported.
 * @param {string} [params.cert] Certificate chain in PEM format.
 * @returns {CHttpServer} The constructed server.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function network_serve({
  handler,
  hostname="0.0.0.0",
  port=8000,
  key,
  cert,
}) {
  if (!runtime_is_deno()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  json_check_type({
    type: "function",
    data: handler,
    count: 1,
    shouldThrow: true
  });
  json_check_type({type: "string", data: hostname, shouldThrow: true});
  json_check_type({type: "number", data: port, shouldThrow: true});
  let serveOptions = {
    hostname: hostname,
    port: port,
    handler: handler,
  };
  if (key && cert) {
    // @ts-ignore It is just an object.
    serveOptions["key"] = key;
    // @ts-ignore It is just an object.
    serveOptions["cert"] = cert;
  }
  // @ts-ignore serve will be attached to globalThis.
  const server = globalThis.serve(serveOptions);
  return new CHttpServer(server);
}

/**
 * Upgrade an incoming HTTP request to a WebSocket.
 * @param {Request} req The initial request asking to upgrade to a
 * @returns {CResult} The result of the upgrade with a CWebSocketProtocol or
 * the error if the upgrade failed.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function network_upgrade_web_socket(req) {
  try {
    const { socket, /** @type {Response} */ response } =
      // @ts-ignore upgradeWebSocket will be available.
      globalThis.upgradeWebSocket(req);
    if (response.ok) {
      return new CResult({value: new CWebSocketProtocol({socket: socket})});
    } else {
      return new CResult({
        error: `Failed to upgrade to a web socket ${response.status}`
      });
    }
  } catch (err) {
    return new CResult({error: err});
  }
}

/**
 * <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function network_webrtc() {
  // TODO: Will only be available in the browser.
  throw API_NOT_IMPLEMENTED;
}

// ============================================================================
// [NPU UC IMPLEMENTATION] ====================================================
// ============================================================================

/**
 * Enumeration defining the mathematical formulas for the [npu_math] function.
 * @enum {object}
 * @property {function} GeodeticDistance
 * Distance in meters between two WGS84 points.
 * @property {function} GeodeticHeading
 * Heading in °N true North 0 - 359.
 * @property {function} GeodeticSpeed
 * Speed in meters per second between two WGS84 points.
 * @property {function} TemperatureCelsiusToFahrenheit
 * °F = (°C x 9/5) + 32
 * @property {function} TemperatureCelsiusToKelvin
 * °K = °C + 273.15
 * @property {function} TemperatureFahrenheitToCelsius
 * °C = (°F − 32) × 5/9
 * @property {function} TemperatureFahrenheitToKelvin
 * °K = (°F − 32) × 5/9 + 273.15
 * @property {function} TemperatureKelvinToCelsius
 * °C = °K − 273.15
 * @property {function} TemperatureKelvinToFahrenheit
 * °F = (°K − 273.15) × 9/5 + 32
 */
export const MATH_FORMULA = Object.freeze({
  GeodeticDistance: (/**@type {number[]} */ args) => {
    const startLatitude = args[0];
    const startLongitude = args[1];
    const endLatitude = args[2];
    const endLongitude = args[3];

    // Convert degrees to radians
    const lat1 = startLatitude * (Math.PI / 180.0);
    const lon1 = startLongitude * (Math.PI / 180.0);
    const lat2 = endLatitude * (Math.PI / 180.0);
    const lon2 = endLongitude * (Math.PI / 180.0);

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
    const cos_theta = dot / (r * r);
    const theta = Math.acos(cos_theta);

    // Distance in meters
    return r * theta;
  },
  GeodeticHeading: (/**@type {number[]} */ args) => {
    const startLatitude = args[0];
    const endLatitude = args[1];
    const startLongitude = args[2];
    const endLongitude = args[3];

    // Convert degrees to radians
    const lat1 = startLatitude * (Math.PI / 180.0);
    const lon1 = startLongitude * (Math.PI / 180.0);
    const lat2 = endLatitude * (Math.PI / 180.0);
    const lon2 = endLongitude * (Math.PI / 180.0);

    // Set up our calculations
    const y = Math.sin(lon2 - lon1) * Math.cos(lat2);
    const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) *
        Math.cos(lat2) * Math.cos(lon2 - lon1);
    const rtnval = Math.atan2(y, x) * (180 / Math.PI);
    return (rtnval + 360) % 360;
  },
  GeodeticSpeed: (/**@type {number[]} */ args) => {
    const startTimeMilliseconds = args[0];
    const startLatitude = args[1];
    const startLongitude = args[2];
    const endTimeMilliseconds = args[3];
    const endLatitude = args[4];
    const endLongitude = args[5];
    const distMeters = MATH_FORMULA.GeodeticDistance([
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ]);
    const timeS = (endTimeMilliseconds - startTimeMilliseconds) / 1000.0;
    return distMeters / timeS;
  },
  TemperatureCelsiusToFahrenheit:
    (/** @type {number[]} */ args) => (args[0] * 9.0 / 5.0) + 32.0,
  TemperatureCelsiusToKelvin:
    (/** @type {number[]} */ args) => args[0] + 273.15,
  TemperatureFahrenheitToCelsius:
    (/** @type {number[]} */ args) => (args[0] - 32.0) * (5.0 / 9.0),
  TemperatureFahrenheitToKelvin:
    (/** @type {number[]} */ args) => (args[0] - 32.0) * (5.0 / 9.0) + 273.15,
  TemperatureKelvinToCelsius:
    (/** @type {number[]} */ args) => args[0] - 273.15,
  TemperatureKelvinToFahrenheit:
    (/** @type {number[]} */ args) => (args[0] - 273.15) * (9.0 / 5.0) + 32.0
})

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function npu_compute() {
  throw API_NOT_IMPLEMENTED;
}

/**
 * Executes a specified mathematical formula with the specified parameters
 * returning the calculated results.
 * @param {object} params The named parameters
 * @param {function} params.formula The MATH_FORMULA enumeration to execute.
 * @param {Array<number>} params.args The arguments needed for the formula.
 * @returns {number} The calculated result or NaN if something in the args
 * force that value (i.e. division by 0).
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function npu_math({formula, args}) {
  json_check_type({
    type: "function",
    data: formula,
    count: 1,
    shouldThrow: true
  });
  json_check_type({type: Array, data: args, shouldThrow: true});
  try {
    return formula(args);
  } catch (err) {
    if (err instanceof RangeError) {
      throw API_MISUSE;
    }
    return NaN;
  }
}

// ============================================================================
// [PROCESS UC IMPLEMENTATION] ================================================
// ============================================================================

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function process_exists() {
  if (runtime_is_deno()) {
    throw API_UNSUPPORTED_RUNTIME;
  } else if (runtime_is_nodejs()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function process_run() {
  if (runtime_is_deno()) {
    throw API_UNSUPPORTED_RUNTIME;
  } else if (runtime_is_nodejs()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function process_spawn() {
  if (runtime_is_deno()) {
    throw API_UNSUPPORTED_RUNTIME;
  } else if (runtime_is_nodejs()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

// ============================================================================
// [RUNTIME UC IMPLEMENTATION] ================================================
// ============================================================================

/**
 * Determines the CPU architecture.
 * @returns {string} identifier of the architecture.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // Get the architecture of the deno / node js runtime
 * const arch = runtime_cpu_arch();
 * console.log("arch = ", arch);
 */
export function runtime_cpu_arch() {
  if (runtime_is_deno() || runtime_is_nodejs()) {
    // @ts-ignore Property exists in a browser runtime.
    return globalThis.process.arch;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Determines the available CPU processors for background workers.
 * @returns {number} The available hardware processors.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_cpu_count() {
  if (runtime_is_browser() || runtime_is_deno() || runtime_is_worker()) {
    return globalThis.navigator.hardwareConcurrency;
  }
  // @ts-ignore Property exists in a browser runtime.
  return globalThis.os.cpus().length;
}

/**
 * Searches the host operating system / JavaScript runtime for a variable
 * value.
 * @param {string} name The name of the operating system variable to lookup.
 * @returns {string?} The value associated with the name or null if not found.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_environment(name) {
  if (runtime_is_browser()) {
    let params = new URLSearchParams(globalThis.location.search);
    return params.get(name);
  } else if (runtime_is_deno()) {
    return globalThis.Deno.env.has(name)
      // @ts-ignore Property exists in a browser runtime.
      ? globalThis.Deno.env.get(name)
      : null;
  } else if (runtime_is_nodejs()) {
    // @ts-ignore Property exists in a browser runtime.
    return globalThis.process.env[name] != undefined
      // @ts-ignore Property exists in a browser runtime.
      ? globalThis.process.env[name]
      : null;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

// TODO: EVENT_REQUEST enum

/**
 * Adds or removes an event listener to the JavaScript runtime or individual
 * element.
 * @param {object} params The named parameters.
 * @param {string} params.action Whether to "add" or "remove" the listener.
 * @param {string} params.type The event listener identifier.
 * @param {CEventHandler} params.listener The listener called when the
 * identified event is triggered or being removed.
 * @param {EventSource} [params.obj] An optional element to attach an event
 * handler to if it supports it.
 * @returns {void}
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_event({
  action,
  type,
  listener,
  obj = undefined,
}) {
  json_check_type({type: "string", data: type, shouldThrow: true});
  json_check_type({
    type: "function",
    data: listener,
    count: 1,
    shouldThrow: true
  });
  if (action === "add") {
    if (obj) {
      obj.addEventListener(type, listener);
    } else {
      globalThis.addEventListener(type, listener);
    }
  } else if (action === "remove") {
    if (obj) {
      obj.removeEventListener(type, listener);
    } else {
      globalThis.removeEventListener(type, listener);
    }
  } else {
    throw API_MISUSE;
  }
}

/**
 * Determines the home path of the logged in user.
 * @returns {string?} The identified home path on disk.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // Get the user's home path for deno or nodejs runtime
 * const homePath = runtime_home_path();
 * console.log("homePath = ", homePath);
 */
export function runtime_home_path() {
  if (runtime_is_deno() || runtime_is_nodejs()) {
    return runtime_environment("USERPROFILE") ||
      runtime_environment("USER");
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Determines the hostname of the host operating system.
 * @returns {string} The hostname of the computer.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_hostname() {
  if (runtime_is_browser()) {
    return globalThis.location.hostname;
  } else if (runtime_is_deno()) {
    return globalThis.Deno.hostname();
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Determines if the JavaScript runtime is web browser.
 * @returns {boolean} true if web browser, false otherwise.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_is_browser() {
  return "document" in globalThis;
}

/**
 * Determines if the JavaScript runtime is Deno runtime.
 * @returns {boolean} true if Deno, false otherwise.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_is_deno() {
  return "Deno" in globalThis && "version" in globalThis.Deno;
}

/**
 * Determines if the JavaScript runtime is a NodeJS runtime.
 * @returns {boolean} true if NodeJS, false otherwise.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_is_nodejs() {
  return "process" in globalThis && !runtime_is_deno();
}

/**
 * Determines if the JavaScript runtime is a Worker thread.
 * @returns {boolean} true if worker, false otherwise.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_is_worker() {
  return "WorkerGlobalScope" in globalThis;
}

/**
 * Determines what JavaScript runtime the app is running.
 * @returns {string} Either "deno" / "nodejs" for backend or
 * the name of the actual browser. Or "UNDETERMINED" if it could not
 * be determined.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" checked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_name() {
  if (runtime_is_browser()) {
    const userAgent = globalThis.navigator.userAgent.toLowerCase();
    if (userAgent.includes("firefox/")) {
      return "firefox";
    } else if (userAgent.includes("opr/")
        || userAgent.includes("presto/")) {
      return "opera";
    } else if (userAgent.includes("mobile/")
        || userAgent.includes("version/")) {
      return "safari";
    } else if (userAgent.includes("edg/")) {
      return "edge";
    } else if (userAgent.includes("chrome/")) {
      return "chrome";
    } else {
      return "UNKNOWN BROwSER";
    }
  } else if (runtime_is_deno()) {
    return "deno";
  } else if (runtime_is_nodejs()) {
    return "nodejs";
  } else if (runtime_is_worker()) {
    return "worker";
  }
  return "UNDETERMINED";
}

/**
 * Retrieves the host operating systems newline character.
 * @returns {string} of the newline character for strings.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // Get the newline for the string for deno or nodejs runtime.
 * const newline = runtime_newline();
 * console.log("newline = ", newline);
 */
export function runtime_newline() {
  if (runtime_is_deno() || runtime_is_nodejs()) {
    return runtime_environment("USERPROFILE") != null
      ? "\r\n"
      : "\n"
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Determines if the web app has access to the Internet.
 * @returns {boolean} true if path to Internet available, false otherwise.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_online() {
  if (runtime_is_browser()) {
    // @ts-ignore Property exists in a browser runtime.
    return globalThis.navigator.onLine;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Determines the name of the host operating system.
 * @returns {string} The identification of the OS.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_os_name() {
  if (runtime_is_deno()) {
    return globalThis.Deno.build.os;
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Gets the path separator of directories on disk.
 * @returns {string} representing the separation.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_path_separator() {
  if (runtime_is_deno() || runtime_is_nodejs()) {
    return runtime_environment("USERPROFILE") != null
      ? "\\"
      : "/"
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Gets the temporary directory location of the host operating system.
 * @returns {string} representing the directory on disk.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_temp_path() {
  if (runtime_is_deno() || runtime_is_nodejs()) {
    return runtime_environment("TMPDIR") || runtime_environment("TMP") ||
      runtime_environment("TEMP") || "/tmp";
  }
  throw API_UNSUPPORTED_RUNTIME;
}

/**
 * Identifies the logged in user running the application on the host operating
 * system.
 * @returns {string} user name on disk or "UNDETERMINED".
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" unchecked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" checked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function runtime_user() {
  if (runtime_is_deno() || runtime_is_nodejs()) {
    return runtime_environment("USERNAME") || runtime_environment("USER") ||
      "UNDETERMINED";
  }
  throw API_UNSUPPORTED_RUNTIME;
}

// ============================================================================
// [STORAGE UC IMPLEMENTATION] ================================================
// ============================================================================

/**
 * Static utility class to mirror that of Session / Local storage APIs.
 * @private
 */
class CCookieStorage {
  /** @type {number} */
  static #expireDays = 365;

  /** @type {string[]} */
  static #keyList = [];

  /**
   * Clears the cookie storage entries.
   */
  static clear() {
    // @ts-ignore Will exist in the browser context
    let cookies = globalThis.document.cookie.split(";");
    for (let i = 0; i < cookies.length; i++) {
      // @ts-ignore Will exist in the browser context
      globalThis.document.cookie =
        `${cookies[i]}=;expires=Thu, 01 Jan 1970 00:00:00 UTC`;
    }
    CCookieStorage.initKeyList();
  }

  /**
   * Retrieves an entry from cookie storage.
   * @param {string} key The key to lookup.
   * @returns {string?} The found entry or null if not found.
   */
  static getItem(key) {
    let name = `${key}=`;
    // @ts-ignore Will exist in a browser context.
    let decodedCookie = decodeURIComponent(globalThis.document.cookie);
    let ca = decodedCookie.split(";");
    for (let i = 0; i < ca.length; i++) {
      let c = ca[i];
      while (c.charAt(0) == " ") {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return null;
  }

  /**
   * Retrieves the key name at the specified index.
   * @param {number} index The key to retrieve from the given index
   * @returns {string | null} The key entry or null if index went beyond
   * length.
   */
  static key(index) {
    return index < CCookieStorage.#keyList.length
      ? CCookieStorage.#keyList[index]
      : null;
  }

  /**
   * Retrieves the number of entries in cookie storage.
   * @readonly
   * @type {number}
   */
  static get length() { return CCookieStorage.#keyList.length; }

  /**
   * Sets an item within cookie storage.
   * @param {string} key The key entry in the cooke storage.
   * @param {string} value The value to set with the cookie.
   * @returns {void}
   */
  static setItem(key, value) {
    const d = new Date();
    d.setTime(d.getTime() + (this.#expireDays * 24 * 60 * 60 * 1000));
    let expires = `expires=${d.toUTCString()}`;
    // @ts-ignore Will exist in the browser context
    globalThis.document.cookie = `${key}=${value};${expires};path=/`;
    CCookieStorage.initKeyList();
  }

  /**
   * Removes an item from cookie storage.
   * @param {string} key The key to remove
   * @returns {void}
   */
  static removeItem(key) {
    // @ts-ignore Will exist in the browser context
    globalThis.document.cookie =
      `${key}=;expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/;`;
    CCookieStorage.initKeyList();
  }

  /**
   * Provides the ability to get a list of keys to support the length
   * property and key method of the Storage interface.
   * @private
   * @returns {void}
   */
  static initKeyList() {
    CCookieStorage.#keyList = [];
    // @ts-ignore Will exist in the browser context
    let decodedCookie = decodeURIComponent(globalThis.document.cookie);
    let ca = decodedCookie.split(";");
    for (let i = 0; i < ca.length; i++) {
      let key = ca[i].split("=");
      if (!key[0].includes("expires") && !key[0].includes("path")) {
        CCookieStorage.#keyList.push((key[0]));
      }
    }
  }
}

/**
 * Provides the type of storage to utilize with each of the [storage_xxx] use
 * case functions. They all default to STORAGE_TYPE.Local.
 * @enum {object}
 * @property {string} Cookie
 * @property {string} Local
 * @property {string} Session
 */
export const STORAGE_TYPE = Object.freeze({
  Cookie: "cookie",
  Local: "local",
  Session: "session",
});

/**
 * Clears the local storage of the module.
 * @param {string} [type=STORAGE_TYPE.Local] The STORAGE_TYPE to act upon.
 * @returns {void}
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function storage_clear(type = STORAGE_TYPE.Local) {
  if (runtime_is_nodejs() || runtime_is_worker()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  switch (type) {
    case STORAGE_TYPE.Cookie:
      CCookieStorage.clear();
      break;
    case STORAGE_TYPE.Local:
      globalThis.localStorage.clear();
      break;
    case STORAGE_TYPE.Session:
      globalThis.sessionStorage.clear();
      break;
    default:
      throw API_MISUSE;
  }
}

/**
 * Gets the value associated with the key from the module's local storage.
 * @param {object} params The named parameters.
 * @param {string} [params.type=STORAGE_TYPE.Local] The STORAGE_TYPE to act
 * upon.
 * @param {string} params.key The key to search.
 * @returns {string?} The value associated with the key if found.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function storage_get({type = STORAGE_TYPE.Local, key}) {
  if (runtime_is_nodejs() || runtime_is_worker()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  json_check_type({type: "string", data: key, shouldThrow: true});
  switch (type) {
    case STORAGE_TYPE.Cookie:
      return CCookieStorage.getItem(key);
    case STORAGE_TYPE.Local:
      return globalThis.localStorage.getItem(key);
    case STORAGE_TYPE.Session:
      return globalThis.sessionStorage.getItem(key);
    default:
      throw API_MISUSE;
  }
}

/**
 * Retrieves the key at the specified index.
 * @param {object} params The named parameters
 * @param {string} [params.type=STORAGE_TYPE.Local] The STORAGE_TYPE to act
 * upon.
 * @param {number} params.index The key entry to look up.
 * @returns {string?} The key at the specified index or null if beyond the
 * storage capacity.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function storage_key({type, index}) {
  if (runtime_is_nodejs() || runtime_is_worker()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  json_check_type({type: "number", data: index, shouldThrow: true});
  switch (type) {
    case STORAGE_TYPE.Cookie:
      return CCookieStorage.key(index);
    case STORAGE_TYPE.Local:
      return index < globalThis.localStorage.length
        ? globalThis.localStorage.key(index)
        : null;
    case STORAGE_TYPE.Session:
      return index < globalThis.sessionStorage.length
        ? globalThis.sessionStorage.key(index)
        : null;
    default:
      throw API_MISUSE;
  }
}

/**
 * Retrieves the number of entries within the module's local storage.
 * @param {string} [type=STORAGE_TYPE.Local] The STORAGE_TYPE to act upon.
 * @returns {number} The number of entries.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function storage_length(type = STORAGE_TYPE.Local) {
  if (runtime_is_nodejs() || runtime_is_worker()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  switch (type) {
    case STORAGE_TYPE.Cookie:
      return CCookieStorage.length;
    case STORAGE_TYPE.Local:
      return globalThis.localStorage.length;
    case STORAGE_TYPE.Session:
      return globalThis.sessionStorage.length;
    default:
      throw API_MISUSE;
  }
}

/**
 * Removes a given entry from the module's local storage.
 * @param {object} params The named parameters.
 * @param {string} [params.type=STORAGE_TYPE.Local] The STORAGE_TYPE to act
 * upon.
 * @param {string} params.key The key to remove.
 * @returns {void}
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function storage_remove({type = STORAGE_TYPE.Local, key}) {
  if (runtime_is_nodejs() || runtime_is_worker()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  json_check_type({type: "string", data: key, shouldThrow: true});
  switch (type) {
    case STORAGE_TYPE.Cookie:
      CCookieStorage.removeItem(key);
      break;
    case STORAGE_TYPE.Local:
      globalThis.localStorage.removeItem(key);
      break;
    case STORAGE_TYPE.Session:
      globalThis.sessionStorage.removeItem(key);
      break;
    default:
      throw API_MISUSE;
  }
}

/**
 * Sets a key/value pair within the module's local storage.
 * @param {object} params The named parameters
 * @param {string} [params.type=STORAGE_TYPE.Local] The STORAGE_TYPE to act
 * upon.
 * @param {string} params.value The storage entry.
 * @param {string} params.key The key to store.
 * @returns {void}
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" checked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function storage_set({type = STORAGE_TYPE.Local, key, value}) {
  if (runtime_is_nodejs() || runtime_is_worker()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  json_check_type({type: "string", data: key, shouldThrow: true});
  json_check_type({type: "string", data: value, shouldThrow: true});
  switch (type) {
    case STORAGE_TYPE.Cookie:
      CCookieStorage.setItem(key, value);
      break;
    case STORAGE_TYPE.Local:
      globalThis.localStorage.setItem(key, value);
      break;
    case STORAGE_TYPE.Session:
      globalThis.sessionStorage.setItem(key, value);
      break;
    default:
      throw API_MISUSE;
  }
}

// ============================================================================
// [UI UC IMPLEMENTATION] =====================================================
// ============================================================================

/**
 * Provides the request actions of the [ui_action] function all.
 * @enum {object}
 * @property {string} Focus Makes a request to bring the window to the front.
 * It may fail due to user settings and the window isn't guaranteed to be
 * front most before this method returns.
 * @property {string} MoveBy moves the current window by a specified amount.
 * @property {string} MoveTo moves the current window to the specified
 * coordinates.
 * @property {string} Print Opens the print dialog to print the current
 * document.
 * @property {string} ResizeBy resizes the current window by a specified
 * amount.
 * @property {string} ResizeTo dynamically resizes the window.
 * @property {string} Scroll scrolls the window to a particular place in the
 * document.
 * @property {string} ScrollBy scrolls the document in the window by the
 * given amount.
 * @property {string} ScrollTo scrolls to a particular set of coordinates in
 * the document.
 * @property {string} Share invokes the native sharing mechanism of the
 * device to share data such as text, URLs, or files. The available share
 * targets depend on the device, but might include the clipboard, contacts
 * and email applications, websites, Bluetooth, etc.
 * @property {string} Vibrate Most modern mobile devices include vibration
 * hardware, which lets software code provide physical feedback to the user
 * by causing the device to shake. The Vibration API offers Web apps the
 * ability to access this hardware, if it exists, and does nothing if the
 * device doesn't support it.
 */
export const ACTION_REQUEST = Object.freeze({
  Focus: "focus",
  MoveBy: "moveBy",
  MoveTo: "moveTo",
  Print: "print",
  ResizeBy: "resizeBy",
  ResizeTo: "resizeTo",
  Scroll: "scroll",
  ScrollBy: "scrollBy",
  ScrollTo: "scrollTo",
  Share: "share",
  Vibrate: "vibrate",
});

/**
 * Provides the request for executing audio playback in an HTML document via
 * the [ui_audio] function call.
 * @enum {object}
 * @property {string} File Loads and plays back an audio file hosted on the
 * web.
 * @property {string} TextToSpeech Will take a string of text and read it
 * aloud via speech synthesis.
 */
export const AUDIO_REQUEST = Object.freeze({
  File: "file",
  TextToSpeech: "tts",
});

/**
 * Object created from a call to the [ui_audio] function to allow for audio
 * playback on a document. This object is only valid with the data it is
 * created with. Once playback is completed or stopped, it can only be started
 * (i.e. played) again. To change the audio source requires a call to
 * [ui_audio] to get a new audio player.
 */
export class CAudioPlayer {
  /** @type {HTMLAudioElement | null} */
  #audioPlayer = null;
  /** @type {SpeechSynthesisUtterance | null} */
  #ttsUtterance = null;
  /** @type {string} */
  #state;

  /**
   * Sets an error handler to listen for errors that may occur when
   * utilizing the audio player.
   * @param {CEventHandler} handler The handler to listen for errors
   * with the audio player.
   */
  set onerror(handler) {
    json_check_type({
      type: "function",
      data: handler,
      count: 1,
      shouldThrow: true
    });
    if (this.#audioPlayer) {
      this.#audioPlayer.onerror = handler;
    } else {
      // @ts-ignore This object won't be null
      this.#ttsUtterance.onerror = handler;
    }
  }

  /**
   * Signal fired when the audio player has completed the audio source.
   * @param {CEventHandler} handler Handler that signals the audio player has
   * completed playing the data source.
   */
  set onended(handler) {
    json_check_type({
      type: "function",
      data: handler,
      shouldThrow: true
    });
    if (this.#audioPlayer) {
      this.#audioPlayer.onended = handler;
    } else {
      // @ts-ignore This object won't be null
      this.#ttsUtterance.onend = handler;
    }
  }

  /**
   * Sets / gets the playback rate of the audio player.
   * @type {number}
   */
  get rate() {
    return this.#audioPlayer != null
      ? this.#audioPlayer.playbackRate
      // @ts-ignore This object won't be null
      : this.#ttsUtterance.rate;
  }
  set rate(v) {
    let rate = v > 11
      ? 11
      : v < 0.1
        ? 0.1
        : v;
    if (this.#audioPlayer) {
      this.#audioPlayer.playbackRate = rate;
    } else {
      // @ts-ignore Object won't be null
      this.#ttsUtterance.rate = rate;
    }
  }

  /**
   * Either "stopped" / "paused" / "playing".
   * @readonly
   * @type {string}
   */
  get state() {
    return this.#state;
  }

  /**
   * Sets / gets the volume of the audio player.
   * @type {number}
   */
  get volume() {
    return this.#audioPlayer != null
      ? this.#audioPlayer.volume
      // @ts-ignore This object won't be null
      : this.#ttsUtterance.volume;
  }
  set volume(v) {
    let volume = v < 0
      ? 0
      : v > 1
        ? 1
        : v;
    if (this.#audioPlayer) {
      this.#audioPlayer.volume = volume;
    } else {
      // @ts-ignore This is in a browser context
      this.#ttsUtterance.volume = volume;
    }
  }

  /**
   * Will resume the audio player from a paused state.
   * @returns {Promise<CResult>} Identifying success / failure of
   * transitioning to the new audio state.
   * @throws {API_MISUSE} if you call when in an invalid state.
   */
  async resume() {
    if (this.#state != "paused") {
      throw API_MISUSE;
    }
    try {
      if (this.#audioPlayer) {
        await this.#audioPlayer.play();
      } else {
        // @ts-ignore This is in a browser context
        globalThis.speechSynthesis.resume();
      }
      this.#state = "playing";
      return new CResult();
    } catch (err) {
      return new CResult({error: err});
    }
  }

  /**
   * Will pause the audio player from a playing state.
   * @returns {CResult} Identifying success / failure of
   * transitioning to the new audio state.
   * @throws {API_MISUSE} if you call when in an invalid state.
   */
  pause() {
    if (this.#state != "playing") {
      throw API_MISUSE;
    }
    try {
      if (this.#audioPlayer) {
        this.#audioPlayer.pause();
      } else {
        // @ts-ignore This is in a browser context
        globalThis.speechSynthesis.pause();
      }
      this.#state = "paused";
      return new CResult();
    } catch (err) {
      return new CResult({error: err});
    }
  }

  /**
   * Will play the audio player from a stopped state.
   * @returns {Promise<CResult>} Identifying success / failure of
   * transitioning to the new audio state.
   * @throws {API_MISUSE} if you call when in an invalid state.
   */
  async play() {
    if (this.#state != "stopped") {
      throw API_MISUSE;
    }
    try {
      if (this.#audioPlayer) {
        await this.#audioPlayer.play();
      } else {
        // @ts-ignore This is in a browser context
        globalThis.speechSynthesis.speak(this.#ttsUtterance);
      }
      this.#state = "playing";
      return new CResult();
    } catch (err) {
      return new CResult({error: err});
    }
  }

  /**
   * Will stop the audio player from a paused or playing state.
   * @returns {CResult} Identifying success / failure of
   * transitioning to the new audio state.
   * @throws {API_MISUSE} if you call when in an invalid state.
   */
  stop() {
    if (this.#state === "stopped") {
      throw API_MISUSE;
    }
    try {
      if (this.#audioPlayer) {
        this.#audioPlayer.load();
        this.#audioPlayer.currentTime = 0;
      } else {
        // @ts-ignore This is in a browser context
        globalThis.speechSynthesis.cancel();
      }
      this.#state = "stopped";
      return new CResult();
    } catch (err) {
      return new CResult({error: err});
    }
  }

  /**
   * Constructor for the class.
   * @param {string} request {@link AUDIO_REQUEST} property identifying which audio
   * source to utilize.
   * @param {string} data The data associated with the request.
   */
  constructor(request, data) {
    json_check_type({type: "string", data: data, shouldThrow: true});
    switch (request) {
      case AUDIO_REQUEST.File:
        // @ts-ignore Constructor works fine in browser context.
        this.#audioPlayer = new Audio(data);
        break;
      case AUDIO_REQUEST.TextToSpeech:
        // @ts-ignore Type definition has all the complaints.
        this.#ttsUtterance = new SpeechSynthesisUtterance(data);
        break;
      default:
        throw API_MISUSE;
    }
    this.#state = "stopped";
  }
}

/**
 * Utility class to control the showing / hiding of dialogs on an HTML
 * document via the [ui_dialog] function.
 * @private
 */
class CDialog {
  /** @type {any} */
  static returnValue;

  /**
   * Closes an open dialog and removes it from the body
   * @param {string} id The HTML node id of the dialog opened.
   * @param {any} [returnValue] The optional return values associated
   * with the dialog.
   * @returns {void}
   */
  static close(id, returnValue) {
    // @ts-ignore In browser context, will not be null
    const dlg = globalThis.document.getElementById(id);
    CDialog.returnValue = returnValue;
    // @ts-ignore In browser context, will not be null
    dlg.close();
    // @ts-ignore In browser context, will not be null
    dlg.style.display = "none";
    // @ts-ignore In browser context, will not be null
    globalThis.document.body.removeChild(dlg);
  }

  /**
   * Supports the [ui_dialog] use case function in constructing
   * the HTML template to display embedded modal dialog content.
   * @param {string} icon An icon to put in the title bar.
   * @param {string} id The HTML node id that is unique on the page
   * @param {string} title The title to display in the title bar.
   * @param {string} content The HTML content to display
   * @param {string} [width] The width as px / % to size the dialog to.
   * @param {string} [height] The width as px / % to size the dialog to.
   * @returns {void}
   */
  static show(icon, id, title, content, width, height) {
    const style = `
      <style>
        .codemelted-dialog {
          flex-flow: column;
          border: 5px solid black;
          padding: 0;
        }
        .codemelted-dialog::backdrop {
          background: rgba(0, 0, 0, 0.25);
        }
        .codemelted-dialog-title {
          flex: 0 1 auto;
          font-size: large;
          font-weight: bolder;
          text-align: center;
          vertical-align: middle;
          background-color: black;
          color: white;
          display: grid;
          grid-template-columns: auto 1fr auto;
          border-bottom: 3px solid black;
        }
        .codemelted-dialog-title button {
          cursor: pointer;
        }
        .codemelted-dialog-content {
          background-color: gray;
          color: white;
          border: 0;
          margin: 0;
          padding: 0;
          width: 100%;
          flex: 1 1 auto;
        }
        .codemelted-dialog-content div {
          padding: 10px;
        }
        .codemelted-dialog-content input[type=text] {
          margin-left: 10px;
          margin-right: 10px;
        }
        .codemelted-dialog-content select {
          margin-left: 10px;
          margin-right: 10px;
          margin-bottom: 10px;
          width: 150px;
        }
        .codemelted-dialog-content button {
          cursor: pointer;
          height: 25px;
          width: 75px;
        }
      </style>
    `;
    const html = `
      <div class="codemelted-dialog-type">
        <label>${icon}</label>
        <label>${title}</label>
        <button id="${id}CloseDialog">X</button>
      </div>
      ${content}
    `;
    // @ts-ignore In browser context
    const dialog = globalThis.document.createElement("dialog");
    // @ts-ignore In browser context
    dialog.id = id;
    // @ts-ignore In browser context
    dialog.innerHTML = html;
    // @ts-ignore In browser context
    dialog.style = style;
    // @ts-ignore In browser context
    dialog.classList.add("codemelted-dialog");
    // @ts-ignore In browser context
    globalThis.document.body.appendChild(dialog);
    if (width) {
      // @ts-ignore In browser context
      dialog.style.width = width;
    }
    if (height) {
      // @ts-ignore In browser context
      dialog.style.height = height;
    }
    // @ts-ignore In browser context
    dialog.style.display = "flex";
    // @ts-ignore In browser context
    dialog.showModal();
  }
}

/**
 * Provides the request to render a bottom sheet set of options to support a
 * Single Page Application (SPA) document to get information from the user.
 * @enum {object}
 * @property {string} Alert Displays a snack bar to alert the user of a
 * condition. Disappears after 4 seconds.
 * @property {string} Browser Opens a full page browser iFrame.
 * @property {string} Choose Provides a half page selection of options.
 * @property {string} Close Will asynchronously close an open page.
 * @property {string} Confirm Provides a half-page confirmation Yes / No
 * question to the user.
 * @property {string} Custom Provides a full page custom dialog to the user.
 * @property {string} Loading Provides a loading half-page dialog closed via
 * the Close request.
 * @property {string} Prompt Provides a half-page text field prompt input
 * box.
 */
export const DIALOG_REQUEST = Object.freeze({
  Alert: "alert",
  Browser: "browser",
  Choose: "choose",
  Close: "close",
  Confirm: "confirm",
  Custom: "custom",
  Loading: "loading",
  Prompt: "prompt",
});

/**
 * Interface adds to HTMLElement the properties and methods needed to support
 * basic media-related capabilities that are common to audio and video.
 * NOTE: Defined to support proper typing in the JSDocs when type checking in
 *       a TypeScript environment.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/HTMLAudioElement
 * @typedef {object} HTMLAudioElement
 * @property {number} currentTime specifies the current playback time in
 * seconds.
 * @property {number} playbackRate property sets the rate at which the media
 * is being played back. This is used to implement user controls for fast
 * forward, slow motion, and so forth. The normal playback rate is multiplied
 * by this value to obtain the current rate, so a value of 1.0 indicates
 * normal speed.
 * @property {number} volume sets the volume at which the media will be
 * played.
 * @property {function} load resets the media element to its initial state
 * and begins the process of selecting a media source and loading the media
 * in preparation for playback to begin at the beginning.
 * @property {function} pause will pause playback of the media, if the media
 * is already in a paused state this method will have no effect.
 * @property {function} play method attempts to begin playback of the media.
 * It returns a Promise which is resolved when playback has been successfully
 * started.
 * @property {function} onerror Handles the error events.
 * @property {function} onended Handles the onended events.
 * @property {Event} error event is fired when the resource could not be
 * loaded due to an error (for example, a network connectivity problem).
 * @property {Event} ended event is fired when playback or streaming has
 * stopped because the end of the media was reached or because no further data
 * is available.
 */

/**
 * NOTE: Defined to support proper typing in the JSDocs when type checking in
 *       a TypeScript environment.
 * @typedef {object} HTMLElement
 */

/**
 * Provides the request actions of the [ui_is] function call.
 * @enum {object}
 * @property {string} PWA Determines if the browser window represents an
 * installed Progressive Web Application.
 * @property {string} SecureContext indicating whether the current context
 * is secure (true) or not (false).
 * @property {string} TouchEnabled Identifies if the browser is accessible via
 * a touch device.
 */
export const IS_REQUEST = Object.freeze({
  PWA: "PWA",
  SecureContext: "SecureContext",
  TouchEnabled: "TouchEnabled",
});

/**
 * Provides the request options of the [ui_message] function call.
 * @enum {object}
 * @property {string} Alert instructs the browser to display a dialog with
 * an optional message, and to wait until the user dismisses the dialog.
 * @property {string} Confirm instructs the browser to display a dialog with
 * an optional message, and to wait until the user either confirms or cancels
 * the dialog.
 * @property {string} Prompt instructs the browser to display a dialog with
 * an optional message prompting the user to input some text, and to wait
 * until the user either submits the text or cancels the dialog.
 * @property {string} Post safely enables cross-origin communication between
 * Window objects; e.g., between a page and a pop-up that it spawned, or
 * between a page and an iframe embedded within it.
 */
export const MESSAGE_REQUEST = Object.freeze({
  Alert: "alert",
  Confirm: "confirm",
  Prompt: "prompt",
  Post: "post",
});

/**
 * Identifies queryable requests to discover more about your application
 * running in the given browser.
 * @enum {object}
 * @property {string} AvailableHeight the height of the screen, in pixels,
 * minus permanent or semipermanent user interface features displayed by the
 * operating system, such as the Taskbar on Windows.
 * @property {string} AvailableWidth the amount of horizontal space in pixels
 * available to the window.
 * @property {string} ColorDepth the color depth of the screen.
 * @property {string} DevicePixelRatio the ratio of the resolution in physical
 * pixels to the resolution in CSS pixels for the current display device.
 * @property {string} Height the height of the screen in pixels.
 * @property {string} InnerHeight the interior height of the window in pixels,
 * including the height of the horizontal scroll bar, if present.
 * @property {string} InnerWidth interior width of the window in pixels (that
 * is, the width of the window's layout viewport). That includes the width of
 * the vertical scroll bar, if one is present.
 * @property {string} OuterHeight the height in pixels of the whole browser
 * window, including any sidebar, window chrome, and window-resizing
 * borders/handles.
 * @property {string} OuterWidth the width of the outside of the browser
 * window. It represents the width of the whole browser window including
 * sidebar (if expanded), window chrome and window resizing borders/handles.
 * @property {string} PixelDepth the bit depth of the screen.
 * @property {string} ScreenLeft the horizontal distance, in CSS pixels, from
 * the left border of the user's browser viewport to the left side of the
 * screen.
 * @property {string} ScreenOrientationAngle the document's current orientation
 * angle.
 * @property {string} ScreenOrientationType the document's current orientation
 * type, one of portrait-primary, portrait-secondary, landscape-primary, or
 * landscape-secondary.
 * @property {string} ScreenTop the vertical distance, in CSS pixels, from the
 * top border of the user's browser viewport to the top side of the screen.
 * @property {string} ScreenX the horizontal distance, in CSS pixels, of the
 * left border of the user's browser viewport to the left side of the screen.
 * @property {string} ScreenY the vertical distance, in CSS pixels, of the top
 * border of the user's browser viewport to the top edge of the screen.
 * @property {string} ScrollX the number of pixels by which the document is
 * currently scrolled horizontally. This value is subpixel precise in modern
 * browsers, meaning that it isn't necessarily a whole number.
 * @property {string} ScrollY the number of pixels by which the document is
 * currently scrolled vertically. This value is subpixel precise in modern
 * browsers, meaning that it isn't necessarily a whole number.
 * @property {string} Width the width of the screen.
 */
export const SCREEN_REQUEST = Object.freeze({
  AvailableHeight: "availHeight",
  AvailableWidth: "availWidth",
  ColorDepth: "colorDepth",
  DevicePixelRatio: "devicePixelRatio",
  Height: "height",
  InnerHeight: "innerHeight",
  InnerWidth: "innerWidth",
  OuterHeight: "outerHeight",
  OuterWidth: "outerWidth",
  PixelDepth: "pixelDepth",
  ScreenLeft: "screenLeft",
  ScreenOrientationAngle: "screenOrientationAngle",
  ScreenOrientationType: "screenOrientationType",
  ScreenTop: "screenTop",
  ScreenX: "screenX",
  ScreenY: "screenY",
  ScrollX: "scrollX",
  ScrollY: "scrollY",
  Width: "width",
});

/**
 * Represents a speech request. It contains the content the speech service
 * should read and information about how to read it (e.g., language,
 * pitch and volume.)
 * NOTE: Defined to support proper typing in the JSDocs when type checking in
 *       a TypeScript environment.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesisUtterance
 * @typedef {object} SpeechSynthesisUtterance
 * @property {number} rate gets and sets the speed at which the utterance will
 * be spoken.
 * @property {number} volume gets and sets the volume that the utterance will
 * be spoken.
 * @property {Event} end fired when the utterance has finished being spoken.
 * @property {Event} error fired when an error occurs that prevents the
 * utterance from being successfully spoken.
 */

/**
 * Provides the ability to carry out actions with the open browser window.
 * @param {object} params The named parameters.
 * @param {string} params.request The {@link ACTION_REQUEST} enumerated value
 * to carry out with the open browser window.
 * @param {object} [params.options] The optional data associated with the
 * Share / OpenFilePicker / SaveFilePicker requests. See <ul>
 * <li> https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share#data </li>
 * <li> https://developer.mozilla.org/en-US/docs/Web/API/Window/showOpenFilePicker#parameters </li>
 * <li> https://developer.mozilla.org/en-US/docs/Web/API/Window/showSaveFilePicker#parameters </li>
 * </ul>
 * @param {number[]} [params.pattern] Provides a pattern of vibration and pause
 * intervals. Each value indicates a number of milliseconds to vibrate or pause,
 * in alternation.
 * @param {number} [params.x] An X coordinate or delta coordinate for a given
 * action that moves / sets position of the browser window or item on the
 * browser window.
 * @param {number} [params.y] An X coordinate or delta coordinate for a given
 * action that moves / sets position of the browser window or item on the
 * browser window.
 * @returns {Promise<CResult>} Reflecting success or failure of the given
 * request.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export async function ui_action({request, options, pattern=[], x, y}) {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  let value = null;
  switch (request) {
    case ACTION_REQUEST.Focus:
      // @ts-ignore This is in a browser context
      globalThis.focus();
      break;
    case ACTION_REQUEST.MoveBy:
      json_check_type({type: "number", data: x, shouldThrow: true});
      json_check_type({type: "number", data: y, shouldThrow: true});
      // @ts-ignore check types above will validate number is not null.
      globalThis.moveBy(x, y);
      break;
    case ACTION_REQUEST.MoveTo:
      json_check_type({type: "number", data: x, shouldThrow: true});
      json_check_type({type: "number", data: y, shouldThrow: true});
      // @ts-ignore check types above will validate number is not null.
      globalThis.moveTo(x, y);
      break;
    case ACTION_REQUEST.Print:
      // @ts-ignore This is in a browser context
      globalThis.print();
      break;
    case ACTION_REQUEST.ResizeBy:
      json_check_type({type: "number", data: x, shouldThrow: true});
      json_check_type({type: "number", data: y, shouldThrow: true});
      // @ts-ignore check types above will validate number is not null.
      globalThis.resizeBy(x, y);
      break;
    case ACTION_REQUEST.ResizeTo:
      json_check_type({type: "number", data: x, shouldThrow: true});
      json_check_type({type: "number", data: y, shouldThrow: true});
      // @ts-ignore check types above will validate number is not null.
      globalThis.resizeTo(x, y);
      break;
    case ACTION_REQUEST.Scroll:
      json_check_type({type: "number", data: x, shouldThrow: true});
      json_check_type({type: "number", data: y, shouldThrow: true});
      // @ts-ignore check types above will validate number is not null.
      globalThis.scroll(x, y);
      break;
    case ACTION_REQUEST.ScrollBy:
      json_check_type({type: "number", data: x, shouldThrow: true});
      json_check_type({type: "number", data: y, shouldThrow: true});
      // @ts-ignore check types above will validate number is not null.
      globalThis.scrollBy(x, y);
      break;
    case ACTION_REQUEST.ScrollTo:
      json_check_type({type: "number", data: x, shouldThrow: true});
      json_check_type({type: "number", data: y, shouldThrow: true});
      // @ts-ignore check types above will validate number is not null.
      globalThis.scrollTo(x, y);
      break;
    case ACTION_REQUEST.Share:
      try {
        // @ts-ignore This is in a browser context
        await globalThis.navigator.share(options);
      } catch (err) {
        return new CResult({error: err});
      }
    case ACTION_REQUEST.Vibrate:
      json_check_type({type: Array, data: pattern, shouldThrow: true});
      try {
        // @ts-ignore Will exist in the browser context
        globalThis.navigator.vibrate(pattern);
      } catch (err) {
        return new CResult({error: err});
      }
    default:
      throw API_MISUSE;
  }
  return new CResult({value: value});
}

/**
 * Constructs a [CAudioPlayer] to assist in either performing text to speech
 * or playback of an audio file.
 * @param {object} params The named parameters.
 * @param {string} params.request The {@link AUDIO_REQUEST} to carry out.
 * @param {string} params.data The string url for audio file or string of text
 * to perform text to speech.
 * @returns {CAudioPlayer} Reflecting success or failure of the given
 * request.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function ui_audio({request, data}) {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  return new CAudioPlayer(request, data);
}

/**
 * An asynchronous function to display a dialog to inform user's of things
 * occurring with their HTML document.
 * @param {object} params The named parameters
 * @param {string} params.request The {@link DIALOG_REQUEST} to carry out.
 * @param {string} params.title A unique way of identifying the dialog.
 * @param {string | HTMLElement} [params.message] The message to use with all
 * DIALOG_REQUEST options except .Browser / .Close / .Loading
 * @param {string[]} [params.choices=[]] The choices to utilize with the
 * DIALOG_REQUEST.Choose option.
 * @param {any} [params.returnValue] The optional value to pass along with
 * the DIALOG_REQUEST.Close option.
 * @param {string} [params.width] The optional width to set of the dialog
 * either by percentage or pixel.
 * @param {string} [params.height] The optional height to set of the dialog
 * either by percentage or pixel.
 * @returns {Promise<CResult>} The returned value from the dialog.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function ui_dialog({
  request,
  title,
  message,
  choices = [],
  returnValue,
  width,
  height
}) {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  json_check_type({type: Array, data: choices, shouldThrow: true});
  json_check_type({type: "string", data: request, shouldThrow: true});
  json_check_type({type: "string", data: title, shouldThrow: true});
  if (!json_check_type({type: "string", data: message}) &&
      // @ts-ignore This will exist in a browser context
      !json_check_type({type: globalThis.HTMLElement, data: message})) {
    throw API_TYPE_VIOLATION;
  }
  const id = title.replace(/\s/g, '');
  switch (request) {
    case DIALOG_REQUEST.Alert:
      return new Promise((resolve) => {
        const content = `
          <div class="cm-dialog-content">
            <div>${message}</div>
            <div class="cm-align-center">
              <button id="${id}OK">OK</button>
            </div>
          </div>
        `;
        setTimeout(() => {
          // @ts-ignore Will exist in the browser context.
          const dlg = globalThis.document.getElementById(id);
          // @ts-ignore Will not be null
          dlg.onclose = () => {
            resolve(new CResult());
          }

          // @ts-ignore Will exist in the browser context
          const closeBtn = globalThis.document.getElementById(
            `${id}CloseDialog`
          );
          // @ts-ignore Will not be null
          closeBtn.onclick = () => {
            CDialog.close(id);
            resolve(new CResult());
          };

          // @ts-ignore Will exist in the browser context.
          const ok = globalThis.document.getElementById(`${id}OK`);
          // @ts-ignore Will not be null
          ok.onclick = () => {
            CDialog.close(id);
            resolve(new CResult());
          };
        });
        CDialog.show("💬", id, title, content, width, height);
      });
    case DIALOG_REQUEST.Browser:
      return new Promise((resolve) => {
        const content = `
          <iframe class="codemelted-dialog-content" src="${message}">
          </iframe>
        `;
        setTimeout(() => {
          // @ts-ignore Will exist in a browser context.
          const dlg = globalThis.document.getElementById(id);
          // @ts-ignore Will not be null
          dlg.onclose = () => {
            resolve(new CResult());
          }

          // @ts-ignore Will exist in a browser context.
          const closeBtn = globalThis.document.getElementById(
            `${id}CloseDialog`
          );
          // @ts-ignore Will not be null
          closeBtn.onclick = () => {
            CDialog.close(id);
            resolve(new CResult());
          };
        });
        CDialog.show("💻", id, title, content, width, height);
      });
    case DIALOG_REQUEST.Choose:
      return new Promise((resolve) => {
        /** @type {string[]} */
        const selectOptions = [];
        choices.forEach((e) => {
          selectOptions.push(`<option value="${e}">${e}</option>`);
        });
        const content = `
          <div class="cm-dialog-content">
            <div>${message}:</div>
            <select id="${id}Select">
              ${selectOptions.toString()}
            </select>
            <div class="cm-align-center">
              <button id="${id}OK">OK</button>
              <button id="${id}Cancel">Cancel</button>
            </div>
          </div>
        `;

        setTimeout(() => {
          // @ts-ignore Will exist in the browser context
          const dlg = globalThis.document.getElementById(id);
          // @ts-ignore Will not be null
          dlg.onclose = () => {
            resolve(new CResult());
          }

          // @ts-ignore Will exist in the browser context
          const closeBtn = globalThis.document.getElementById(
            `${id}CloseDialog`
          );
          // @ts-ignore Will not be null
          closeBtn.onclick = () => {
            CDialog.close(id, null);
            resolve(new CResult(CDialog.returnValue));
          };

          // @ts-ignore Will exist in the browser context
          const cancel = globalThis.document.getElementById(`${id}Cancel`);
          // @ts-ignore Will not be null
          cancel.onclick = () => {
            CDialog.close(id, null);
            resolve(new CResult(CDialog.returnValue));
          };

          // @ts-ignore Will exist in the browser context
          const cmbSelect = globalThis.document.getElementById(`${id}Select`);
          // @ts-ignore Will exist in the browser context
          const ok = globalThis.document.getElementById(`${id}OK`);
          // @ts-ignore Will not be null
          ok.onclick = () => {
            // @ts-ignore Will not be null
            CDialog.close(id, cmbSelect.value);
            const rtnval = CDialog.returnValue
              ? CDialog.returnValue
              : "";
            resolve(new CResult({value: rtnval}));
          };
        });
        CDialog.show("🤔", id, title, content, width, height);
      });
    case DIALOG_REQUEST.Close:
      return new Promise((resolve) => {
        CDialog.close(id, returnValue);
        resolve(new CResult());
      });
    case DIALOG_REQUEST.Confirm:
      return new Promise((resolve) => {
        const content = `
          <div class="cm-dialog-content">
            <div>${message}</div>
            <div class="cm-align-center">
              <button id="${id}OK">OK</button>
              <button id="${id}Cancel">Cancel</button>
            </div>
          </div>
        `;
        setTimeout(() => {
          // @ts-ignore Will exist in the browser context
          const dlg = globalThis.document.getElementById(id);
          // @ts-ignore Will not be null.
          dlg.onclose = () => {
            resolve(new CResult());
          }

          // @ts-ignore Will exist in a browser context
          const closeBtn = globalThis.document.getElementById(
            `${id}CloseDialog`
          );
          // @ts-ignore This will not be null
          closeBtn.onclick = () => {
            CDialog.close(id, false);
            resolve(new CResult({value: CDialog.returnValue}));
          };

          // @ts-ignore Will exist in the browser context
          const ok = globalThis.document.getElementById(`${id}OK`);
          // @ts-ignore Will not be null
          ok.onclick = () => {
            CDialog.close(id, true);
            resolve(new CResult({value: CDialog.returnValue}));
          };

          // @ts-ignore Will exist in browser context
          const cancel = globalThis.document.getElementById(`${id}Cancel`);
          // @ts-ignore It will not be null
          cancel.onclick = () => {
            CDialog.close(id, false);
            resolve(new CResult({value: CDialog.returnValue}));
          };
        });
        CDialog.show("🙋‍♂️", id, title, content, width, height);
      });
    case DIALOG_REQUEST.Custom:
      return new Promise((resolve) => {
        // @ts-ignore Will exist in the browser context.
        const content = message instanceof globalThis.HTMLElement
          // @ts-ignore innerHTML will exist
          ? message.innerHTML
          : message;

        setTimeout(() => {
          // @ts-ignore Will exist in the browser context
          const dlg = globalThis.document.getElementById(id);
          // @ts-ignore It will not be null.
          dlg.onclose = () => {
            resolve(new CResult());
          }

          // @ts-ignore Will exist in the browser context.
          const closeBtn = globalThis.document.getElementById(
            `${id}CloseDialog`
          );
          // @ts-ignore Button will not be null.
          closeBtn.onclick = () => {
            CDialog.close(id);
            resolve(new CResult());
          };
        });
        // @ts-ignore It will not be null.
        CDialog.show("🛃", id, title, content, width, height);
      });
    case DIALOG_REQUEST.Loading:
      return new Promise((resolve) => {
        const content = `
          <div class="codemelted-dialog-content">
            <div>${message}</div>
            <div id="${id}-${request}"></div>
          </div>
        `;
        setTimeout(() => {
          // @ts-ignore Will exist in a browser context
          const txtProcessing = globalThis.document.getElementById(
            `${id}-${request}`
          );
          let x = 0;
          const timerId = setInterval(() => {
            let dots = "";
            if (x === 0) {
              dots = " .";
            } else if (x === 1) {
              dots = " . .";
            } else if (x == 2) {
              dots = " . . .";
              x = -1;
            }
            // @ts-ignore This will not be null
            txtProcessing.innerHTML = `Processing${dots}`;
            x += 1;
          }, 500);

          // @ts-ignore This will be in a browser context.
          const dlg = globalThis.document.getElementById(id);
          // @ts-ignore This will not be null
          dlg.onclose = () => {
            resolve(new CResult({value: CDialog.returnValue}));
            clearInterval(timerId);
          }
        });
        CDialog.show("⏳", id, title, content, width, height);
      });
    case DIALOG_REQUEST.Prompt:
      return new Promise((resolve) => {
        const content = `
          <div class="cm-dialog-content">
            <div>${message}:</div>
            <input id="${id}Text" type="text" />
            <div class="cm-align-center">
              <button id="${id}OK">OK</button>
              <button id="${id}Cancel">Cancel</button>
            </div>
          </div>
        `;
        setTimeout(() => {
          // @ts-ignore Will exist in a browser context
          const dlg = globalThis.document.getElementById(id);
          // @ts-ignore Will not be null
          dlg.onclose = () => {
            resolve(new CResult());
          }

          // @ts-ignore Will exist in a browser context
          const closeBtn = globalThis.document.getElementById(
            `${id}CloseDialog`
          );
          // @ts-ignore Will not be null
          closeBtn.onclick = () => {
            CDialog.close(id, null);
            resolve(new CResult({value: CDialog.returnValue}));
          };

          // @ts-ignore Will exist in a browser context
          const txtField = globalThis.document.getElementById(`${id}Text`);
          // @ts-ignore Will exist in a browser context
          const ok = globalThis.document.getElementById(`${id}OK`);
          // @ts-ignore Won't be null
          ok.onclick = () => {
            // @ts-ignore Won't be null
            CDialog.close(id, txtField.value);
            const rtnval = CDialog.returnValue
              ? CDialog.returnValue
              : "";
            resolve(new CResult({value: rtnval}));
          };

          // @ts-ignore Exists in a browser context
          const cancel = globalThis.document.getElementById(`${id}Cancel`);
          // @ts-ignore Will not be null
          cancel.onclick = () => {
            CDialog.close(id, null);
            resolve(new CResult({value: CDialog.returnValue}));
          };
        });
        CDialog.show("🤨", id, title, content, width, height);
      });
    default:
      throw API_MISUSE;
  }
}

/**
 * Boolean queries of the given browser runtime to discovery different
 * features about the given browser window.
 * @param {string} request {@link IS_REQUEST} enumerated value of different
 * browser properties.
 * @returns {boolean} true if the given property is supported, false
 * otherwise.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function ui_is(request) {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  switch (request) {
    case IS_REQUEST.PWA:
      // @ts-ignore This is in a browser context
      return globalThis.matchMedia("(display-mode: standalone)").matches;
    case IS_REQUEST.SecureContext:
      // @ts-ignore This is in a browser context
      return globalThis.isSecureContext;
    case IS_REQUEST.TouchEnabled:
      // @ts-ignore This is in a browser context
      return globalThis.navigator.maxTouchPoints > 0;
    default:
      throw API_MISUSE;
  }
}

/**
 * Wraps the browser provided messaging mechanisms.
 * @param {object} params The named parameters
 * @param {string} params.request  {@link MESSAGE_REQUEST} enumerated value
 * identifying the type of messaging to perform.
 * @param {string | any} params.data String for the Alert / Confirm / Prompt
 * request. Serializable data for Post communication between browser windows.
 * @param {string} [params.targetOrigin="*"] Which window to send the data
 * when utilizing the Post request. Not setting it will send to all open
 * windows.
 * @returns {boolean | string | null | void} Alert is void / Confirm
 * is boolean / Prompt is string, null / Post is void.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function ui_message({request, data, targetOrigin = "*"}) {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  switch (request) {
    case MESSAGE_REQUEST.Alert:
      // @ts-ignore This is in a browser context
      globalThis.alert(data);
      break;
    case MESSAGE_REQUEST.Confirm:
      // @ts-ignore This is in a browser context
      return globalThis.confirm(data);
    case MESSAGE_REQUEST.Prompt:
      // @ts-ignore This is in a browser context
      return globalThis.prompt(data);
    case MESSAGE_REQUEST.Post:
      // @ts-ignore This is in a browser context
      globalThis.postMessage(data, targetOrigin);
    default:
      throw API_MISUSE;
  }
}

// TODO: Break out SCHEMA and TARGET enumerations.

/**
 * Opens the specified protocol to a browser window or native app
 * configured to handle the given specified schema.
 * @param {object} params The named parameters
 * @param {string} params.schema One of the supported schemas of "file:",
 * "http://", "https://", "mailto:", "sms:", or "tel:".
 * @param {boolean} [params.popupWindow=false] Whether to open the protocol in
 * a separate browser window.
 * @param {string} [params.url] The url of the protocol unless utilizing
 * "mailto:" schema with [params.mailtoParams] which will already be
 * formatted.
 * @param {string[]} [params.mailto=[]] The primary addresses to send the email.
 * @param {string[]} [params.cc=[]] The carbon copy email addresses to send the
 * email.
 * @param {string[]} [params.bcc=[]] The people you don't want others to know
 * about on the email.
 * @param {string} [params.subject=""] The subject of the email.
 * @param {string} [params.body=""] The actual email message.
 * @param {string} [params.target="_blank"] The target affecting the open
 * behavior when not popping up a new window.
 * @param {number} [params.width=900] The width of a popup window. Defaulted to
 * 900.0 when not set.
 * @param {number} [params.height=600] The height of a popup window. Defaulted to
 * 600.0 when not set.
 * @returns {Window | null} Reference to the newly opened browser window.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function ui_open({
  schema,
  popupWindow = false,
  url,
  mailto = [],
  cc = [],
  bcc = [],
  subject = "",
  body = "",
  target = "_blank",
  width=900,
  height=600
}) {
  // Basic validation of runtime and required parameters.
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  json_check_type({type: "boolean", data: popupWindow, shouldThrow: true});
  json_check_type({type: "string", data: target, shouldThrow: true});
  json_check_type({type: "number", data: width, shouldThrow: true});
  json_check_type({type: "number", data: height, shouldThrow: true});
  json_check_type({type: Array, data: mailto, shouldThrow: true});
  json_check_type({type: Array, data: cc, shouldThrow: true});
  json_check_type({type: Array, data: bcc, shouldThrow: true});
  json_check_type({type: "string", data: subject, shouldThrow: true});
  json_check_type({type: "string", data: body, shouldThrow: true});

  // Now go build the URL to open.
  let urlToLaunch = schema;
  if (schema === "file:" ||
      schema === "http://" ||
      schema === "https://" ||
      schema === "sms:" ||
      schema === "tel:") {
    json_check_type({type: "string", data: url, shouldThrow: true});
    urlToLaunch += url;
  } else if (schema === "mailto:") {
    if (url) {
      json_check_type({type: "string", data: url, shouldThrow: true});
      urlToLaunch += url;
    } else {
      // Form the mailto parameters to better control the URL formatting.
      if (mailto.length > 0) {
        mailto.forEach((addr) => {
          urlToLaunch += `${addr};`;
        });
        urlToLaunch.substring(0, urlToLaunch.length - 1);
      }

      let delimiter = "?";
      if (cc.length > 0) {
        urlToLaunch += `${delimiter}cc=`;
        delimiter = "&";
        cc.forEach((addr) => {
          urlToLaunch += `${addr};`;
        });
        urlToLaunch.substring(0, urlToLaunch.length - 1);
      }

      if (bcc.length > 0) {
        urlToLaunch += `${delimiter}bcc=`;
        delimiter = "&";
        bcc.forEach((addr) => {
          urlToLaunch += `${addr};`;
        });
        urlToLaunch.substring(0, urlToLaunch.length - 1);
      }

      if (subject.trim().length > 0) {
        urlToLaunch += `${delimiter}subject=${subject.trim()}`;
        delimiter = "&";
      }

      if (body.trim().length > 0) {
        urlToLaunch += `${delimiter}body=${body.trim()}`;
        delimiter = "&";
      }
    }
  } else {
    throw API_MISUSE;
  }

  // Determine how we are opening the item.
  if (popupWindow) {
    // @ts-ignore Will return a number.
    let top = (ui_screen(SCREEN_REQUEST.Height) - height) / 2;
    // @ts-ignore Will return a number.
    let left = (ui_screen(SCREEN_REQUEST.Width) - width) / 2;
    let settings = `toolbar=no, location=no, ` +
      `directories=no, status=no, menubar=no, ` +
      `scrollbars=no, resizable=yes, copyhistory=no, ` +
      `width=${width}, height=${height}, top=${top}, left=${left}`;
    // @ts-ignore Property exists in a browser runtime.
    return globalThis.open(urlToLaunch, "_blank", settings);
  }
  // @ts-ignore Property exists in a browser runtime.
  return globalThis.open(urlToLaunch, target);
}

/**
 * Provides a mechanism for discovering information about the current browser
 * screen the web app is running in.
 * @param {string} request {@link SCREEN_REQUEST} enumerated value identifying the
 * different aspects to request information about.
 * @returns {number | string} Number for all requests except
 * ScreenOrientationType request.
 * @throws {SyntaxError} Reflecting either {@link API_MISUSE},
 * {@link API_NOT_IMPLEMENTED}, {@link API_TYPE_VIOLATION}, or
 * {@link API_UNSUPPORTED_RUNTIME} codemelted.js module API violations. You
 * should not try-catch these as these serve as asserts to the
 * developer.
 * </p>
 * <b>Supported Platforms:</b>
 * <input type="checkbox" onclick="return false;" checked><label>Browser</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Deno</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>NodeJS</label>
 * <input type="checkbox" onclick="return false;" unchecked><label>Worker</label>
 * </p>
 * @example
 * // TBD
 */
export function ui_screen(request) {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_RUNTIME;
  }
  switch (request) {
    case SCREEN_REQUEST.AvailableHeight:
      // @ts-ignore This is in a browser context
      return globalThis.screen.availHeight;
    case SCREEN_REQUEST.AvailableWidth:
      // @ts-ignore This is in a browser context
      return globalThis.screen.availWidth;
    case SCREEN_REQUEST.ColorDepth:
      // @ts-ignore This is in a browser context
      return globalThis.screen.colorDepth;
    case SCREEN_REQUEST.DevicePixelRatio:
      // @ts-ignore This is in a browser context
      return globalThis.devicePixelRatio;
    case SCREEN_REQUEST.Height:
      // @ts-ignore This is in a browser context
      return globalThis.screen.height;
    case SCREEN_REQUEST.InnerHeight:
      // @ts-ignore This is in a browser context
      return globalThis.innerHeight;
    case SCREEN_REQUEST.InnerWidth:
      // @ts-ignore This is in a browser context
      return globalThis.innerWidth;
    case SCREEN_REQUEST.OuterHeight:
      // @ts-ignore This is in a browser context
      return globalThis.outerHeight;
    case SCREEN_REQUEST.OuterWidth:
      // @ts-ignore This is in a browser context
      return globalThis.outerWidth;
    case SCREEN_REQUEST.PixelDepth:
      // @ts-ignore This is in a browser context
      return globalThis.screen.pixelDepth;
    case SCREEN_REQUEST.ScreenLeft:
      // @ts-ignore This is in a browser context
      return globalThis.screenLeft;
    case SCREEN_REQUEST.ScreenOrientationAngle:
       // @ts-ignore This is in a browser context
      return globalThis.screen.orientation.angle;
    case SCREEN_REQUEST.ScreenOrientationType:
      // @ts-ignore This is in a browser context
      return globalThis.screen.orientation.type;
    case SCREEN_REQUEST.ScreenTop:
      // @ts-ignore This is in a browser context
      return globalThis.screenTop;
    case SCREEN_REQUEST.ScreenX:
      // @ts-ignore This is in a browser context
      return globalThis.screenX
    case SCREEN_REQUEST.ScreenY:
      // @ts-ignore This is in a browser context
      return globalThis.screenY
    case SCREEN_REQUEST.ScrollX:
      // @ts-ignore This is in a browser context
      return globalThis.scrollX;
    case SCREEN_REQUEST.ScrollY:
      // @ts-ignore This is in a browser context
      return globalThis.scrollY;
    case SCREEN_REQUEST.Width:
      // @ts-ignore This is in a browser context
      return globalThis.screen.width;
    default:
      throw API_MISUSE;
  }
}

/**
* <mark>FUTURE DEVELOPMENT. DO NOT USE!</mark>
 */
export function ui_widget() {
  if ("HTMLElement" in globalThis) {
    // TODO: This is how we will define our custom components.
    // @ts-ignore Exists in a browser context.
    // globalThis.customElements.define("codemelted-something",
    //     class extends globalThis.HTMLElement {
    //   // Define something cool.
    // });
  } else {
    throw API_UNSUPPORTED_RUNTIME;
  }
}