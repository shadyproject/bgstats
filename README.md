# BGStats

BGStats is a World of Warcraft: Forever addon that automatically records battleground results for each character. It shows wins, losses, draws, confirmed early departures, and win/loss ratios overall and by battleground. Each battleground has a dated match history.

## Installation

1. Place the addon in a folder named `BGStats` under `World of Warcraft/_forever_/Interface/AddOns/`. The `BGStats.toc` file must be at the root of that folder.
2. Enable BGStats in the game's AddOns list.

## Usage

1. Click the minimap icon to open your stats. Select a battleground to see its totals and match history.
2. Open **Settings → AddOns → BGStats** to show or hide the minimap icon or reset its position.
3. With Titan Panel installed, enable the BGStats plugin. Right-click it to open **Global Stats**, a specific battleground, or **Settings**.

## Translations

All non-English BGStats translations are machine-generated. Translation submissions and corrections from native speakers are welcome. Edit the relevant file in [Locales](Locales/) and submit a pull request. The addon uses the WoW client locale and falls back to English for missing strings.

## Development

Run the checks from the repository root with Lua installed.

```sh
for test in tests/*.lua; do lua "$test" || exit 1; done
```
