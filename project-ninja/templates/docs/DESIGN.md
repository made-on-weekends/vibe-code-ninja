---
version: alpha
name: TODO(<owner>) # design system name
description: TODO(<owner>) # one-line summary
colors:
  primary: TODO # required, e.g. "#2563eb"
  secondary: TODO
  bg: TODO
  fg: TODO
  muted: TODO
  success: TODO
  warning: TODO
  danger: TODO
typography:
  body:
    fontFamily: TODO
    fontSize: TODO    # Dimension, e.g. "1rem"
    fontWeight: TODO  # number
    lineHeight: TODO  # Dimension | number
  heading:
    fontFamily: TODO
    fontSize: TODO
    fontWeight: TODO
    lineHeight: TODO
rounded:
  sm: TODO   # Dimension, e.g. "4px"
  md: TODO
  lg: TODO
spacing:
  1: TODO    # Dimension | number, e.g. 4
  2: TODO
  3: TODO
  4: TODO
  6: TODO
  8: TODO
components:
  button-primary:
    bg: "{colors.primary}"
    fg: "{colors.bg}"
    rounded: "{rounded.md}"
  button-primary-hover:
    bg: TODO
---

# DESIGN.md

> Self-contained design-system source of truth. Conforms to the [design.md spec](https://github.com/google-labs-code/design.md/blob/main/docs/spec.md): YAML frontmatter holds machine-readable tokens; the body holds human rationale. This doc owns the values; `BRAND.md` owns identity.
>
> Spec sections below (Overview → Colors → Typography → Layout → Elevation & Depth → Shapes → Components → Do's and Don'ts) use the canonical headings in order. Sections after "Do's and Don'ts" are project extensions — the spec preserves unknown sections.

## Overview

TODO(<owner>): Brand & style summary — the feel of the system (e.g., "clean, high-contrast, generous whitespace"). BRAND.md owns identity; this names the visual approach.

## Colors

TODO(<owner>): Full palette. Values mirror the `colors` frontmatter (`primary` required). BRAND.md may *name* brand-defining colors but never duplicates the values. Hex (`#RRGGBB`) is the recommended default; rgb/hsl/oklch/color-mix also valid.

| Token       | Hex / value | Usage          |
|-------------|-------------|----------------|
| `primary`   | TODO        | TODO(<owner>)  |
| `secondary` | TODO        | TODO(<owner>)  |
| `bg`        | TODO        | TODO(<owner>)  |
| `fg`        | TODO        | TODO(<owner>)  |
| `muted`     | TODO        | TODO(<owner>)  |
| `success`   | TODO        | TODO(<owner>)  |
| `warning`   | TODO        | TODO(<owner>)  |
| `danger`    | TODO        | TODO(<owner>)  |

## Typography

TODO(<owner>): Full type scale. BRAND.md names the typeface; values live here and in the `typography` frontmatter.

- Font families: TODO(<owner>): e.g., heading, body, mono
- Font weights in use: TODO(<owner>)
- Type scale:

| Token       | Size | Line height | Usage          |
|-------------|------|-------------|----------------|
| `text-xs`   | TODO | TODO        | TODO(<owner>)  |
| `text-sm`   | TODO | TODO        | TODO(<owner>)  |
| `text-base` | TODO | TODO        | TODO(<owner>)  |
| `text-lg`   | TODO | TODO        | TODO(<owner>)  |
| `heading-1` | TODO | TODO        | TODO(<owner>)  |
| `heading-2` | TODO | TODO        | TODO(<owner>)  |

## Layout

TODO(<owner>): Spacing scale and layout rules. Values mirror the `spacing` frontmatter.

- Spacing scale: TODO(<owner>): e.g., 4 / 8 / 12 / 16 / 24 / 32 px, and rules for when to use each.
- Container max-width: TODO(<owner>)
- Grid: TODO(<owner>)
- Breakpoints: TODO(<owner>)

## Elevation & Depth

TODO(<owner>): Shadow / elevation system. Define each level and when to use it.

## Shapes

TODO(<owner>): Standard border radii. Values mirror the `rounded` frontmatter.

## Components

Component tokens use related keys (e.g., `button-primary`, `button-primary-hover`) and reference base tokens with dot-notation, e.g. `{colors.primary}`. Mirror the `components` frontmatter.

- Forms: TODO(<owner>): label position, error display, required-field indication
- Buttons: TODO(<owner>): hierarchy (primary/secondary/ghost), loading state, disabled state
- Empty states: TODO(<owner>): default pattern
- Loading states: TODO(<owner>): skeleton / spinner / shimmer policy
- Toasts/alerts: TODO(<owner>): position, dismiss behavior, types

## Do's and Don'ts

**Do:**
- Always use tokens, never raw hex/px values in components.
- Reference base tokens via dot-notation (`{colors.primary}`) in component definitions.
- Reserve `danger` for destructive actions only.
- Use `heading-1` once per page, `heading-2` for section breaks within a page.
- Pair color choices with sufficient contrast (WCAG AA minimum).

**Don't:**
- Don't introduce a new token without a `DECISIONS.md` entry.
- Don't use `text-decoration: underline` for non-link emphasis.
- Don't remove focus rings without providing an equivalent visible focus state.
- Don't use color alone to convey meaning (accessibility).

<!-- Sections below are project extensions beyond the design.md spec; the spec preserves unknown sections without error. -->

## Dark mode

TODO(<owner>): Strategy (CSS variable swap, class-based, system-preference, none).

## Motion

TODO(<owner>): Duration scale, easing curves, when motion is appropriate, when it's reduced (`prefers-reduced-motion`).

## Density

TODO(<owner>): Compact vs comfortable spacing mode, if applicable.

## Accessibility minimums

- Color contrast: WCAG AA minimum
- Keyboard nav: all interactive elements reachable
- Focus rings: visible
- TODO(<owner>): project-specific rules
