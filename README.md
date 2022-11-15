# Tree of life endogenous viral element (EVE) discovery

![banner2-01](https://user-images.githubusercontent.com/27350062/201880841-6cc0cf34-e26a-4d69-9c52-9fbf2c1d0cd6.png)

## Linux workflow for processing 100s to 1000s of genomes to discover EVEs

# Highlights:

- No storage issues when processing 1000s of genomes. Using cressdnavirus queries, total output for ~25,000 eukaryotic genomes was <2 GB
- Custom protein queries can be used to target any virus/EVE lineage
- Each element represents a region of interest (ROI) in the assembly. ROIs are likely to get multiple distinct alignments. This workflow first merges overlapping alignments to record the maximal ranges of a ROI, before extracting the predicted protein sequence of the best single alignment (unlikely to span the maximal ranges)
- Older EVEs often contain stop codons. These are retained in the final ".fmt6" output, as they are potentially informative. Ensure they are removed prior to phylogenetic analysis, or BLAST curation of sequences
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
conda EVE_discovery create -f environment.yml
conda activate EVE_discovey
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
- For 200+ genomes, splitting up the input ftp list into multiple subfiles is recommended, with subsets run in parallel using copies of the script
- Sequential assembly accessions often have similar size (e.g. same organism submitted together), therefore shuffling ftp links will ensure a more similar work burden for each job
- To shuffle the complete list: 
```
shuf ftp.list > ftp_shuffled.list
```
- Then split into smaller batches:
```
split -l 100 ftp_shuffled.list
```
- Approximate run time (Intel® Xeon® Gold 6130 - 2.10GHz, 16 cores): 100 eukaryotic genomes in 1-2 days
- For best performance, work with all files within a compute environment/compute node
- It's recommended to carry out quality control on the resulting sequences. E.g. with a DIAMOND installation:
```
diamond blastp --very-sensitive --query queries.faa --db nr --unal 1 --max-target-seqs 20 --outfmt 6 qseqid sseqid pident length evalue bitscore stitle --out diamond.fmt6 --threads 8
```

# Problems with large and highly repetitive genome assemblies
- For a small number of large and very repetitive assemblies (particularly wheats), tBLASTn can fail to finish in reasonable time
- A list of assemblies with known issues can be found in the file "difficultAssemblies.txt"
- Masking simple repeats with repeatmasker can help to reduce runtime
```
RepeatMasker -engine rmblast -pa 4 -noint -species wheat -dir ./out assembly.fna
```
