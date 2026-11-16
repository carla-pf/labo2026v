#!/bin/bash
# Diagnostico (C1, idea de Maylen, ExpCol 10 B): de donde viene la variacion de la ganancia de los modelos sueltos.
# ANOVA ganancia ~ configuracion + semilla, con la ganancia de cada semilla sola (promedio de la ventana del mes).
# Necesita tres o mas corridas con las mismas semillas (misma semilla primigenia y el mismo orden).
# No decide: explica cuanto pesa la configuracion frente al azar de cada modelo.
#
# Uso:   cd ~/buckets/b1/labo2026v-modelo-final
#        bash diagnostico_semillas.sh 9004 9014 9016 9023 9024            (202107, ventana 1300 a 3500)
#        MES=202105 bash diagnostico_semillas.sh 9104 9114 9123
# Deja el resultado en ~/buckets/b1/exp/comparaciones/diagnostico_semillas_<mes>_<corridas>.txt

if [ $# -lt 3 ]; then echo "Hacen falta tres o mas corridas. Ej: bash diagnostico_semillas.sh 9004 9014 9023"; exit 1; fi
MES=${MES:-202107}
EXP=$HOME/buckets/b1/exp
DS=/content/datasets/analistajr_competencia_2026.csv.gz
mkdir -p "$EXP/comparaciones"
OUT=$EXP/comparaciones/diagnostico_semillas_${MES}_$(echo "$@" | tr ' ' '_').txt

Rscript - "$EXP" "$DS" "$MES" "$@" <<'RR' 2>&1 | tee "$OUT"
suppressMessages(library(data.table))
options(width = 200, warn = -1)
arg <- commandArgs(trailingOnly = TRUE)
EXP <- arg[1]; DS <- arg[2]; MES <- as.integer(arg[3]); corr <- arg[-(1:3)]
V <- seq(1300, 3500, 100)
cat("===== DIAGNOSTICO DE SEMILLAS (C1)  mes:", MES, "  corridas:", corr, "  ", format(Sys.time(), "%F %T"), "\n")
cache <- file.path(EXP, "comparaciones", paste0("clase_", MES, ".txt"))
cl <- if (file.exists(cache)) fread(cache) else fread(DS, select = c("numero_de_cliente", "foto_mes", "clase_ternaria"))[foto_mes == MES, list(numero_de_cliente, clase_ternaria)]
L <- list(); semi <- list()
for (x in corr) {
  p <- merge(fread(file.path(EXP, paste0("WF", x), "prediccion_validacion.txt")), cl, by = "numero_de_cliente")
  if (nrow(p) != nrow(cl)) stop("corrida ", x, ": no coincide con los clientes de ", MES)
  g <- ifelse(p$clase_ternaria == "BAJA+2", 975000, -25000)
  cols <- grep("^prob_[0-9]+$", names(p), value = TRUE)
  sf <- file.path(EXP, paste0("WF", x), "validacion_semillas.txt")
  semi[[x]] <- if (file.exists(sf)) unique(fread(sf)$semilla)[seq_along(cols)] else seq_along(cols)
  L[[x]] <- data.table(config = x, semilla = semi[[x]],
                       g = sapply(cols, function(cc) mean(cumsum(g[order(-p[[cc]])])[V]) / 1e6),
                       semilleria = mean(cumsum(g[order(-p$prob)])[V]) / 1e6)
}
d <- rbindlist(L)
comunes <- Reduce(intersect, semi)
cat("semillas en comun entre todas:", length(comunes), "\n")
if (length(comunes) < 5) stop("hacen falta al menos 5 semillas en comun")
d <- d[semilla %in% comunes]
d[, config := factor(config, levels = corr)][, semilla := factor(semilla)]
a <- anova(lm(g ~ config + semilla, d))
ss <- a[["Sum Sq"]]
cat("\n----- ANOVA: ganancia del modelo suelto ~ configuracion + semilla (ventana 1300 a 3500)\n")
print(data.table(fuente = c("configuracion", "semilla", "residuo (semilla x configuracion)"), gl = a$Df,
                 suma_cuadrados = round(ss, 1), proporcion_pc = round(100 * ss / sum(ss), 1),
                 F = round(a[["F value"]], 2), p = signif(a[["Pr(>F)"]], 3)))
cat("\n----- por corrida\n")
print(d[, list(ganancia_media_suelto = round(mean(g), 2), desvio_entre_semillas = round(sd(g), 2), semillerio = round(semilleria[1], 2)), by = config])
cat("\n----- correlacion de la ganancia por semilla entre corridas\n")
w <- dcast(d, semilla ~ config, value.var = "g"); print(round(cor(w[, -1]), 2))
cat("\nLectura: la configuracion pesa lo que dice su proporcion; el resto es azar de cada modelo, que el semillerio promedia.\n")
cat("El orden de los modelos sueltos no tiene por que ser el de los semillerios (ver 9004 vs 9005 y 9024 en la bitacora).\n")
RR

echo
echo "Listo. Guardado en $OUT"
