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
        const [n] = args.map(s => parseInt(s, 10));
        if (isNaN(n)) {
            throw new Error('needs 1 integer number passed in as a cli argument!');
        }
        // const isEven = Boolean( EvenCheck(n) ); console.log('is even?', isEven);
        // const eq2 = Boolean( Eq2(n) ); console.log('is 2?', eq2);
        // const mc = Boolean( MultipleCheck(n, m) ); console.log(n, m, 'is multiple?', mc);
        const isP = Boolean( IsPrime(n) ); console.log(n, 'is prime?', isP);
    }
} else {
    console.log('expects the wasm file to be provided, followed by the arguments to pass to it');
}
