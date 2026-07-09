# Tower Defense – závěrečný projekt

Strategická hra typu *tower defense* vytvořená v enginu **Godot 4.x**
(jazyk GDScript). Projekt vznikl jako závěrečný projekt do předmětu
**Pokročilé programování**.

Nápad na hru je popsán v [idea.md](idea.md), zdroje assetů v
[resources.md](resources.md).

## O čem hra je
Braníš hrad před vlnami nepřátel. Za zlato stavíš věže podél cesty;
věže automaticky střílí na nepřátele. Za každého zabitého dostaneš zlato.
Když nepřítel projde na konec cesty, ztratíš život. Přežij všechny vlny.

Hra má **hlavní menu**, **nastavení** (hlasitost, celá obrazovka) a **3 úrovně**
(Louka, Poušť, Pevnost) s rostoucí obtížností. Úrovně se postupně odemykají
a postup se ukládá.

## Jak hru spustit
1. Stáhni **Godot 4.x** z <https://godotengine.org/download> (jeden `.exe`,
   nevyžaduje instalaci).
2. Spusť Godot → **Import** → vyber soubor `project.godot` v této složce → **Import & Edit**.
3. Stiskni **F5** (Run Project) nebo klikni na ▶ vpravo nahoře.
4. Otevře se **hlavní menu** → *Hrát* → vyber úroveň.

## Ovládání
- **Tlačítko „Spustit vlny"** – spustí příchod nepřátel.
- **Tlačítko „Věž (50)"** – vybere stavbu základní věže.
- **Tlačítko „Silná věž (90)"** – vybere stavbu silné věže (větší dosah
  i poškození, pomalejší střelba).
- **Levé tlačítko myši** – po výběru typu věže postaví věž na volné místo.
  Náhled u kurzoru ukazuje, kam lze stavět (**zeleně** = ano, **červeně** = ne –
  moc blízko cesty / jiné věže / málo zlata).
- **Klávesa R** – restart úrovně.
- **Tlačítko „Menu" / klávesa ESC** – návrat do hlavního menu.
- **Rychlost hry** (1×/2×/3×) se nastavuje v *Nastavení*.

## Implementované systémy
- **Ekonomika** – zlato, odměny, ceny věží.
- **Vlny** – 5 vln s rostoucí obtížností.
- **Boj** – věže zaměřují a otáčejí hlaveň na cíl, projektily působí poškození.
  Nepřátelské tanky natáčejí věžičku na nejbližší věž.
- **Životy** – ztráta životů, ukazatel nad hradem, konec hry (výhra/prohra).
- **Stavba** – dva typy věží, umisťování na mřížku s náhledem a kontrolou.
- **Zvuky** – výstřel a výbuch (Kenney, CC0).
- **Úrovně** – 3 úrovně s odemykáním, postup se ukládá (`user://save.cfg`).
- **Menu a nastavení** – hlavní menu, výběr úrovně, hlasitost, rychlost hry, celá obrazovka.

## Struktura projektu
```
project.godot          – konfigurace projektu
icon.svg               – ikona
scripts/               – herní logika (GDScript)
  game_manager.gd      – globální stav (autoload): zlato, životy, skóre
  main.gd              – propojení systémů, vykreslení cesty
  wave_manager.gd      – systém vln
  build_manager.gd     – stavební systém
  enemy.gd             – nepřítel (pohyb po cestě, HP)
  tower.gd             – věž (zaměřování, střelba)
  projectile.gd        – projektil
  hud.gd               – uživatelské rozhraní
scenes/                – scény hry
  Main.tscn            – hlavní scéna
  Enemy.tscn, Tower.tscn, Projectile.tscn, HUD.tscn
assets/                – místo pro grafiku/zvuky (viz resources.md)
```

## Architektura
Herní stav je oddělen v autoloadu `GameManager` a systémy spolu komunikují
přes **signály** (např. `gold_changed`, `game_over`, `wave_started`), takže
jsou volně provázané a snadno rozšiřitelné.

## Stav / možná vylepšení (TODO)
- Více typů věží (různý dosah, rychlost, poškození).
- Vylepšování věží za zlato.
- Skutečné sprity a zvuky místo geometrických tvarů.
- Ukazatel postupu vlny a odpočet do další vlny.
