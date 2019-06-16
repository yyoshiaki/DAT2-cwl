class: Workflow
cwlVersion: v1.0
id: transcriptome_assemble
label: transcriptome_assemble
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: runid
    type: string
    'sbg:exposed': true
  - id: max_memory
    type: string
    'sbg:exposed': true
  - id: cpu
    type: int?
    'sbg:exposed': true
outputs: []
steps:
  - id: fasterq_dump
    in:
      - id: split_files
        default: true
      - id: split_spot
        default: false
      - id: runid
        source: runid
    out:
      - id: fastqFiles
      - id: forward
      - id: reverse
    run: ../../tool/fasterq-dump/fasterq-dump.cwl
    label: 'fastq-dump: dump .sra format file to generate fastq file'
    'sbg:x': 0
    'sbg:y': 39.5
  - id: trim_galore
    in:
      - id: read1
        source: gzip/output
      - id: read2
        source: gzip_1/output
    out:
      - id: out1
      - id: out2
    run: ../../tool/trim_galore/trim_galore_PE.cwl
    label: trim_galore
    'sbg:x': 464.015625
    'sbg:y': 46.5
  - id: for_trinity
    in:
      - id: IN1
        source: trim_galore/out1
      - id: IN2
        source: trim_galore/out2
    out:
      - id: output1
      - id: output2
    run: ../../tool/for_trinity/for_trinity.cwl
    label: for_trinity
    'sbg:x': 703
    'sbg:y': 64
  - id: trinity_pe
    in:
      - id: cpu
        source: cpu
      - id: fq1
        source: for_trinity/output1
      - id: fq2
        source: for_trinity/output2
      - id: max_memory
        source: max_memory
      - id: seq_type
        default: fq
    out:
      - id: trinity_results
    run: ../../tool/trinity/trinity-pe.cwl
    'sbg:x': 869
    'sbg:y': 56
  - id: gzip
    in:
      - id: input
        source: fasterq_dump/forward
    out:
      - id: output
    run: ../../tool/gzip/gzip.cwl
    label: gzip
    'sbg:x': 250
    'sbg:y': 101
  - id: gzip_1
    in:
      - id: input
        source: fasterq_dump/reverse
    out:
      - id: output
    run: ../../tool/gzip/gzip.cwl
    label: gzip
    'sbg:x': 234
    'sbg:y': -44
requirements: []