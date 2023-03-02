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

#################################### Step 2: Filter mapped samples and sort ############################################

if [ -e dedup.param ]; then rm dedup.param; fi

if [ ! -d $LOG ]; then 
    echo "Log directory doesn't exist. Making $LOG"
    mkdir $LOG
fi

COMM="/work2/02786/taslima/stampede2/tools/bwa-mem2-2.0pre2_x64-linux/bwa-mem2 mem"
while read line
do
    SAMP=`echo $line | cut -d',' -f1`
    INF="${outDir}/MAP_SORTED/${SAMP}_sorted.bam"
    OFIL="${outDir}/MAP_SORTED_DEDUP/${SAMP}_dedup.bam"
    MT="${outDir}/MAP_SORTED_DEDUP/${SAMP}_MAT.txt"
    OLOG="${LOG}/DEDUP_${SAMP}.log"
    echo "ulimit -c unlimited && java -Xmx60G -jar \$TACC_PICARD_DIR/build/libs/picard.jar MarkDuplicates USE_JDK_DEFLATER=true USE_JDK_INFLATER=true OUTPUT=$OFIL INPUT=$INF M=$MT \
        VALIDATION_STRINGENCY=LENIENT ASSUME_SORTED=true SORTING_COLLECTION_SIZE_RATIO=0.05 REMOVE_DUPLICATES=true TMP_DIR=$TMP \
         MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 MAX_RECORDS_IN_RAM=1000000 CREATE_INDEX=true" >>dedup.param

done < $met

# Now count the line number of the file and copy will not take more that one hr
#Core=`wc -l rename.param |cut -f1 -d ' '`
#if (( $Core % 26 == 0)); then Node="$(($Core/26))";
#        else  Node="$((($Core/26)+1))";
#fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J rename -N $Node -n $Core --ntasks-per-node=26 -p normal -t 06:00:00 slurm.sh rename.param

