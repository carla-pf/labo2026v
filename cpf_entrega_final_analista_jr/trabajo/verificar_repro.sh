#!/bin/bash
# Verificacion de reproducibilidad de la entrega: compara la corrida original (A, por defecto 9031) con la
# re-corrida de la notebook de la carpeta de entrega (B, por defecto 9084), con el criterio del 13/11
# (ver "Reproducibilidad: 9029 en las dos VM (13/11)" en la bitacora):
#   mismo orden de clientes, mismos elegidos y misma ganancia; cada archivo de Kaggle tiene que dar el mismo md5.
# Archivos de Kaggle, corte por corte (por defecto 1900 a 2700 de a 100):
#   A: WF<A>/repro/KA<A>_100_<corte>.csv (generados desde prediccion.txt con el codigo de la notebook);
#      si falta alguno, lo genera ahi (no toca WF<A>/kaggle).
#   B: WF<B>/kaggle/KA<B>_100_<corte>.csv (los genera la notebook de la entrega).
# No sube nada a Kaggle.
#
# Uso:   bash verificar_repro.sh [A] [B]          Ej.: bash verificar_repro.sh 9031 9084
# Otros cortes: CORTES="1900 2400" bash verificar_repro.sh 9031 9084

A=${1:-9031}; B=${2:-9084}
CORTES=${CORTES:-$(seq -s ' ' 1900 100 2700)}
EXP=$HOME/buckets/b1/exp
for e in $A $B; do
  for f in prediccion.txt prediccion_validacion.txt; do
    [ -f $EXP/WF$e/$f ] || { echo "[ERROR] falta $EXP/WF$e/$f"; exit 1; }
  done
done

Rscript - "$EXP" "$A" "$B" "$CORTES" <<'RR'
suppressMessages(library(data.table))
arg <- commandArgs(trailingOnly = TRUE)
EXP <- arg[1]; A <- arg[2]; B <- arg[3]; CORTES <- as.integer(strsplit(arg[4], " ")[[1]])
md5 <- function(f) unname(tools::md5sum(f))
wf <- function(e) file.path(EXP, paste0("WF", e))
fila <- function(nombre, a, b) cat(sprintf("%-48s %-34s %-34s %s\n", nombre, a, b, if (identical(a, b)) "[IGUAL]" else "[DISTINTO]"))

cat("Verificacion de reproducibilidad:", A, "(original) contra", B, "(re-corrida)\n")
for (arch in c("prediccion.txt", "prediccion_validacion.txt")) {
  pa <- fread(file.path(wf(A), arch)); pb <- fread(file.path(wf(B), arch))
  cat("\n", arch, "\n", sep = "")
  fila("  filas x columnas", paste(dim(pa), collapse = " x "), paste(dim(pb), collapse = " x "))
  fila("  md5 (puede diferir en el decimal 14)", md5(file.path(wf(A), arch)), md5(file.path(wf(B), arch)))
  if (!identical(pa$numero_de_cliente, pb$numero_de_cliente)) { cat("  [DISTINTO] los clientes no estan en el mismo orden\n"); next }
  cols <- grep("^prob", names(pa), value = TRUE)
  cat(sprintf("  columnas de probabilidad identicas: %d de %d · diferencia maxima: %.1e\n",
              sum(sapply(cols, function(cc) identical(pa[[cc]], pb[[cc]]))), length(cols),
              max(sapply(cols, function(cc) max(abs(pa[[cc]] - pb[[cc]]))))))
  oa <- pa[order(-prob), numero_de_cliente]; ob <- pb[order(-prob), numero_de_cliente]
  fila("  orden de clientes del semillerio", "-", if (identical(oa, ob)) "-" else "distinto")
  if (arch == "prediccion_validacion.txt") {
    cl <- fread(file.path(EXP, "comparaciones", "clase_202107.txt"))
    gan <- function(p) { x <- merge(p[, .(numero_de_cliente, prob)], cl, by = "numero_de_cliente"); setorder(x, -prob)
      sprintf("%.1f M", mean(cumsum(ifelse(x$clase_ternaria == "BAJA+2", 975000, -25000))[1300:3500]) / 1e6) }
    fila("  ganancia 202107, promedio 1300 a 3500", gan(pa), gan(pb))
  }
}

# archivos de Kaggle, corte por corte
pa <- fread(file.path(wf(A), "prediccion.txt")); nsa <- length(grep("^prob_[0-9]+$", names(pa))); setorder(pa, -prob)
dir.create(file.path(wf(A), "repro"), showWarnings = FALSE)
cat("\nArchivos de Kaggle (excluyente): ", A, " en WF", A, "/repro, ", B, " en WF", B, "/kaggle\n", sep = "")
cat(sprintf("  %-6s %-34s %-34s\n", "corte", A, B))
todos <- TRUE
for (k in CORTES) {
  fa <- file.path(wf(A), "repro", paste0("KA", A, "_", nsa, "_", k, ".csv"))
  if (!file.exists(fa)) { pa[, Predicted := 0L]; pa[1:k, Predicted := 1L]; fwrite(pa[, list(numero_de_cliente, Predicted)], file = fa, sep = ",") }
  fb <- Sys.glob(file.path(wf(B), "kaggle", paste0("KA", B, "_*_", k, ".csv")))
  mb <- if (length(fb) == 1) md5(fb) else "falta el archivo"
  ok <- identical(md5(fa), mb); todos <- todos && ok
  cat(sprintf("  %-6d %-34s %-34s %s\n", k, md5(fa), mb, if (ok) "[IGUAL]" else "[DISTINTO]"))
}
cat("\n", if (todos) paste0("[OK] REPRODUCIBLE: los ", length(CORTES), " archivos de Kaggle tienen el mismo md5")
        else "[REVISAR] NO REPRODUCIBLE: algun archivo de Kaggle difiere o falta", "\n", sep = "")
RR
