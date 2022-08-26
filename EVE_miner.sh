#!/bin/bash
#SBATCH -N 1
#SBATCH -t 120:00:00
#SBATCH --mem=60G
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=USER@example.com

#########################################################################
# SET THESE PARAMETERS (N.B. $TMPDIR variable refers to compute node scratch space, adjust this to your system)

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate EVE_discovery

# FTP list
cp /directory/ftp.list $TMPDIR

# Protein queries
cp /directory/proteins.fasta $TMPDIR

# Out directory
outdir=/directory/outputs

# Set maximum number of download attempts per genome (if failed md5)
max_downloads=5

# Set number of threads to use
thread_num=16

# Set wd to compute node
cd $TMPDIR

#########################################################################

# Start script

# Script progresses line by line through the list of ftp directories
while read line

do

# Tracks current download attempts
count=0

# Downloads and checks assembly file for corruption, re-attempts if md5 check fails
md5check_function () {
        assembly_ID=`echo $line | sed 's/^.*\///'`
        wget ftp://$line/${assembly_ID}_genomic.fna.gz
        wget ftp://$line/md5checksums.txt
        assemblyFile=`ls -1 *genomic.fna.gz`
        grep $assemblyFile md5checksums.txt > $assemblyFile.md5; rm md5checksums.txt
        status=`md5sum -c $assemblyFile.md5 2>/dev/null | sed 's/.* //'`
        if [ "$status" == FAILED ]
        then
                        if [ "$count" == "$max_downloads" ]
                        then
                                echo "$assemblyFile FAILED md5check $max_downloads times, exiting"; exit 1
                        else
                                echo "$assemblyFile FAILED md5check"; rm $assemblyFile*; count=$[$count +1]; md5check_function
                        fi
        else
                echo "$assemblyFile PASSED md5check"; rm $assemblyFile.md5
        fi
        }

md5check_function

# Formats assembly
gunzip $assemblyFile
for i in *fna; do sed -i 's/ /_/g' $i; done
for i in *fna; do sed -i 's/,//g' $i; done
for i in *fna; do makeblastdb -in $i -dbtype nucl; done
for i in *fna; do samtools faidx $i; done

# Searches for regions of interest
for i in *fna; do tblastn -db $i -query proteins.fasta -evalue 1e-5 -outfmt "6 stitle sstart send sframe qseqid pident length qlen mismatch gapopen evalue bitscore" -num_threads $thread_num | sort -k1,1 -k2,2nr | tr ' ' '\t' > ${i}.tblastn.fmt6; done

# Converts BLAST6 output to ascending BED
for i in *fmt6; do awk '$3>$2' $i > ${i}.bed; done
for i in *fmt6; do awk '$2>$3' $i | awk 'BEGIN{OFS="\t"}; {print $1, $3, $2, $4, $5, $6, $7, $8, $9, $10, $11, $12}' >> ${i}.bed; done
rm *fmt6

# Creates merged BED of maximal strictly overlapping alignment ranges
for i in *bed; do sort -k1,1 -k2,2n $i | bedtools merge > ${i}.strict_coord_merge; done

# Creates merged BEDs, one allowing 1 kb between elements, and another allowing 1 kb between elements & appending up to 3 kb sequence context
for i in *bed; do sort -k1,1 -k2,2n $i | bedtools merge -d 1000 | bedtools slop -i - -g ${i%tblastn.fmt6.bed}fai -b 3000 > ${i}.relaxed_slop_coord_merge; done
for i in *bed; do sort -k1,1 -k2,2n $i | bedtools merge -d 1000 > ${i}.1k_tandem_coord_merge; done
gzip *bed

# Extracts and formats FASTAs using coordinate ranges
for i in *strict_coord_merge; do bedtools getfasta -fi ${i%.tblastn*} -bed $i > ${i}.fas; done
for i in *relaxed_slop_coord_merge; do bedtools getfasta -fi ${i%.tblastn*} -bed $i > ${i}.fas; done
for i in *fas; do sed -i 's/:/=/g' $i; done

# Generates aa output for each strict alignment region, formats output to add assembly name
for i in *strict_coord_merge.fas; do makeblastdb -in $i -dbtype nucl; done
for i in *strict_coord_merge.fas; do tblastn -db $i -query proteins.fasta -outfmt "6 stitle sstart send sframe qseqid pident length qlen slen mismatch gapopen evalue bitscore sseq" -num_threads $thread_num | sort -k1,1 -k13,13nr -k12,12n | sort -u -k1,1 --merge | tr ' ' '\t' > $i.fmt6; done
for i in *fmt6; do while read line; do readlink -f $i | sed 's/^.*\///' | cut -c1-16 | sed 's/_$//' >> $i.name; done < $i; done
for i in *fmt6; do paste $i $i.name > $i.named; done
for i in *named; do mv $i ${i%.named}; rm ${i%d}; done

# File clear up
mv *bed.gz *fas *coord_merge *fmt6 $outdir
rm G*

done < ftp.list
