# llama.cpp performance investigation notes

This is a living log for the Terra llama.cpp investigation. Keep failed and
invalid experiments here as well as successful changes. Unless stated
otherwise, tests use `Kitchoon-V2-26B-A4B.i1-Q4_K_M.gguf`, an RTX 3070 Laptop
GPU (8 GiB), Ryzen 7 5800H, roughly 14 GiB of host RAM, and Linux 7.2.

Do not test with mmap disabled. This model and context size can exhaust host
memory when all model tensors are allocated instead of file-backed.

## Current production configuration

- `LLAMA_MMAP_SEQUENTIAL=1` enables the local whole-file sequential-advice
  patch during initial model loading.
- Router concurrency is one model and one slot.
- Kitchoon uses a 65,536-token context, F16 KV, 8 generation threads, 16 batch
  threads, batch 2048, and ubatch 1024.
- Prompt-cache RAM, idle-slot caching, and SWA context checkpoints are disabled
  to avoid competing with mmap-backed model pages.
- The fragment-aware phase-advice patch is wired into Nix with generation
  advice set to `normal`. A clean package build and direct-binary validation
  succeeded; activating that package as the system service remains outstanding.
- Backend sampling is enabled globally in `models.ini`; this also awaits
  the same system rebuild. Unsupported grammar/schema requests fall back to the
  CPU sampler automatically.

## Established results

### Whole-file sequential mmap advice fixes cold prompt paging

llama.cpp already called `posix_fadvise(POSIX_FADV_SEQUENTIAL)`, but on Linux
7.2 this did not establish the VMA advice needed to preserve useful mmap
readahead. The opt-in `MADV_SEQUENTIAL` patch produced an approximately 9.5x
cold-prompt improvement in the original regression reproduction.

This is a real improvement, but permanent sequential advice is not necessarily
correct for sparse MoE token generation. Linux sequential advice can discard
pages behind the read cursor, while expert routing revisits the file in a
non-monotonic pattern.

### Configuration measurements retained

| Experiment | Result | Decision |
| --- | --- | --- |
| Kitchoon `ubatch-size`: 512 -> 1024 | 2K prompt about 758 -> 1114 t/s; generation unchanged at about 27.8 t/s | Kept |
| Context: 65K -> 32K | Generation about 5.1% faster | Not kept; capacity tradeoff |
| Q8 KV | Marginal speed effect and output change | Not kept for Gemma 4 presets; F16 override remains |
| Generation threads: 8 -> 16 | About 34% slower | Rejected |
| `n-cpu-moe=24` | About 11% slower | Rejected |
| `fit-target=512` | No useful gain | Rejected |

### Generation is starved rather than GPU-compute-bound

A 60-second generation profile showed GPU SM utilization mostly around 21-32%
despite the memory allocation being full. Process counters included roughly
29,945 major faults, 117,217 total page faults, 0.54 instructions per cycle,
and 802 million cache misses during the sample. That points toward host-side
memory/storage stalls rather than saturated CUDA compute.

One pathological request under permanent whole-file sequential advice added
about 946,691 major faults and 106 GiB of process read I/O for only 256 output
tokens. This strongly suggests sequential drop-behind plus sparse-expert
refaulting, although page-cache state makes raw throughput from different runs
non-comparable without care.

## Phase-aware mmap experiment

Patch: `patches/llama-mmap-phase-advice-env.patch`

Hypothesis: retain sequential advice for prompt prefill, then cancel it for
sparse MoE generation with either normal or random advice. The server is
currently single-slot, so changing advice on the model-wide mapping does not
introduce cross-slot phase races.

The first implementation advised the original `[base, base + file_size)`
mapping after load. This was wrong: llama.cpp unmaps the fragments copied to
the GPU, leaving holes in that address range. Both phase transitions failed
with `ENOMEM` from `posix_madvise`.

An invalid run from that implementation measured:

- 2302-token prompt: 165.44 t/s
- 128-token generation: 10.47 t/s
- major-fault delta: 568,043
- read-I/O delta: about 11.5 GiB

Do not use that run to compare random versus normal advice. The log proved
that neither requested transition covered the surviving CPU mappings.

The patch now iterates `llama_mmap::impl::mapped_fragments`, which is updated by
`unmap_fragment`, and reports transition failure at the slot level. A fresh
patch-application check and incremental compile both succeed.

Fragment-aware runtime results:

| Generation advice | Result | Fault/I/O observation |
| --- | --- | --- |
| `random` | Did not finish 128 generated tokens inside 60 seconds | More than 3.06 million major faults and 23.2 GiB of reads before abort |
| `normal`, cold 2302 + 128 | Prompt 154.53 t/s; generation 18.46 t/s | About 59k major faults and 13.0 GiB of reads for the whole request |
| `normal`, later 93 + 256 | Prompt 18.33 t/s; generation 21.52 t/s | About 15.3k major faults and 2.98 GiB of reads for the whole request |

`random` is rejected. It prevents readahead even though each selected expert
slice is consumed sequentially. `normal` successfully cancels sequential
drop-behind while retaining adaptive readahead. Absolute throughput in these
runs was depressed by the immediately preceding random-advice fault storm, so
the useful result is the qualitative and fault-count separation, not a claim
that 21.52 t/s is the final warm steady-state speed.

### Clean Nix package validation (2026-10-19)

The package built successfully as
`/nix/store/5fj07h3943glbimd4b14pwzx6pbcc0ni-llama-cpp-0.6.0`, with CUDA
architecture 86 only. All 48 package tests passed. The package was not switched
into the running NixOS system; its `llama-server` was launched directly on an
isolated port with the production Kitchoon arguments and both mmap environment
variables.

| Request | Prompt | Generation | Major faults | Read I/O |
| --- | --- | --- | --- | --- |
| 93 + 256, first request | 24.96 t/s | 20.96 t/s | 24,129 | 3.93 GB |
| 93 + 512, later request | 46.03 t/s | 22.12 t/s | 2,565 | 0.91 GB |

Both requests completed normally and the server logged no failure to set or
switch mmap advice. The longer generation did not develop the escalating
refault/read-amplification behavior seen with permanent sequential advice; its
fault and read rates instead fell sharply after the cache warmed. This is
strong enough to accept the fragment-aware `normal` switch as a deployment
candidate, while normal real-use observation after activation is still useful.

## Incremental build harness

The normal Nix package builds every CPU dispatch variant and CUDA SASS for ten
architectures (`75;80;86;89;90;100;103;107;120;121`). A clean patch build has
758 targets and spends most of its time recompiling unchanged CUDA templates.

For experiments, `/tmp/llama-cpp-dev` is a writable copy of the exact pinned
source with all Nix patches applied. It is configured through the package's
`nix develop` environment, targets only CUDA architecture 86, and retains the
normal CPU dynamic-dispatch variants. Its first `llama-server` build took
about seven minutes. Rebuilding the corrected mmap and server-context files
took about 27 seconds and reused every CUDA object.

The development binary needs this at runtime because the Nix post-install
driver-runpath hook has not run:

```sh
LD_LIBRARY_PATH=/run/opengl-driver/lib
```

For a final NixOS package, consider appending
`-DCMAKE_CUDA_ARCHITECTURES=86`; Terra has one fixed Ampere GPU and does not
benefit from shipping kernels for nine other architecture families.

## Next tests

1. Keep speculative source edits and executable tests in
   `/tmp/llama-cpp-dev`. Accumulate measured winners, then integrate them into
   Nix as a batch instead of using clean Nix derivations as the edit/test loop.
2. Activate the already-built phase-aware package at a convenient point and
   observe ordinary longer conversations for any renewed paging amplification.

## Experiment status and deferred system-assisted tests

Use these labels consistently in future work:

- **Accepted:** a measured improvement that survives appropriate controls.
- **Rejected:** an experiment that was actually run and measured as neutral or
  worse. A permission failure or missing facility is not a rejection.
- **Inconclusive:** a run occurred, but its controls or noise do not support a
  decision.
- **Deferred:** the idea remains technically plausible, but testing needs a
  reboot, temporary privilege, kernel/sysctl change, or other coordination.

Status of system-assisted paths:

