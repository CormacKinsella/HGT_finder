# Horizontal gene transfer finder

![banner2-01](https://user-images.githubusercontent.com/27350062/201880841-6cc0cf34-e26a-4d69-9c52-9fbf2c1d0cd6.png)

## HGT detection workflow using custom protein queries - designed to process 100s or 1000s of genome assemblies

## [Example study available here](https://www.pnas.org/doi/10.1073/pnas.2303844120) 

# Highlights:

- Custom protein queries are used to identify any type of HGT event, e.g. virus-eukaryote (endogenous virus elements or EVEs), virus-virus (gene capture), or others. 
- Designed for processing 1000s of genomes (handles corrupted downloads, and manages disk storage by sequential file processing and cleanup)

# Rationale of the workflow:

- Each HGT-derived element represents a region of interest (ROI) in a genome assembly. ROIs are likely to have multiple distinct alignments when a broad protein query database is used. The workflow first merges overlapping alignments to record the maximal ranges of a ROI, before extracting the predicted protein sequence of the best single alignment (unlikely to span the maximal ranges)
- When used for detecting EVEs, older elements often contain stop codons. These are retained in the final ".fmt6" output, as they are potentially informative. Ensure they are removed prior to phylogenetic analysis, or Diamond/BLAST curation of sequences
- Information such as assembly, contig, maximal ROI ranges, putative EVE amino acid sequence, frame, and exact sequence coordinates are straightforward to extract or calculate from outputs

# Usage:

Prerequisite programmes in $PATH:
- BLAST+
- samtools
- bedtools

Alternatively, a conda environment.yml is provided in this repository for fast setup.
Get conda here:
https://docs.conda.io/en/latest/miniconda.html#linux-installers

Create, activate, and check environment:
```
conda HGT_finder create -f environment.yml
conda activate HGT_finder
conda list
```

The workflow itself is provided as a Linux command line script for use on a HPC environment. Adapt this to your system, e.g.:
- Workload manager information
- Input file locations
- $num_threads
- $outdir

# Required input files:
- Custom "proteins.fasta" query file. Recommend no spaces in headers & informative labelling
- A text list of ftp repositories to target, for example:
```
ftp.ncbi.nlm.nih.gov/genomes/all/GCA/014/108/235/GCA_014108235.1_mMyoMyo1.p
ftp.ncbi.nlm.nih.gov/genomes/all/GCA/016/865/085/GCA_016865085.1_ASM1686508v1
ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/704/035/GCF_003704035.1_HU_Pman_2.1.3
ftp.ncbi.nlm.nih.gov/genomes/all/GCA/913/844/085/GCA_913844085.1_s3r1_clone4_genome
ftp.ncbi.nlm.nih.gov/genomes/all/GCA/001/662/575/GCA_001662575.1_ASM166257v1 
```

# Notes
- When processing large numbers of eukaryotic genome assemblies, splitting the workload across multiple jobs is recommended to improve runtime
- Sequential assembly accessions often have similar size (e.g. same organism submitted as a batch of assemblies), therefore shuffling ftp links will ensure a more similar work burden between jobs
```
shuf ftp.list | split -l 100
```
- Approximate run time (Intel® Xeon® Gold 6130 - 2.10GHz, 16 cores): 100 eukaryotic genomes in <1 day (N.B. highly dependent on taxon of interest)
- For best performance, work with all files within a compute environment/compute node
- It's recommended to carry out quality control on the resulting sequences. E.g. with a DIAMOND installation:
```
diamond blastp --query query.fas --db nr --ultra-sensitive --threads 16 --unal 1 --out diamond.fmt6 --outfmt 6 qseqid sseqid pident length evalue bitscore stitle --max-target-seqs 50
```

# Problems with large and highly repetitive genome assemblies
- For a small number of large and very repetitive assemblies (particularly wheats), tBLASTn can fail to finish in reasonable time
- A list of assemblies with known issues can be found in the file "difficultAssemblies.txt"
- Masking simple repeats with repeatmasker can help to reduce runtime
```
RepeatMasker -engine rmblast -pa 4 -noint -species wheat -dir ./out assembly.fna
```
