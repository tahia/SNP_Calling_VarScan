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

#################################### Step 4: VarScan ############################################

if [ -e varscan.param ]; then rm varscan.param; fi

if [ ! -d $LOG ]; then 
    echo "Log directory doesn't exist. Making $LOG"
    mkdir $LOG
fi

if [ ! -d ${outDir}/VarScan/ ]; then
    echo "Log directory doesn't exist. Making ${outDir}/VarScan/"
    mkdir ${outDir}/VarScan/
fi


while read line
do
    SAMP=`echo $line | cut -d',' -f1`
    INF="${outDir}/MAP_SORTED_DEDUP/${SAMP}_dedup.bam"
    OFIL="${outDir}/VarScan/${SAMP}.vcf.gz"
    OLOG="${LOG}/VARscan_${SAMP}.log"
    #samtools mpileup -d 500 -Q 20 -f Pvirgatum_V5.1.fa LIB.Pvirgatum_V5.1.dedup.bam | java -jar VarScan.v2.4.3.jar mpileup2cns --min-coverage 1 --min-reads2 0 --output-vcf |  awk 'FS=OFS="\t" {if($0 ~ /^#/) {print} else {split($10,s,":"); if(s[1] != "./.") print $1,$2,$3,$4,$5,$6,$7,".","GT:RD:AD", s[1]":"s[5]":"s[6]}' | bgzip -c > LIB.vcf.gz;

    echo "samtools mpileup -d 500 -Q 20 -f $refDir/$ref $INF | java -Xmx60G -jar /work2/02786/taslima/stampede2/tools/VarScan.v2.3.9.jar mpileup2cns --min-coverage 1 --min-reads2 0 --output-vcf | \
   awk 'FS=OFS=\"\t\" {if(\$0 ~ /^#/) {print} else {split(\$10,s,\":\"); if(s[1] != \"./.\") print \$1,\$2,\$3,\$4,\$5,\$6,\$7,\".\",\"GT:RD:AD\", s[1]\":\"s[5]\":\"s[6]}}' | bgzip -c > $OFIL 2>$OLOG" >> \
       varscan.param
done < $met

# Now count the line number of the file and copy will not take more that one hr
#Core=`wc -l rename.param |cut -f1 -d ' '`
#if (( $Core % 26 == 0)); then Node="$(($Core/26))";
#        else  Node="$((($Core/26)+1))";
#fi

## Change time (-t) and partition (-p) as per your need and in slurm file change your allocation name
#sbatch -J rename -N $Node -n $Core --ntasks-per-node=26 -p normal -t 06:00:00 slurm.sh rename.param

