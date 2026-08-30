# UX.md

> User flows and behavior rules. The "what happens when" doc.
> Visual rules in `DESIGN.md`. Component-level rules in `COMPONENTS.md`.

## Core flows

### Sign-up / sign-in
TODO(<owner>): Step-by-step. What the user sees, what they enter, what feedback they get.

### TODO(<owner>): primary product flow
TODO(<owner>): The main thing users come here to do.

## Always / Never (behavior rules)

**Always:**
- Always show a clear error message when an action fails — never silently fail.
- Always confirm destructive actions (see "Irreversible action policy" below).
- Always provide a way back / out of any flow the user enters.
- Always reflect server state in the UI within <N> ms of a change (TODO: pick a threshold).
- Always preserve user input on validation failure — never wipe a form on error.

**Never:**
- Never use a single-click action to delete data the user can't recover.
- Never block the UI on a network call without a loading indicator after <N> ms.
- Never auto-redirect mid-form-fill without saving.
- Never use `confirm()` browser dialogs in the product UI.
- Never depend on color alone to indicate state.

## Irreversible action policy

TODO(<owner>): Define what counts as irreversible (delete, send, publish, charge) and the confirmation pattern. Recommended pattern:

- Light confirmation: "Are you sure?" modal with action labeled clearly (not just "OK")
- Heavy confirmation: type-to-confirm the resource name
- Always: confirmation dialog summarizes what will happen, not just "are you sure?"

## Undo policy

TODO(<owner>): Which actions are undoable, how the undo surfaces (toast with action), how long the window is.

## Form validation

- When: TODO(<owner>): inline on blur / on submit / both
- Where errors appear: TODO(<owner>): below field / summary at top / both
- Required field indication: TODO(<owner>)
- Invalid input handling: TODO(<owner>): block submit / show error and allow / etc.

## Empty states

TODO(<owner>): Policy. Recommended: empty states always include a primary action to fill the void.

## Loading thresholds

TODO(<owner>): Standard thresholds. Common values:
- < 200ms: no indicator
- 200ms – 1s: cursor / inline spinner
- 1s – 5s: skeleton or spinner with progress
- > 5s: explicit progress + "still working" message

## Notifications

TODO(<owner>): Toast vs inline vs modal — when each. Dismiss behavior. Stacking.

## Error recovery

TODO(<owner>): When an action fails, what does the user see and what can they do? Default pattern:
1. Error message naming the failure
2. What the user can do next (retry, edit input, contact support)
3. Original state preserved so they can try again

## Optimistic updates

TODO(<owner>): Policy. When do we show changes before the server confirms? When do we wait?

## Navigation

- Top-level structure: TODO(<owner>)
- Breadcrumbs: TODO(<owner>): policy
- Back-button behavior: TODO(<owner>)

## Mobile rules

TODO(<owner>): Anything specific to mobile that differs from desktop.

## Accessibility behavior

- Keyboard shortcuts: TODO(<owner>)
- Focus management: TODO(<owner>): rules for modals, route changes
- Announcements: TODO(<owner>): when do we use ARIA live regions
