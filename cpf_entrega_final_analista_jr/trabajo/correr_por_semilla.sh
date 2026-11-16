#!/bin/bash
# DR-3 (13/11): semillerio en "modo por semilla". Cada semilla es una corrida completa de la notebook
# (CA, drifting con empates al azar propios, FE, RF, canaritos, entrenamiento de UNA semilla), asi el azar
# de los empates del rank cambia de semilla en semilla y el semillerio lo promedia.
# Cada semilla deja lo suyo en WF<exp>/semilla_<i>; al final se juntan las N en WF<exp> con el mismo
# formato que una corrida normal (prediccion_validacion.txt, prediccion.txt, validacion_semillas.txt,
# validacion_cortes.txt, PARAM.yml con el AUC), asi comparar_corridas.sh, mirar.sh y enviar_cortes.sh andan igual.
# Se puede cortar y volver a lanzar: saltea las semillas que ya terminaron.
#
# Uso:   cd ~/buckets/b1/labo2026v-modelo-final && bash correr_por_semilla.sh <exp> <N>
# Ej.:   bash correr_por_semilla.sh 9042 100

E=$1; N=$2
if [ -z "$E" ] || [ -z "$N" ]; then echo "Uso: bash correr_por_semilla.sh <exp> <N>"; exit 1; fi
REPO=$HOME/buckets/b1/labo2026v-modelo-final
WF=$HOME/buckets/b1/exp/WF$E
cd "$REPO" || exit 1
mkdir -p "$WF"
NB="$HOME/.venv/bin/jupyter nbconvert --to notebook --execute --ExecutePreprocessor.kernel_name=ir --ExecutePreprocessor.timeout=-1"

# si no hay ninguna semilla terminada, se arranca de cero: se borra el cache de hojas de RF (lo usa 9043)
if ! ls "$WF"/semilla_*/prediccion.txt > /dev/null 2>&1; then rm -f "$HOME/cache_rf_$E.rds"; fi

for i in $(seq 1 $N); do
  if [ -f "$WF/semilla_$i/prediccion.txt" ]; then echo "semilla $i: ya estaba, la salteo"; continue; fi
  echo "semilla $i de $N empieza $(date +%H:%M:%S)"
  SEMILLA_IDX=$i $NB --output-dir="$WF/semilla_$i" --output=corrida_${E}_$i.ipynb ${E}_739_final_senior.ipynb > "$WF/semilla_$i.log" 2>&1
  if [ ! -f "$WF/semilla_$i/prediccion.txt" ]; then
    echo "[ERROR] la semilla $i fallo; ultimas lineas de $WF/semilla_$i.log:"; tail -20 "$WF/semilla_$i.log"; exit 1
  fi
done

echo "juntando las $N semillas $(date +%H:%M:%S)"
Rscript - "$WF" "$N" <<'RR'
suppressMessages(library(data.table))
arg <- commandArgs(trailingOnly = TRUE); WF <- arg[1]; N <- as.integer(arg[2])
junta <- function(archivo) {
  L <- lapply(seq_len(N), function(i) {
    d <- fread(file.path(WF, paste0("semilla_", i), archivo), select = c("numero_de_cliente", "prob_1"))
    setnames(d, "prob_1", paste0("prob_", i)); setkey(d, numero_de_cliente); d })
  d <- Reduce(function(a, b) a[b], L)
  stopifnot(nrow(d) == nrow(L[[1]]), !anyNA(d))
  cols <- paste0("prob_", seq_len(N))
  d[, prob := rowMeans(.SD), .SDcols = cols]
  setcolorder(d, c("numero_de_cliente", "prob", cols)); d
}
v <- junta("prediccion_validacion.txt"); fwrite(v, file.path(WF, "prediccion_validacion.txt"), sep = "\t")
f <- junta("prediccion.txt");            fwrite(f, file.path(WF, "prediccion.txt"), sep = "\t")
fwrite(rbindlist(lapply(seq_len(N), function(i) fread(file.path(WF, paste0("semilla_", i), "validacion_semillas.txt")))),
       file.path(WF, "validacion_semillas.txt"), sep = "\t")
# clase del mes de validacion (sale de la corrida misma: semilla 1)
cl <- fread(file.path(WF, "semilla_1", "prediccion_validacion.txt"), select = "numero_de_cliente")
mes <- as.integer(sub(".*validate:\\s*", "", grep("validate:", readLines(file.path(WF, "semilla_1", "PARAM.yml")), value = TRUE)[1]))
cache <- file.path(dirname(WF), "comparaciones", paste0("clase_", mes, ".txt"))
clase <- if (file.exists(cache)) fread(cache) else fread("/content/datasets/analistajr_competencia_2026.csv.gz",
           select = c("numero_de_cliente", "foto_mes", "clase_ternaria"))[foto_mes == mes]
v <- merge(v[, list(numero_de_cliente, prob)], clase[, list(numero_de_cliente, clase_ternaria)], by = "numero_de_cliente")
v[, c01 := as.integer(clase_ternaria %in% c("BAJA+1", "BAJA+2"))]
r <- frank(v$prob); n1 <- as.numeric(sum(v$c01)); n0 <- as.numeric(sum(1 - v$c01))
auc <- (sum(r[v$c01 == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
setorder(v, -prob); v[, ga := cumsum(ifelse(clase_ternaria == "BAJA+2", 975000, -25000))]
vc <- seq(1300, 2200, 100)
fwrite(data.table(envios = vc, ganancia = v$ga[vc]), file.path(WF, "validacion_cortes.txt"), sep = "\t")
writeLines(c("# junta de correr_por_semilla.sh: el PARAM completo de cada semilla esta en semilla_<i>/PARAM.yml",
             paste0("semillas_juntadas: ", N), "trainingstrategy:", paste0("  validate: ", mes),
             "out:", "  validacion:", paste0("    AUC: ", signif(auc, 7)), paste0("    ganancia_max: ", max(v$ga)),
             paste0("    envios_max: ", which.max(v$ga))), file.path(WF, "PARAM.yml"))
cat("listo: mes", mes, " semillas", N, " AUC", round(auc, 4), " ganancia media 1300-3500:",
    round(mean(v$ga[seq(1300, 3500, 100)]) / 1e6, 2), "M\n")
RR
