#!/bin/sh
set -eux
cd .
docker build -t dat2-cwl/extraxt_transcript_id .