1. **Function-level CPU profiling: completed.** The owner temporarily lowered
   `kernel.perf_event_paranoid` to `1`; the resulting call graph and hardware
   counters are recorded below. The temporary value remains approved for this
   investigation and should eventually be restored to `2`.
2. **Kernel MM/I/O tracing.** With temporary root access, inspect the available
   filemap-fault, page-cache, block-I/O, and scheduler tracepoints, then trace a
   short controlled decode. The exact tracepoints should be discovered on the
   running kernel rather than assuming names or rebuilding the kernel first.
3. **Kernel-version A/B.** Booting one known-good older kernel alongside 7.2 and
   repeating the same cold/warm mmap workload would help determine whether the
   original paging regression is kernel-specific. This needs a NixOS generation
   and reboot, so coordinate it rather than silently dropping the hypothesis.
4. **Block-device readahead A/B.** The current NVMe readahead is 128 KiB. A
   bounded, reversible test at one or two larger values may show whether the
   sparse expert access pattern benefits, despite the negative defragmentation
   result. Record and restore the original sysfs value; treat this as lower
   priority than profiling because it affects all traffic on the device.

Do not persist a sysctl, kernel option, trace facility, or device setting in
NixOS merely to unblock an experiment. Record the proposed temporary change,
its scope, restoration command/value, and expected evidence, then coordinate
it with the machine owner. Promote it to configuration only after a measured
win or a continuing diagnostic need.

## Benchmark coverage

A result from one fixed prompt is a useful screening result, not automatically
a broad conclusion. Prompt length changes the balance between prefill, cache
population, and decode; prompt content can also change MoE expert routing and
therefore which file-backed weights are touched.

Use a staged matrix rather than multiplying every exploratory run:

1. **Fast screen:** one short fixed prompt and 256 generated tokens, with an
   A/B/A or equivalent control when system state may drift.
2. **Promising candidates:** short, medium, and long prompts (roughly 32-128,
   512-1K, and 2K-4K tokens) while keeping generation length comparable.
3. **Routing/content coverage:** include at least prose/conversation, code or
   structured reasoning, and one deliberately different subject or language.
   Preserve the exact prompt text with the result.
4. **Decode-duration coverage:** use a longer 512-1K-token generation before
   accepting changes intended to improve steady-state decode or paging.
5. **Cache-state coverage:** label cold, partially warm, and warm tests; never
   average them together. Compare prompt throughput, generation throughput,
   major faults, bytes read, and peak memory independently.

Keep sampling deterministic where practical (fixed seed and sampling settings),
and distinguish a real throughput improvement from altered output, fewer
generated tokens, reduced context, changed expert count, or lower numerical
quality. Expensive profiling does not need the whole matrix: use the smallest
case that reproduces the measured bottleneck, then validate any resulting fix
against the broader set.

## Short execution-path screens (2026-10-20)

These used build 11429 (`d812350`), an 81-token technical prompt, 768 greedy
output tokens, seed 1234, and the normal 65K/F16-KV/automatic-fit server shape.
All compared outputs had SHA-256
`84f5356e96722c77d132fef15b7d4b34d7ae3a2840e710aca136e4fe3f455a86`.

### Repacking versus the alternate CPU path: neutral

| Run | Mode | Generation speed |
| --- | --- | ---: |
| warm-up | repack | 21.6278 t/s |
| A1, same process | repack | 22.3633 t/s |
| B, fresh process | `--no-repack` | 21.5739 t/s |
| A2, fresh process | repack | 21.5653 t/s |

The apparent A1 advantage was process/page warm-up: the fresh-process B and A2
results differ by only 0.04%. Disabling repacking therefore produced no useful
speed change in this screen. This does not yet prove which `MUL_MAT_ID` kernel
ran; lightweight kernel-selection instrumentation would be needed before
making a claim about the tiled path itself.

### Backend sampling: measured small win, enabled

An interleaved B/A/B/A sequence in one warm process compared per-request
`backend_sampling: true` (B) against ordinary CPU sampling (A):

| Run | Sampling | Generation speed | Wall time |
| --- | --- | ---: | ---: |
| B1 | backend | 22.6626 t/s | 33.844 s |
| A1 | CPU | 22.1055 t/s | 34.697 s |
| B2 | backend | 23.1705 t/s | 33.102 s |
| A2 | CPU | 22.5382 t/s | 34.031 s |

The two-run averages are 22.9166 versus 22.3218 t/s, a 2.66% backend-sampling
lead. Greedy output was identical, so the gain was not obtained by changing the
generated sequence.

A follow-up used a properly templated technical chat and the phase-patched
build, again interleaving backend/CPU/backend/CPU in one warm process. Backend
sampling averaged 23.2387 t/s and CPU sampling 23.1508 t/s, only +0.38%; all
four reasoning outputs had the same SHA-256
`5430e766454d946e277a637da6aebc841602a0e45c22f135a965fc1f5b984932`.
That particular templated prompt shows the effect can nearly disappear, so the
feature is not a universal generation-speed multiplier. A later
production-shape 65K/F16-KV A/B/A screen was clearer: matching first requests
were 21.63--21.59 t/s on CPU versus 22.89 t/s on the backend, while matching
warm requests were 23.49 versus 25.46 t/s. Output was byte-identical.

The actual stochastic chain (`temperature=0.8`, `top_k=64`, `top_p=0.95`,
`min_p=0.05`, fixed seed) was then switched per request in a single server.
An initial warm CPU/backend comparison reached 21.3430 versus 22.5654 t/s
(+5.73%), with identical generated bytes. That headline still contained page
state and request-order effects. A source-timing follow-up measured the whole
synchronized sampling critical section in a CPU/backend/CPU/backend sequence:

| Sampling arm | Critical section | Generation |
| --- | ---: | ---: |
| CPU A1 | 0.7668 ms/token | 19.19 t/s (still warming) |
| backend B1 | 0.0161 ms/token | 23.53 t/s |
| CPU A2 | 0.7679 ms/token | 23.20 t/s |
| backend B2 | 0.0163 ms/token | 23.58 t/s |

The stable A2/B2 pair is +1.63%, consistent with removing about 0.752 ms from
a roughly 43 ms token. Source inspection explains it: without a backend
sampler, `needs_raw_logits()` copies the full 262K-vocabulary float row to the
host and `common_sampler::set_logits()` constructs/scans the full candidate
array; backend sampling executes the supported chain in the graph and returns
the sampled token plus only required reduced data. The sampling section itself
is about 47x faster, but most token time is still model evaluation. All four
measured stochastic outputs had the same hash. Treat roughly 1-2%, not the
earlier 5-8%, as the defensible single-slot steady-state gain.

A JSON-schema request returned the same valid JSON in both arms. The backend
arm reported `backend_sampling: false`, with the expected server message that
grammar is incompatible and backend sampling was being disabled. This is the
safe fallback behavior wanted for tool/structured requests.

`backend-sampling = true` is therefore enabled globally in `models.ini`.
It avoids host-side full-vocabulary sampling and the associated synchronization
when supported, while grammars automatically retain the CPU path. It needs a
system rebuild/update before the packaged service uses it.

### Physical-core affinity: neutral

Terra's topology was reconfirmed from sysfs: adjacent logical CPUs are SMT
siblings (`0-1`, `2-3`, and so on). The phase-patched server was pinned to
`0,2,4,6,8,10,12,14`, preserving eight worker threads on eight distinct cores.
On the warm templated chat it generated 22.5857 t/s versus 22.6643 t/s under the
default scheduler (-0.35%), with identical output. Do not add a permanent
affinity policy for throughput on this evidence.

### CPU power-profile screen: inconclusive and not compelling

The machine normally uses `amd-pstate-epp`, the `powersave` governor,
`balance_performance` EPP, and the desktop `balanced` profile. A reversible
screen switched to `performance` (`performance` EPP), ran the same deterministic
72 + 256 technical chat, and restored `balanced`. Output length and content
were unchanged.

The first sandwich was dominated by warming: balanced/performance/balanced
decode measured 20.31/20.33/23.29 t/s. A subsequent warm performance/balanced
pair measured 21.42/21.19 t/s, only +1.1%, while both were slower than the
immediately preceding balanced leg. Thermal and page-cache drift are larger
than any demonstrated profile effect. Leave the machine on `balanced`; revisit
only with simultaneous clocks/power/temperature sampling if later evidence
points to frequency throttling.

