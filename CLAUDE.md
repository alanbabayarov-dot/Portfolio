# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

This is a **single-file static portfolio site** — all HTML, CSS, and JS live in `portfolio.html`. There is no build system, no bundler, no package manager.

**Media assets** go in a `works/` directory alongside the HTML:
```
works/001-olympics/hero.png    ← 16:9, <500KB
works/001-olympics/look-01.jpg ← 4:5, <300KB
works/002-euler/hero.mp4       ← requires poster.jpg alongside it
```

## Viewing the site

Open `portfolio.html` directly in a browser. For live reload, use VS Code's **Live Server** extension. No server, no npm, no build step.

For Netlify deployment: drag the entire folder onto https://app.netlify.com/drop. Rename `portfolio.html` → `index.html` first if deploying to a root domain.

## Content placeholder system

Empty media slots use a `data-empty` attribute, which triggers a CSS `::after` pseudo-element showing placeholder text. To fill a slot, **remove `data-empty`** and add an `<img>` or `<video>` child:

```html
<!-- Before -->
<div class="case__hero" data-num="N° 002 / EULER" data-empty></div>

<!-- After -->
<div class="case__hero" data-num="N° 002 / EULER">
  <img src="works/002-euler/hero.jpg" alt="..." loading="lazy" decoding="async">
</div>
```

Same pattern applies to `.frame` (gallery) and `.tile__media` (archive) elements.

## Key CSS architecture

Design tokens are CSS custom properties in `:root`:
- `--bg` / `--bg-2` — background blacks
- `--fg` / `--fg-dim` / `--fg-quiet` — foreground whites/greys
- `--accent` — `#e60012` (red), used for highlights, tags, hover states
- `--serif` — Fraunces (display type)
- `--mono` — JetBrains Mono (labels, UI text)

Typography scale uses two classes: `.h-display` (hero title, ~17vw) and `.h-section` (section headers, ~9vw).

## Section navigation

Each major section is marked with an HTML comment for quick search:
- `<!-- CASE 001 — OLYMPIC GAMES -->` through `<!-- CASE 006 — KOZ DUJNO XR -->`
- `<!-- ARCHIVE -->`, `<!-- ABOUT / MANIFESTO -->`, `<!-- CLIENTS -->`, `<!-- SERVICES -->`, `<!-- CONTACT -->`

Find editable content by searching the class in `portfolio.html` (see README.md table for the full map).

## JavaScript

Three self-contained scripts at the bottom of `portfolio.html`, no external libraries:
1. **Loader** — hides the intro screen 1.1s after `window.load`
2. **IntersectionObserver** — adds `.is-visible` to `.reveal` elements as they scroll into view
3. **Archive filter** — toggles `.tile` visibility via `data-cat` attribute matching; updates the count display

## Video requirements

All autoplay video must have `muted`, `autoplay`, `loop`, and `playsinline` attributes. Videos >10MB should be hosted on Vimeo and embedded via iframe with `background=1`. The IO-based video pause/resume runs automatically for any `<video>` in the DOM.
