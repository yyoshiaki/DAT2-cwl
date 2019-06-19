class: Workflow
cwlVersion: v1.0
id: transcriptome_assemble
label: transcriptome_assemble
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: split_spot
    type: boolean?
    'sbg:exposed': true
  - id: split_files
    type: boolean?
    'sbg:exposed': true
  - id: split_3
    type: boolean?
    'sbg:exposed': true
  - id: skip_technical
    type: boolean?
    'sbg:exposed': true
  - id: runid
    type: string
    'sbg:exposed': true
  - id: seq_type
    type: string
    'sbg:exposed': true
  - id: output_name
    type: string
    'sbg:exposed': true
  - id: url
    type: string
    'sbg:exposed': true
  - id: minimum_protein_length
    type: int
    'sbg:exposed': true
  - id: domtblout
    type: string
    'sbg:exposed': true
  - id: output_1
    type: string
    'sbg:exposed': true
  - id: db_flag
    type: string
    'sbg:exposed': true
  - id: out_flag
    type: string
    'sbg:exposed': true
  - id: cpu
    type: int
    'sbg:x': 68
    'sbg:y': -291
  - id: max_memory
    type: string
    'sbg:x': 63.1796875
    'sbg:y': -118
outputs:
  - id: output2
    outputSource:
      - for_trinity/output2
    type: File
    'sbg:x': 455
    'sbg:y': -7
  - id: output1
    outputSource:
      - for_trinity/output1
    type: File
    'sbg:x': 451
    'sbg:y': 246
  - id: output_2
    outputSource:
      - aaea/output
    type: Directory?
    'sbg:x': 559
    'sbg:y': 425
  - id: trinity_results
    outputSource:
      - trinity_pe/trinity_results
    type: Directory
    'sbg:x': 768
    'sbg:y': -1
  - id: output
    outputSource:
      - transdecoder/output
    type: Directory?
    'sbg:x': 864
    'sbg:y': 313
  - id: out
    outputSource:
      - extract_transcript_id/out
    type: File?
    'sbg:x': 1347
    'sbg:y': -70
  - id: blastdbcmd_results
    outputSource:
      - blastdbcmd/blastdbcmd_results
    type: File
    'sbg:x': 1391
    'sbg:y': 160
  - id: reverse
    outputSource:
      - fasterq_dump/reverse
    type: File?
    'sbg:x': -233.8203125
    'sbg:y': 74.5
  - id: forward
    outputSource:
      - fasterq_dump/forward
    type: File?
    'sbg:x': -203.8203125
    'sbg:y': 438.5
steps:
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
    'sbg:x': 316
    'sbg:y': 176
  - id: fasterq_dump
    in:
      - id: skip_technical
        source: skip_technical
      - id: split_3
        source: split_3
      - id: split_files
        source: split_files
      - id: split_spot
        source: split_spot
      - id: runid
        source: runid
    out:
      - id: fastqFiles
      - id: forward
      - id: reverse
    run: ../../tool/fasterq-dump/fasterq-dump.cwl
    label: 'fasterq-dump: dump .sra format file to generate fastq file'
    'sbg:x': -375
    'sbg:y': 222
  - id: aaea
    in:
      - id: transcript
        source: trinity_pe/transcript
      - id: thread_count
        default: 30
      - id: left
        source: trim_galore/out1
      - id: right
        source: trim_galore/out2
      - id: est_method
        default: kallisto
      - id: kallisto_add_opts
        default: '"-t 30"'
      - id: output_dir
        default: kallisto_out
    out:
      - id: output
    run: ../../tool/trinity/aaea.cwl
    label: aaea
    'sbg:x': 364
    'sbg:y': 422
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
      - id: output_dir
        default: trinity_out_dir
      - id: seq_type
        source: seq_type
    out:
      - id: trinity_results
      - id: transcript
    run: ../../tool/trinity/trinity-pe.cwl
    'sbg:x': 611
    'sbg:y': 173
  - id: transdecoder
    in:
      - id: transcripts
        source: trinity_pe/transcript
      - id: minimum_protein_length
        source: minimum_protein_length
    out:
      - id: output
      - id: pep
    run: ../../tool/transdecoder/transdecoder.cwl
    label: transdecoder
    'sbg:x': 803
    'sbg:y': 191
  - id: wget
    in:
      - id: output_name
        source: output_name
      - id: url
        source: url
    out:
      - id: downloaded
      - id: stderr
    run: ../../tool/wget/wget.cwl
    'sbg:x': 1018
    'sbg:y': -12
  - id: gzip
    in:
      - id: file
        source: fasterq_dump/reverse
    out:
      - id: compressed
      - id: stderr
    run: ../../tool/gzip/gzip.cwl
    'sbg:x': -70
    'sbg:y': 147
  - id: gzip_1
    in:
      - id: file
        source: fasterq_dump/forward
    out:
      - id: compressed
      - id: stderr
    run: ../../tool/gzip/gzip.cwl
    'sbg:x': -61
    'sbg:y': 306
  - id: trim_galore
    in:
      - id: read1
        source: gzip_1/compressed
      - id: read2
        source: gzip/compressed
      - id: fastqc
        default: true
      - id: trim1
        default: true
      - id: paired
        default: true
    out:
      - id: out1
      - id: out2
    run: ../../tool/trim_galore/trim_galore_PE.cwl
    label: trim_galore
    'sbg:x': 122
    'sbg:y': 234
  - id: hmmsearch
    in:
      - id: cpu
        source: cpu
      - id: domtblout
        source: domtblout
      - id: hmm
        source: wget/downloaded
      - id: pep
        source: transdecoder/pep
    out:
      - id: output
    run: ../../tool/hmmer/hmmsearch.cwl
    label: hmmsearch
    'sbg:x': 1110
    'sbg:y': -175
  - id: extract_transcript_id
    in:
      - id: input
        source: hmmsearch/output
      - id: output
        source: output_1
    out:
      - id: out
    run: ../../tool/extract_transcript_id/extract_transcript_id.cwl
    label: extract_transcript_id
    'sbg:x': 1175
    'sbg:y': -69
  - id: makeblastdb
    in:
      - id: input_pep
        source: transdecoder/pep
    out:
      - id: db_dir
    run: ../../tool/blast/makeblastdb.cwl
    label: makeblastdb
    'sbg:x': 1022
    'sbg:y': 175
  - id: blastdbcmd
    in:
      - id: blastdb_dir
        source: makeblastdb/db_dir
      - id: db_flag
        source: db_flag
      - id: entry_batch_flag
        source: extract_transcript_id/out
      - id: out_flag
        source: out_flag
    out:
      - id: blastdbcmd_results
    run: ../../tool/blast/blastdbcmd.cwl
    label: Blastdbcmd to dump seqs/info.
    'sbg:x': 1199
    'sbg:y': 159
requirements: []