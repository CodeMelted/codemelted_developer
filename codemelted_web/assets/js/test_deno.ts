// @ts-nocheck
// The above is done to ensure type checking works in case person does not use
// good editor for type checking. Remove it while defining tests to ensure type
// checking does in fact work. You will see a bunch of failures with the
// "failure" type checking cases.
// ============================================================================
/**
 * @file Provides the Deno.test of the codemelted.js file.
 * @version 0.1.0
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
import {
  // API_UNSUPPORTED_PLATFORM,
  hw_request_orientation,
  runtime_online,
} from "./codemelted.js";

// ===============================================================================
// [Unsupported Use Cases Throw] =================================================
// ===============================================================================

Deno.test("Unsupported Functions Throw Syntax Error", async () => {
  assertThrows(() => hw_request_orientation(), SyntaxError);
  assertThrows(() => runtime_online(), SyntaxError);
});

// // ----------------------------------------------------------------------------
// // [console use case] ---------------------------------------------------------
// // ----------------------------------------------------------------------------

// Deno.test("codemelted.console Tests", () => {
//   assertExists(codemelted.console);
//   try {
//     codemelted.console.writeln();
//   } catch (err) {
//     fail("Should not throw.")
//   }
// });

// // ----------------------------------------------------------------------------
// // [disk use case] ------------------------------------------------------------
// // ----------------------------------------------------------------------------

// Deno.test("codemelted.disk Properties Test", () => {
//   assertExists(codemelted.disk.homePath);
//   assertExists(codemelted.disk.pathSeparator);
//   assertExists(codemelted.disk.tempPath);
// });

// Deno.test("codemelted.disk Error Check Tests", async () => {
//   assertThrows(() => codemelted.disk.cp({src: 1, dest: 2}), SyntaxError);
//   assertThrows(() => codemelted.disk.cp("test.txt"), SyntaxError);
//   assertThrows(() => codemelted.disk.exists(), SyntaxError);
//   assertThrows(() => codemelted.disk.ls(), SyntaxError);
//   assertThrows(() => codemelted.disk.mkdir(), SyntaxError);
//   assertThrows(() => codemelted.disk.mv(), SyntaxError);
//   assertThrows(() => codemelted.disk.mv("test.txt"), SyntaxError);

//   try {
//     await codemelted.disk.readEntireFile();
//     fail("Should throw");
//   } catch (err) {
//     assert(err instanceof SyntaxError);
//   }

//   try {
//     await codemelted.disk.readEntireFile({filename: "test", isTextFile: 42});
//     fail("Should throw");
//   } catch (err) {
//     assert(err instanceof SyntaxError);
//   }

//   try {
//     await codemelted.disk.writeEntireFile();
//     fail("Should throw");
//   } catch (err) {
//     assert(err instanceof SyntaxError);
//   }

//   try {
//     await codemelted.disk.writeEntireFile({filename: "temp.txt"});
//     fail("Should throw");
//   } catch (err) {
//     assert(err instanceof SyntaxError);
//   }

//   try {
//     await codemelted.disk.writeEntireFile({filename: "temp.txt", data: "data", append: 42});
//     fail("Should throw");
//   } catch (err) {
//     assert(err instanceof SyntaxError);
//   }

//   assertThrows(() => codemelted.disk.rm(), SyntaxError);
// });

// Deno.test("codemelted.disk Manipulation Tests", async () => {
//   // Get the temporary directory and do some cleanup if necessary
//   const tempPath = codemelted.disk.tempPath;
//   assert(tempPath != null);
//   codemelted.disk.rm({filename: `${tempPath}/results`});

//   // First fail to copy and move stuff
//   let success = codemelted.disk.cp({
//     src: "duh.txt",
//     dest: tempPath}
//   );
//   assert(!success);
//   success = codemelted.disk.mv({
//     src: "duh.txt",
//     dest: tempPath
//   });
//   assert(!success);

//   // Now lets go create directories and files
//   success = codemelted.disk.exists({
//     filename: `${tempPath}/results/`
//   });
//   assert(!success);
//   success = codemelted.disk.mkdir({filename: `${tempPath}/results`});
//   assert(success);

//   // Go write some files
//   await codemelted.disk.writeEntireFile({
//     filename: `${tempPath}/results/writeTextFile.txt`,
//     data: "Hello There",
//     append: true,
//   });
//   assert(codemelted.disk.exists({filename: `${tempPath}/results/writeTextFile.txt`}));

//   await codemelted.disk.writeEntireFile({
//     filename: `${tempPath}/results/writeFile.txt`,
//     data: new Uint8Array([42]),
//   });
//   assert(codemelted.disk.exists({filename: `${tempPath}/results/writeFile.txt`}));

//   // Prove the files got written
//   let result = codemelted.disk.ls({filename: `${tempPath}/results/`});
//   assert(result.length === 2);

//   // Prove we can read the files
//   result = await codemelted.disk.readEntireFile({
//     filename: `${tempPath}/results/writeTextFile.txt`
//   });
//   assert(result.includes("Hello There"));
//   result = await codemelted.disk.readEntireFile({
//     filename: `${tempPath}/results/writeFile.txt`,
//     isTextFile: false,
//   });
//   assert(result[0] === 42);

//   // Now some cleanup to remove items.
//   success = codemelted.disk.rm({filename: `${tempPath}/results`});
//   assert(success);
// });

// // ----------------------------------------------------------------------------
// // [json use case] ------------------------------------------------------------
// // ----------------------------------------------------------------------------

// Deno.test("codemelted.json API Violations", () => {
//   // Functions that throw if you completely ignore thigns.
//   assertThrows(() => codemelted.json.checkHasProperty(), SyntaxError);
//   assertThrows(() => codemelted.json.checkType(), SyntaxError);
// });

// Deno.test("codemelted.json Conversion Tests", () => {
//   // Test data
//   const testObj = {
//     field1: "field1",
//     field2: 2,
//     field3: true,
//     field4: [ "1", 2, null, false ],
//     field5: null,
//   };
//   const testArray = ["1", 2, null, false ];
//   const testFunc = (a, b) => {};

//   // asXXX Validation
//   assert(codemelted.json.asBool({data: "yes"}) === true);
//   assert(codemelted.json.asBool({data: "no"}) === false);
//   assert(codemelted.json.asDouble({data: "6.85"}) === 6.85);
//   assert(codemelted.json.asDouble({data: "-6.85"}) === -6.85);
//   assert(codemelted.json.asDouble({data: "no"}) === null);
//   assert(codemelted.json.asInt({data: "6"}) === 6);
//   assert(codemelted.json.asInt({data: "-6"}) === -6);
//   assert(codemelted.json.asInt({data: "no"}) === null);

//   // checkHasProperty Validation
//   let success = codemelted.json.checkHasProperty({
//     obj: testObj,
//     key: "field6",
//   });
//   assert(success === false);
//   assertThrows(() => codemelted.json.tryHasProperty({
//     obj: testObj,
//     key: "field6",
//   }));

//   success = codemelted.json.checkHasProperty({
//     obj: testObj,
//     key: "field5",
//   });
//   assert(success === true);

//   // checkXXXX / tryXXX Validation
//   success = codemelted.json.checkType({type: "object", data: testObj});
//   assert(success === true);
//   success = codemelted.json.checkType({type: "string", data: testObj});
//   assert(success === false);
//   assertThrows(() => codemelted.json.tryType({type: "string", data: testObj}));

//   success = codemelted.json.checkType({type: Array, data: testArray});
//   assert(success === true);
//   success = codemelted.json.checkType({type: "string", data: testArray});
//   assert(success === false);
//   assertThrows(() => codemelted.json.tryType({type: "string", data: testArray}));

//   success = codemelted.json.checkType({type: "function", data: testFunc, count: 2});
//   assert(success === true);
//   success = codemelted.json.checkType({type: "function", data: testFunc, count: 1});
//   assert(success === false);
//   assertThrows(() => codemelted.json.tryType({type: "function", data: testFunc, count: 1}));

//   success = codemelted.json.checkValidUrl({data: "https://codemelted.com"});
//   assert(success === true);
//   success = codemelted.json.checkValidUrl({data: ":::: garbage::::"});
//   assert(success === false);
//   assertThrows(() => codemelted.json.tryValidUrl({data: ":::: garbage::::"}));

//   // createXXXX validation
//   let newObj = codemelted.json.createObject({data: testObj});
//   assert(Object.keys(newObj).length > 0);
//   newObj = codemelted.json.createObject({data: 42});
//   assert(Object.keys(newObj).length === 0);

//   let newArray = codemelted.json.createArray({data: testArray});
//   assert(newArray.length > 0);
//   newArray = codemelted.json.createArray({data: "hello"});
//   assert(newArray.length === 0);

//   // stringify / parse validation
//   let url = new URL("https://codemelted.com");
//   let data = codemelted.json.parse({data: url});
//   assert(data === null);
//   data = codemelted.json.stringify({data: 9007199254740991n});
//   assert(data === null);

//   data = codemelted.json.stringify({data: testObj});
//   assert(data != null);
//   data = codemelted.json.parse({data: data});
//   assert(data != null);

//   data = null;
//   data = codemelted.json.stringify({data: testArray});
//   assert(data != null);
//   data = codemelted.json.parse({data: data});
//   assert(data != null);
// });