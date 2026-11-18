# Windows

## Purpose

Windows behave the way people already expect from macOS: they float, overlap, and are moved and
resized with the mouse. The system never surprises you with where a window goes.

## Experience

- **Title bar.** Every window has a slim title bar with its name centred and three coloured
  buttons on the left: close (red), minimize (yellow), zoom (green). Its colour follows the
  wallpaper. Apps that draw their own title bar, like Chrome, keep it, with the buttons on the
  left as well.
- **Focus.** A window becomes active when you click it, never just by moving the mouse over it.
  Clicking a window behind another brings it to the front.
- **The pointer stays put.** The system never moves the mouse on its own, whatever opens or gets
  focus.
- **Zoom (green button).** The window grows to fill all the free space: from the bar to the
  screen edges, down to the dock if it is always shown. No gaps or frame around it. Clicking
  again brings back its previous size and place. Apps' own maximize buttons do the same.
- **Minimize (yellow button).** The window shrinks into the dock with an animation and appears
  there until you click it to bring it back.
- **Snapping.** Dragging a window to a screen edge shows a preview of where it will land:
  left or right edge = half the screen, a corner = a quarter, top edge = the whole free area.
  Letting go places it there.
- **Motion.** Windows open and close with a quick fade and slight zoom; nothing makes you wait.

## Decisions

- **Click to focus**, like macOS. Focus following the mouse surprised people when crossing
  windows on the way to something else.
- **Zoom fills the free area, not the whole screen.** The bar and the dock stay visible, so you
  never lose your place.
- **No gaps around or between windows.** Space on screen goes to content; the padding and the
  frame Caelestia drew around the screen are gone (principle 3).
- **Snapping is a Hyprland plugin (`yui-snap`)**, not a script: it reacts during the drag, so the
  preview appears instantly.
- **Maximized windows push others behind them when clicked**, so an app's own maximize behaves
  like the green button.

## Open

- Dragging a snapped window away should give it back its previous size.
- Many keyboard shortcuts for windows remain from Hyprland's defaults (move, resize, float,
  pin, center, groups, workspaces). Each one needs to justify itself under principles 3 and 4.
- `Super+F` (fullscreen) and `Super+Shift+F` (zoom) duplicate the green button.
