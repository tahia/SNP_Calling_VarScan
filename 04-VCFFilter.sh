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
ml fastx_toolkit
ml bwa
ml picard
ml samtools
ml gatk/3.8.0
LC_ALL=C

#################################### Step 4: VarScan ############################################

if [ -e filvcf.param ]; then rm filvcf.param; fi

if [ ! -d $LOG ]; then 
    echo "Log directory doesn't exist. Making $LOG"
    mkdir $LOG
fi

if [ ! -d ${outDir}/VarScan/ ]; then
    echo "Input directory doesn't exist! Exiting ..."
    exit 1
fi


while read line
do
    SAMP=`echo $line | cut -d',' -f1`
    INF="${outDir}/VarScan/${SAMP}.vcf.gz"
    OFIL="${outDir}/VarScan/${SAMP}.d8.vcf.gz"
    OLOG="${LOG}/VCFFil_${SAMP}.log"

    echo "gzip -dc $INF | awk 'FS=OFS=\"\t\" {if(\$0 ~ /^#/) {print} else {split(\$10,a,\":\"); \$10 = a[1]}; \$9="GT"; if((a[2] + a[3]) >=8) print \$0}' | bgzip -c > $OFIL 2>$OLOG" >> filvcf.param 
done < $met


