# Trial generators using one-shot continuations

Working branch: `yves/fork_sub`.

This plan was restored during a completion audit because the previous removal
was not supported by sufficient evidence.

## Audit status

- [x] Process snapshots, opcode-boundary hooks, and private stack ownership
- [x] Generator syntax, one-shot resume protocol, and explicit `yield`
- [x] Nested eval, failure propagation, exhaustion, and re-entrancy
- [x] Feature/compiler diagnostics and documentation metadata
- [ ] DEBUGGING and sanitizer validation
- [ ] Destruction, GC, callback-context, and scheduler edge-case coverage
- [ ] Final full relevant validation and cleanup

The process-local `PL_*` fields remain field-by-field snapshots.  Keep the
follow-up investigation for a contiguous execution record that could be
copied or swapped through one assignment, subject to ABI, threading, and GC
constraints.
