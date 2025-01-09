// @ts-nocheck
// The above is done to ensure type checking works in case person does not use
// good editor for type checking. Remove it while defining tests to ensure type
// checking does in fact work. You will see a bunch of failures with the
// "failure" type checking cases.
// ============================================================================
/**
 * @file Provides the Deno.test of the codemelted.js file.
 * @author Mark Shaffer
 * @license MIT
 */
// ============================================================================

import {
  assert,
  assertExists,
  assertThrows,
  fail,
} from "jsr:@std/assert";
import codemelted from "./codemelted.js";

// ----------------------------------------------------------------------------
// [console use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

Deno.test("codemelted.console Tests", () => {
  try {
    codemelted.writelnConsole();
  } catch (err) {
    fail("Should not throw.")
  }
});

// ----------------------------------------------------------------------------
// [disk use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

Deno.test("codemelted.disk Properties Test", () => {
  assertExists(codemelted.homePath);
  assertExists(codemelted.pathSeparator);
  assertExists(codemelted.tempPath);
});

Deno.test("codemelted.disk Manipulation Tests", async () => {
  // Get the temporary directory and do some cleanup if necessary
  const tempPath = codemelted.tempPath;
  assert(tempPath != null);
  codemelted.rm({filename: `${tempPath}/results`});

  // First fail to copy and move stuff
  let success = codemelted.cp({
    src: "duh.txt",
    dest: tempPath}
  );
  assert(!success);
  success = codemelted.mv({
    src: "duh.txt",
    dest: tempPath
  });
  assert(!success);

  // Now lets go create directories and files
  success = codemelted.exists({
    filename: `${tempPath}/results/`
  });
  assert(!success);
  success = codemelted.mkdir({filename: `${tempPath}/results`});
  assert(success);

  // Go write some files
  await codemelted.writeEntireFile({
    filename: `${tempPath}/results/writeTextFile.txt`,
    data: "Hello There",
    append: true,
  });
  assert(codemelted.exists({filename: `${tempPath}/results/writeTextFile.txt`}));

  await codemelted.writeEntireFile({
    filename: `${tempPath}/results/writeFile.txt`,
    data: new Uint8Array([42]),
  });
  assert(codemelted.exists({filename: `${tempPath}/results/writeFile.txt`}));

  // Prove the files got written
  let result = codemelted.ls({filename: `${tempPath}/results/`});
  assert(result.length === 2);

  // Prove we can read the files
  result = await codemelted.readEntireFile({
    filename: `${tempPath}/results/writeTextFile.txt`
  });
  assert(result.includes("Hello There"));
  result = await codemelted.readEntireFile({
    filename: `${tempPath}/results/writeFile.txt`,
    isTextFile: false,
  });
  assert(result[0] === 42);

  // Now some cleanup to remove items.
  success = codemelted.rm({filename: `${tempPath}/results`});
  assert(success);
});

// ----------------------------------------------------------------------------
// [file use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

Deno.test("codemelted.file API Violations", async () => {
  try {
    await codemelted.readEntireFile({filename: "test", isTextFile: 42});
    fail("Should throw");
  } catch (err) {
    assert(err instanceof SyntaxError);
  }

  try {
    await codemelted.writeEntireFile({filename: "temp.txt"});
    fail("Should throw");
  } catch (err) {
    assert(err instanceof SyntaxError);
  }

  try {
    await codemelted.writeEntireFile({filename: "temp.txt", data: "data", append: 42});
    fail("Should throw");
  } catch (err) {
    assert(err instanceof SyntaxError);
  }
});

// ----------------------------------------------------------------------------
// [json use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

Deno.test("codemelted.json Conversion Tests", () => {
  // Test data
  const testObj = {
    field1: "field1",
    field2: 2,
    field3: true,
    field4: [ "1", 2, null, false ],
    field5: null,
  };
  const testArray = ["1", 2, null, false ];
  const testFunc = (a, b) => {};

  // asXXX Validation
  assert(codemelted.asBool({data: "yes"}) === true);
  assert(codemelted.asBool({data: "no"}) === false);
  assert(codemelted.asDouble({data: "6.85"}) === 6.85);
  assert(codemelted.asDouble({data: "-6.85"}) === -6.85);
  assert(codemelted.asDouble({data: "no"}) === null);
  assert(codemelted.asInt({data: "6"}) === 6);
  assert(codemelted.asInt({data: "-6"}) === -6);
  assert(codemelted.asInt({data: "no"}) === null);

  // checkHasProperty Validation
  let success = codemelted.checkHasProperty({
    obj: testObj,
    key: "field6",
  });
  assert(success === false);
  assertThrows(() => codemelted.tryHasProperty({
    obj: testObj,
    key: "field6",
  }));

  success = codemelted.checkHasProperty({
    obj: testObj,
    key: "field5",
  });
  assert(success === true);

  // checkXXXX / tryXXX Validation
  success = codemelted.checkType({type: "object", data: testObj});
  assert(success === true);
  success = codemelted.checkType({type: "string", data: testObj});
  assert(success === false);
  assertThrows(() => codemelted.tryType({type: "string", data: testObj}));

  success = codemelted.checkType({type: Array, data: testArray});
  assert(success === true);
  success = codemelted.checkType({type: "string", data: testArray});
  assert(success === false);
  assertThrows(() => codemelted.tryType({type: "string", data: testArray}));

  success = codemelted.checkType({type: "function", data: testFunc, count: 2});
  assert(success === true);
  success = codemelted.checkType({type: "function", data: testFunc, count: 1});
  assert(success === false);
  assertThrows(() => codemelted.tryType({type: "function", data: testFunc, count: 1}));

  success = codemelted.checkValidUrl({data: "https://codemelted.com"});
  assert(success === true);
  success = codemelted.checkValidUrl({data: ":::: garbage::::"});
  assert(success === false);
  assertThrows(() => codemelted.tryValidUrl({data: ":::: garbage::::"}));

  // createXXXX validation
  let newObj = codemelted.createObject({data: testObj});
  assert(Object.keys(newObj).length > 0);
  newObj = codemelted.createObject({data: 42});
  assert(Object.keys(newObj).length === 0);

  let newArray = codemelted.createArray({data: testArray});
  assert(newArray.length > 0);
  newArray = codemelted.createArray({data: "hello"});
  assert(newArray.length === 0);

  // stringify / parse validation
  let url = new URL("https://codemelted.com");
  let data = codemelted.parseJson({data: url});
  assert(data === null);
  data = codemelted.stringifyJson({data: 9007199254740991n});
  assert(data === null);

  data = codemelted.stringifyJson({data: testObj});
  assert(data != null);
  data = codemelted.parseJson({data: data});
  assert(data != null);

  data = null;
  data = codemelted.stringifyJson({data: testArray});
  assert(data != null);
  data = codemelted.parseJson({data: data});
  assert(data != null);
});