The kernel-matched `perf` 7.2.10 tool is available through
`nix shell nixpkgs#linuxPackages_latest.perf`. The owner temporarily changed
`kernel.perf_event_paranoid` from `2` to `1`, enabling the function-level and
hardware-counter profiles below. They explicitly approved leaving it at `1`
while this investigation continues. No persistent NixOS setting was added;
restore it with `sudo sysctl -w kernel.perf_event_paranoid=2` afterward.

### Function-level profile: CPU quantized dots dominate; OpenMP is not the lever

The owner temporarily set `kernel.perf_event_paranoid=1`. A 499 Hz attached
user-space `cpu-clock` profile of one warm, templated 91 + 256 chat request
captured 46,897 samples with zero losses. DWARF recording reduced that request
to 20.43 generation t/s, so use the profile for attribution rather than as a
throughput result.

| Self samples | Symbol |
| ---: | --- |
| 36.99% | `ggml_vec_dot_q4_K_q8_K` |
| 25.08% | `gomp_barrier_wait_end` |
| 15.75% | `ggml_vec_dot_q8_0_q8_0` |
| 12.00% | `ggml_vec_dot_q5_0_q8_0` |
| 5.67% | `gomp_team_barrier_wait_end` |
| about 1% | CUDA host-to-device submission/copy path |

The eight participating threads had nearly equal shares of each dot kernel and
of barrier waiting. This is not one slow worker holding up seven others. The
profile locates about 65% of sampled CPU time in three quantized dot products,
with Q4_K alone accounting for about 37%; it does not show CUDA submission as a
large host-side cost.

The roughly 31% OpenMP-barrier share looked actionable, but exact local testing
rejected that interpretation. Rebuilding with upstream's existing
`GGML_OPENMP=OFF` threadpool path produced 22.9531 and 23.1103 t/s, while the
restored OpenMP A2 controls produced 23.0010 and 23.1100 t/s. All outputs were
byte-identical. OpenMP and the internal spin barrier are effectively tied on
this Linux/Zen 3 host; sampled barrier bookkeeping is not equivalent to
recoverable wall time. This agrees with upstream evidence that the very large
non-OpenMP gain is specific to the sleep-only MinGW barrier implementation:
<https://github.com/ggml-org/llama.cpp/issues/26200>.

A matching warm OpenMP `perf stat` request generated at 23.0221 t/s and counted
338.53 billion cycles, 179.35 billion instructions (about 0.53 aggregate IPC),
8.62 billion cache references, 504.08 million cache misses, 6.77 billion
front-end-stalled cycles, and 1,513 major faults. The backend-stall event is not
supported by this PMU. The low IPC with only about 2% of cycles attributed to
front-end stalls is consistent with execution/data stalls in the quantized dot
path, but these generic cache events are not precise enough to distinguish DRAM
bandwidth from cache latency.

Exact upstream PR 28212 was then applied to the profiled Q4_K/Q5_K x86 dot
kernels. On CPUs with VNNI it fuses multiply-add instructions; Zen 3 uses its
bit-identical dual-accumulator AVX2 fallback. Rebuilding only
`ggml-cpu-haswell.so` took two compile/link steps. The patch measured 22.6954
and 23.0133 t/s versus restored-original controls of 23.0010 and 23.1100 t/s,
an average -0.87%, with identical output. Reject it on Terra and do not carry a
local copy: <https://github.com/ggml-org/llama.cpp/pull/28212>.

Upstream PR 22181 was an even closer architectural match: it replaces the
`VPHADDW` reduction in the Q4_K/Q5_K AVX2 kernels and reports a 4-10% complete
inference improvement on Zen 4. Applied verbatim to the same Haswell dispatch
module, it measured 21.2744 and 21.9117 t/s versus the 23.0555 t/s restored
control average, about -6.4% on Terra's Zen 3. Output remained byte-identical.
The proposed vertical reduction increases cost on this microarchitecture;
reject it and do not carry it locally:
<https://github.com/ggml-org/llama.cpp/pull/22181>.

The temporary sysctl still reads `1`. The owner explicitly approved leaving it
there while profiling continues; no persistent NixOS configuration change was
made. Restore it with `sudo sysctl -w kernel.perf_event_paranoid=2` when this
investigation no longer needs sampling access.

### Routed-expert tensor inventory

Read-only GGUF metadata inspection ties the three hottest profile symbols
directly to the model's routed experts rather than to miscellaneous dense work.
The model has 30 MoE layers and 659 tensors. Every layer has:

- `ffn_gate_up_exps.weight`: Q4_K, shape `[2816, 1408, 128]`, 285,474,816
  bytes (about 272.25 MiB);
- `ffn_down_exps.weight`: shape `[704, 2816, 128]`, either Q8_0 at
  269,615,104 bytes (about 257.13 MiB) or Q5_0 at 174,456,832 bytes (about
  166.37 MiB);
- a tiny F32 expert scale tensor.

The Q8_0 down tensors occur in layers 0, 1, 2, 5, 8, 11, 14, 17, 20, 23, 26,
27, 28, and 29; the other 16 use Q5_0. With 24 expert layers executing on the
host and eight of 128 experts selected, decode touches roughly 0.7 GiB of
quantized expert weights per token. At 23 t/s that is on the order of 16 GiB/s
of useful expert data before cache-line, page-fault, and activation overhead.
This estimate is deliberately approximate, but it explains both the hot
Q4_K/Q8_0/Q5_0 dot symbols and why expert residency/locality matters more than
another global compiler flag.

### Current-upstream MoE GPU cache: rejected on the 8 GiB GPU

A standalone build of upstream build 11741 (`1b29621ba`) tested the merged
`--moe-cache-mib` implementation without reimplementing it locally. Automatic
fit retained the 1 GiB device-margin target, so cache memory displaced ordinary
GPU-resident model tensors rather than risking shared VRAM or OOM.

| Cache | Host experts | Slot coverage | 128-token hit rate | Uploaded | Decode |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 256 MiB | 11,963.88 MiB | 2.1% | 14 / 25,951 = 0.05% | 96,965 MiB | 5.52-6.09 t/s |
| 1,024 MiB | 12,841.12 MiB | 7.9% | 4,869 / 28,025 = 17.37% | 85,949 MiB | 5.89 t/s |

The 256 MiB cache is smaller than the cyclic per-token expert working set and
almost completely thrashes. One GiB crosses the approximate one-token capacity
threshold and does produce hits, but still uploads about 86 GiB in a 128-token
screen and is slower than the CPU-on-miss path by nearly 5x. It also reduced
the ordinary CUDA model buffer from 4,028 MiB at 256 MiB cache to 3,153 MiB at
1 GiB cache. Intermediate sub-1-GiB sizes cannot solve the observed working-set
problem, so they were deliberately skipped. This implementation is not useful
on Terra; a CPU-on-miss/async-fill design or materially more spare VRAM would
be a different experiment.

### Current upstream itself: unexpectedly promising, attribution pending

With the MoE cache disabled, build 11741 produced 28.7037 t/s on the warm
768-token control, versus roughly 22-23 t/s on build 11429. Prompt throughput
was 65.999 t/s once file-backed weights were warm. The first cold prompt was
still catastrophic without the local phase-advice patch (0.891 t/s and about
1.30 million major faults), so this upstream build is not yet a production
replacement.

An exact `d812350` rebuild in the same build tree/toolchain reproduced the old
result: 22.9204 t/s, with the same output hash as build 11429. That confirms a
source-era difference rather than a Nix-versus-standalone compiler effect.
However, current upstream's unconstrained greedy output diverged immediately
and both direct-completion outputs were repetitive nonsense; a sparse MoE can
therefore take a different routing path. The apparent 25% lead is not yet a
valid same-work performance win.

Two likely merged optimizations were transplanted verbatim onto `d812350` and
screened with 256 forced newline tokens so the feedback token IDs stayed
identical:

