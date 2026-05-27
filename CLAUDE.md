# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the Site

No build system. Open `Portfolio v6.html` directly in a browser. All dependencies load from CDN (React 18, Babel Standalone, Google Fonts).

The `tweaks-panel.jsx` file is transpiled at runtime by Babel in the browser — it is not pre-compiled.

## Architecture

Two source files:

- **`Portfolio v6.html`** — the entire site: HTML structure, all CSS (inline `<style>`), and all JavaScript (inline `<script>`). ~52 KB.
- **`tweaks-panel.jsx`** — a draggable React floating panel (bottom-right) for live-tweaking atmosphere values. Communicates with the host page via `window.postMessage`.

Images live in `assets/`.

## CSS Custom Properties

All theming is driven by CSS variables on `:root`. Key variables:

- `--mood` — active palette preset (`bordeaux` | `blood` | `ember`)
- `--voltage` — ambient orb opacity (0–1)
- `--grit` — grain/scanline opacity (0–1)
- Color tokens: `--clr-ink`, `--clr-neon`, `--clr-bone`, `--clr-red`, `--clr-bg`, `--clr-accent`

Mood presets switch color tokens. The tweaks panel writes to these variables directly on `document.documentElement`.

## Tweaks Panel Protocol

The panel uses `postMessage` for design-tool integration (e.g. embedding in Figma or a preview iframe):

| Message `type` | Direction | Purpose |
|---|---|---|
| `__activate_edit_mode` | → panel | Show panel |
| `__deactivate_edit_mode` | → panel | Hide panel |
| `__edit_mode_set_keys` | → panel | Inject key/value overrides |

Panel state is persisted in `localStorage` under `v6-tweaks`.

## Visual Effects Stack

All effects are CSS-only overlays stacked as fixed/absolute children of `<body>`:

- `.fx-grain` — animated SVG turbulence filter (film grain)
- `.fx-scan` — horizontal scanlines
- `.fx-vig` — radial vignette
- `.fx-orbs` — three blurred divs animated with `@keyframes`
- `.fx-cursor` — custom glow cursor (hidden on touch devices)

## JavaScript Patterns

All JS is vanilla, inline at the bottom of `Portfolio v6.html`:

- **Loader** — SVG spinner; removed from DOM on `DOMContentLoaded`
- **Cursor** — RAF loop with lerped `x/y` toward `mouseX/mouseY`
- **Nav hide/show** — compares `scrollY` to previous tick
- **Flicker** — `IntersectionObserver` on `<em>` elements; random opacity intervals
- **Idle sparks** — `setTimeout`-based dots spawned after inactivity; count scales with `--voltage`

The global `window.__V6_TWEAKS` object is the shared state between JS effects and the React tweaks panel.
