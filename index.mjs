#!/usr/bin/env node

/* eslint-env node */

import { readFile } from 'node:fs/promises';
import { createInterface } from 'node:readline';
import chalk from 'chalk';

const getInput = (prompt) => new Promise((resolve) => {
    const rl = createInterface({
        input: process.stdin,
        output: process.stdout
    });
    rl.question(prompt, (out) => {
        rl.close();
        resolve(out);
    });
});

const charCodeToChar = (charCode) => String.fromCharCode(charCode);

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
} else if (wasmFile === 'NumberString.wasm') {
    {
        const memory = new WebAssembly.Memory ({ initial: 1 });

        const importObject = {
            env: {
                buffer: memory,
                PrintString: (startStrIdx, strLen) => {
                    const bytes = new Uint8Array(memory.buffer, startStrIdx, strLen);
                    const strToLog = new TextDecoder('utf8').decode(bytes);
                    console.log(strToLog);
                }
            }
        };

        const watBuf = await readFile('NumberString.wasm');
        const obj = await WebAssembly.instantiate(watBuf, importObject);

        const { to_string } =  obj.instance.exports;
        const n = parseInt(args[0], 10);
        if (isNaN(n)) {
            throw new Error('needs 1 integer number passed in as a cli argument!');
        }
        to_string(n);
    }
} else if (wasmFile === 'TicTacToe.wasm') {
    {
        const memory = new WebAssembly.Memory ({ initial: 1 });

        const importObject = {
            env: {
                buffer: memory,
                PrintChar: (charCode) => {
                    console.log(String.fromCharCode(charCode));
                },
                PrintString3x3: (startStrIdx, strLen) => {
                    const bytes = new Uint8Array(memory.buffer, startStrIdx, strLen);
                    const strToLog = new TextDecoder('utf8').decode(bytes);
                    const lines = strToLog.split('').reduce((prev, curr, i) => {
                        let line;
                        if (i % 3 === 0) {
                            line = [];
                            prev.push(line);
                        }
                        else {
                            line = prev[prev.length - 1];
                        }
                        line.push(curr);
                        return prev;
                    }, []);
                    console.log(lines.map(line => line.join('')).join('\n'));
                }
            }
        };

        const watBuf = await readFile('TicTacToe.wasm');
        const obj = await WebAssembly.instantiate(watBuf, importObject);

        const {
            setCharAt, isValidSet, printBoard, hasWon, isBoardFull, nextCharToPlay, getMoveNumber,
        } =  obj.instance.exports;
        
        while (true) {
            const currChar = nextCharToPlay();
            const moveNr = getMoveNumber();

            console.log(`\nmove #${moveNr}`);

            console.log('\nboard:');
            printBoard();

            console.log(`\nnext to play: ${charCodeToChar(currChar)}`);

            let x, y;
            while (true) {
                x = parseInt(await getInput('x: '), 10);
                y = parseInt(await getInput('y: '), 10);
                console.log(x, y);

                if (isValidSet(x, y, currChar)) break;
                console.warn('incorrect move!');
            }
            
            setCharAt(x, y, currChar);

            if (hasWon(currChar)) {
                console.log(`${charCodeToChar(currChar)} has won!`);
                break;
            }

            if (isBoardFull()) {
                console.log(`Game was tied!`);
                break;
            }
        }
    }
} else if (wasmFile === 'StoreData.wasm') {
    {
        const mem = new WebAssembly.Memory ({ initial: 1 });

        const data_addr = 32; // the address of the first byte of our data        
        const data_count = 16; // the number of 32-bit integers to set

        const importObject = {
            env: {
                mem,
                data_addr,
                data_count,
            }
        };

        const mem_i32 = new Uint32Array(mem.buffer);
        const data_i32_index = data_addr / 4; // The 32-bit index of the beginning of our data

        const watBuf = await readFile('StoreData.wasm');
        await WebAssembly.instantiate(watBuf, importObject);

        for (let i = 0; i < data_i32_index + data_count + 4; ++i) {
            let data = mem_i32[i];
            if (data !== 0) {
                console.log(chalk.red(`data[${i}]=${data}`));
            } else {
                console.log(`data[${i}]=${data}`);
            }
        }
    }
} else if (wasmFile === 'DataStructures.wasm') {
    {
        const mem = new WebAssembly.Memory ({ initial: 1 });
        const mem_i32 = new Uint32Array(mem.buffer);

        const obj_base_addr = 0; // the address of the first byte of our data
        const obj_count = 32; // the number of structures
        const obj_stride = 16; // 16-byte stride
     
        // structure attribute offsets
        const x_offset = 0;
        const y_offset = 4;
        const radius_offset = 8;
        const collision_offset = 12;
        
        // 32-bit integer indexes
        const obj_i32_base_index = obj_base_addr / 4; // 32-bit data index
        const obj_i32_stride = obj_stride / 4; // 32-bit stride

        // offsets in the 32-bit integer array
        const x_offset_i32 = x_offset / 4;
        const y_offset_i32 = y_offset / 4;
        const radius_offset_i32 = radius_offset / 4;
        const collision_offset_i32 = collision_offset / 4;

        const importObject = {
            env: {
                mem,
                obj_base_addr,
                obj_count,
                obj_stride,
                x_offset,
                y_offset,
                radius_offset,
                collision_offset,
            }
        };

        // populate structures
        for (let i = 0; i < obj_count; ++i) {
            const index = obj_i32_stride * i + obj_i32_base_index;
            const x = Math.floor( Math.random() * 100 );
            const y = Math.floor( Math.random() * 100 );
            const r = Math.ceil( Math.random() * 10 );
            mem_i32[index + x_offset_i32] = x; 
            mem_i32[index + y_offset_i32] = y;
            mem_i32[index + radius_offset_i32] = r;
        }

        // run collision detection in wasm...
        const watBuf = await readFile('DataStructures.wasm');
        await WebAssembly.instantiate(watBuf, importObject);

        // print results
        for (let i = 0; i < obj_count; ++i) {
            const index = obj_i32_stride * i + obj_i32_base_index;
            const x = mem_i32[index + x_offset_i32].toString().padStart(2, ' ');
            const y = mem_i32[index + y_offset_i32].toString().padStart(2, ' ');
            const r = mem_i32[index + radius_offset_i32].toString().padStart(2,' ');
            const i_str = i.toString().padStart(2, '0');
            const c = !!mem_i32[index + collision_offset_i32];

            if (c) console.log(chalk.red(`obj[${i_str}] x=${x} y=${y} r=${r} collision=${c}`));
            else console.log(chalk.green(`obj[${i_str}] x=${x} y=${y} r=${r} collision=${c}`));
        }
    }
} else {
    console.log('expects the wasm file to be provided, followed by the arguments to pass to it');
}