| Exact upstream change | Baseline | Patched | Result |
| --- | ---: | ---: | ---: |
| CUDA MMQ Stream-K work cap, PR 30553 | 23.0959 t/s | 22.8545 t/s | -1.05%; neutral/reject here |
| AVX2 tiled accumulator reduction, PR 30296, `--no-repack` | 22.4740 t/s | 23.2267 t/s | +3.35% on synthetic forced tokens |

The AVX2 result did not generalize. A properly templated technical chat with
byte-identical reasoning text measured 23.2173 t/s before and 23.2366 t/s after
the patch (+0.08%). It therefore remains upstream code, not a local patch to
carry. These tests also confirm that the newer Stream-K patch is not the source
of the large unconstrained difference. Any continued attribution must preserve
the evaluated token stream or use a representative chat workload whose output
remains identical.

## Cross-engine and research leads (2026-10-20)

The broader MoE literature consistently treats prefill and decode as different
scheduling problems. This matches the local evidence: prefill wants dense,
batched GPU work and sequential file access, while decode wants a small and
changing expert working set with minimal synchronization.

- KTransformers assigns attention/shared experts to the GPU and routed experts
  to CPU kernels rather than treating a transformer layer as the placement
  unit: <https://github.com/kvcache-ai/ktransformers/>.
- DuoServe-MoE uses separate prefill/decode policies, overlaps prefill copies
  with computation, and predicts the next layer's decode experts from routing
  traces: <https://arxiv.org/abs/2509.07379>.
- The 2026 YALIS work "Speculating Experts Accelerates Inference for
  Mixture-of-Experts" predicts future routing from the current quasi-hidden
  state and overlaps expert transfers with compute. It reports a 9-14% TPOT
  reduction on Qwen3-30B-A3B, identifies early layers as the least predictable,
  and raises prediction hit rate to about 90% with a small distilled estimator.
  This strongly supports trying a real hidden-state/router predictor instead of
  extending the local ID-only table. For exact inference here, prediction must
  initiate prefetch only; executing the predicted expert in place of the true
  router choice changes model math: <https://arxiv.org/abs/2603.19289> and
  <https://github.com/axonn-ai/yalis/tree/offload_prefetch>.
- The new Strata research prototype is aimed at models whose experts remain on
  NVMe every token. Its useful ideas are multi-layer lookahead, measured
  co-activation layout, admission control, and expert-major prefill. Its own
  README is explicit that it has not yet run a real model and that its large
  prefill result uses synthetic weights. On Terra, the phase-mmap fix has moved
  NVMe mostly out of the warm steady-state path, and llama.cpp's CPU
  `MUL_MAT_ID` already groups a ubatch's rows by expert before multiplying, so
  transplanting the headline scheduler is not justified without a new trace:
  <https://github.com/Cintu07/strata>.
- MoEpic divides each expert vertically, caches a segment of more hot experts,
  and assigns different cache budgets/split ratios per layer. That directly
  addresses the local observation that a 1 GiB whole-expert cache has only
  about 50% predicted residency. Its published system, however, uses PyTorch,
  FP16 Qwen1.5-MoE/Mixtral, and eight A6000 GPUs. A llama.cpp experiment would
  need quant-block-aligned row segments, partial-output accumulation, and a
  CPU-on-miss fallback before the paper's gains are comparable:
  <https://arxiv.org/abs/2509.08342>.
- Fiddler avoids copying missing expert weights to the GPU at all: it transfers
  the much smaller activation to CPU, computes the miss there, and returns the
  output. This is the systems-level ancestor of the CPU-on-miss path already
  used locally; the opportunity is overlapping it with GPU-resident hits:
  <https://arxiv.org/abs/2402.07033> and
  <https://github.com/efeslab/fiddler>.
- MoE-Infinity uses request-level activation traces for cache and prefetch
  decisions rather than a global fixed hot set. SiDA-MoE goes further with an
  offline-trained activation predictor. The local lightweight predictor below
  is much less accurate, but its cross-workload result supports adaptive
  request/session state before considering a trained side model:
  <https://arxiv.org/abs/2401.14361> and
  <https://proceedings.mlsys.org/paper_files/paper/2024/file/698cfaf72a208aef2e78bcac55b74328-Paper-Conference.pdf>.
- PowerInfer profiles activation hotness offline and reserves GPU memory for
  hot weights while leaving cold work on the CPU. Its implementation also
  chooses to leave KV on the CPU to free GPU residency, though that particular
  trade is not automatically right for this model:
  <https://arxiv.org/abs/2312.12456>.
- `ik_llama.cpp` independently developed IQK CPU matrix/matvec paths and
  reports AVX2 decode improvements for several legacy K quants. Its ordinary
  AVX2 `ggml_vec_dot_q4_K_q8_K` is effectively the same loop as llama.cpp's;
  any gain must be tested with its wider dispatch, layout, and scheduling path
  intact rather than attributed to that one function:
  <https://github.com/ikawrakow/ik_llama.cpp>.
- The purpose-built `gemma4-engine` documents this exact A4B shape and reports
  useful bandwidth accounting. Its large headline result combines a lower-bit
  expert quant (a quality/storage trade) with n-gram lookup decoding on highly
  predictable output; its own API workload saw only 25% n-gram acceptance.
  The directly transferable ideas are phase-specific benchmarking and fused
  gate/up execution, not the headline 230 t/s. This GGUF already stores gate
  and up together as `ffn_gate_up_exps.weight`, so verify the executed kernel
  before attempting another fusion: <https://github.com/gatordevin/gemma4-engine>.

There are also two materially different GPU-cache designs in llama.cpp forks:

1. A GPU-side cache that runs cache hits on the GPU and cache misses on the
   existing CPU path, so a miss need not synchronously upload an expert. This
   is the design proposed in discussion 24528:
   <https://github.com/ggml-org/llama.cpp/discussions/24528>.
2. A persistent per-tensor GPU slot pool that remaps expert IDs, uploads misses,
   and bypasses the pool for prefill/ubatches too large for it. It recommends
   two to four times top-k slots and is described in discussion 28248:
   <https://github.com/ggml-org/llama.cpp/discussions/28248>.

The independent TurboQuant hybrid fork implements the first class rather than
only describing it: cache hits run on GPU, misses remain on the stock CPU
`MUL_MAT_ID`, admissions are asynchronous, and a heat-aware policy limits
churn. Its published matrix includes small or negative-like gains on some
models and large gains on others, which is a useful warning against assuming a
cache win from hit rate alone. The repository is a squashed source snapshot,
not a clean patch series against current llama.cpp, so benchmark it as a
separate engine before attempting any port:
<https://github.com/giveen/llama-cpp-turboquant-hybrid/blob/master/docs/backend/MOE-CACHE.md>.

### TurboQuant CPU-on-miss/GPU-on-hit fork: fast microbenchmark, invalid output

The TurboQuant hybrid fork at commit `15b4981` was built in the reusable
incremental tree `/tmp/llama-cpp-hybrid`, targeting only CUDA architecture 86.
The local whole-file `MADV_SEQUENTIAL` control and fragment-aware generation
switch were ported into that tree. The fork is a squashed source snapshot, so
this was an engine screen rather than a patch applied to the packaged
llama.cpp.

An isolated same-placement `llama bench` comparison put all 30 routed-expert
layers on the CPU and disabled repacking in both arms. It used mmap,
`LLAMA_MMAP_SEQUENTIAL=1`, eight CPU threads, F16 KV, and a short context. The
1 GiB cache allocated 550 slots; a verbose run ended at 239,406 / 429,128
residency probes hit (55.8%), 21,918 fills, 21,368 evictions, and no fill or
dispatch failures. After the mmap control stabilized the baseline, three
256-token samples measured:

| Arm | Generation | Std. dev. | Relative |
| --- | ---: | ---: | ---: |
| Canonical CPU experts, cache off | 16.37 t/s | 0.26 t/s | baseline |
| Same placement, 1 GiB hybrid cache | 20.74 t/s | 0.37 t/s | +26.7% |

A two-sample capacity screen suggested that the cache mechanism itself scaled:
512 MiB reached 18.55 t/s, 1,536 MiB reached 25.80 t/s, and 2,048 MiB reached
27.02 t/s. These short-context numbers are not production candidates because
65K F16 KV and the large ubatch need the same VRAM.

