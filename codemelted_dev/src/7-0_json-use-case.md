# 7.0 JSON Use Case

According to Wikipedia,
> "JSON (JavaScript Object Notation) is an open standard file format and data interchange format that uses human-readable text to store and transmit data objects consisting of name–value pairs and arrays (or other serializable values). It is a commonly used data format with diverse uses in electronic data interchange, including that of web applications with servers. JSON is a language-independent data format. It was derived from JavaScript, but many modern programming languages include code to generate and parse JSON-format data. JSON filenames use the extension .json.

For the purposes of the CodeMelted Dev project, the *JSON Use Case* will provide the functions necessary to facilitate working with the JSON format. This includes data validation, translating between supported data types, creating the SDK language JSON compliant format, parsing of strings to JSON, and stringifying the JSON object to a serialized JSON string.

## 7.1 Acceptance Criteria

1. The *JSON Use Case* will support the translation of Strings to the appropriate JSON data types. Failure to perform such a translation will result in a NULL (whatever that means in the given SDK language).
2. The *JSON Use Case* will support the checking of variable data types to ensure that dynamic type data is as expected. This will support Boolean true / false returns along with the ability to throw an exception.
3. The *JSON Use Case* will support the creation on JSON compliant arrays and objects to support later JSON stringifying.
4. The *JSON Use Case* will support the ability to check a JSON object containing expected keys. This will support Boolean true / false returns along with the ability to throw an exception.
5. The *JSON Use Case* will support the parsing of a JSON string into a JSON compliant object. Failure to perform the parse will result in a NULL (whatever that means in the given SDK language).
6. The *JSON Use Case* will support the stringifying of a JSON compliant object to produce a JSON serialized string. Failure to perform the parse will result in a NULL (whatever that means in the given SDK language).
7. The *JSON Use Case* will support the validation of URL strings. This will support Boolean true / false returns along with the ability to throw an exception.

## 7.2 SDK Notes

None.
