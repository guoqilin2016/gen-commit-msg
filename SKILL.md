---
name: gen-commit-msg
description: "Generate a one-line Chinese commit message with a ticket prefix from current git branch and working tree diff. Use when asked to generate commit messages or run gen-commit-msg."
---

# Gen Commit Msg

## Run script

```bash
scripts/gen-commit-msg.sh
```

## Interpret output

- `KEY`: ticket key from branch name (e.g. `SPLOP-123`)
- `NAMES`: comma-separated function names from changed Go code; may be empty
- `DIFF`: full unified diff from `git diff --unified=0`

## Compose commit message

- Format: `KEY: 动词+对象+目的`
- Output exactly one line, <= 72 characters
- Prefer object from `NAMES`; if empty, use "名称候选"

## Error handling

If the script prints an error (no branch, no ticket, or no diff), output that error and stop.