The fork's 65K-aware benchmark fitter changed the conclusion. Ordinary fit
kept approximately expert layers 0-9 on the GPU and reached 25.44 t/s. Cache
auto moved all experts to the host, projected a 1,589 MiB pool, and reached
23.07 t/s. `soft` retained only two complete expert layers, projected a
556 MiB pool, and fell to 20.61 t/s. On this card, whole-layer expert residency
is a better use of constrained VRAM than evicting those layers to fund the
cache.

Most importantly, real server validation rejected the cache implementation:

- The ordinary 65,536-context/F16-KV server allocated successfully, used
  6,718 MiB VRAM, generated coherent deterministic output, and measured 20.45
  then 22.24 t/s on two identical 256-token requests after switching mmap
  advice to `normal` for generation.
- An explicit all-30-host-expert plus 1 GiB-cache server also allocated safely
  and used only 4,710 MiB VRAM. It produced severely divergent, repetitive
  text on both identical requests and was slower at 15.34 then 18.93 t/s.
  This is not credible near-tie rounding. Do not use this fork's cache for
  Kitchoon without first finding and fixing the numerical/execution bug.
- Server policy also differs from `llama bench`: `--moe-cache auto` with
  `-ngl auto` kept stock placement and left the cache dormant, while literal
  `-ngl 99` was considered user-fixed and the fitter refused to adjust it.
  The subsequent full-GPU allocation failed safely with CUDA OOM. Explicit
  `-ncmoe 30 --moe-cache 1024 --no-repack` was required to exercise the cache
  at the production context.

This is a useful negative result. The synthetic speedup proves that
CPU-on-miss/GPU-on-hit can save substantial wall time on this hardware, but
`llama bench` does not validate logits or generated text and therefore hid a
fatal correctness problem. Any future port must add logits/perplexity parity
tests before throughput tuning. No cache changes were wired into Nix.

The tested build-11741 `--moe-cache-mib` path behaved like the second class:
its 1 GiB cache uploaded about 86 GiB in 128 tokens and was nearly five times
slower. Together, these results still do **not** reject CPU-on-miss/GPU-on-hit
as a general design or a static profiled hot set; they reject the two tested
implementations for production use here. Locally, the top eight experts per layer account for
54.66% of selections, so static residency could avoid churn; however, eight
gate/up plus down experts across the 24 host layers consume roughly 0.7 GiB and
would displace ordinary model tensors on this 8 GiB GPU. A serious prototype
must therefore hold the non-expert placement constant, report bytes uploaded
and hit rate, and compare the saved CPU dot work against both added
synchronization and displaced GPU work. Do not call a cache successful merely
because its hit counter rises.

### ik_llama.cpp matched-placement screen: small promising gain

`ik_llama.cpp` commit `565f08d1eac9b73bd39fa369b3ffc154e8394b27`
was built separately for CUDA architecture 86. Host expert weights remained
mmap-backed by setting `GGML_CUDA_NO_PINNED_WEIGHTS=1`; no no-mmap run was used.
Its scheduler reports fused MoE, fused gate/up, fused matrix multiplication,
and active-expert-only scheduling.

The production 65K/F16-KV shape is not currently viable in that engine on this
GPU: its fit calculation requires roughly 14.95 GiB for KV and fails before
allocating the model. This was a safe startup failure, not an OOM. At 8K,
ordinary automatic fit was initially an invalid engine comparison because
ik_llama put expert layers 4-29 on CPU while mainline put only layers 8-29 on
CPU. The resulting mainline lead therefore measured placement, not kernels.

A corrected test explicitly kept the same 26 expert layers, 4-29, on CPU in
both engines. Both used 8K F16 KV, `t8/tb16`, `b2048/ub1024`, mmap-backed
weights, and generated the same 256 forced newline tokens. Warm decode in an
A/B/A sequence was:

| Engine/leg | Warm generation results | Mean |
| --- | --- | ---: |
| llama.cpp build 11429, A1 | 21.10, 21.73 t/s | 21.41 t/s |
| ik_llama.cpp, B | 21.62, 22.31, 22.26, 22.48 t/s | 22.17 t/s |
| llama.cpp build 11429, A2 | 21.50, 21.69 t/s | 21.59 t/s |

Against all four warm mainline samples (21.50 t/s), ik_llama averaged about
3.1% faster. Keep this as a promising engine/scheduler lead, not yet as an
accepted production change: 65K is unsupported by its current allocation
strategy, the fork differs in many places, and a representative templated chat
plus longer run still needs validation. Its scheduler-level expert prefetch is
also a different mechanism from the rejected late `MADV_WILLNEED` hook, but it
is lower priority because the warm matched result had little paging pressure.

## Broad execution-pipeline brainstorm (2026-10-19)

The mmap regression was one severe fault in one layer of the stack. Do not let
it constrain future hypotheses to file advice. For this model, relevant layers
include decoding strategy, graph construction, tensor placement, CPU and CUDA
kernels, backend scheduling, PCIe transfers, KV/attention work, sampling, host
thread scheduling, and finally virtual-memory/storage behavior.

These are hypotheses and experiment candidates, not conclusions. The priority
reflects the present Kitchoon/RTX 3070/5800H evidence.

### Priority A: bounded experiments with a plausible material win

1. **Test the newly merged upstream MoE GPU expert cache.** The installed
   package is build 11429 at `d812350`; its help and source contain no
   `--moe-cache-mib`. Upstream merged the option in PR 29887 just afterward.
   It caches repeatedly selected host-resident experts in spare VRAM, targeting
   exactly the routing locality already measured here. This is fundamentally
   different from `MADV_WILLNEED`: a hit avoids host expert computation/reads
   instead of merely requesting those same pages earlier.

   Use a separate newer upstream checkout and incremental build before trying
   to rebase the local mmap patches or change Nix. Compare cache off against a
   few small budgets that an 8 GiB card can really sustain, such as 256, 512,
   and 1024 MiB. Read the actual placement, dedicated-VRAM use, cache hit rate,
   PCIe traffic, and fallback logs. Test varied prompts long enough to warm the
   cache, and verify greedy output. A larger-GPU benchmark is not evidence that
   a small cache on Terra wins: the merged design uploads misses and moves the
   operation to the GPU, while alternate CPU-on-miss designs sometimes perform
   better by retaining CPU/GPU parallelism. Reject it here if limited cache
   capacity or miss-upload overhead loses to the current CPU path.

   Sources: <https://github.com/ggml-org/llama.cpp/pull/29887> and
   <https://github.com/ggml-org/llama.cpp/discussions/24528>.

2. **A/B the two CPU expert-kernel families already in this build.** Default
   weight repacking gives expert tensors an `extra` buffer. In this source, the
   newer tiled Q4_K `MUL_MAT_ID` path explicitly declines tensors with
   `src0->extra != NULL`, so `--no-repack` is not merely a loading tweak: it can
   select a different decode kernel. Confirm kernel counts with lightweight
   instrumentation, then run A/B/A with and without repack. Compare warm decode,
   memory footprint, faults, and output; also include a medium prefill because
   the two paths may trade prompt speed against token speed. If neither kernel
   dominates, a source patch could choose per operation shape rather than use a
   global flag.

3. **Replace contiguous layer offload with measured placement.** `n-cpu-moe`
   and auto-fit tend to make a contiguous layer decision, but the routing trace
   showed large per-layer differences: top-eight concentration ranged from
   41.61% to 82.68%, and distinct experts ranged from 38 to 103. Instrument
   per-layer CPU time, bytes/faults if practical, and stable routing entropy
   across several prompt types. With the same number of GPU-resident expert
   layers and the same VRAM budget, use tensor overrides to place the most
   expensive/least cache-friendly layers on CUDA rather than assuming layer
   order predicts cost. This preserves model math and expert routing. A useful
   source-level follow-up would teach the fitter a measured/static placement
   cost instead of adding a permanent hand-written regex list.

