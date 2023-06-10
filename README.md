# learn WAT WASM

All WAT code so far is either copied from the book or heavily inspired by it.
Wasm-loading code was updated to latest node.js and browser APIs.

To generate WASM files out of WAT, do `npm install && npm build`.

Run it in node.js with `index.mjs` or in the browser by serving a web page from `index.html`.


## examples

- AddInt (p.28, p.32) - sums two 32-bit numbers
- HelloWorld (p.44) - sets a string into a memory buffer and calls a JS function to print the string via console.log
- ForLoop (original code) - does a loop between start and end, logging numbers in between


## reference

- https://webassembly.github.io/spec/core/
- https://developer.mozilla.org/en-US/docs/WebAssembly/Concepts
- https://developer.mozilla.org/en-US/docs/WebAssembly/Loading_and_running
- https://developer.mozilla.org/en-US/docs/WebAssembly/Understanding_the_text_format
- https://webassembly.github.io/spec/core/text/index.html
- https://wasmbook.com/ https://github.com/battlelinegames/ArtOfWasm
- [wasi in nodejs](https://nodejs.org/api/wasi.html)


## alternatives

- https://www.assemblyscript.org/


## tools

- https://www.npmjs.com/package/wat-wasm https://wasmbook.com/wat-wasm.html
- https://marketplace.visualstudio.com/items?itemName=dtsvet.vscode-wasm


## examples

- https://github.com/binji/raw-wasm/tree/main


## wasm runners

- https://wasmer.io/ , https://wapm.io/  
- https://wasmtime.dev/


## misc notes

### types

basic types: i32, i64, f32, f64

https://developer.mozilla.org/en-US/docs/WebAssembly/Understanding_the_text_format#types

and numeric instructions https://webassembly.github.io/spec/core/text/instructions.html#numeric-instructions


### type conversions

64-bit float to a 32-bit integer

`i32.trunc_s/f64`,
`i32.trunc_u/f64`


32-bit float to a 32-bit integer

`i32.trunc_s/f32`,  
`i32.trunc_u/f32`,  
`i32.reinterpret/f32`


64-bit integer to a 32-bit integer

`i32.wrap/i64`


64-bit float to a 64-bit integer

`i64.trunc_s/f64`,  
`i64.trunc_u/f64`,  
`i64.reinterpret/f64`


32-bit integer to a 64-bit integer

`i64.extend_s/i32`,  
`i64.extend_u/i32`


64-bit float to a 32-bit float

`f32.demote/f64`


32-bit integer to a 32-bit float

`f32.convert_s/i32`,  
`f32.convert_u/i32`,  
`f32.reinterpret/i32`


64-bit integer to a 32-bit float

`f32.convert_s/i64`,  
`f32.convert_u/i64`


32-bit float to a 64-bit float

`f64.promote/f32`


32-bit integer to a 64-bit float

`f64.convert_s/i32`,  
`f64.convert_u/i32`


64-bit integer to a 64-bit float

`f64.convert_s/i64`,  
`f64.convert_u/i64`,  
`f64.reinterpret/i64`


### memory allocation

memory allocated in pages. 1 page = 64KB

### strings

i64 needs string parsing on wasm side or
[bigint](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt)
and [experimental wasm bigint](https://sauleau.com/notes/wasm-bigint.html)

comes without any string abstraction

### s-expressions to unpacked WAT

```clojure
(i32.mul ;; executes 7th (last)
    (i32.add ;; executes 3rd
        (i32.const 3) ;; executes 1st
        (i32.const 2) ;; executes 2nd
    )
    (i32. sub ;; executes 6th
        (i32.const 9) ;; executes 4th
        (132.const 7) ;; executes 5th
    )
)
```

```clojure
i32.const 3 ;; Stack = [3]
i32.const 2 ;; Stack = [2, 3]
i32.add ;; 2 & 3 popped from stack, added sum of 5 pushed onto stack [5]

i32.const 9 ;; Stack = [9, 5]
i32.const 7 ;; Stack = [7, 9, 5]
i32.sub ;; 7 & 9 popped off stack. 9-7=2 pushed on stack [2, 5]

i32.mul ;; 2,5 popped off stack, 2×5=10 is pushed on the stack [10]
```


### conditionals

There are no booleans in WASM. If expects an i32 any value other than 0 is considered true.

```clojure
;; This code is for demonstration and not part of a larger app
(if (local.get $bool_i32)
    (then
        <STUFF GOES HERE> ;; executes if i32 is not 0
    )
    (else
        <STUFF GOES HERE> ;; executes if i32 is 0
    )
)
```

```clojure
local.get $bool_i32
if
    <STUFF GOES HERE> ;; executes if i32 is not 0
else
    <STUFF GOES HERE> ;; executes if i32 is 0
end
```


### loops and blocks

```clojure
(block $block_name
    ...
    br $block_name
    ;; all subsequent lines of the block will be skipped
)

(block $block_name2
    ...
    local.get $should_i_branch
    br_if $block_name2
    ;; all subsequent lines of the block will be skipped if $should_i_branch is not 0
)
```

Loops work like blocks but branching takes you back to the beginning of the block, not the end.

```clojure
(loop $block_name
    ...
    br $block_name ;; infinite loop
)
```

If we want a loop not to be infinite, we have to place its branching logic inside a block living inside the loop.


There's also `br_table` but it has an ugly syntax and only pays off above ~~ 12 branches.
https://musteresel.github.io/posts/2020/01/webassembly-text-br_table-example.html
