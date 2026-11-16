#!/bin/bash

output_path=/out/semgrep.json

semgrep scan -q --json --config /semgrep-rules/ /in > ${output_path}
