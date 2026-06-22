/*
 * abc/mayhem/asan_options.c — ASan runtime option overrides.
 *
 * LeakSanitizer (LSan) is enabled by default when ASan is built with
 * -fsanitize=address on Linux.  LSan works by ptrace-attaching to the
 * target's own threads at process exit to scan for leaks.  Mayhem's
 * coverage-collection mode ALREADY runs the target under ptrace, so when
 * LSan tries to attach again it fails with:
 *   "ERROR: LeakSanitizer: ptrace(PTRACE_ATTACH, …) failed"
 * and the process aborts — producing 0 edges (has_critical_errors) even
 * when the code path is perfectly reachable.
 *
 * ABC compiles the whole logic-synthesis library (libabc.a) with
 * -fsanitize=address, embedding ASan instrumentation throughout.  A weak
 * __asan_default_options can lose to the runtime's own weak copy when the
 * whole instrumented archive is pulled in; a STRONG definition always wins
 * at link time regardless of link order or --whole-archive.
 *
 * This file provides a strong __asan_default_options that disables LSan
 * while keeping all other detectors (heap-overflow, use-after-free via
 * ASan; undefined behavior via UBSan) fully active.
 */

/* Strong (non-weak) definition — wins over the ASan runtime's weak copy. */
const char *__asan_default_options(void)
{
    return "detect_leaks=0";
}

/* Also suppress the LSan-level options interface as a belt-and-suspenders
 * measure: some LSan builds consult __lsan_default_options separately. */
const char *__lsan_default_options(void)
{
    return "detect_leaks=0";
}
