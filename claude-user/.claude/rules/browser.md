# Browser Automation Rules

These rules apply whenever a browser is needed to load, inspect, or interact
with a web page, in any project.

## Choosing a browser

When checking something for yourself  use the headless Playwright browser.
**ALWAYS** prefer this approach for self-directed checks, so that no window
opens on the user's desktop.

Only use a user-visible browser (whether via Playwright, Chrome DevTools MCP,
or Claude in Chrome tools) when there is a definite requirement for it, in
which case use your own judgement to determine the best option.
