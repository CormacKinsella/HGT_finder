# Tree of life EVE discovery

![image](https://user-images.githubusercontent.com/27350062/185176894-c5895241-b498-4a2e-9800-7ea5678780c5.png | width=50)

For processing 100s or 1000s of genomes to discover EVEs. 

- No storage issues: assemblies are not retained locally. Using cressdnaviruses, total output for ~25,000 eukaryotic genomes is <5 GB.
- Custom protein queries can be used to target any viral group.
- Each element represents a region of interest (ROI) in the assemmbly. ROIs are likely to get multiple alignments. This script first merges overlapping alignments to define the maximal ranges of an ROI, before reanalysing each individually to extract the best predicted protein sequence.
- Older EVEs often contain stop codons. These are retained in the final tBLASTn output, as they are potentially informative. Ensure they are removed prior to phylogenetic analysis or BLAST curation. 
- It's recommended to carry out quality control on the resulting sequences. E.g. with DIAMOND:
diamond blastp --very-sensitive --query queries.aa.fa --db nr --unal 1 --max-target-seqs 1 --outfmt 6 qseqid sseqid pident length evalue bitscore stitle --out out.diamond.fmt6 --threads NUMBER

# Usage:

- The workflow is provided as a bash script, adapt this to your system, e.g.:
Workload manager information
Input file locations
$num_threads
$outdir

- A conda environment.yml is provided with all software dependencies. 
EXAMPLE CODE SET UP CONDA
LOAD ENVIRONMENT

# Required input files:
- Custom protein queries in a file with ".fasta" extension.
- A text list of ftp repositories to target, for example: 
EXAMPLE

# Notes
- For 1000+ genomes, splitting up the input ftp list is recommended, with subsets run in parallel. 
If splitting, first run:
shuf ftp.list > ftp_shuffled.list
Accessions of similar size are often depositied in sequence (mass assembly submission), shuffling will ensure a more similar workload for each job.
split -l 100 ftp_shuffled.list
- Approximate run time (Intel® Xeon® Gold 6130 - 2.10GHz, 16 cores): 100 eukaryotic genomes in 1-2 days.
- For best performance, work with all files within a compute environment/compute node. 
