// @ts-check
// ============================================================================
/**
 * @file The implementation of the codemelted.js Module.
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
 * Identifies a future implementation within the codemelted.js module.
 * @constant {SyntaxError}
 */
const API_FUTURE_IMPLEMENTATION = new SyntaxError(
  "codemelted.js module future implementation"
);

/**
 * Error thrown when the module is not used as intended providing the error
 * for a developer to fix their code.
 * @constant {SyntaxError}
 */
const API_MISUSE_ERROR = new SyntaxError(
  "codemelted.js module logic was not used properly!"
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
const API_UNSUPPORTED_PLATFORM = new SyntaxError(
  "codemelted.js module function called on an unsupported JavaScript runtime!"
);

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
  async get_message(request="") { throw API_FUTURE_IMPLEMENTATION; }

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
  get is_running() { throw API_FUTURE_IMPLEMENTATION; }

  /**
   * Posts a given message to the given implementing protocol.
   * @param {any} data
   * @returns {Promise<CResult>}
   */
  post_message(data) { throw API_FUTURE_IMPLEMENTATION; }

  /**
   * Terminates the given protocol.
   * @returns {void}
   */
  terminate() { throw API_FUTURE_IMPLEMENTATION; }

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
  /** @type {string | null} */
  #error = null;

  /** @type {any} */
  #value = undefined;

  /**
   * Holds any error message associated with a failed transaction request.
   * @readonly
   * @type {string | null}
   */
  get error() { return this.#error; }

  /**
   * Signals whether an error was captured or not.
   * @readonly
   * @type {boolean}
   */
  get is_error() { return this.error != null && this.error.length > 0; }

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
   * @throws {API_MISUSE_ERROR} When called on an already terminated
   * timer.
   */
  stop() {
    if (!this.is_running) {
      throw API_MISUSE_ERROR;
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @private
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
function async_worker() {
  throw API_FUTURE_IMPLEMENTATION;
}

// ============================================================================
// [CONSOLE UC IMPLEMENTATION] ================================================
// ============================================================================

/**
 * Writes an alert message (via STDOUT) to the user awaiting an enter key
 * press via STDIN.
 * @param {string} [message=""] The message to prompt out or "ALERT".
 * @returns {void}
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
    throw API_FUTURE_IMPLEMENTATION;
  } else {
    throw API_UNSUPPORTED_PLATFORM;
  }
}

/**
 * Prompts (via STDOUT) for a user confirmation (via STDIN).
 * @param {string} [message=""] The confirmation you are looking for.
 * @returns {boolean} The choice made.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
    throw API_FUTURE_IMPLEMENTATION;
  } else {
    throw API_UNSUPPORTED_PLATFORM;
  }
}

/**
 * Prompts (via STDOUT) for a user to make a choice (via STDIN) between an
 * array of choices
 * @param {object} params The named parameters.
 * @param {string} [params.message=""] The message to write to STDOUT.
 * @param {string[]} params.choices The choices to choose from
 * written to STDOUT.
 * @returns {number} The index of the selection in [params.choices].
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
    throw API_FUTURE_IMPLEMENTATION;
  } else {
    throw API_UNSUPPORTED_PLATFORM;
  }
}

/**
 * Prompts (via STDOUT) for a user to enter their password via STDIN.
 * @param {string} [message=""] The custom prompt to write out to STDOUT.
 * @returns {string} the password entered via STDIN.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
    throw API_FUTURE_IMPLEMENTATION;
  } else {
    throw API_UNSUPPORTED_PLATFORM;
  }
}

/**
 * Write a prompt to STDOUT to receive an answer via STDIN.
 * @param {string} [message=""] The custom prompt message for STDOUT.
 * @returns {string} The typed in answer received via STDIN.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
    throw API_FUTURE_IMPLEMENTATION;
  } else {
    throw API_UNSUPPORTED_PLATFORM;
  }
}

/**
 * Writes the given message to STDOUT.
 * @param {string} [message=""] The message to write or a blank line.
 * @returns {void}
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function console_writeln(message = "") {
  json_check_type({type: "string", data: message, shouldThrow: true});
  if (runtime_is_deno()) {
    globalThis.console.log(message);
  } else if (runtime_is_nodejs()) {
    throw API_FUTURE_IMPLEMENTATION;
  } else {
    throw API_UNSUPPORTED_PLATFORM;
  }
}

// ============================================================================
// [DB UC IMPLEMENTATION] =====================================================
// ============================================================================

// TO BE DEVELOPED

// ============================================================================
// [DISK UC IMPLEMENTATION] ===================================================
// ============================================================================

// TO BE DEVELOPED

// ============================================================================
// [HW UC IMPLEMENTATION] =====================================================
// ============================================================================

/**
 * Defined to support proper typing in the JSDocs when type checking in a
 * TypeScript environment.
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
 * TypeScript environment.
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
 * Represents the geodetic data captured from the codemelted.sensor()
 * protocol.
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
export class CDeviceOrientationProtocol extends CProtocolHandler {
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
  post_message(data) { throw API_FUTURE_IMPLEMENTATION; }

  /**
   * @inheritdoc
   * @override
   */
  terminate() {
    if (!this.is_running) {
      throw API_MISUSE_ERROR;
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
    super("CDeviceOrientationProtocol");

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
 * @private
 */
class CSerialPort extends CProtocolHandler {

}

/**
 * @private
 * @returns {Promise<string[]>}
 */
async function hw_available_serial_ports() {
  if (hw_serial_ports_supported()) {
    // @ts-ignore This is available in some web browsers
    const ports = await globalThis.navigator.serial.getPorts();
    throw "TODO: Implement id parsing of ports";
  }
  return [];
}

/**
 * Opens a device orientation protocol to retrieve the devices current
 * geodetic orientation in 3D space.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Geolocation/getCurrentPosition#options
 * @param {object} [options] The options for tuning the protocol to
 * watch for geolocation position updates.
 * @return {CDeviceOrientationProtocol} The protocol that handles device
 * orientation changes until terminated.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function hw_open_device_orientation(options) {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_PLATFORM;
  }
  return new CDeviceOrientationProtocol(options)
}

/**
 * Determines if the JavaScript browser runtime will provide the ability to
 * connect with serial ports.
 * @returns {boolean} true if available, false otherwise.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 *   // Use hw_available_serial_ports() for further processing.
 * }
 */
export function hw_serial_ports_supported() {
  return "navigator" in globalThis &&
    "serial" in globalThis.navigator &&
    runtime_is_browser() || runtime_is_worker();
}

// ============================================================================
// [JSON UC IMPLEMENTATION] ===================================================
// ============================================================================

/**
 * @private
 */
function json_create_array() {
  throw API_FUTURE_IMPLEMENTATION;
}

/**
 * @private
 */
function json_create_object() {
  throw API_FUTURE_IMPLEMENTATION;
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
 * @throws {API_MISUSE_ERROR} On API violation
 * or if called on an unsupported platform.
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
    throw API_MISUSE_ERROR;
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @type {LOGGER}
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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

// TO BE DEVELOPED

// ============================================================================
// [NETWORK UC IMPLEMENTATION] ================================================
// ============================================================================

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
   * @param {string | null} [params.error]
   */
  constructor({status, data, error=null}) {
    super({value: data, error: error});
    this.#status = status;
  }
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
 * @private
 */
function npu_compute() {
  throw API_FUTURE_IMPLEMENTATION;
}

/**
 * Executes a specified mathematical formula with the specified parameters
 * returning the calculated results.
 * @param {object} params The named parameters
 * @param {MATH_FORMULA} params.formula The formula to execute.
 * @param {Array<number>} params.args The arguments needed for the formula.
 * @returns {number} The calculated result or NaN if something in the args
 * force that value (i.e. division by 0).
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
    // @ts-ignore This is a map of formulas in the dictionary.
    return formula(args);
  } catch (err) {
    if (err instanceof RangeError) {
      throw API_MISUSE_ERROR;
    }
    return NaN;
  }
}

// ============================================================================
// [PROCESS UC IMPLEMENTATION] ================================================
// ============================================================================

// TO BE DEVELOPED

// ============================================================================
// [RUNTIME UC IMPLEMENTATION] ================================================
// ============================================================================

/**
 * The event handler utilized within a given JavaScript runtime.
 * @callback CEventHandler
 * @param {Event} e The event object that was triggered
 * @returns {void}
 */
/**
 * Determines the CPU architecture.
 * @returns {string} identifier of the architecture.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
  throw API_UNSUPPORTED_PLATFORM;
}

/**
 * Determines the available CPU processors for background workers.
 * @returns {number} The available hardware processors.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
  throw API_UNSUPPORTED_PLATFORM;
}

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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function runtime_event_listener({
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
  } else if (action = "remove") {
    if (obj) {
      obj.removeEventListener(type, listener);
    } else {
      globalThis.removeEventListener(type, listener);
    }
  }
}

/**
 * Determines the home path of the logged in user.
 * @returns {string?} The identified home path on disk.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
  throw API_UNSUPPORTED_PLATFORM;
}

/**
 * Determines the hostname of the host operating system.
 * @returns {string} The hostname of the computer.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
  throw API_UNSUPPORTED_PLATFORM;
}

/**
 * Determines if the JavaScript runtime is web browser.
 * @returns {boolean} true if web browser, false otherwise.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
* @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
  throw API_UNSUPPORTED_PLATFORM;
}

/**
 * Determines if the web app has access to the Internet.
 * @returns {boolean} true if path to Internet available, false otherwise.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
  throw API_UNSUPPORTED_PLATFORM;
}

/**
 * Determines the name of the host operating system.
 * @returns {string} The identification of the OS.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
  throw API_UNSUPPORTED_PLATFORM;
}

/**
 * Gets the path separator of directories on disk.
 * @returns {string} representing the separation.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
  throw API_UNSUPPORTED_PLATFORM;
}

/**
 * Gets the temporary directory location of the host operating system.
 * @returns {string} representing the directory on disk.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
  throw API_UNSUPPORTED_PLATFORM;
}

/**
 * Identifies the logged in user running the application on the host operating
 * system.
 * @returns {string} user name on disk or "UNDETERMINED".
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
  throw API_UNSUPPORTED_PLATFORM;
}

// ============================================================================
// [STORAGE UC IMPLEMENTATION] ================================================
// ============================================================================

/**
 * Clears the local storage of the module.
 * @returns {void}
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function storage_clear() {
  if (runtime_is_nodejs() || runtime_is_worker()) {
    throw API_UNSUPPORTED_PLATFORM;
  }
  globalThis.localStorage.clear();
}

/**
 * Gets the value associated with the key from the module's local storage.
 * @param {string} key The key to search.
 * @returns {string?} The value associated with the key if found.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function storage_get(key) {
  if (runtime_is_nodejs() || runtime_is_worker()) {
    throw API_UNSUPPORTED_PLATFORM;
  }
  json_check_type({type: "string", data: key, shouldThrow: true});
  return globalThis.localStorage.getItem(key);
}

/**
 * Retrieves the number of entries within the module's local storage.
 * @returns {number} The number of entries.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function storage_length() {
  if (runtime_is_nodejs() || runtime_is_worker()) {
    throw API_UNSUPPORTED_PLATFORM;
  }
  return globalThis.localStorage.length;
}

/**
 * Removes a given entry from the module's local storage.
 * @param {string} key The key to remove.
 * @returns {void}
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function storage_remove(key) {
  if (runtime_is_nodejs() || runtime_is_worker()) {
    throw API_UNSUPPORTED_PLATFORM;
  }
  json_check_type({type: "string", data: key, shouldThrow: true});
  globalThis.localStorage.removeItem(key);
}

/**
 * Sets a key/value pair within the module's local storage.
 * @param {string} key The key to identify the storage entry.
 * @param {string} value The storage entry.
 * @returns {void}
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function storage_set(key, value) {
  if (runtime_is_nodejs() || runtime_is_worker()) {
    throw API_UNSUPPORTED_PLATFORM;
  }
  json_check_type({type: "string", data: key, shouldThrow: true});
  json_check_type({type: "string", data: value, shouldThrow: true});
  globalThis.localStorage.setItem(key, value);
}

// ============================================================================
// [UI UC IMPLEMENTATION] =====================================================
// ============================================================================

/**
 * Retrieves the height of the running browser window.
 * @returns {number} The current height of the window.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function ui_height() {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_PLATFORM;
  }
  // @ts-ignore Property exists in a browser runtime.
  return globalThis.screen.height;
}

/**
 * Determines if the browser UI is installed as a PWA.
 * @returns {boolean} true if browser app installed as PWA, false otherwise.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function ui_is_pwa() {
  if (runtime_is_browser()) {
    // @ts-ignore Property exists in a browser runtime.
    return globalThis.matchMedia("(display-mode: standalone)").matches;
  }
  throw API_UNSUPPORTED_PLATFORM;
}

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
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
    throw API_UNSUPPORTED_PLATFORM;
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
    throw API_MISUSE_ERROR;
  }

  // Determine how we are opening the item.
  if (popupWindow) {
    let top = (ui_height() - height) / 2;
    let left = (ui_width() - width) / 2;
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
 * Will print the current loaded browser document.
 * @returns {void}
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function ui_print() {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_PLATFORM;
  }
    // @ts-ignore Property exists in a browser runtime.
  globalThis.print();
}

/**
 * Provides the ability to share items via the share services. You specify
 * options via the shareData object parameters. Only available on the browser
 * environment.
 * @see https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share
 * @param {object} data See the reference URL for the object fields.
 * @returns {Promise<CResult>} The result of the transaction.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export async function ui_share(data) {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_PLATFORM;
  }
  try {
    // @ts-ignore Property exists in a browser runtime.
    await globalThis.navigator.share(data);
    return new CResult();
  } catch (err) {
    return new CResult({error: err});
  }
}

/**
 * Used to determine if the browser app is running on a touch enabled device.
 * @returns {boolean} if the browser app is touch enabled, false otherwise.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function ui_touch_enabled() {
  if (runtime_is_browser()) {
    // @ts-ignore Property exists in browser context.
    return globalThis.navigator.maxTouchPoints > 0;
  }
  throw API_UNSUPPORTED_PLATFORM;
}

/**
 * Retrieves the width of the running browser window.
 * @returns {number} The current width of the window.
 * @throws {API_TYPE_VIOLATION | API_UNSUPPORTED_PLATFORM} On API violation
 * or if called on an unsupported platform.
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
export function ui_width() {
  if (!runtime_is_browser()) {
    throw API_UNSUPPORTED_PLATFORM;
  }
  // @ts-ignore This property exists in browser.
  return globalThis.screen.width;
}
