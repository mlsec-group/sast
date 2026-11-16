# Dockerized SAST tools

This repository packages **Semgrep** (0xdea rules), **RATS**, and **Cppcheck** for consistent static analysis. Each tool lives under its own directory with a `Dockerfile` and an Apptainer `*.def` file.

## Sample C corpus

The [`samples/`](samples/) directory contains small, intentionally vulnerable C files used to exercise different rules:

| File | Intended findings |
|------|-------------------|
| [`samples/insecure_gets.c`](samples/insecure_gets.c) | Semgrep (insecure `gets`), RATS (`gets`) |
| [`samples/insecure_strcpy.c`](samples/insecure_strcpy.c) | Semgrep (`strcpy`), RATS (unbounded copy) |
| [`samples/insecure_scanf.c`](samples/insecure_scanf.c) | Semgrep (insecure `scanf` patterns), RATS |
| [`samples/unchecked_malloc.c`](samples/unchecked_malloc.c) | Semgrep (unchecked `malloc` result) |
| [`samples/format_string_printf.c`](samples/format_string_printf.c) | Semgrep (format string), often RATS |
| [`samples/cppcheck_issues.c`](samples/cppcheck_issues.c) | Cppcheck (leak, uninitialized use, division by zero, null dereference) |

Subdirectories for more information: [`semgrep/`](semgrep/), [`rats/`](rats/), [`cppcheck/`](cppcheck/).

## Layout for scans

Containers expect:

- **`/in`** — read directory tree to analyze (bind your sources here).
- **`/out`** — writable directory for reports (create it on the host first).

**Semgrep** writes a single JSON report: **`/out/semgrep.json`**.

**RATS** and **Cppcheck** run per file under `/in` and write one host-named file per source file under `/out` (basename without extension, per their `execute.sh` scripts).

## Docker: build and run

From the repository root, with `samples` as input and a fresh output directory:

```bash
mkdir -p out-docker

(cd semgrep && docker build . -t semgrep)
docker run --rm \
  -v "$(pwd)/samples:/in:ro" \
  -v "$(pwd)/out-docker:/out" \
  semgrep
cat out-docker/semgrep.json | head

(cd rats && docker build . -t rats)
docker run --rm \
  -v "$(pwd)/samples:/in:ro" \
  -v "$(pwd)/out-docker:/out" \
  rats
ls out-docker/

(cd cppcheck && docker build . -t cppcheck)
docker run --rm \
  -v "$(pwd)/samples:/in:ro" \
  -v "$(pwd)/out-docker:/out" \
  cppcheck
```

You can also use each tool’s `build.sh` (`docker build . -t <name>`).

## Apptainer / Singularity: build and run

Build one or all SIF images (requires `apptainer` or `singularity` on `PATH`). Optional: `APPTAINER_BUILD_OPTS=--fakeroot ./apptainer_build.sh` if your site requires fakeroot for build.

```bash
./apptainer_build.sh
# or: ./apptainer_build.sh semgrep

mkdir -p out-apptainer/cppcheck out-apptainer/rats out-apptainer/semgrep
./apptainer_execute.sh semgrep "$(pwd)/samples" "$(pwd)/out-apptainer/semgrep"
./apptainer_execute.sh rats "$(pwd)/samples" "$(pwd)/out-apptainer/rats"
./apptainer_execute.sh cppcheck "$(pwd)/samples" "$(pwd)/out-apptainer/cppcheck"
```

Results appear under `out-apptainer/` the same way as in Docker (`semgrep.json` plus per-file outputs for RATS and Cppcheck).

## Optional cleanup

Report directories (`out-docker`, `out-apptainer`) are only examples; remove them when no longer needed.
