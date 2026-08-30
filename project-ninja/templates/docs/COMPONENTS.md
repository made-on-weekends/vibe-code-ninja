# COMPONENTS.md

> Reusable UI component rules and inventory. Framework-agnostic principles; project-specific patterns filled in by the project.

## Component conventions

- Location: TODO(<owner>): where components live
- File naming: TODO(<owner>): casing rule, one component per file or co-located variants
- Styling: TODO(<owner>): CSS-in-JS, utility classes, scoped styles, etc.
- TypeScript / type strictness: TODO(<owner>)

## Prop API rules

**Do:**
- Props for data going IN. Slots/children for content composition. Events for actions going OUT.
- Type every prop explicitly. Optional props get explicit defaults.
- Name boolean props affirmatively (`isOpen` not `notClosed`).
- Provide sensible defaults so simple use cases need few props.

**Don't:**
- Don't accept a prop that's only there to switch internal behavior — use composition instead.
- Don't pass deep object trees as props — pass primitives or small objects.
- Don't accept 8+ props to configure a single component. That's a sign to break it up or extract a composable.
- Don't render different fundamental layouts based on a single prop — make them separate components.

## State ownership

Rule of thumb: **state lives at the lowest common ancestor of components that need it.** Lift only when necessary, push down when possible.

TODO(<owner>): Project-specific patterns (e.g., URL state for filters, persistent state for prefs, session state for auth).

## Base components

These are the primitives. New UI should compose these, not reinvent them.

| Name           | Purpose                       | Path                              | Test expectation     |
|----------------|-------------------------------|-----------------------------------|----------------------|
| TODO(<owner>)  |                               |                                   |                      |

Test expectation links to `TESTING.md` for what level of testing each base component requires.

## Composite components

Higher-level components built from base components. Document each so agents don't recreate them.

| Name           | Purpose                                    | Notes                  |
|----------------|--------------------------------------------|------------------------|
| TODO(<owner>)  |                                            |                        |

## When to create a new component

**Do create one when:**
- The pattern appears 3+ times
- The pattern needs consistent behavior across pages
- A specific accessibility or interaction concern needs to be encapsulated

**Don't create one when:**
- It's only used in one place
- The "reuse" requires the parent to pass 8+ props to configure it (extract a function/composable instead)
- The component would be a thin wrapper around a single base component with no added value

## When patterns become design tokens

If you find yourself hardcoding the same value (color, spacing, animation duration) in multiple components, that value belongs in `DESIGN.md` as a token, not in each component. Cross-link: DESIGN.md owns tokens; COMPONENTS.md uses them.

## Composables / shared logic

Logic-only reusables go in shared modules, not as components.

- TODO(<owner>): list as added

## Storybook / component playground

TODO(<owner>): If used. Otherwise delete this section.
