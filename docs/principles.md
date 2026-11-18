# Principles

These are the rules every part of Yui is judged against. They will get sharper as we go; when
one changes, we write down why.

## 1. Instant

Yui must feel immediate. Everything that responds to a click or a key answers within a frame or
two, animations never make you wait, and nothing runs in the background without a reason.

In practice:

- Measure before and after. "Seems fast" is not enough.
- No daemons, polling or services for features that can be event-driven or on demand.
- Animations are short and can be interrupted; they show what happened, they don't delay it.
- Fewer dependencies over more: every package we add must earn its place.

## 2. A delight to use

Using Yui should be pleasant and beautiful, the kind of system you enjoy looking at. Details
matter: alignment, spacing, motion, colour, the feel of each click.

In practice:

- One visual language across the whole system: same corners, shadows, typography and motion.
- Colours follow the wallpaper, so the system always looks like one piece.
- Nothing looks unfinished: no placeholder pages, no raw error text, no misaligned pixels.
- When something goes wrong, the system recovers on its own where it can (like display changes
  that revert unless you keep them).

## 3. Only what matters

Yui is minimal. Every button, menu item and setting must be necessary; if in doubt, leave it
out. A smaller set of things that work perfectly beats many that work well enough.

In practice:

- Prefer good defaults over options. A setting is a decision we failed to make for the person.
- Each screen shows the few things you came for, nothing else.
- Removing something is as valuable as adding something.

## 4. One way to do each thing

Each action has a single, obvious way to do it. You never have to learn which of three methods
is "the right one", and the system stays easy to explain.

In practice:

- One entry point per feature. Spotlight opens by clicking the **Y** on the bar, nothing else.
- The mouse is the primary way to use Yui; keyboard shortcuts are the exception, not a second
  path to everything.
- Where a gesture is the natural way on a given device (a trackpad swipe, for example), it
  replaces other ways instead of adding to them.
