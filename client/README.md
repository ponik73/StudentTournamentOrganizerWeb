# Študentské turnaje

Program nie je nutné inštalovať lokálne, je dostupný na [webovej adrese](https://www.stud.fit.vutbr.cz/~xdzuri00/).

Backend programu je nasadený na školskom servere eva. Jedná sa o MySQL databázu a PHP API.

## Lokálne spustenie

Pre lokálne spustenie programu zo zdrojových kódov je potrebná inštalácia programu na beh frontendu **NodeJS**. Je potrebný NodeJS(verzia 8.19.2 a vyššia), framework **Vue** externé knižnice.

Externé knižnice: 

    @element-plus/icons-vue@2.0.10
    @vitejs/plugin-vue@3.1.2
    class-transformer@0.5.1
    chart.js@^3.9.1
    element-plus@2.2.21
    reflect-metadata@0.1.13
    vite@3.1.8
    vue-axios@3.5.0
    vue-router@4.1.6
    vue@3.2.41
    @element-plus/icons-vue@2.0.10

inštalácia Vue:
```
npm install vue@latest
```

inštalácia knižníc:
```
npm install <lib>
```
Po inštalácii externých knižníc je frontend programu spustiteľný z koreňového adresára *studentskeTurnaje* príkazmi npm.

spustenie:
```
npm run dev
```