4. **Draftless speculative decoding was not useful in the first screen.** This build supports `ngram-simple`,
   `ngram-map-k`, `ngram-map-k4v`, `ngram-mod`, and `ngram-cache`; they can
   reduce the number of serial target-model decode steps without loading a
   second model. This is most promising for code, editing, structured output,
   and text that repeats prompt material, and may do nothing for unconstrained
   prose. Compare wall time and accepted/drafted counts across those workload
   types, not just raw target-evaluation t/s. Verification should preserve the
   target distribution, but greedy output must still be checked because a
   multi-token verification batch can select different kernels/summation order.
   Avoid `ngram-cache` until its reported cross-request slot-state issue is
   confirmed fixed or locally patched.

   Sources: <https://github.com/ggml-org/llama.cpp/blob/master/docs/speculative.md>
   and <https://github.com/ggml-org/llama.cpp/issues/27852>.

   A production-shape 65K/F16-KV server test used deterministic generation and
   checked the complete output. Ordinary explanatory prose found no useful
   draft sequence: output was bit-identical and throughput changed only from
   21.63 to 22.32 t/s, which is within the paging/run-order noise seen here.
   A deliberately copy-heavy Python-handler completion was more informative:

   | N-gram configuration | Accepted / drafted | Decode | Versus 23.92 t/s baseline |
   | --- | ---: | ---: | ---: |
   | Off | n/a | 23.92 t/s | baseline |
   | `ngram-simple`, default 12-token lookup / 48-token proposal | 81 / 493 (16.4%) | 15.58 t/s | -34.9% |
   | 12-token lookup / 16-token proposal | 81 / 176 (46.0%) | 21.05 t/s | -12.0% |

   Both speculative arms produced exactly the same correct code as the
   baseline. Shortening the proposal removed most rejected work but verification
   batches still cost more than the 81 accepted tokens saved. An 8-token
   proposal was shorter than the 12-token lookup key, produced no drafts, and
   measured 22.42 t/s. Do not enable `ngram-simple` globally. Revisit only for
   a workload with materially longer copied spans, or after a scheduler/kernel
   change makes multi-token verification cheaper; more blind parameter sweeps
   are not justified by this result.

5. **Backend sampling is a measured small win and is enabled.** `--backend-sampling` is already in build 11429
   and can avoid copying full logits to the host and running supported samplers
   on the CPU. Published large gains are high-concurrency results, so expect a
   smaller single-slot effect; nevertheless, a large vocabulary and an already
   fragmented CPU/GPU critical path make it cheap to measure. Test greedy and
   the actual interactive sampler separately, watch for fallback warnings, and
   compare output because stochastic CPU and backend floating-point paths need
   not make identical draws.

   Source: <https://github.com/ggml-org/llama.cpp/issues/27050>.

   A 65K/F16-KV server A/B/A screen used the same deterministic 39-token prose
   prompt, 256 generated tokens, seed, placement, phase-aware mmap settings,
   and executable. Backend sampling produced byte-identical output.

   | Arm | First request | Repeated/warm request |
   | --- | ---: | ---: |
   | A1/A2 CPU sampling | 21.63 / 21.59 t/s | 23.49 t/s in A2 |
   | B backend sampling | 22.89 t/s | 25.46 t/s |

   Those 5-8% screens included request-order/page-state effects. Direct timing
   of the synchronized sampling critical section found 0.767-0.768 ms/token on
   CPU versus 0.016 ms/token on the backend. In the stable interleaved pair,
   end-to-end generation was 23.20 versus 23.58 t/s (+1.63%), which matches the
   approximately 0.752 ms/token removed from a roughly 43 ms token. The actual
   stochastic chain remained byte-identical at a fixed seed. JSON-schema
   generation automatically disabled backend sampling, logged the fallback,
   and returned identical valid JSON. `backend-sampling = true` is now wired
   globally in `models.ini`; a system rebuild/update is required to
   deploy it.

6. **Do not threshold phase advice by prompt-suffix length.** A long first turn
   followed by ten identical five-token cached suffixes tested this directly.
   With the existing sequential/normal transition, steady suffix evaluations
   were mostly 150-157 ms. With phase advice disabled they drifted to 166-183
   ms. More importantly, the initial 91-token cold prompt took 5.21 s with the
   patch and 53.15 s without it. The transition overhead is not a problem at
   this scale, and even tiny suffixes did not benefit from skipping it. Keep the
   current unconditional phase switch.

### Priority B: profile-guided patch directions

1. **Capture a CPU/GPU execution timeline.** Use Nsight Systems if available,
   plus privileged `perf`/tracepoints as already deferred. Mark prompt, decode,
   router, CPU `MUL_MAT_ID`, H2D/D2H copies, CUDA graph launches, and stream
   synchronizations. The question is not merely which function consumes CPU;
   it is which dependency leaves both processors idle or serializes work that
   could overlap.
2. **Reduce the CPU-expert barrier.** Depending on the timeline, candidates are
   pinned staging for pageable expert copies, asynchronous/lagged cache fills,
   overlapping GPU cache hits with CPU misses, or retaining CUDA graph segments
   across CPU expert work. Do not implement all at once. Upstream reports show
   that forcing every decode expert through H2D without persistent residency is
   about 3x slower, so cache/overlap structure is essential.
3. **Evaluate the next router on a stale hidden state.** The ID-only
   previous-layer table measured below reaches only about 49-53% in-domain
   recall. ProMoE, AdapMoE, HOBBIT, and related systems instead feed a current
   intermediate/hidden state through a future layer's small router, exploiting
   residual-stream similarity; published next-layer accuracy is much higher.
   For this model a router projection is only 2816 by 128, tiny beside eight
   expert FFNs. First add a trace-only shadow router for layer `L+1` and compare
   its top-8 with the real route without issuing I/O. If accuracy and lead time
   are sufficient, use it to initiate asynchronous fills or page prefetch one
   layer early; never use the prediction to change routing. Source:
   <https://arxiv.org/abs/2410.22134>.
4. **Examine fusion and kernel selection at real shapes.** Count whether gate
   and up projections plus activation are fused, which CPU Q4_K kernel handles
   one-token expert rows, which CUDA `MUL_MAT_ID` path handles GPU layers, and
   whether speculative verification batches change those choices. Tune a
   threshold or tile only after a profile identifies that kernel on the critical
   path; compiler-wide `-march=znver3` already failed to move the result.
5. **Context-depth cost is flat through 8K, then visible at 32K.** A fixed
   six-expert-layer placement and 128 generated tokens measured occupied depths
   of 512, 2K, 8K, and 32K. The first three were indistinguishable at roughly
   22.4-22.8 t/s; 32K fell to roughly 21.2-21.5 t/s (about 6%). This does not
   justify reducing the retained 65K capacity: it says short conversations are
   not paying an attention-length penalty merely because that capacity exists.
   A growable context allocation could still release VRAM for weights in short
   sessions, but the extra-layer placement experiment below found no throughput
   win from spending that reserve, so this is now low priority.
6. **Test physical-core affinity and host wakeup behavior.** CPU numbering on
   Terra pairs SMT siblings (`0,1` per core, then `2,3`, etc.). Compare the
   default scheduler with strict one-thread-per-core placement such as even CPUs,
   while holding thread count at eight. Also screen polling/priority and record
   clocks, thermals, context switches, and migrations. Treat this as noise and
   latency control unless throughput moves consistently.

### Priority C: sustained-service and system-level ideas

- Protecting a bounded amount of the service's charged file cache with cgroup
  v2 `memory.low` may reduce interference from Open WebUI, browsers, or
  containers. It cannot create RAM and can worsen global pressure, so first
  measure the service cgroup's anon/file split and reclaim activity.
- A selective `mlock2(MLOCK_ONFAULT)` experiment could retain only a small,
  observed hot expert set without eagerly faulting it. This differs from the
  rejected one-shot prefetch, but the 14 GiB machine has little margin and the
  full model must never be locked. Start only after residency traces establish
  that useful hot pages are actually being reclaimed.
- CPU governor/EPP, GPU power/thermal limits, PCIe link state, and NVMe thermal
  throttling belong in the benchmark record. They are possible ceilings or
  confounders, not presumed fixes.

### Explicitly low-value without new evidence

- Another whole-file mmap advice variant.
- Decode-time `GGML_OP_OFFLOAD_MIN_BATCH=1` without persistent expert caching;
  upstream measurements show repeated H2D traffic can make it about 3x slower.
- Whole-model `mlock` or non-mmap loading on this 14 GiB host; it violates the
  established OOM constraint.
