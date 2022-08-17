# Tree of life EVE discovery

Linux workflow for processing 100s or 1000s of genomes to discover EVEs. 
Read the paper here:

Highlights:
- No storage issues for 1000s of genomes: assemblies are not retained locally. Using cressdnaviruses, total output for ~25,000 eukaryotic genomes is <5 GB.
- Custom protein queries can be used to target any viral group.
- Each element represents a region of interest (ROI) in the assemmbly. ROIs are likely to get multiple alignments. This workflow first merges overlapping alignments to define the maximal ranges of a ROI, before reanalysing each individually to extract the best predicted protein sequence.
- Older EVEs often contain stop codons. These are retained in the final .fmt6 output, as they are potentially informative. Ensure they are removed prior to phylogenetic analysis or BLAST curation of sequences. 
- It's recommended to carry out quality control on the resulting sequences. E.g. with DIAMOND:
```
diamond blastp --very-sensitive --query queries.aa.fa --db nr --unal 1 --max-target-seqs 1 --outfmt 6 qseqid sseqid pident length evalue bitscore stitle --out out.diamond.fmt6 --threads NUMBER
```

# Usage:

Prerequisite programmes in $PATH:
- BLAST+
- samtools
- bedtools

A conda environment.yml is provided in the repo for fast setup.
Get conda here:
https://docs.conda.io/en/latest/miniconda.html#linux-installers

Create, activate, and check environment:
```
conda EVE_discovery create -f environment.yml
conda activate EVE_discovey
conda env list
```

The workflow itself is provided as a Linux command line script for use on a HPC environment. Adapt this to your system, e.g.:
Workload manager information
Input file locations
$num_threads
$outdir

# Required input files:
- Custom protein queries in a file with ".fasta" extension.
- A text list of ftp repositories to target, for example: 
EXAMPLE

# Notes
- For 200+ genomes, splitting up the input ftp list is recommended, with subsets run in parallel. 
If splitting, first run:
shuf ftp.list > ftp_shuffled.list
Sequential assembly accessions often have similar size, if they are submitted together. 
Shuffling will ensure a more similar workload for each job.
split -l 100 ftp_shuffled.list
- Approximate run time (Intel® Xeon® Gold 6130 - 2.10GHz, 16 cores): 100 eukaryotic genomes in 1-2 days.
- For best performance, work with all files within a compute environment/compute node. 
