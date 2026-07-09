# Idea hry

## Název
**Tower Defense** (pracovní název)

## Žánr
Strategická hra – *tower defense* (obrana věžemi), 2D, pohled shora.

## Koncept (jednou větou)
Braň svou základnu tím, že za zlato stavíš věže podél cesty a likviduješ
postupující vlny nepřátel dřív, než ti proberou všechny životy.

## Cílový hráč
Hráč, který má rád strategii a plánování. Hra je jednoduchá na ovládání
(myš), ale nutí přemýšlet, kam a kdy věže postavit a jak hospodařit se zlatem.

## Hlavní mechaniky
- **Stavba věží** – hráč kliknutím staví věže na volná místa mimo cestu.
- **Zaměřování a střelba** – věž automaticky střílí na nejbližšího nepřítele
  ve svém dosahu.
- **Ekonomika** – za každého zabitého nepřítele hráč dostane zlato, za které
  staví další věže.
- **Vlny nepřátel** – nepřátelé přicházejí ve vlnách, každá je silnější.
- **Životy** – každý nepřítel, který projde na konec cesty, ubere hráči život.

## „Systémy" hry (téma zadání: *Strategická hra obsahující systém*)
Hra je postavená z pěti provázaných systémů, které se navzájem ovlivňují:

1. **Ekonomický systém** – zlato, odměny za zabití, ceny věží.
   *(scripts/game_manager.gd)*
2. **Systém vln** – časované spawnování nepřátel s rostoucí obtížností.
   *(scripts/wave_manager.gd)*
3. **Bojový systém** – zaměřování cílů, střelba, poškození, smrt nepřítele.
   *(scripts/tower.gd, projectile.gd, enemy.gd)*
4. **Systém životů** – ztráta životů a konec hry.
   *(scripts/game_manager.gd)*
5. **Stavební systém** – umisťování věží na mřížku s kontrolou platnosti.
   *(scripts/build_manager.gd)*

## Herní smyčka
1. Hráč začíná se zlatem a životy.
2. Stiskne „Spustit vlny".
3. Nepřátelé se spawnují a jdou po cestě k základně.
4. Hráč staví věže → věže střílí → nepřátelé umírají → hráč dostává zlato.
5. Nepřítel, který projde, ubere život.
6. Opakuje se pro každou vlnu.

## Podmínky výhry / prohry
- **Výhra:** hráč přežije všechny vlny (životy > 0).
- **Prohra:** životy klesnou na 0.

## Vizuální styl
Minimalistický, geometrické tvary (barevné čtverce a kruhy) jako placeholder.
Později lze nahradit vypůjčenými sprity (viz `resources.md`).

## Ovládání
- **Levé tlačítko myši** – ve stavebním režimu postaví věž.
- **Tlačítko „Stavět věž"** – zapne/vypne stavební režim.
- **Tlačítko „Spustit vlny"** – spustí hru.
- **Klávesa R** – restart hry.
