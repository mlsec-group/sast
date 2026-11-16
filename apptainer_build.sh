#!/usr/bin/env bash
set -euo pipefail

usage() {
	echo "Usage: $0 [<tool>]" >&2
	echo "  <tool>: semgrep | rats | cppcheck (omit to build all)" >&2
	echo "  Extra build flags: set APPTAINER_BUILD_OPTS (e.g. --fakeroot)" >&2
	exit 1
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	usage
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

runner=()
if command -v apptainer &>/dev/null; then
	runner=(apptainer)
elif command -v singularity &>/dev/null; then
	runner=(singularity)
else
	echo "Neither apptainer nor singularity found in PATH." >&2
	exit 1
fi

tools=(semgrep rats cppcheck)
if [[ -n "${1:-}" ]]; then
	tools=("$1")
fi

build_extra=()
if [[ -n "${APPTAINER_BUILD_OPTS:-}" ]]; then
	# shellcheck disable=SC2206
	build_extra=( ${APPTAINER_BUILD_OPTS} )
fi

for tool in "${tools[@]}"; do
	case "$tool" in
		semgrep | rats | cppcheck) ;;
		*) echo "Unknown tool: $tool (expected semgrep, rats, or cppcheck)" >&2; usage ;;
	esac
	def_path="$REPO_ROOT/$tool/$tool.def"
	sif_path="$REPO_ROOT/$tool/$tool.sif"
	if [[ ! -f "$def_path" ]]; then
		echo "Missing definition file: $def_path" >&2
		exit 1
	fi
	echo "Building $sif_path from $def_path ..."
	pushd "$REPO_ROOT/$tool" >/dev/null
	(
		"${runner[@]}" build "${build_extra[@]}" "$tool.sif" "$tool.def"
	)
	popd >/dev/null
done

echo "Done."