- More compiler target flags without a function/kernel profile.
- More expert prefetch at the same too-late CPU matmul hook. A future prefetch
  experiment must move the decision earlier or overlap useful work to be a
  genuinely different mechanism.

## Rejected routed-expert prefetch experiment

An environment-gated prototype called `MADV_WILLNEED` for the eight selected
`MUL_MAT_ID` expert slices during single-token decode. It was tested only in
the temporary development tree and is not part of the Nix patch set.

On the same 93-token prompt plus 256 generated tokens used for the later
`normal` run:

- baseline `normal`: 21.52 generation t/s, about 15.3k major faults, and
  2.98 GiB of reads;
- routed-expert `WILLNEED`: 14.84 generation t/s, about 171.6k major faults,
  and 5.40 GiB of reads.

This is rejected. Issuing `WILLNEED` at each CPU matmul is too late to overlap
usefully and/or causes overlapping readahead and page-cache pollution. It made
generation about 31% slower and substantially increased faults and I/O.

## Rejected Zen 3 compiler-tuning experiment

Runtime mappings confirmed that dynamic dispatch selects
`libggml-cpu-haswell.so` on the Ryzen 7 5800H. The upstream all-variants build
contains Zen 4 but no Zen 3 backend. As a bounded test, the selected Haswell
library retained the same AVX2 feature/dispatch contract but was rebuilt with a
final `-march=znver3`. This rebuilt 18 CPU objects plus one shared library in
14 seconds and did not rebuild CUDA or `llama-server`.

A deterministic 93-token prompt plus 768-token generation was measured as an
A/B/A sandwich to expose page-cache warming:

| Backend/run | Generation | Major faults | Read I/O |
| --- | --- | --- | --- |
| Original Haswell A1 | 21.11 t/s | 31,892 | 5.20 GB |
| `znver3` middle run | 21.75 t/s | 28,611 | 4.29 GB |
| Restored byte-identical Haswell A2 | 21.84 t/s | 25,768 | 3.89 GB |

The warmed original backend was slightly faster than the Zen 3 build. The
middle run's apparent 3% improvement over A1 tracks reduced paging and is not a
compiler win. Reject this change; do not add a Zen 3 variant to Nix on this
evidence. The temporary CMake edit was reverted and the exact original Haswell
library restored.

## MoE routing locality measurement

A dev-only CPU `MUL_MAT_ID` instrument counted expert selection for a
deterministic 768-token generation. It counted only
`ffn_gate_up_exps.weight`, so each layer/token was represented once. Layers
0-5 did not execute this tensor on CPU; the CPU-resident/overflowing layers
6-29 each contributed 767 decoded tokens.

Across those 24 layers:

- the top eight of 128 experts received an average 54.66% of selections
  (per-layer range 41.61-82.68%);
- the top sixteen received an average 78.63% (range 65.09-99.19%);
- consecutive tokens reused an average 2.68 of their eight selected experts
  (range 1.75-5.61);
- each layer touched 38-103 distinct experts during the run.

This confirms substantial routing locality and explains why normal page-cache
policy improves after warmup. It does not by itself justify permanently
pinning experts: the preferred experts are layer-specific, still evolve with
the prompt, and all 24 CPU layers together make even eight experts per layer a
large working set.

### Cross-workload route prediction and realistic residency bounds

A second trace used two properly chat-templated workloads: 511 generated
systems-analysis tokens and 512 generated Rust/code-analysis tokens. For each,
the first 256 routes trained a small table and the remainder was held out. The
table predicts a layer's experts from the eight experts selected by the
immediately preceding layer; it changes no model decisions.

| Train/test | Static top 8 | Previous token | Previous-layer predictor |
| --- | ---: | ---: | ---: |
| Systems, held-out continuation | 39.51% | 41.52% | 52.67% |
| Code, held-out continuation | 34.54% | 40.67% | 48.73% |
| Train systems, test all code | 27.48% | n/a | 38.75% |
| Train code, test all systems | 28.40% | n/a | 40.81% |

The predictor therefore captures a real cross-layer relationship, but its
accuracy shifts with content. A fixed offline hot list is insufficient; an
online/adaptive table or model-derived predictor is the defensible form. This
agrees with request-level tracing in MoE-Infinity, cross-layer prediction in
DuoServe-MoE, and learned prediction in SiDA-MoE, while providing model- and
machine-specific numbers here.

A token-granularity per-layer LRU simulation bounds a more practical persistent
GPU pool. These are selected-expert hits already resident before the token;
they do not assume free or instantaneous miss uploads:

| Slots per CPU layer | Systems LRU hit rate | Code LRU hit rate |
| ---: | ---: | ---: |
| 8 | 41.41% | 40.52% |
| 10 | 45.95% | 45.13% |
| 12 | 50.70% | 50.11% |
| 16 | 59.71% | 59.01% |
| 24 | 71.82% | 70.64% |
| 32 | 79.86% | 79.21% |

One expert's gate/up plus down weights are about 3.4-4.1 MiB in this GGUF.
Across 24 CPU layers, 12 slots per layer therefore cost roughly 1.0-1.2 GiB
before maps and scratch, and the trace predicts only about a 50% hit rate. That
explains why a synchronous upload-on-miss 1 GiB cache thrashed, but also makes a
CPU-on-miss/GPU-on-hit design credible: misses retain the current CPU path,
hits can remove about half of CPU expert rows, and asynchronous admission need
not delay the token that caused it. The next cache experiment should start from
an existing hybrid implementation, hold non-expert placement constant, and
measure actual admission bytes, overlap, residency hits, GPU memory, and
end-to-end output—not build another upload-on-miss pool.

The trace hook was removed after collection and `libggml-cpu-haswell.so` was
incrementally rebuilt, restoring the uninstrumented development baseline.

### Non-contiguous expert-layer placement: broad ranking loses, one swap inconclusive

An all-CPU-expert trace extended the earlier measurement from the 24 overflow
layers to all 30 routed layers on the same 256-token stochastic workload. The
default six GPU expert layers are 0-5. They are not uniformly the hardest CPU
working sets: layer 4 was exceptionally concentrated (61.23% in its top eight,
4.20/8 consecutive-token reuse), while layer 28 was the worst observed layer
(28.48% top-eight concentration, 1.93/8 reuse, 5.924-bit expert entropy).

Keeping exactly six expert layers on the GPU, a route-ranked placement used
layers 1, 7, 9, 15, 21, and 28. On a forced identical-token A/B/A server test,
the normal contiguous placement reproduced at 22.98 and 23.00 t/s, while the
ranked placement reached only 22.10 t/s (-3.9%). Its first pass also faulted
and warmed much more poorly. Scattering 24 CPU layers through the GGUF loses
enough spatial/readahead locality to overwhelm the routing-locality benefit.

A narrow swap kept the CPU region nearly contiguous: layer 28 moved to GPU and
layer 4 moved to CPU. It screened at 23.30 t/s in the server (+1.3%). Five
`llama-bench` repetitions averaged 23.12 versus 22.70 t/s, but after excluding
each placement's first run the medians were effectively tied. A real greedy
chat diverged within the first few tokens because changing CPU/CUDA evaluation
changed rounding and then routing, making its large timing difference invalid.
Do not wire either placement. If revisited, collect multiple workload traces,
penalize every added CPU-region discontinuity in the placement objective, and
use forced tokens or another exact-work comparison.

The trace ranking also hid unequal layer sizes: Q8_0 down-expert tensors are
about 95 MiB larger than Q5_0 ones. A targeted capacity experiment therefore
tested the next contiguous Q5-down layer rather than another entropy ranking.
The six-layer production control used 6,950 MiB process VRAM (about 823 MiB
device free); moving the complete seventh expert layer to GPU used 7,388 MiB
and left only about 385 MiB free. Moving only its 272 MiB Q4_K gate/up tensor
left about 551 MiB free. Both allocated safely, but violate the intended 1 GiB
operational reserve.

Single server passes misleadingly suggested +3.4% for the complete layer and
+1.2% for gate/up only. A three-placement, five-repetition exact-token
`llama-bench` run rejected those signals. Excluding the first two strongly
warming samples from each process, the last-three means were:

