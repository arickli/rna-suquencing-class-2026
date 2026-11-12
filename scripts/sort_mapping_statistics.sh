#!/bin/bash
# ==============================================================================
# Script: parse_hisat2_pure_bash.sh
# Purpose: Parst HISAT2 error logs rein mit Bash & AWK (ohne Python)
#          Extrahiert alle Anzahlen + Prozentwerte und berechnet Mean, Median, Min, Max.
# ==============================================================================

set -e

cd output/mapping/

TARGET_DIR="."
if [ -d "mapping" ]; then
    TARGET_DIR="mapping"
fi

OUT_CSV="${TARGET_DIR}/hisat2_all_metrics_with_stats.csv"
STATS_CSV="${TARGET_DIR}/hisat2_summary_statistics.csv"
TMP_DATA="${TARGET_DIR}/.tmp_raw_data.csv"

# 1. Header mit allen Anzahlen und Prozentwerten
HEADER="file,total_reads,paired_reads,paired_pct,concordant_0x,concordant_0x_pct,concordant_exact_1x,concordant_exact_1x_pct,concordant_gt1x,concordant_gt1x_pct,pairs_concordant_0x,discordant_1x,discordant_1x_pct,pairs_unaligned_conc_disc,mates_total,mates_aligned_0x,mates_aligned_0x_pct,mates_aligned_exact_1x,mates_aligned_exact_1x_pct,mates_aligned_gt1x,mates_aligned_gt1x_pct,overall_alignment_rate_pct"

echo "$HEADER" > "$TMP_DATA"

# 2. Werte aus allen Log-Dateien numerisch sortiert extrahieren (_0.e bis _14.e)
for f in $(ls -v ${TARGET_DIR}/error_mapping_*.e 2>/dev/null); do
    fname=$(basename "$f")

    tot=$(grep "reads; of these:" "$f" | awk '{print $1}')
    paired=$(grep "were paired; of these:" "$f" | awk '{print $1}')
    paired_pct=$(grep "were paired; of these:" "$f" | awk '{print $2}' | tr -d '()%')

    c0=$(grep "aligned concordantly 0 times" "$f" | head -n 1 | awk '{print $1}')
    c0_pct=$(grep "aligned concordantly 0 times" "$f" | head -n 1 | awk '{print $2}' | tr -d '()%')

    c1=$(grep "aligned concordantly exactly 1 time" "$f" | awk '{print $1}')
    c1_pct=$(grep "aligned concordantly exactly 1 time" "$f" | awk '{print $2}' | tr -d '()%')

    cgt1=$(grep "aligned concordantly >1 times" "$f" | awk '{print $1}')
    cgt1_pct=$(grep "aligned concordantly >1 times" "$f" | awk '{print $2}' | tr -d '()%')

    p_c0=$(grep "pairs aligned concordantly 0 times; of these:" "$f" | awk '{print $1}')

    disc1=$(grep "aligned discordantly 1 time" "$f" | awk '{print $1}')
    disc1_pct=$(grep "aligned discordantly 1 time" "$f" | awk '{print $2}' | tr -d '()%')

    p_un=$(grep "pairs aligned 0 times concordantly or discordantly; of these:" "$f" | awk '{print $1}')
    mates_tot=$(grep "mates make up the pairs; of these:" "$f" | awk '{print $1}')

    m0=$(grep "aligned 0 times" "$f" | tail -n 1 | awk '{print $1}')
    m0_pct=$(grep "aligned 0 times" "$f" | tail -n 1 | awk '{print $2}' | tr -d '()%')

    m1=$(grep "aligned exactly 1 time" "$f" | awk '{print $1}')
    m1_pct=$(grep "aligned exactly 1 time" "$f" | awk '{print $2}' | tr -d '()%')

    mgt1=$(grep "aligned >1 times" "$f" | tail -n 1 | awk '{print $1}')
    mgt1_pct=$(grep "aligned >1 times" "$f" | tail -n 1 | awk '{print $2}' | tr -d '()%')

    rate=$(grep "overall alignment rate" "$f" | awk '{print $1}' | tr -d '%')

    echo "${fname},${tot},${paired},${paired_pct},${c0},${c0_pct},${c1},${c1_pct},${cgt1},${cgt1_pct},${p_c0},${disc1},${disc1_pct},${p_un},${mates_tot},${m0},${m0_pct},${m1},${m1_pct},${mgt1},${mgt1_pct},${rate}" >> "$TMP_DATA"
done

# 3. Berechnung von Mean, Median, Min, Max ausschließlich mit AWK
awk -F',' -v stats_file="$STATS_CSV" -v out_file="$OUT_CSV" '
NR==1 {
    header = $0
    n_cols = NF
    for(i=1; i<=NF; i++) col_names[i] = $i
    next
}
{
    rows[NR-1] = $0
    n_rows++
    for(i=2; i<=NF; i++) {
        val = $i + 0
        vals[i, n_rows] = val
        sum[i] += val
        if(n_rows == 1 || val < min[i]) min[i] = val
        if(n_rows == 1 || val > max[i]) max[i] = val
    }
}
END {
    # 1. Statistik-Tabelle schreiben (Spalten: metric, mean, median, min, max)
    print "metric,mean,median,min,max" > stats_file

    for(i=2; i<=n_cols; i++) {
        mean[i] = (n_rows > 0) ? sum[i] / n_rows : 0

        # Sortierung für den Median
        for(r=1; r<=n_rows; r++) temp[r] = vals[i, r]
        for(a=1; a<=n_rows; a++) {
            for(b=a+1; b<=n_rows; b++) {
                if(temp[a] > temp[b]) {
                    t = temp[a]; temp[a] = temp[b]; temp[b] = t
                }
            }
        }
        if(n_rows % 2 == 1) {
            median[i] = temp[(n_rows + 1) / 2]
        } else {
            median[i] = (temp[n_rows / 2] + temp[(n_rows / 2) + 1]) / 2.0
        }

        printf "%s,%.2f,%.2f,%.2f,%.2f\n", col_names[i], mean[i], median[i], min[i], max[i] >> stats_file
    }

    # 2. Haupt-CSV mit Daten und angehängten Statistik-Zeilen schreiben
    print header > out_file
    for(r=1; r<=n_rows; r++) print rows[r] >> out_file

    printf "MEAN" >> out_file
    for(i=2; i<=n_cols; i++) printf ",%.2f", mean[i] >> out_file
    printf "\n" >> out_file

    printf "MEDIAN" >> out_file
    for(i=2; i<=n_cols; i++) printf ",%.2f", median[i] >> out_file
    printf "\n" >> out_file

    printf "MIN" >> out_file
    for(i=2; i<=n_cols; i++) printf ",%.2f", min[i] >> out_file
    printf "\n" >> out_file

    printf "MAX" >> out_file
    for(i=2; i<=n_cols; i++) printf ",%.2f", max[i] >> out_file
    printf "\n" >> out_file
}
' "$TMP_DATA"

rm -f "$TMP_DATA"

echo "Erfolgreich ausgeführt!"
echo "  1. Gesamttabelle mit Statistik-Zeilen: $OUT_CSV"
echo "  2. Statistik-Tabelle (eigene Spalten):  $STATS_CSV"