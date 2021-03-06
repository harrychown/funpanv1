

### GENERATE DATA FOR GLIMMERHMM ###
cd /data/global/prediction/glimmerHMM

: <<'END'
# Remove description tags from FASTA
sed 's/ |.*//g' FungiDB-58_AfumigatusAf293_AnnotatedCDSs.fasta > Af293.cds.fasta
grep ">" Af293.cds.fasta | sed 's/>//g' > cds_in_fasta.txt
# Extract exon names and information
grep -f cds_in_fasta.txt FungiDB-58_AfumigatusAf293.gff > Af293.matched.gff
grep -P "\texon\t" Af293.matched.gff | sed 's/.*Parent=//g'| cut -d";" -f1 > exon.names.tmp
grep -P "\texon\t" Af293.matched.gff | cut -d$'\t' -f3-5 > exon.info.tmp

# Combine the ID and exons
paste exon.names.tmp exon.info.tmp | column -s $'\t' -t > exon.combined.tmp

# Generate list of ordered exon names
cat exon.names.tmp | sort | uniq > exon.uniq.tmp
# Add blank space after each gene
while read gene
do
	sed -i '1h;1!H;$!d;x;s/.*'"$gene"'[^\n]*/&\n/' exon.combined.tmp
done <exon.uniq.tmp
END
cat exon.combined.tmp | awk '{print $1}' | cat -n |  sort -uk2 | sort -n | cut -f2- > exon.combined.order.tmp

samtools faidx Af293.cds.fasta $(cat exon.combined.order.tmp) > Af293.ordered.fasta


sed 's/exon //g' exon.combined.tmp > exon.file

/home/harry/GlimmerHMM-3.0.4/GlimmerHMM/train/trainGlimmerHMM Af293.ordered.fasta exon.file

/home/harry/GlimmerHMM-3.0.4/GlimmerHMM/train/trainGlimmerHMM Af293.ordered.fasta exon.file
/home/harry/GlimmerHMM-3.0.4/GlimmerHMM/sources/glimmerhmm Af293.fna -d train_glim_4_7 -g 


#grep "protein_coding_gene" FungiDB-58_AfumigatusAf293.gff | sed 's/.*ID=//g' | cut -d";" -f1 | wc -l
#grep -P "\texon\t" FungiDB-58_AfumigatusAf293.gff > exon.gff

#grep "protein_coding_gene" FungiDB-58_AfumigatusAf293.gff

