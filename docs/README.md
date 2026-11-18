# Yui product documentation

This folder describes **what Yui is like to use**, not how it is built. The technical side
(packages, scripts, build) lives in the [repository README](../README.md).

## How we work

1. **Experience first.** Before writing code, we describe the change here: what the person sees,
   what they click, how it feels. If it can't be explained simply, it isn't ready to build.
2. **Check it against the [principles](principles.md).** A change that adds a second way to do
   something, an extra button or a slow path needs a very good reason.
3. **Build it, then test it as a user would**, on the real desktop, with screenshots.
4. **Update the page** if what we built turned out different from what we wrote.

## Contents

- [Principles](principles.md): what every part of Yui must be.
- [Glossary](glossary.md): the name of each part of the screen.
- Experience, one page per part of the system:
  - [Windows](experience/windows.md): title bars, zoom, minimize, snapping.
  - [Dock](experience/dock.md): apps, hiding, the right-click menu.
  - [Spotlight](experience/spotlight.md): one place to find anything.
  - [Switching](experience/switching.md): Alt+Tab and Mission Control.
  - [Settings](experience/settings.md): the Settings app and its pages.
  - [Terminal](experience/terminal.md): Ghostty, fish and the prompt.
  - [Apps](experience/apps.md): the apps Yui ships with and what they open.

## Page template

Each experience page has the same four parts:

- **Purpose**: why this part exists, in one or two sentences.
- **Experience**: how it looks and how it is used, from the person's point of view.
- **Decisions**: what we chose and why, so we don't argue the same thing twice.
- **Open**: what is still undecided, or where today's behaviour breaks a principle.
