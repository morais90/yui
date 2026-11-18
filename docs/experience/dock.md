# Dock

## Purpose

The dock is where you start and switch apps with one click. It shows the apps you keep there
and the ones that are open, nothing else.

## Experience

- Centred at the bottom of the screen, in the same material and colours as the bar.
- **Kept apps** stay in the dock; **open apps** that aren't kept appear after them while open.
  A dot under an icon means the app is open.
- Hovering magnifies the icons gently; clicking an app that isn't open makes it bounce while it
  starts.
- Clicking an open app brings its window to the front. **Minimized windows** wait at the end of
  the dock and come back with an animation when clicked.
- **Right-click** an app for its menu: open or new window, keep in / remove from the dock, turn
  hiding on or off, and close its windows.
- **Hiding.** When hiding is on, the dock slides away and comes back when the mouse touches the
  bottom edge of the screen; windows then use the whole height.

## Decisions

- **The dock belongs to the shell**, not a separate program: same look, same animations, no
  extra process.
- **Hiding is chosen from the dock's own menu**, where you notice the dock, instead of in a
  separate settings page.

## Open

- Should there be a Settings page for the dock at all? Principle 3 suggests the right-click
  menu may be enough.
- Icon size and magnification amount are fixed today; decide whether that stays.
