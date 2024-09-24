// @ts-check
// ============================================================================
/**
 * @file The implementation of a codemelted global namespace implementing the
 * CodeMelted - Developer cross platform use cases. The use cases will
 * be objects tied to the codemelted namespace. These will target the Deno
 * and Web Browser runtime environments. They will have a series of public
 * functions in accordance to that particular use case design.
 * @author Mark Shaffer
 * @version 0.0.0
 * @license MIT
 * @see https://developer.codemelted.com
 */
// ============================================================================

/**
 * Something Something star wars.
 * @namespace codemelted
 */
globalThis["codemelted"] = (function() {
  // --------------------------------------------------------------------------
  // [Data Definition] --------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Module event to support different callback listeners. Those events will be
   * transformed into this object event.
   * @typedef {object} CModuleEvent
   * @property {string} type "data" / "error" / "status".
   * @property {any} data The actual data associated with the type. The type
   * will depend on what interface callback you are hooking up to.
   */

  /**
   * A general purpose module event listener to be used throughout the module.
   * The data attached to the event will be specific to the callback you are
   * hooking up to.
   * @callback CModuleEventListener
   * @param {CModuleData} event The event that occurred for the registered
   * callback.
   * @returns {void}
   */

  // --------------------------------------------------------------------------
  // [Async Use Case] ---------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.async
   */
  const _async = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [Audio Use Case] ---------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.audio
   */
  const _audio = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [Console Use Case] -------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.console
   */
  const _console = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [Database Use Case] ------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.db
   */
  const _db = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [Firebase Use Case] ------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.firebase
   */
  const _firebase = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [Game Use Case] ----------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.game
   */
  const _game = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [Hardware Use Case] ------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.hw
   */
  const _hw = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [JSON Use Case] ----------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.json
   */
  const _json = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [Logger Use Case] --------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.logger
   */
  const _logger = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [Math Use Case] ----------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.math
   */
  const _math = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [Memory Use Case] --------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.memory
   */
  const _memory = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [Network Use Case] -------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.network
   */
  const _network = Object.freeze({
    //
  });


  // --------------------------------------------------------------------------
  // [Runtime Use Case] -------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.runtime
   */
  const _runtime = Object.freeze({
    //
  });

  // --------------------------------------------------------------------------
  // [Storage Use Case] -------------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Name it something...
   * @private
   * @namespace codemelted.storage
   */
  const _storage = Object.freeze({
    /**
     * Clears the specified storage method.
     * @memberof codemelted.storage
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
     * @memberof codemelted.storage
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
     * @memberof codemelted.storage
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
     * @memberof codemelted.storage
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
     * @memberof codemelted.storage
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
     * @memberof codemelted.storage
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
    },
  });

  // --------------------------------------------------------------------------
  // [User Interface Use Case] ------------------------------------------------
  // --------------------------------------------------------------------------

  /**
   * Something Something star wars.
   * @private
   * @namespace codemelted.ui
   */
  const _ui = Object.freeze({

  });

  // --------------------------------------------------------------------------
  // [Public API] -------------------------------------------------------------
  // --------------------------------------------------------------------------
  return {
    // async: _async,
    // audio: _audio,
    // console: _console,
    // db: _db,
    // firebase: _firebase,
    // game: _game,
    // hw: _hw,
    // json: _json,
    // logger: _logger,
    // math: _math,
    // memory: _memory,
    // network: _network,
    // runtime: _runtime,
    // storage: _storage,
    // ui: _ui,
  }
})();