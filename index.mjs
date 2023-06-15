#!/usr/bin/env node

/* eslint-env node */

import { readFile } from 'node:fs/promises';

// gets args via cli arguments
const [_, __, ...args] = process.argv;

const wasmFile = args.shift();

console.log(`wasmFile file: ${wasmFile}`);
console.log('args:', args);

if (wasmFile === 'AddInt.wasm') {
    {
        const watBuf = await readFile('AddInt.wasm');
        const obj = await WebAssembly.instantiate(watBuf);

        const [a, b] = args.map(s => parseInt(s, 10));
        if (isNaN(a) || isNaN(b)) {
            console.log('needs 2 integer numbers passed in as cli arguments!');
            process.exit(1);
        }
        const { AddInt } =  obj.instance.exports;
        const c = AddInt(a, b);
        console.log('result:', c);
    }
} else if (wasmFile === 'HelloWorld.wasm') {
    {
        const memory = new WebAssembly.Memory ({ initial: 1 });

        const importObject = {
            env: {
                buffer: memory,
                startStringIndex: 100,
                PrintString: (startStrIdx, strLen) => {
                    const bytes = new Uint8Array(memory.buffer, startStrIdx, strLen);
                    const strToLog = new TextDecoder('utf8').decode(bytes);
                    console.log(strToLog);
                }
            }
        };

        const watBuf = await readFile('HelloWorld.wasm');
        const obj = await WebAssembly.instantiate(watBuf, importObject)

        const { HelloWorld } = obj.instance.exports;
        HelloWorld();
    }
} else if (wasmFile === 'ForLoop.wasm') {
    {
        const importObject = {
            env: {
                PrintI32: (numI32) => {
                    console.log(numI32);
                }
            }
        };
        
        const watBuf = await readFile('ForLoop.wasm');
        const obj = await WebAssembly.instantiate(watBuf, importObject);
        
        const { ForLoop } =  obj.instance.exports;
        const [startNum, endNum] = args.map(s => parseInt(s, 10));
        if (isNaN(startNum) || isNaN(endNum)) {
            console.log('needs 2 integer numbers passed in as cli arguments!');
            process.exit(1);
        }
        ForLoop(startNum, endNum);
    }
} else if (wasmFile === 'Prime.wasm') {
    {
        const watBuf = await readFile('Prime.wasm');
        const obj = await WebAssembly.instantiate(watBuf);

        const { IsPrime } =  obj.instance.exports;
        const n = parseInt(args[0], 10);
        if (isNaN(n)) {
            throw new Error('needs 1 integer number passed in as a cli argument!');
        }
        // const isEven = Boolean( EvenCheck(n) ); console.log('is even?', isEven);
        // const mc = Boolean( MultipleCheck(n, m) ); console.log(n, m, 'is multiple?', mc);
        console.time('Prime.wasm');
        const isP = Boolean( IsPrime(n) ); console.log(n, 'is prime?', isP);
        console.timeEnd('Prime.wasm');
    }
} else if (wasmFile === 'Prime.mjs') {
    {
        const mod = await import('./Prime.mjs');
        const { Prime } = mod;
        const n = parseInt(args[0], 10);
        console.time('Prime.mjs');
        const isP = Prime(n); console.log(n, 'is prime?', isP);
        console.timeEnd('Prime.mjs');
    }
} else if (wasmFile === 'TableTest.wasm') {
    {
        let i;
        const increment = () => ++i;
        const decrement = () => --i;

        const importObject = {
            js: {
                increment,
                decrement,
                tbl: undefined, // set by TableExport.wasm
                wasm_increment: undefined, // set by TableExport.wasm
                wasm_decrement: undefined // set by TableExport.wasm
            }
        };
        
        const watBufExport = await readFile('TableExport.wasm');
        const objExport = await WebAssembly.instantiate(watBufExport, importObject);

        importObject.js.tbl = objExport.instance.exports.tbl;
        importObject.js.wasm_increment = objExport.instance.exports.increment;
        importObject.js.wasm_decrement = objExport.instance.exports.decrement;

        const watBufTest = await readFile('TableTest.wasm');
        const objTest = await WebAssembly.instantiate(watBufTest, importObject);

        const { js_table_test, js_import_test,
            wasm_table_test, wasm_import_test } =  objTest.instance.exports;
        
        i = 0;
        console.time('js_table');
        js_table_test();
        console.timeEnd('js_table');

        i = 0;
        console.time('js_import');
        js_import_test();
        console.timeEnd('js_import');

        i = 0;
        console.time('wasm_table');
        wasm_table_test();
        console.timeEnd('wasm_table');

        i = 0;
        console.time('wasm_import');
        wasm_import_test();
        console.timeEnd('wasm_import');
    }
} else if (wasmFile === 'BigIntI64.wasm') {
    {
        const watBuf = await readFile('BigIntI64.wasm');
        const obj = await WebAssembly.instantiate(watBuf);

        const [a, b] = args.map(s => BigInt(s));
        const { AddBigInts } =  obj.instance.exports;
        const c = AddBigInts(a, b);
        console.log('result:', c);
    }
} else if (wasmFile === 'Strings.wasm') {
    {
        const memory = new WebAssembly.Memory ({ initial: 1 });

        const importObject = {
            env: {
                buffer: memory,
                str_pos_len: (startStrIdx, strLen) => {
                    const bytes = new Uint8Array(memory.buffer, startStrIdx, strLen);
                    const strToLog = new TextDecoder('utf8').decode(bytes);
                    console.log(`[${strToLog}]`);
                },
                str_pos_len_prefixed: (startStrIdx) => {
                    const strLen = new Uint8Array(memory.buffer, startStrIdx, 1)[0];
                    const bytes = new Uint8Array(memory.buffer, startStrIdx+1, strLen);
                    const strToLog = new TextDecoder('utf8').decode(bytes);
                    console.log(`[${strToLog}]`);
                }
            }
        };

        const watBuf = await readFile('Strings.wasm');
        const obj = await WebAssembly.instantiate(watBuf, importObject);

        const { main } =  obj.instance.exports;
        main();

        const bytes = new Uint8Array( memory.buffer );

        const char = (bytes, idx) => String.fromCharCode(bytes[idx]);
        const chars = (bytes, idx, len) => Array.from( bytes.slice(idx, idx + len) )
        .map(u8 => u8 ? String.fromCharCode(u8) : '◆') // to make char 0 visible
        .join('');

        console.log('bytes', bytes);

        console.log(char(bytes, 0));
        console.log(chars(bytes, 0, 30)); // 1st string

        console.log(chars(bytes, 32, 35)); // 2nd string

        console.log(chars(bytes, 0, 70)); // we can also see 2 0ed bytes between the strings and after the 2nd one ends

        const readNullTerminatedString = (bytes, idx) => {
            let s = '';
            while (true) {
                const u8 = bytes[idx];
                if (u8 === 0) return s;
                const utf8Char = String.fromCharCode(u8);
                s += utf8Char;
                ++idx;
            }
        }

        console.log(readNullTerminatedString(bytes, 0)); // 1st string
        console.log(readNullTerminatedString(bytes, 32)); // 2nd string
    }
} else {
    console.log('expects the wasm file to be provided, followed by the arguments to pass to it');
}
