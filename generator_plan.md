# Trial generators using one-shot continuations

Working branch: `yves/fork_sub` (based on current `origin/blead`).

## Phase 0 — Baseline and instrumentation

Status: completed.

- Confirm branch ancestry and clean working tree.
- Record available baseline test results.
- Identify the runops boundary and the smallest focused harness.

Baseline:

- `make test_prep`: passed.
- `./perl -Ilib t/op/eval.t`: passed; only the suite's existing TODO tests
  reported as TODO failures.
- Working tree was clean before this plan file was created.

## Phase 1 — Process execution state

Status: completed.

- Add the internal process-state representation and save/restore primitives.
- Compile and run focused tests before proceeding to the runops hook.

Implementation notes:

- `PERL_PROCESS_STATE` records the opcode, cop/pad, stackinfo, value-stack
  bounds, mark/save/scope/temp stacks, regex context pointers, and execution
  flags needed at a boundary.
- `process_state_save()` and `process_state_restore()` are core-internal
  operations; they do not capture `JMPENV`, which must remain a fresh C-stack
  exception boundary for each run.
- The current implementation preserves ownership by retaining interpreter
  stack allocations and switching only their active pointers. Scheduler use
  and explicit detach/cleanup semantics are deferred to the next phase.

Validation:

- `make regen`: passed.
- Rebuilt `perl` with `CCACHE_DIR=/home/demerphq/git_tree/perldev/.ccache`:
  passed.
- `nm ./perl`: confirmed both process-state symbols are linked.
- `./perl -Ilib t/op/eval.t`: passed.

## Phase 2 — Opcode-boundary scheduler hook

Status: completed.

Implementation notes:

- Added an interpreter-local boundary callback and callback data pointer.
- `runops_standard()` and `runops_debug()` invoke it only after `pp_*()` has
  returned, passing the returned next op (or `NULL` at normal completion).
- A non-zero callback result returns `PERL_RUNOPS_BOUNDARY_YIELD`; an unset
  callback leaves existing execution unchanged.
- Debug-loop cleanup and high-water-mark restoration remain on the common path
  before a yield result is returned.
- Added a bounded round-robin scheduler driver which saves each process at a
  boundary, marks normal completion, alternates runnable states by quantum,
  detects a global boundary limit, and restores the caller state afterward.

Validation so far:

- `make regen`: passed.
- Rebuilt `perl` with the workspace-local `.ccache`: passed.
- `make test_prep` with the workspace-local `.ccache`: passed.
- `./perl -Ilib t/op/eval.t`: passed.
- `./perl -Ilib t/op/while.t`: passed.

## Phase 3 — Prompt and generator runtime

Status: runtime ownership layer in progress.

Implementation notes:

- Added generator lifecycle states, reserving zero as `INVALID` so zeroed
  storage cannot look like a valid generator.
- Added retained body/value ownership and explicit capture/free operations.
- Added resume logic with a fresh `JMPENV`, boundary capture, exhaustion, and
  failed-generator handling. The compiler-side body setup and explicit yield
  operation are still pending.
- Nullable yielded values are retained conditionally, so an empty yielded
  value cannot be mistaken for an owned SV reference.

Compiler direction:

- Generator bodies may reuse the existing anonymous-CV compiler machinery.
  The specialized behavior belongs in the generator prompt/runtime, which
  owns the suspended call frame and process state.
- `yield` remains a real feature-gated keyword and dedicated opcode. It is the
  user-visible suspension point; automatic opcode-boundary yielding is only a
  trial/scheduler mechanism for validating continuation mechanics.
- The required `bison` and `Devel::Tokenizer::C` tools are now available. The
  first compiler increment adds the feature-gated `yield` keyword, grammar
  production, and dedicated opcode, with generated parser and keyword files
  regenerated in the same change. The opcode currently diagnoses use outside
  a generator; generator prompt context and suspension semantics remain
  pending.
- `generator { ... }` now parses through the existing anonymous-CV path and
  produces a code reference. It is still only a compiler shape: calling that
  code reference does not yet create or resume a generator continuation.
- The compiler marks these body CVs with an internal generator flag so the
  eventual invocation path can distinguish them from ordinary anonymous CVs.
- The trial runtime now has an explicit value handoff from `pp_yield` to the
  active generator boundary. A normal code-reference call still has no
  generator boundary installed and therefore reports the guarded diagnostic;
  persistent invocation bridging is the next runtime step.
- `generator_resume()` can now start a new body through the normal `call_sv()`
  call-frame setup, while subsequent resumes use the saved process state. The
  public expression still returns an ordinary CV, so this internal seam is not
  yet reachable through the trial Perl calling protocol.
- A first attempt to expose that seam through an anonymous XSUB wrapper was
  reverted after the first call segfaulted. The failure confirms that a
  continuation cannot retain temporary call machinery whose return path or
  exception bookkeeping lives in `call_sv()`'s C stack. The next runtime
  design must give the generator a persistent return operation/context before
  exposing a callable wrapper.
- The generator state now owns a persistent `LOGOP` entry operation for its
  body. New-body startup no longer depends on a temporary `call_sv()` op;
  wrapper exposure remains deferred until this entry path is exercised safely.
- The process snapshot now also carries the execution-local stash/default-GV,
  debugger COP, regex-interpolation, multideref, taint, warning, and magic
  flags. These are still copied field-by-field; the contiguous-record/one-
  assignment optimization remains a follow-up investigation.
- The callable wrapper is now backed by a persistent `LOGOP` entry frame and
  an owned stackinfo. Basic finite generators, closures, `undef` yields,
  exhaustion, and uncaught failure propagation have been exercised. Nested
  `eval` during a suspended body still needs exception-context integration;
  that remains an explicit blocker for completing this phase.

Follow-up design investigation:

- Assess reorganizing the process-local `PL_*` execution variables into a
  contiguous record, allowing save/restore to use a structure copy and, if
  safe, swapping the active record through one indirection. Check ABI,
  threaded-interpreter layout, GC visibility, and embedded/perl extensions
  before adopting such a layout.

Later phases remain as specified in the task handoff: generator prompt/runtime
integration, exception/cleanup integration, compiler body syntax, and protocol
hardening. This file is updated at each phase boundary and removed only after
all implementation and validation work is complete.
