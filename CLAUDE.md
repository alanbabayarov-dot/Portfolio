# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the Site

No build system. Open `Portfolio v6.html` directly in a browser, or use the `portfolio-v6` server from `.claude/launch.json`. Google Fonts load from CDN; everything else is local.

## Architecture

Two source files:

- **`Portfolio v6.html`** — the entire site: HTML structure, all CSS (inline `<style>`), and all JavaScript (inline `<script>`).
- **`tweaks-panel.jsx`** — a draggable React floating panel for live-tweaking atmosphere values. **Loaded only when `?tweaks` is in the URL** (see below). Communicates with the host page via `window.postMessage`.

Images and videos live in `assets/`. Source material archive: `C:\Users\Admin\Desktop\PortfolioContent`.

## Content Structure (v6.4)

Twelve case files — digital atelier first, then craft/state, current production, AI, direction:

1. **c01 Digital atelier** — CLO3D/Blender/UE5; FILM 01 `dg-look3.mp4` + FILM 02 `dg-turntable.mp4` (muted autoloop); `.duo-feature` row = render poster (abs-positioned img fills) + **accent red mood loop** (3/4, drives row height); bottom `.strip` (3): cloak still · tamga loop · robe still; class `c02` layout
2. **c02 Olympic & national teams** — class `c03`; **lead = Akzhol Makhmudov Paris 2024 (accent, `.lead.sixteen` 16/9)**; jersey N°7 / walkout / team demoted to a small `.strip`; IIHF Kyrgyz Hockey `wide-duo.tall` at the end; link @olympic.kg
3. **c03 Toolor × Cool Group** — current work; lead = `.lead.stack` (lime key visual 4/5 + `dg-trench.jpg` 16/9 below, flex:1 so the column bottom-aligns with the body column); RUH chapter: FILM 03 in `.film-wide` (poster = `ruh-film-poster2.jpg` title card, NOT the black-cloak frame) + `.poster-row`; link @toolor_official
4. **c04 EULER** — brand universe (moved after Toolor); link @eulercentralasia; ВИД print removed → `eu-ornament.jpg`
5. **c05 World Nomad Games** — eagles ceremony lead; `.strip.flat` renders; link worldnomadgames.org
6. **c06 Jetlag Production** — URUS / MINOR; **dates 2020 → 2022**
7. **c07 Artefact (ARTÉ.FACT)** — AI bureau; FILM 04 = **commercial showreel** `af-showreel.mp4` (480×854, 1:00), poster = `af-showreel-poster.jpg` (logo card); posters in `.strip.accent` (khan 2fr accent); no separate logo slot; links @artefact_mag + @artefact.bureau
8. **c08 Totemism** — FILM 05 vertical `tot-film.mp4`
9. **c09 Rapha × Burning Man**
10. **c10 KOZ DUJNO** — XR exhibition; link @kozdujno
11. **c11 MADH × Acne Studios** — link @madh.official
12. **c12 Qoorchaq** — art direction & styling; Kyrgyz myth × domestic violence (`qor-*.jpg` b/w series)

Project links live as the last `<dt>link</dt><dd><a…>` row of each case's `dl` — when editing a translated `dl`, keep the link row in **both** the EN HTML and the RU dict value.

Article `id` = order; `class` = layout. `data-cat` (craft/3d/ai/direction, space-separated) drives the `.filter` bar (hides via `.case.filtered`; buttons carry inline SVG icons, translatable text lives in nested `span[data-i18n]`). Layout helpers: `wide-duo` `.tall`=3/2 `.wide`=9/4; `.strip.flat`=16/9 `.strip.four`=4-col `.strip.accent`=2fr/1fr/1fr; `.film-wide` 21:9; `.poster-row`; `.lead.sixteen`=16/9 lead for `.c03`; `.lead.stack`=two stacked slots for `.c04`; `.wide-solo.half`=max-width 640px; `.duo-feature`=2fr/1fr wide-render + tall accent loop. Muted loops auto-resume on `visibilitychange` (Chrome pauses video-only media in hidden tabs). `wide-solo` images need `width`/`height` attrs. Hero portrait `ava-portrait.jpg` (object-position 58% 40% / mobile 58% 32%).

## Video Pipeline

All mp4s are H.264 yuv420p with `-movflags +faststart` (moov up front — required for instant web streaming). Muted ambient loops (`data-loop`): ≤960px, crf 26, no audio track. Click-to-play films keep AAC audio. ffmpeg is NOT installed system-wide — download the gyan.dev essentials build into the scratchpad when needed (see git history). Never ship >1080p video: 8K sources must be downscaled or many phones won't decode them.

## i18n (EN/RU)

`.lang` toggles in nav + mobile overlay switch language; RU strings live in a **selector-keyed `RU` dictionary** in the main inline script (EN originals cached at runtime in `EN{}`; choice persisted in `localStorage['v6-lang']`). To change copy: edit the EN in HTML **and** the matching RU dict entry. New translatable elements: add a selector key (or `data-i18n` attribute + `[data-i18n="…"]` key). Hero/manifesto copy source: `C:\Users\Admin\Downloads\alan-babayarov-portfolio-blocks.md`. Contacts: Instagram alain4hmspns, Telegram @dodogepoison, Linktree alain4hmspns.

Each case has `.chips` marking medium: plain chips = craft/3D, `.chip.ai` = AI-involved. Films are click-to-play **with sound** (`[data-video]` slots, `.vbtn` buttons); `video[data-loop]` autoplay muted via IntersectionObserver, all pause off-screen.

## Performance Rules

- All images `loading="lazy"` except the hero portrait (`fetchpriority="high"`).
- Videos are `preload="none"` (turntable: `preload="metadata"`) with poster JPEGs.
- React 18 + Babel Standalone (~2 MB) load **only with `?tweaks` in the URL** — normal visitors never fetch them. The loader manually transforms `text/babel` scripts in document order (Babel's own `transformScriptTags` misorders src-vs-inline when invoked post-DOMContentLoaded).
- Keep new images ≤ ~1400px, JPEG q≈72 (System.Drawing recompress pattern in git history).

## CSS Custom Properties

All theming is driven by CSS variables on `:root`. Key variables:

- `--mood` — active palette preset (`bordeaux` | `blood` | `ember`)
- `--voltage` — ambient orb opacity (0–1)
- `--grit` — grain/scanline opacity (0–1)
- Color tokens: `--clr-ink`, `--clr-neon`, `--clr-bone`, `--clr-red`, `--clr-bg`, `--clr-accent`

Mood presets switch color tokens. The tweaks panel writes to these variables directly on `document.documentElement`.

## Tweaks Panel Protocol

Open the site with `?tweaks=1`, then the panel mounts but stays hidden until it receives `__activate_edit_mode`:

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
- **Films** — `[data-video]` click-to-play with sound, one at a time, pause off-screen
- **Idle sparks** — `setTimeout`-based dots spawned after inactivity; count scales with `--voltage`

The global `window.__V6_TWEAKS` object is the shared state between JS effects and the React tweaks panel.

## Gotchas

- Never put layout-affecting inline styles (e.g. `grid-column`) on elements that mobile media queries must re-place — use classes.
- The preview MCP screenshot tool times out on this site (infinite CSS animations); verify with `preview_eval` metrics instead.
