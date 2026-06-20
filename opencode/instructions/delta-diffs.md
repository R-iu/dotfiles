# Delta Diff Display

When showing file changes after edits, use the machine's configured `delta` style instead of describing or relying on opencode's built-in patch renderer.

Prefer commands such as:

```sh
git diff --color=always | delta
```

For files outside a git repository, use `diff -u` or `git diff --no-index --color=always` and pipe the output to `delta`.