| Placement | Generation | Versus baseline |
| --- | ---: | ---: |
| six complete GPU expert layers | 22.54 t/s | baseline |
| layer 6 gate/up on GPU, down on CPU | 21.59 t/s | -4.2% |
| seven complete GPU expert layers | 22.30 t/s | -1.1% |

The split layer creates a material cross-device scheduling/synchronization
penalty, and merely consuming the reserve for another complete layer did not
help. Keep `fit-target=1024`; do not add explicit tensor overrides. MoEpic-like
segmentation would need fused partial-output accumulation and real overlap,
not whole gate/up and down operations placed on opposite devices.

### Occupied context depth: negligible through 8K, about 6% at 32K

`llama-bench` generated the same 128 synthetic tokens after restoring contexts
at depths 0, 512, 2,048, 8,192, and 32,768. The explicit tensor override kept
the normal six complete expert layers on the GPU, so changing context size did
not silently refit model weights. Four repetitions produced:

| Occupied depth | Raw generation samples (t/s) | Median |
| ---: | --- | ---: |
| 0 | 7.77, 17.56, 18.21, 20.55 | 17.89 |
| 512 | 21.63, 22.01, 22.89, 22.86 | 22.43 |
| 2,048 | 22.37, 22.71, 22.63, 22.38 | 22.51 |
| 8,192 | 22.30, 23.00, 22.79, 22.56 | 22.67 |
| 32,768 | 18.74, 21.37, 21.97, 21.08 | 21.23 |

The depth-zero arm ran first and was dominated by whole-model/page warming, so
it is not a valid short-context comparison. Depths 512 through 8K are flat
within noise. At 32K, the median is 6.4% below 8K; comparing last-three means
gives a similar 5.7% gap. This is a real long-context attention/KV cost, not an
argument for lowering configured capacity: each benchmark context was sized to
only `depth + 128`, whereas the server retains 65K capability. The sweep used
the benchmark default `ubatch=512`, but decode is one token at a time, so that
does not materially change the measured generation path.

The result weakens the case for a complex phase/depth-aware weight-placement
patch. Short occupied contexts are already fast, and separately consuming more
VRAM for a seventh expert layer failed to improve them. Revisit growable KV or
placement only if memory pressure or a real long-session trace identifies a
specific payoff.

### What the successful changes have in common

The results so far favor changes that remove work from the serial token path
without creating a new miss penalty:

- phase-aware mmap advice changes kernel read policy and restores normal advice
  before decode; it does not copy weights or demand extra residency;
- backend sampling removes about 0.752 ms/token of synchronized host work and
  returns only the needed sample, while unsupported grammar requests safely
  keep the old CPU path;
- CPU-on-miss/GPU-on-hit caching was fast in the microbenchmark because a miss
  retained the existing CPU computation, whereas synchronous upload-on-miss
  made every miss a PCIe stall;
- changes that look locally attractive but disturb the larger memory system
  (forced `WILLNEED`, scattered CPU layers, execution-order GGUF repacking)
  consistently lose through refaults, read amplification, or broken spatial
  locality.

This suggests a practical filter for new work: measure the removable critical
path first, preserve an immediate fallback, and account for page/cache layout
before implementing a more elaborate predictor. The strongest remaining patch
direction is asynchronous predicted admission with CPU-on-miss, not another
synchronous expert mover.

### Rejected one-shot hot-expert prefetch

Using the measured locality, a second dev-only prototype observed 128 tokens,
then issued exactly one `MADV_WILLNEED` for the top eight gate/up and down
expert ranges in each CPU layer. All advice calls succeeded and covered about
0.7 GiB in total. Unlike the earlier per-matmul prototype, this did not repeat
the requests every token.

On the same 93 + 768 workload it reached 20.27 generation t/s with 35,170
major faults and 5.27 GB of reads. The immediately preceding instrument-only
run reached 20.78 t/s, and uninstrumented sandwich controls were about
21.75-21.84 t/s under warmer cache conditions. The server's interval timings
dropped after the token-128 prefetch and did not recover. Even selective,
one-shot forced warming displaced more useful cache state and/or competed with
demand reads. Reject it. Both the statistics and hot-prefetch code were removed
from the dev tree, and the original CPU backend library was restored.

Function-level profiling was subsequently enabled by the owner's temporary
`kernel.perf_event_paranoid=1` setting; see the profile section above.

## Rejected GGUF execution-order layout

GGUF offset inspection found that each layer is physically packed roughly as
`down_experts -> gate/router -> gate_up_experts`, while MoE execution consumes
`gate/router -> gate_up_experts -> down_experts`. This creates a large backward
file-offset transition in every CPU MoE layer. A separate model copy was built
with each layer's affected tensor-info records and data blocks reordered to
`gate/router -> gate_up_experts -> down_experts`.

The transformation kept the original file untouched, retained the exact file
size (17,211,254,912 bytes), reparsed as all 659 tensors, and matched samples
from both ends of every tensor. llama.cpp additionally requires tensor-info
records to be in the same monotonic order as packed data; the first prototype
exposed that validation rule and was rebuilt correctly. The corrected model
loaded and generated an identical deterministic output hash.

Both model inodes received `POSIX_FADV_DONTNEED` before their respective test
legs. On the same 93 + 768 workload:

| Layout | Prompt | Generation | Major faults | Read I/O |
| --- | --- | --- | --- | --- |
| Original quantizer order | 26.30 t/s | 21.82 t/s | 23,712 | 3.85 GB |
| MoE execution order | 25.17 t/s | 21.34 t/s | 29,410 | 4.42 GB |

Physical execution order is rejected: it was about 2.2% slower in generation
and caused more faults and reads. NVMe seek direction is not the relevant
bottleneck here, and the original packing evidently produces better effective
cache/readahead locality. The rejected 17 GiB duplicate was deleted after the
test; it was a generated artifact and can be recreated, while the original
model was never modified.

## Rejected filesystem defragmentation hypothesis

The original GGUF is an ext4 file with 18,152 physical extents on an NVMe
device using the `none` scheduler and 128 KiB block-device readahead. This is
high fragmentation, likely inherited from the downloader's write pattern. To
isolate it from GGUF tensor order, an exact-byte copy was preallocated and
written sequentially. That reduced the copy to 1,373 extents (13.2x fewer)
without changing any GGUF offsets or model bytes.

After applying `POSIX_FADV_DONTNEED` to both inodes, the exact copy produced the
same deterministic output hash but generated at 21.74 t/s versus 21.82 t/s for
the original. Major faults were likewise effectively identical: 23,827 versus
23,712. A shell formatting error made the copy run's process read-byte print
invalid, so that field is intentionally omitted rather than inferred.

Fragmentation is visually severe but does not explain generation throughput on
this NVMe workload. Do not run in-place `e4defrag` for inference speed on this
evidence. The 17 GiB exact-copy artifact was deleted; the original model was
not modified.

## Build and handoff (2026-10-19)

The checked-in configuration is ready for a clean NixOS build with:

```sh
cd /home/infinity/nixos-config
sudo nixos-rebuild switch --flake .#terra
```

The package now appends `CMAKE_CUDA_ARCHITECTURES=86`, so the clean build should
compile CUDA only for Terra's RTX 3070 rather than all ten nixpkgs targets.

After activation, confirm the service and patch environment:

```sh
systemctl status llama-cpp --no-pager
systemctl show llama-cpp -p Environment
journalctl -u llama-cpp -b --no-pager | grep -E 'MADV_SEQUENTIAL|mmap advice|failed to (set|switch)'
```

Expected environment values are `LLAMA_MMAP_SEQUENTIAL=1` and
`LLAMA_MMAP_GENERATION_ADVICE=normal`. Model-load logs should contain the
`MADV_SEQUENTIAL enabled` line. There should be no `failed to set sequential
mmap advice` or `failed to switch mmap advice` warning after a request.

Then use the service normally or run one generation of at least 256 tokens.
Record prompt/generation timing plus any phase-advice warning before doing more
patch work. The next useful question is whether a longer real conversation
avoids the old escalating read-amplification/refault behavior; do not revive
whole-mapping `RANDOM` or the per-matmul `WILLNEED` prototype.
