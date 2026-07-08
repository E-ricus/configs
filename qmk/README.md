# QMK keymaps

Personal QMK keymaps, kept in this repo and symlinked into `~/qmk_firmware`.

## Keyboards

| Keyboard | QMK board | Keymap |
|----------|-----------|--------|
| Dactyl Manuform 6x6 (Oh Keycaps, Pro Micro) | `handwired/dactyl_manuform/6x6/promicro` | `dactyl_manuform_6x6/ericus` |

## One-time setup

```bash
# 1. Clone QMK firmware (tooling comes from the keyboards-qmk nix aspect)
qmk setup

# 2. Symlink the personal keymap into the QMK tree
cd ~/configs && symlinkmanager link qmk/dactyl_manuform_6x6/ericus
```

## Remapping keys

1. Edit `dactyl_manuform_6x6/ericus/keymap.c` — replace `KC_*` keycodes.
   Reference: <https://docs.qmk.fm/#/keycodes>
2. Compile:
   ```bash
   qmk compile -kb handwired/dactyl_manuform/6x6/promicro -km ericus
   ```
3. Flash (each half separately — plug USB into the half being flashed, and
   short RST to GND on the Pro Micro when qmk waits for the bootloader):
   ```bash
   qmk flash -kb handwired/dactyl_manuform/6x6/promicro -km ericus
   ```

Layers: `_QWERTY` (base), `_LOWER`, `_RAISE`. `_______` means transparent
(falls through to the layer below). `MO(layer)` = momentary layer while held.

## Hardware notes

- Matrix: cols `D4 C6 D7 E6 B4 B5`, rows `F5 F6 F7 B1 B3 B2 B6`, diodes COL2ROW.
- Column 5 (rightmost on left half: F6/5/T/G/B + thumb) is pin **B5** — this
  is the column that had the cold solder joint at the switch-side PCB.
