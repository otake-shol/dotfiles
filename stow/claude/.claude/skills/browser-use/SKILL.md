---
name: browser-use
description: Use when the user wants AI-driven browser automation, web scraping, form filling, E2E testing, or interacting with web pages programmatically using Playwright MCP
---

# Browser Use

AI-driven browser automation using the existing Playwright MCP server.

## When to Use

- User wants to interact with a web page (click, fill, navigate)
- User needs to scrape or extract data from a website
- User wants to automate a multi-step web workflow
- User needs visual verification of a web page state

## Core Pattern: Snapshot → Interact → Verify

Every browser automation follows this loop:

### 1. Navigate & Snapshot
```
browser_navigate(url)     → Load the page
browser_snapshot()        → Get accessibility tree with ref IDs
```

### 2. Interact
Use `ref` values from the snapshot to target elements:
```
browser_click(ref, element)       → Click buttons/links
browser_type(ref, text)           → Type into inputs
browser_fill_form(fields)         → Fill multiple fields
browser_select_option(ref, values)→ Select dropdowns
browser_press_key(key)            → Keyboard actions
```

### 3. Verify
```
browser_snapshot()           → Confirm state changed
browser_take_screenshot()    → Visual verification
browser_console_messages()   → Check for errors
browser_network_requests()   → Verify API calls
```

### Repeat until workflow is complete.

## Available MCP Tools Reference

| Tool | Purpose |
|------|---------|
| `browser_navigate` | Go to URL |
| `browser_snapshot` | Accessibility tree (best for interaction) |
| `browser_take_screenshot` | Visual capture (best for verification) |
| `browser_click` | Click element by ref |
| `browser_type` | Type text into element |
| `browser_fill_form` | Fill multiple form fields |
| `browser_select_option` | Select dropdown value |
| `browser_press_key` | Keyboard input |
| `browser_evaluate` | Run JavaScript on page |
| `browser_wait_for` | Wait for text/element/time |
| `browser_tabs` | Manage browser tabs |
| `browser_file_upload` | Upload files |
| `browser_handle_dialog` | Accept/dismiss dialogs |
| `browser_navigate_back` | Go back |
| `browser_close` | Close browser |

## Implementation Tips

- **Always snapshot before interacting** — refs change after page mutations
- **Use `browser_wait_for`** after navigation or clicks that trigger loading
- **Prefer `browser_snapshot` over `browser_take_screenshot`** for finding elements
- **Use `browser_evaluate`** for complex data extraction or DOM manipulation
- **Chain tab operations** for multi-tab workflows

## Common Mistakes

- **Using stale refs**: Always re-snapshot after any page state change
- **Skipping wait**: Pages need time to load; use `browser_wait_for`
- **Screenshot for interaction**: Screenshots can't provide refs; use snapshot
- **Ignoring errors**: Check `browser_console_messages` when things fail
