#!/bin/bash
# Mirada rapida a varias corridas, sin remuestreo (la decision la toma comparar_corridas.sh).
# Para cada corrida que ya tiene prediccion_validacion.txt: AUC del semillerio, ganancia promedio
# de los cortes 1300 a 3500 en 202107, maximo suavizado y meseta.
# Uso:   cd ~/buckets/b1/labo2026v-modelo-final
#        bash mirar.sh 9004 9014 9015 9016

if [ -z "$1" ]; then echo "Uso: bash mirar.sh 9004 9014 9015 ..."; exit 1; fi
EXP=$HOME/buckets/b1/exp
DS=/content/datasets/analistajr_competencia_2026.csv.gz
[ -f "$DS" ] || DS=$HOME/datasets/analistajr_competencia_2026.csv.gz

Rscript - "$EXP" "$DS" "$@" <<'RR'
suppressMessages(library(data.table))
options(width = 200, warn = -1)
a <- commandArgs(trailingOnly = TRUE); EXP <- a[1]; DS <- a[2]; corridas <- a[-(1:2)]
cache <- file.path(EXP, "comparaciones", "clase_202107.txt")
if (file.exists(cache)) clase <- fread(cache) else {
  clase <- fread(DS, select = c("numero_de_cliente", "foto_mes", "clase_ternaria"))[foto_mes == 202107, list(numero_de_cliente, clase_ternaria)]
  dir.create(dirname(cache), showWarnings = FALSE); fwrite(clase, cache, sep = "\t")
}
res <- rbindlist(lapply(corridas, function(e) {
  f <- file.path(EXP, paste0("WF", e), "prediccion_validacion.txt")
  if (!file.exists(f)) return(data.table(corrida = e, estado = "todavia no"))
  p <- fread(f, select = c("numero_de_cliente", "prob"))
  t <- clase[p, on = "numero_de_cliente"]
  y <- as.integer(t$clase_ternaria %in% c("BAJA+1", "BAJA+2")); r <- frank(t$prob)
  n1 <- as.numeric(sum(y)); n0 <- as.numeric(sum(1 - y))
  auc <- (sum(r[y == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
  g <- cumsum(ifelse(t$clase_ternaria == "BAJA+2", 975000, -25000)[order(-t$prob)])
  cc <- seq(1000, 5000, by = 100); su <- as.numeric(frollmean(g[cc], 5, align = "center"))
  mx <- max(su, na.rm = TRUE); mes <- cc[!is.na(su) & su >= mx - 1e6]
  data.table(corrida = e, estado = "lista", AUC = round(auc, 4),
             prom_1300_3500 = round(mean(g[seq(1300, 3500, by = 100)]) / 1e6, 2),
             max_suavizado = round(mx / 1e6, 1), en = cc[which.max(su)], meseta = paste(min(mes), "a", max(mes)))
}), fill = TRUE)
print(res)
cat("\nMirada rapida, sin remuestreo: para decidir, comparar_corridas.sh (regla: P >= 0,90).\n")
RR
