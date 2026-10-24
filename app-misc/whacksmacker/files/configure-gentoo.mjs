import {readFile,writeFile,rm} from 'node:fs/promises';
const geo=process.env.WSM_SELECTED_GEO==='yes';
const langs=process.env.WSM_SELECTED_STUDY?.split(' ').filter(Boolean)??[];
const map={ar:'arabic',nl:'dutch',en:'english',fr:'french',de:'german',hi:'hindi',ja:'japanese',ko:'korean',ru:'russian',es:'spanish',th:'thai',vi:'vietnamese',zu:'zulu',lzh:'chinese-classical',zh_CN:'chinese-simplified',zh_TW:'chinese-traditional',grc:'classical-greek',la:'latin'};
for(const l of langs)if(!map[l])throw Error(`Unknown study language ${l}`);
const ids=langs.map(l=>'com.sleepymario.language.'+map[l]);
if(langs.includes('zh_CN')&&langs.includes('zh_TW'))ids.push('com.sleepymario.language.chinese-simplified-traditional');
const p='packages/core/modules.ts';let s=await readFile(p,'utf8');
s=s.replace('export function getBuiltInFirstClassModules(): readonly FirstClassModuleDescriptor[] {','function getAllBuiltInFirstClassModules(): readonly FirstClassModuleDescriptor[] {');
s+=`\nexport function getBuiltInFirstClassModules(): readonly FirstClassModuleDescriptor[] {\n const selected = new Set<string>(${JSON.stringify(ids)});\n return getAllBuiltInFirstClassModules().filter(m => (m.category !== "Languages" || selected.has(m.moduleId)) && (${geo} || m.category !== "Geography"));\n}\n`;
await writeFile(p,s);
const zh=process.env.WSM_SELECTED_ZH==='yes';
if(!zh){
 const p='src/i18n/index.ts';let s=await readFile(p,'utf8');s=s.replace('import zhHantTW from "./locales/zh-Hant-TW.json";','const zhHantTW = enUS;');s=s.replace('sourceLocales.includes(value as SourceLocale)','value === "en-US"');await writeFile(p,s);
 const menu='apps/cli/interactive-menu.ts';s=await readFile(menu,'utf8');s=s.replace('return locale === "zh-Hant-TW" ? "en-US" : "zh-Hant-TW";','return "en-US";');await writeFile(menu,s);
 await rm('src/i18n/locales/zh-Hant-TW.json');
}
await writeFile('gentoo-build-options.json',JSON.stringify({release:'0.1.0-alpha.4',interfaceLocales:zh?['en-US','zh-Hant-TW']:['en-US'],studyLanguages:langs,moduleIds:ids,geography:geo,privateContent:false},null,2)+'\n');
