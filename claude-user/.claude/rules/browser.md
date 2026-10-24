# Browser Automation Rules

These rules apply whenever a browser is needed to load, inspect, or interact
with a web page, in any project.

## Choosing a browser

When checking something for yourself use the headless Playwright browser.
**ALWAYS** prefer this approach for self-directed checks, so that no window
opens on the user's desktop.

Only use a user-visible browser (whether via Playwright, Chrome DevTools MCP,
or Claude in Chrome tools) when there is a definite requirement for it, in
which case use your own judgement to determine the best option.

## Playwright MCP file roots

The Playwright MCP only reads and writes files under the project root. A path
in the scratchpad or `/tmp` fails with "outside allowed roots". Put scripts
and screenshots in a gitignored directory inside the project (for example
`target/` or `.playwright-mcp/`), or run Playwright from Node directly, which
has no such limit and no 120 s cap.

## Research fallback

Headless Playwright is also the fallback for research fetches: a 403 with a
plain client, a Cloudflare "Just a moment" page, or a page whose content is
rendered by JavaScript. Load the page, wait for the content, and read its
text; do not mark a page UNVERIFIED before trying this. The ladder is in
research.md.
