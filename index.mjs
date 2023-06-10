#!/usr/bin/env node

/* eslint-env node */

import { readFile } from 'node:fs/promises';

// gets args via cli arguments
const [_, __, ...args] = process.argv;



/* const watBuf = await readFile('AddInt.wasm');
const obj = await WebAssembly.instantiate(watBuf);

const [a, b] = args.map(s => parseInt(s, 10));
if (isNaN(a) || isNaN(b)) {
    console.log('needs 2 integer numbers passed in as cli arguments!');
    process.exit(1);
}
console.log('args:', [a, b]);
const { AddInt } =  obj.instance.exports;
const c = AddInt(a, b);
console.log('result:', c); */



/* const memory = new WebAssembly.Memory ({ initial: 1 });

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
HelloWorld(); */



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
