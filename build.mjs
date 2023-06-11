#!/usr/bin/env node

/* eslint-env node */

import { readdir } from "node:fs/promises";
import { exec as exec_ } from "node:child_process";

const LOG_WAT_FILE_NAME = true;
// const COMMAND = `npx wat-wasm {WAT}`;
const COMMAND = `wabt/build/wat2wasm --debug-names {WAT}`;

export const exec = (cmd, opts = {}) =>
  new Promise((resolve, reject) => {
    if (!opts.cwd) opts.cwd = process.cwd();

    exec_(cmd, opts, (err, stdout, _stderr) => {
      if (err && !opts.ignoreExitCode) return reject(err);
      resolve(stdout);
    });
  });

const [_, __, ...args] = process.argv;

const watFileArg = args[0];

const watFiles = watFileArg ? [watFileArg] : (await readdir('.')).filter(s => s.includes('.wat'));

for (let wat of watFiles) {
    if (LOG_WAT_FILE_NAME) console.log(`** ${wat} **`);
    const out = (await exec(COMMAND.replace('{WAT}', wat)));
    if (out.trim()) console.log(out);
}
