#!/usr/bin/env bash
set -euo pipefail

usage() {
	echo "Usage: $0 <tool> <input_dir> <output_dir> [<args-for-runscript>...]" >&2
	echo "  <tool>: semgrep | rats | cppcheck" >&2
	echo "  Binds <input_dir> -> /in and <output_dir> -> /out inside the container." >&2
	echo "  Build images first: ./apptainer_build.sh [<tool>]" >&2
	exit 1
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	usage
fi
if [[ $# -lt 3 ]]; then
	usage
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

tool=$1
input_dir=$2
output_dir=$3
shift 3

case "$tool" in
	semgrep | rats | cppcheck) ;;
	*) echo "Unknown tool: $tool (expected semgrep, rats, or cppcheck)" >&2; usage ;;
esac

sif_path="$REPO_ROOT/$tool/$tool.sif"
if [[ ! -f "$sif_path" ]]; then
	echo "Missing image: $sif_path" >&2
	echo "Run: ./apptainer_build.sh $tool" >&2
	exit 1
fi

if [[ ! -d "$input_dir" ]]; then
	echo "Not a directory: $input_dir" >&2
	exit 1
fi

mkdir -p "$output_dir"

abs_path() {
	local p=$1
	if command -v realpath &>/dev/null; then
		realpath "$p"
	elif command -v readlink &>/dev/null && readlink -f / &>/dev/null; then
		readlink -f "$p"
	else
		(cd "$p" && pwd)
	fi
}

input_real="$(abs_path "$input_dir")"
out_real="$(abs_path "$output_dir")"

runner=()
if command -v apptainer &>/dev/null; then
	runner=(apptainer)
elif command -v singularity &>/dev/null; then
	runner=(singularity)
else
	echo "Neither apptainer nor singularity found in PATH." >&2
	exit 1
fi

exec "${runner[@]}" run -B "${input_real}:/in" -B "${out_real}:/out" "$sif_path" "$@"
