############################################# Head of all Scripts ####################################
# The following directories and files are expected to run for SNP calling
refDir=/work2/02786/taslima/stampede2/dbs/PV/VS16_HAP1_V1/Panicum_virgatum_var_VS16_HAP1_V1_release/Panicum_virgatum_var_VS16/sequences #directory where the reference genome file will be
ref=Panicum_virgatum_var_VS16.mainGenome.fasta # Name of reference genome file
outDir=/scratch/02786/taslima/data/PV_Reseq # output directory. It must be created before running the script
met=/work2/02786/taslima/stampede2/dbs/PV/Pvirg_48_midwest_metadata_mod.csv
TMP=/scratch/02786/taslima/data/phalli/Temp
CHR=/work2/02786/taslima/stampede2/dbs/PV/VS16_HAP1_V1/Panicum_virgatum_var_VS16_HAP1_V1_release/Panicum_virgatum_var_VS16/sequences/Panicum_virgatum_var_VS16.ChrName.tab

LOG="logs"

# Sample of meta file, ignore the "#" before each line. you can use any kind of tab delim file and change Step 1 accordingly.


# load required module in TACC
ml intel/17.0.4
ml picard
ml samtools
LC_ALL=C

#################################### Step 6: Merge VCF by bctools ############################################

if [ -e bcfmerge.param ]; then rm bcfmerge.param; fi
if [ -e bcfindex1.param ]; then rm bcfindex1.param; fi
if [ -e bcfindex2.param ]; then rm bcfindex2.param; fi

if [ -e bcflist.txt ]; then rm bcflist.txt; fi

if [ ! -d $LOG ]; then 
    echo "Log directory doesn't exist. Making $LOG"
    mkdir $LOG
fi

if [ ! -d ${outDir}/VarScan_Filter/ ]; then
    echo "Input directory doesn't exist! Exiting ..."
    exit 1
fi


while read line
do
    SAMP=`echo $line | cut -d',' -f1`
    FIL="${outDir}/VarScan_Filter/${SAMP}.d8.vcf.gz"

    echo $FIL >> bcflist.txt 
    echo "/work2/02786/taslima/stampede2/tools/bcftools-1.16/bcftools index $FIL" >> bcfindex1.param
done < $met


while read line
do
    NCHR=`echo $line | cut -f1`
    OFIL="${outDir}/MergedVCF/Pvirgatum_5.1_47g${NCHR}.d8.merged.vcf.gz"

    echo "/work2/02786/taslima/stampede2/tools/bcftools-1.16/bcftools merge --file-list bcflist.txt -O z -r $NCHR -o $OFIL" >> bcfmerge.param 
    echo "/work2/02786/taslima/stampede2/tools/bcftools-1.16/bcftools index $OFIL" >> bcfindex2.param
done < $CHR

