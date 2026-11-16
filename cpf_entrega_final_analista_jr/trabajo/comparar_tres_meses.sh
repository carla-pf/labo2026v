#!/bin/bash
# P de los tres meses: probabilidad de que B le gane a A en la SUMA de las ganancias de 202107, 202105 y 202103
# (en cada mes, el promedio de la ventana), remuestreando semillas y clientes DENTRO de cada mes.
# No es la P del mes (esa la da comparar_corridas.sh, una por mes) ni la de "solo semillas".
# La regla decide con la P del mes (>= 0,90 en cada mes); la P de los tres meses se informa al lado.
#
# Uso:   cd ~/buckets/b1/labo2026v-modelo-final
#        bash comparar_tres_meses.sh <A_202107> <B_202107> <A_202105> <B_202105> <A_202103> <B_202103>
# Ej.:   bash comparar_tres_meses.sh 9030 9029_jr2 9104 9114 9204 9214
# Calcula dos versiones: con la ventana general (1300 a 3500 de a 100 en los tres meses, la que decide)
# y con la escalada por BAJA+2 (202107: 1300 a 3500; 202105: 1000 a 2600; 202103: 900 a 2500; de a 50).
# Deja el resultado en ~/buckets/b1/exp/comparaciones/tres_meses_<A_202107>_vs_<B_202107>.txt

if [ $# -ne 6 ]; then echo "Faltan corridas. Uso: bash comparar_tres_meses.sh A_202107 B_202107 A_202105 B_202105 A_202103 B_202103"; exit 1; fi
EXP=$HOME/buckets/b1/exp
DS=/content/datasets/analistajr_competencia_2026.csv.gz
mkdir -p "$EXP/comparaciones"
OUT=$EXP/comparaciones/tres_meses_${1}_vs_${2}.txt

Rscript - "$EXP" "$DS" "$@" <<'RR' 2>&1 | tee "$OUT"
suppressMessages(library(data.table))
options(width = 200, warn = -1)
arg <- commandArgs(trailingOnly = TRUE)
EXP <- arg[1]; DS <- arg[2]; corr <- arg[3:8]
NREP <- 1000
set.seed(384841)
mill <- function(x) round(x / 1e6, 2)
meses <- data.table(mes = c(202107, 202105, 202103), A = corr[c(1, 3, 5)], B = corr[c(2, 4, 6)],
                    esc_desde = c(1300, 1000, 900), esc_hasta = c(3500, 2600, 2500))
cat("===== P DE LOS TRES MESES   ", format(Sys.time(), "%F %T"), "\n")
print(meses[, list(mes, A, B)])

clase_de <- function(mes) {
  cache <- file.path(EXP, "comparaciones", paste0("clase_", mes, ".txt"))
  if (file.exists(cache)) return(fread(cache))
  cl <- fread(DS, select = c("numero_de_cliente", "foto_mes", "clase_ternaria"))[foto_mes == mes, list(numero_de_cliente, clase_ternaria)]
  fwrite(cl, cache, sep = "\t"); cl
}
datos_mes <- function(mes, A, B) {
  cl <- clase_de(mes); setkey(cl, numero_de_cliente)
  m <- function(x) {
    p <- fread(file.path(EXP, paste0("WF", x), "prediccion_validacion.txt"))
    fila <- match(cl$numero_de_cliente, p$numero_de_cliente)
    if (anyNA(fila)) stop("corrida ", x, ": faltan clientes de ", mes, " (¿es el mes de validacion de esa corrida?)")
    mm <- as.matrix(p[fila, grep("^prob_[0-9]+$", names(p)), with = FALSE]); colnames(mm) <- NULL; mm
  }
  list(gan = ifelse(cl$clase_ternaria == "BAJA+2", 975000, -25000), ma = m(A), mb = m(B))
}
D <- lapply(seq_len(nrow(meses)), function(i) datos_mes(meses$mes[i], meses$A[i], meses$B[i]))

gan_v <- function(score, g, v, idx = NULL) { if (!is.null(idx)) { score <- score[idx]; g <- g[idx] }; mean(cumsum(g[order(-score)])[v]) }
ventana <- function(i, tipo) if (tipo == "general") seq(1300, 3500, 100) else seq(meses$esc_desde[i], meses$esc_hasta[i], 50)

resultado <- function(tipo) {
  # sin remuestreo
  base <- rbindlist(lapply(seq_along(D), function(i) { d <- D[[i]]; v <- ventana(i, tipo)
    data.table(mes = meses$mes[i], A = mill(gan_v(rowSums(d$ma), d$gan, v)), B = mill(gan_v(rowSums(d$mb), d$gan, v))) }))
  base[, B_menos_A := B - A]
  # remuestreo: semillas y clientes dentro de cada mes (independiente entre meses)
  dif <- matrix(0, NREP, length(D))
  for (i in seq_along(D)) {
    d <- D[[i]]; v <- ventana(i, tipo); k <- ncol(d$ma); mismas <- ncol(d$ma) == ncol(d$mb); n <- length(d$gan)
    for (r in seq_len(NREP)) {
      ia <- sample(k, k, replace = TRUE); ib <- if (mismas) ia else sample(ncol(d$mb), ncol(d$mb), replace = TRUE)
      idx <- sample(n, n, replace = TRUE)
      dif[r, i] <- gan_v(rowSums(d$mb[, ib, drop = FALSE]), d$gan, v, idx) - gan_v(rowSums(d$ma[, ia, drop = FALSE]), d$gan, v, idx)
    }
  }
  base[, P_del_mes := round(colMeans(dif > 0) + colMeans(dif == 0) / 2, 3)]
  tot <- rowSums(dif); q <- quantile(tot, c(.05, .95))
  cat("\n----- ventana", tipo, if (tipo == "general") "(1300 a 3500 de a 100 en los tres meses; es la que decide)" else "(escalada por BAJA+2, de a 50; lectura fina)", "\n")
  print(base)
  cat("suma de los tres meses (M):", sum(base$A), "contra", sum(base$B), "\n")
  cat("P de los tres meses (B gana en la suma):", round(mean(tot > 0) + mean(tot == 0) / 2, 3),
      "  diferencia media", mill(mean(tot)), "M  (5 % a 95 %:", mill(q[1]), "a", mill(q[2]), ")\n")
}
resultado("general")
resultado("escalada")
cat("\nP del mes: remuestreo de semillas y clientes dentro de ese mes (la misma que comparar_corridas.sh, con otro sorteo).\n")
cat("P de los tres meses: lo mismo en cada mes, sumando las tres diferencias. Ninguna de las dos es la de 'solo semillas'.\n")
cat("Regla: decide la P del mes (>= 0,90 en cada mes, ventana general); la P de los tres meses se informa al lado.\n")
RR

echo
echo "Listo. Guardado en $OUT"
