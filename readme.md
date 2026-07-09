# Tower Defense – závěrečný projekt

Strategická hra typu *tower defense* vytvořená v enginu **Godot 4.x**
(jazyk GDScript). Projekt vznikl jako závěrečný projekt do předmětu
**Pokročilé programování**.

Nápad na hru je popsán v [idea.md](idea.md), zdroje assetů v
[resources.md](resources.md).

## O čem hra je
Braníš základnu před vlnami nepřátel. Za zlato stavíš věže podél cesty;
věže automaticky střílí na nepřátele. Za každého zabitého dostaneš zlato.
Když nepřítel projde na konec cesty, ztratíš život. Přežij všechny vlny.

## Jak hru spustit
1. Stáhni **Godot 4.x** z <https://godotengine.org/download> (jeden `.exe`,
   nevyžaduje instalaci).
2. Spusť Godot → **Import** → vyber soubor `project.godot` v této složce → **Import & Edit**.
3. Stiskni **F5** (Run Project) nebo klikni na ▶ vpravo nahoře.

## Ovládání
- **Tlačítko „Spustit vlny"** – spustí příchod nepřátel.
- **Tlačítko „Stavět věž (50 zlata)"** – zapne stavební režim (přepínací).
- **Levé tlačítko myši** – ve stavebním režimu postaví věž na volné místo
  (nesmí být na cestě ani na jiné věži, potřebuješ 50 zlata).
- **Klávesa R** – restart hry.

## Implementované systémy
- **Ekonomika** – zlato, odměny, ceny věží.
- **Vlny** – 5 vln s rostoucí obtížností.
- **Boj** – věže zaměřují a střílí, projektily působí poškození.
- **Životy** – ztráta životů, konec hry (výhra/prohra).
- **Stavba** – umisťování věží na mřížku s kontrolou.

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

## Poznámka
Jedná se o samostatnou práci (jednotlivec). *(Pokud by šlo o společnou práci
ve dvojici, bylo by to uvedeno zde včetně jmen obou autorů.)*
