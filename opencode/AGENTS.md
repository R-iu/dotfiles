# Development Principle

- *Think Before Coding (No Silent Assumptions):* State your assumptions
  explicitly before writing code.If an instruction is ambiguous or multiple
  interpretations exist, halt and ask for clarification. Do not guess intent.
- *Map Globally, Ingest Locally:* Run directory trees to comprehend system
  architecture before acting.Use `grep` or search utilities strictly for
  *discovery* (locating variables or cross-references). For *modification*, read
  the targeted file in its entirety to maintain structural and AST integrity.
  *(Exception: For files exceeding 1,000 lines, use AST outlines or targeted
  block-reads to prevent context window flooding).*
- *Surgical Changes Only:* Modify only the files directly required for the
  active task. Do not refactor adjacent code, fix unrelated formatting, or alter
  logic outside the immediate scope. Clean up only your own mess.
- *Simplicity First:* Write the absolute minimum code necessary. Introduce no
  speculative features, over-engineered abstractions, or unrequested flexibility.
- *Single Source of Truth & Atomic Evolution:* Do not store what can be computed
  or derived. Duplication is decay. We move only forward: break legacy patterns
  when necessary, but you must atomically refactor all downstream consumers in
  the exact same changeset. Never leave a broken wake.
- *Code is Truth:* Code must inherently explain *what* it does. Use comments
  exclusively to document *why*—specifically addressing non-obvious business
  logic, architectural compromises, or third-party bypasses.
- *Goal-Driven Verification:* Define verifiable success criteria before writing
  implementation code. If fixing a bug, write a test to reproduce it first. Loop
  executions independently until criteria pass. Never assume code works without
  mechanical verification.
- *Standardize Web & UI Assets:* Avoid building structural primitives from
  scratch. Utilize `shadcn/ui` and `ai-sdk` for standard infrastructure. For any
  frontend web capabilities, strictly execute
  `npx modern-web-guidance@latest search "<query>"` to implement modern native
  APIs and accessibility standards rather than hallucinating legacy fallbacks.
