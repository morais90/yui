# Spotlight

## Purpose

One place to find anything: an app, a file, a setting, a quick calculation or a web search.
You type what you want instead of hunting through menus.

## Experience

- **Click the Y** at the top of the bar. A search box appears in the upper middle of the screen,
  over a blurred background.
- Results show up as you type, grouped and in this order:
  1. **Calculator**: typing `12*7+3` shows `= 87`; Enter copies the result.
  2. **Applications**.
  3. **Settings**: pages of the Settings app and system actions (Mission Control, dock hiding,
     lock screen).
  4. **Files** in your home folder (hidden folders and build/dependency folders are skipped).
  5. **Web**: search the web for what you typed, always last.
- The arrows move the selection, Enter opens it, and clicking a result opens it too.
- Esc or a click outside closes it.

## Decisions

- **Opens only from the Y on the bar** (principle 4). No keyboard shortcut.
- **Calculator results come first.** If you typed a calculation, the answer is what you want.
- **Files are searched on demand** with `find`, limited in depth and skipping hidden and
  dependency folders: answers in milliseconds without an indexing service running in the
  background (principle 1).
- **There is no other launcher.** Caelestia's launcher (`Super+R`, typed `>` commands for
  wallpapers, colour schemes, power) was removed: everything it did is already in Spotlight,
  Settings > Wallpaper & style, or the power button on the bar.
- **Web search is always the last result**, so Enter on something unknown still does something
  useful.

## Open

- File results could open the containing folder as an alternative action, if that proves
  needed.
