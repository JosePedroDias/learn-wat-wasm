# learn WAT WASM

All WAT code so far is either copied from the book or heavily inspired by it.
Wasm-loading code was updated to latest node.js and browser APIs.

To generate WASM files out of WAT, do `npm install && npm build`.

Run it in node.js with `index.mjs` or in the browser by serving a web page from `index.html`.


## examples

- AddInt - sums two 32-bit numbers
- HelloWorld - sets a string into a memory buffer and calls a JS function to print the string via console.log


## reference

- https://developer.mozilla.org/en-US/docs/WebAssembly/Concepts
- https://developer.mozilla.org/en-US/docs/WebAssembly/Loading_and_running
- https://webassembly.github.io/spec/core/text/index.html
- https://wasmbook.com/


## alternatives

- https://www.assemblyscript.org/


## tools

- https://www.npmjs.com/package/wat-wasm
- https://marketplace.visualstudio.com/items?itemName=dtsvet.vscode-wasm


## examples

- https://github.com/binji/raw-wasm/tree/main


## wasm runners

- https://wasmer.io/ , https://wapm.io/  
- https://wasmtime.dev/


## misc notes

basic types: i32, i64, f32, f64

memory allocated in pages. 1 page = 64KB

i64 needs string parsing on wasm side or
[bigint](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt)
and [experimental wasm bigint](https://sauleau.com/notes/wasm-bigint.html)

comes without any string abstraction
