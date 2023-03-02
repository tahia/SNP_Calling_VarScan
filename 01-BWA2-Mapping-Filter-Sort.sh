############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/work2/02786/taslima/stampede2/dbs/PV/VS16_HAP1_V1/Panicum_virgatum_var_VS16_HAP1_V1_release/Panicum_virgatum_var_VS16/sequences #directory where the reference genome file will be
ref=Panicum_virgatum_var_VS16.mainGenome.fasta # Name of reference genome file
outDir=/scratch/02786/taslima/data/PV_Reseq # output directory. It must be created before running the script
met=/work2/02786/taslima/stampede2/dbs/PV/Pvirg_48_midwest_metadata_mod.csv
TMP=/scratch/02786/taslima/data/phalli/Temp


LOG="logs"

# Sample of meta file, ignore the "#" before each line. you can use any kind of tab delim file and change Step 1 accordingly.


# load required module in TACC
ml intel/17.0.4
ml picard
ml samtools
LC_ALL=C

#################################### Step 1: Rename ############################################

# Now rename all the files acording to meta deta

if [ -e bwa2-sort.param ]; then rm bwa2-sort.param; fi

if [ ! -d $LOG ]; then 
    echo "Log directory doesn't exist. Making $LOG"
    mkdir $LOG
fi

COMM="/work2/02786/taslima/stampede2/tools/bwa-mem2-2.0pre2_x64-linux/bwa-mem2 mem"
while read line
do
    SAMP=`echo $line | cut -d',' -f1`
    R1="<(bzcat ${outDir}/RAW/${SAMP}*_R1.fastq.bz2)"
    R2="<(bzcat ${outDir}/RAW/${SAMP}*_R2.fastq.bz2)"
    OFIL="${outDir}/MAP_SORTED/${SAMP}_sorted.bam"
    OLOG="${LOG}/BWA2_sorted${SAMP}.log"
    #bwa-mem2 mem -M -t 94  Pvirgatum_V5.1.fa '<zcat R1_001.fastq.gz R1_002.fastq.gz R1_003.fastq.gz' '<zcat R2_001.fastq.gz R2_002.fastq.gz R2_003.fastq.gz'
    echo "$COMM -M -t 64 $refDir/$ref $R1 $R2 | samtools view -u -f 2 -F 4 -@ 32 - | samtools sort -@ 32 -T $TMP  -o $OFIL - 2> $OLOG" >> \
       bwa2-sort.param
done < $met

# Now count the line number of the file and copy will not take more that one hr
#Core=`wc -l rename.param |cut -f1 -d ' '`
#if (( $Core % 26 == 0)); then Node="$(($Core/26))";
#        else  Node="$((($Core/26)+1))";
#fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J rename -N $Node -n $Core --ntasks-per-node=26 -p normal -t 06:00:00 slurm.sh rename.param

