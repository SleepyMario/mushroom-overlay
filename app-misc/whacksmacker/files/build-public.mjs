import {mkdir,cp,writeFile,chmod,readFile} from 'node:fs/promises';
await mkdir('dist',{recursive:true});
await writeFile('dist/main.js','#!/usr/bin/env node\nrequire("./apps/cli/main").main();\n');
await chmod('dist/main.js',0o755);
await cp('apps/web/public','dist/apps/web/public',{recursive:true});
const options=JSON.parse(await readFile('gentoo-build-options.json','utf8'));
if(options.geography) await cp('packages/geography/data','dist/packages/geography/data',{recursive:true});
await cp('gentoo-build-options.json','dist/gentoo-build-options.json');
