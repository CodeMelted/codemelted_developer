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
import codemelted from "./codemelted.js";

// ----------------------------------------------------------------------------
// [async use case] -----------------------------------------------------------
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// [audio use case] -----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [console use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

Deno.test("codemelted.console Tests", () => {
  assertExists(codemelted.console);
  try {
    codemelted.console.writeln();
  } catch (err) {
    fail("Should not throw.")
  }
});

// ----------------------------------------------------------------------------
// [database use case] --------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [disk use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

Deno.test("codemelted.disk Properties Test", () => {
  assertExists(codemelted.disk.homePath);
  assertExists(codemelted.disk.pathSeparator);
  assertExists(codemelted.disk.tempPath);
});

Deno.test("codemelted.disk Error Check Tests", async () => {
  assertThrows(() => codemelted.disk.cp(), SyntaxError);
  assertThrows(() => codemelted.disk.cp("test.txt"), SyntaxError);
  assertThrows(() => codemelted.disk.exists(), SyntaxError);
  assertThrows(() => codemelted.disk.ls(), SyntaxError);
  assertThrows(() => codemelted.disk.mkdir(), SyntaxError);
  assertThrows(() => codemelted.disk.mv(), SyntaxError);
  assertThrows(() => codemelted.disk.mv("test.txt"), SyntaxError);

  try {
    await codemelted.disk.readEntireFile();
    fail("Should throw");
  } catch (err) {
    assert(err instanceof SyntaxError);
  }

  try {
    await codemelted.disk.readEntireFile({filename: "test", isTextFile: 42});
    fail("Should throw");
  } catch (err) {
    assert(err instanceof SyntaxError);
  }

  try {
    await codemelted.disk.writeEntireFile();
    fail("Should throw");
  } catch (err) {
    assert(err instanceof SyntaxError);
  }

  try {
    await codemelted.disk.writeEntireFile({filename: "temp.txt"});
    fail("Should throw");
  } catch (err) {
    assert(err instanceof SyntaxError);
  }

  try {
    await codemelted.disk.writeEntireFile({filename: "temp.txt", data: "data", append: 42});
    fail("Should throw");
  } catch (err) {
    assert(err instanceof SyntaxError);
  }

  assertThrows(() => codemelted.disk.rm(), SyntaxError);
});

Deno.test("codemelted.disk Manipulation Tests", async () => {
  // Get the temporary directory and do some cleanup if necessary
  const tempPath = codemelted.disk.tempPath;
  assert(tempPath != null);
  codemelted.disk.rm(`${tempPath}/results`);

  // First fail to copy and move stuff
  let success = codemelted.disk.cp("duh.txt", tempPath);
  assert(!success);
  success = codemelted.disk.mv("duh.txt", tempPath);
  assert(!success);

  // Now lets go create directories and files
  success = codemelted.disk.exists(`${tempPath}/results/`);
  assert(!success);
  success = codemelted.disk.mkdir(`${tempPath}/results`);
  assert(success);

  // Go write some files
  await codemelted.disk.writeEntireFile({
    filename: `${tempPath}/results/writeTextFile.txt`,
    data: "Hello There",
    append: true,
  });
  assert(codemelted.disk.exists(`${tempPath}/results/writeTextFile.txt`));

  await codemelted.disk.writeEntireFile({
    filename: `${tempPath}/results/writeFile.txt`,
    data: new Uint8Array([42]),
  });
  assert(codemelted.disk.exists(`${tempPath}/results/writeFile.txt`));

  // Prove the files got written
  let result = codemelted.disk.ls(`${tempPath}/results/`);
  assert(result.length === 2);

  // Prove we can read the files
  result = await codemelted.disk.readEntireFile({
    filename: `${tempPath}/results/writeTextFile.txt`
  });
  assert(result.includes("Hello There"));
  result = await codemelted.disk.readEntireFile({
    filename: `${tempPath}/results/writeFile.txt`,
    isTextFile: false,
  });
  assert(result[0] === 42);

  // Now some cleanup to remove items.
  success = codemelted.disk.rm(`${tempPath}/results`);
  assert(success);
});

// ----------------------------------------------------------------------------
// [firebase use case] --------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [game use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [hardware use case] --------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [json use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [logger use case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [math use case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [network use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [runtime use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [storage use case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [ui use case] --------------------------------------------------------------
// ----------------------------------------------------------------------------