# Tree of life EVE discovery

For processing 100s or 1000s of genomes to discover EVEs. 

- No storage issues: assemblies are not retained locally. Using cressdnaviruses, total output for ~25,000 eukaryotic genomes is <5 GB. 
- Custom protein queries can be used to target any viral group. 

# Usage:

- The workflow is provided as a bash script, adapt this to your system.

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
