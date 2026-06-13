# DESIGN.md

> All design tokens (colors, type, spacing, layout) and UI system rules. This doc owns the values; `BRAND.md` owns identity.

## Color palette

TODO(<owner>): Full palette including hex values. BRAND.md may *name* brand-defining colors but never duplicates the values.

| Token name           | Hex     | Usage                              |
|----------------------|---------|------------------------------------|
| `--color-primary`    | TODO    | TODO(<owner>)                      |
| `--color-secondary`  | TODO    | TODO(<owner>)                      |
| `--color-bg`         | TODO    | TODO(<owner>)                      |
| `--color-fg`         | TODO    | TODO(<owner>)                      |
| `--color-muted`      | TODO    | TODO(<owner>)                      |
| `--color-success`    | TODO    | TODO(<owner>)                      |
| `--color-warning`    | TODO    | TODO(<owner>)                      |
| `--color-danger`     | TODO    | TODO(<owner>)                      |

## Typography

TODO(<owner>): Full type scale. BRAND.md names the typeface; values live here.

- Font families: TODO(<owner>): e.g., heading, body, mono
- Font weights in use: TODO(<owner>)
- Type scale:

| Token             | Size | Line height | Usage                |
|-------------------|------|-------------|----------------------|
| `text-xs`         | TODO | TODO        | TODO(<owner>)        |
| `text-sm`         | TODO | TODO        | TODO(<owner>)        |
| `text-base`       | TODO | TODO        | TODO(<owner>)        |
| `text-lg`         | TODO | TODO        | TODO(<owner>)        |
| `heading-1`       | TODO | TODO        | TODO(<owner>)        |
| `heading-2`       | TODO | TODO        | TODO(<owner>)        |

## Spacing

TODO(<owner>): Scale (e.g., 4 / 8 / 12 / 16 / 24 / 32 px) and rules for when to use each.

## Radii

TODO(<owner>): Standard border radii.

## Shadows

TODO(<owner>): Elevation system.

## Layout rules

- Container max-width: TODO(<owner>)
- Grid: TODO(<owner>)
- Breakpoints: TODO(<owner>)

## Do / Don't

**Do:**
- Always use tokens, never raw hex/px values in components.
- Reserve `--color-danger` for destructive actions only.
- Use `heading-1` once per page, `heading-2` for section breaks within a page.
- Pair color choices with sufficient contrast (WCAG AA minimum).

**Don't:**
- Don't introduce a new token without a `DECISIONS.md` entry.
- Don't use `text-decoration: underline` for non-link emphasis.
- Don't remove focus rings without providing an equivalent visible focus state.
- Don't use color alone to convey meaning (accessibility).

## Patterns

- Forms: TODO(<owner>): label position, error display, required-field indication
- Buttons: TODO(<owner>): hierarchy (primary/secondary/ghost), loading state, disabled state
- Empty states: TODO(<owner>): default pattern
- Loading states: TODO(<owner>): skeleton / spinner / shimmer policy
- Toasts/alerts: TODO(<owner>): position, dismiss behavior, types

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
