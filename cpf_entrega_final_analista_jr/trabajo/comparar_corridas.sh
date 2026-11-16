#!/bin/bash
# Prediccion final - compara dos corridas, a nivel SEMILLERIO (lo que se sube a Kaggle).
#   1. Semillerio completo en el mes de validacion (202107 si no se dice otro): AUC y ganancia por corte
#   2. Curva de cortes hasta 5000 (para ver donde esta la meseta)
#   3. Remuestreo: P del mes = probabilidad de que el semillerio de B gane al de A en ese mes
#      (remuestreando semillas, clientes del mes, y las dos cosas juntas; la P del mes es "semillas y clientes")
#      En 202105 y 202103 agrega, como lectura fina, la P del mes con la ventana escalada por BAJA+2 (cortes cada 50)
#   4. Curva de semillas: cuanto mejora el semillerio al sumar semillas
#   5. Semilla por semilla (diagnostico secundario: calidad del modelo suelto)
#   6. Public de Kaggle (se registra, no decide)
#   7. Coincidencia de clientes elegidos (diagnostico, idea de Maylen, ExpCol 10 B)
# Todo sale de lo que la corrida ya guardo (prediccion_validacion.txt): no entrena nada.
# La P de los tres meses (202107, 202105 y 202103 sumados) la calcula comparar_tres_meses.sh.
#
# Uso:   cd ~/buckets/b1/labo2026v-modelo-final
#        bash comparar_corridas.sh 9004 9006              (202107, ventana de cortes 1300 a 3500, desde el 09/11)
#        bash comparar_corridas.sh 9004 9006 1300 2200    (otra ventana de cortes)
#        MES=202105 bash comparar_corridas.sh 9104 9114   (otro mes de validacion: 202105 o 202103)
#        bash comparar_corridas.sh 9030 9029_jr2          (corrida en una carpeta WF<exp>_<algo>)
# Deja el resultado en ~/buckets/b1/exp/comparaciones/<A>_vs_<B>_<desde>_<hasta>.txt
# (la ventana va siempre en el nombre; si el mes no es 202107, tambien el mes: <A>_vs_<B>_<mes>_<desde>_<hasta>.txt)
# y lo muestra en pantalla.

A=$1; B=$2; DESDE=${3:-1300}; HASTA=${4:-3500}
if [ -z "$A" ] || [ -z "$B" ]; then echo "Faltan los dos numeros de corrida. Ej: bash comparar_corridas.sh 9004 9006"; exit 1; fi
MES=${MES:-202107}
case "$MES" in
  202107) ESC="";        CURVA=1000 ;;
  202105) ESC="1000 2600"; CURVA=1000 ;;   # ventana escalada por BAJA+2 (decidida el 13/11, antes de correr)
  202103) ESC="900 2500";  CURVA=500  ;;   # en 202103 la meseta cae en 1200 o menos: la curva empieza en 500
  *) echo "MES tiene que ser 202107, 202105 o 202103"; exit 1 ;;
esac

EXP=$HOME/buckets/b1/exp
DS=/content/datasets/analistajr_competencia_2026.csv.gz
mkdir -p "$EXP/comparaciones"
if [ "$MES" = 202107 ]; then OUT=$EXP/comparaciones/${A}_vs_${B}_${DESDE}_${HASTA}.txt
else OUT=$EXP/comparaciones/${A}_vs_${B}_${MES}_${DESDE}_${HASTA}.txt; fi

Rscript - "$EXP" "$A" "$B" labo-1-virtual-2026-analista-jr "$DS" "$DESDE" "$HASTA" "$MES" "$CURVA" $ESC <<'RR' 2>&1 | tee "$OUT"
suppressMessages(library(data.table))
options(width = 200, warn = -1)
arg <- commandArgs(trailingOnly = TRUE)
EXP <- arg[1]; A <- arg[2]; B <- arg[3]; COMP <- arg[4]; DS <- arg[5]
DESDE <- as.integer(arg[6]); HASTA <- as.integer(arg[7])
MES <- as.integer(arg[8]); CURVA <- as.integer(arg[9])
VENTANA <- seq(DESDE, HASTA, by = 100)
ESCALADA <- if (length(arg) >= 11) seq(as.integer(arg[10]), as.integer(arg[11]), by = 50) else NULL
NREP <- 1000          # repeticiones del remuestreo
set.seed(384841)      # el remuestreo es reproducible
dir <- function(x) file.path(EXP, paste0("WF", x))
mill <- function(x) round(x / 1e6, 2)

cat("===== COMPARACION", A, "vs", B, "  mes de validacion:", MES, "  ", format(Sys.time(), "%F %T"), "\n")
cat("ventana de cortes para resumir la ganancia:", DESDE, "a", HASTA, "de a 100\n\n")

# ---- datos: prediccion de validacion de cada corrida + clase real del mes
leer_pred <- function(x) {
  p <- file.path(dir(x), "prediccion_validacion.txt")
  if (!file.exists(p)) stop("no encuentro ", p)
  fread(p)
}
pa <- leer_pred(A); pb <- leer_pred(B)

cache <- file.path(EXP, "comparaciones", paste0("clase_", MES, ".txt"))
if (file.exists(cache)) clase <- fread(cache) else {
  clase <- fread(DS, select = c("numero_de_cliente", "foto_mes", "clase_ternaria"))[foto_mes == MES, list(numero_de_cliente, clase_ternaria)]
  fwrite(clase, cache, sep = "\t")
}
tb <- clase[pa[, "numero_de_cliente"], on = "numero_de_cliente"]
setkey(tb, numero_de_cliente)
gan <- ifelse(tb$clase_ternaria == "BAJA+2", 975000, -25000)
clase01 <- as.integer(tb$clase_ternaria %in% c("BAJA+1", "BAJA+2"))
matriz <- function(p, x) {        # una columna por semilla, filas en el orden de tb (se ubica por numero de cliente)
  fila <- match(tb$numero_de_cliente, p$numero_de_cliente)
  m <- as.matrix(p[fila, grep("^prob_[0-9]+$", names(p)), with = FALSE])
  colnames(m) <- NULL
  if (anyNA(fila) || anyNA(m)) stop("corrida ", x, ": hay clientes de ", MES, " sin probabilidad (¿es el mes de validacion de esa corrida?)")
  m
}
ma <- matriz(pa, A); mb <- matriz(pb, B)
if (anyNA(tb$clase_ternaria)) stop("hay clientes de la prediccion sin clase en ", MES, " (¿es el mes de validacion de esa corrida?)")
if (nrow(pa) != nrow(clase) || nrow(pb) != nrow(clase)) stop("la cantidad de clientes no coincide con ", MES, ": ¿es el mes de validacion de las dos corridas?")
NB2 <- sum(tb$clase_ternaria == "BAJA+2")

# semillas de cada corrida, en el orden de las columnas prob_i
semillas <- function(x, k) {
  p <- file.path(dir(x), "validacion_semillas.txt")
  if (file.exists(p)) unique(fread(p)$semilla)[1:k] else seq_len(k)
}
sa <- semillas(A, ncol(ma)); sb <- semillas(B, ncol(mb))

# ganancia acumulada en ciertos cortes, para un puntaje y (opcional) un remuestreo de clientes
gan_cortes <- function(score, cortes, idx = NULL) {
  g <- gan
  if (!is.null(idx)) { score <- score[idx]; g <- g[idx] }
  cumsum(g[order(-score)])[cortes]
}
auc <- function(score) {
  r <- frank(score); n1 <- as.numeric(sum(clase01)); n0 <- as.numeric(sum(1 - clase01))
  (sum(r[clase01 == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}
semillerio <- function(m, cols = seq_len(ncol(m))) rowSums(m[, cols, drop = FALSE])

# ---- 1. semillerio completo
cat("===== 1. SEMILLERIO COMPLETO EN VALIDACION", MES, "  BAJA+2 del mes:", NB2, "\n")
cat("semillas:", A, "=", ncol(ma), " ", B, "=", ncol(mb), "\n")
sca <- semillerio(ma); scb <- semillerio(mb)
cat("AUC del semillerio:", A, "=", round(auc(sca), 4), " ", B, "=", round(auc(scb), 4), "\n")
auc_guardado <- function(x) {
  l <- grep("^\\s+AUC:", readLines(file.path(dir(x), "PARAM.yml")), value = TRUE)
  if (length(l)) round(as.numeric(sub(".*AUC:\\s*", "", l[1])), 4) else NA
}
cat("control, AUC que guardo cada corrida:", A, "=", auc_guardado(A), " ", B, "=", auc_guardado(B),
    "  (tiene que coincidir con la linea de arriba)\n\n")
ga <- gan_cortes(sca, VENTANA); gb <- gan_cortes(scb, VENTANA)
t1 <- data.table(envios = VENTANA, A = mill(ga), B = mill(gb), B_menos_A = mill(gb - ga))
setnames(t1, c("A", "B"), c(A, B)); print(t1)
cat("\nganancia promedio de la ventana (millones):", A, "=", mill(mean(ga)), " ", B, "=", mill(mean(gb)), "\n")

# ---- 2. curva de cortes
cat("\n===== 2. CURVA DE CORTES DEL SEMILLERIO (", CURVA, "a 5000 )\n")
cat("suavizada = promedio movil de 5 cortes (el corte y 2 a cada lado), para no elegir por un pico suelto\n")
cc <- seq(CURVA, 5000, by = 100)
ca <- gan_cortes(sca, cc); cb <- gan_cortes(scb, cc)
suav <- function(v) as.numeric(frollmean(v, 5, align = "center"))
t2 <- data.table(envios = cc, A = mill(ca), A_suav = mill(suav(ca)), B = mill(cb), B_suav = mill(suav(cb)))
setnames(t2, c("A", "A_suav", "B", "B_suav"), c(A, paste0(A, "_suav"), B, paste0(B, "_suav")))
print(t2[envios %% 200 == 0 | envios == CURVA])
meseta <- function(v, nombre) {
  s <- suav(v); mx <- max(s, na.rm = TRUE)
  en <- cc[!is.na(s) & s >= mx - 1e6]
  cat(nombre, ": maximo suavizado", mill(mx), "M en", cc[which.max(s)],
      "  meseta (a menos de 1 M del maximo suavizado):", min(en), "a", max(en),
      "  en envios por BAJA+2:", round(cc[which.max(s)] / NB2, 1), "(meseta", round(min(en) / NB2, 1), "a", round(max(en) / NB2, 1), ")\n")
  if (min(en) <= cc[3]) cat("   ojo: la meseta toca el comienzo de la curva; puede seguir mas abajo\n")
}
cat("\n"); meseta(ca, A); meseta(cb, B)
cat("Si la meseta llega a 4800 o mas, el rango de cortes todavia es corto.\n")

# ---- 3. remuestreo
cat("\n===== 3. REMUESTREO: P DEL MES = PROBABILIDAD DE QUE EL SEMILLERIO DE", B, "GANE AL DE", A, "EN", MES, "\n")
cat("medida: ganancia promedio de la ventana", DESDE, "a", HASTA, "  repeticiones:", NREP, "\n")
mismas <- ncol(ma) == ncol(mb) && all(sa == sb)
if (mismas) {
  cat("mismas semillas en las dos corridas: cada repeticion usa las mismas semillas para A y para B\n")
} else {
  cat("semillas distintas (o distinta cantidad): cada corrida remuestrea sus propias semillas\n")
}
iguales <- ncol(ma) <= ncol(mb) && isTRUE(all.equal(ma, mb[, seq_len(ncol(ma)), drop = FALSE]))
remuestreo <- function(tipo, vent = VENTANA) {
  d <- numeric(NREP)
  for (r in seq_len(NREP)) {
    if (tipo == "clientes") { ia <- seq_len(ncol(ma)); ib <- seq_len(ncol(mb)) }
    else if (mismas) { ia <- ib <- sample(ncol(ma), ncol(ma), replace = TRUE) }
    else { ia <- sample(ncol(ma), ncol(ma), replace = TRUE); ib <- sample(ncol(mb), ncol(mb), replace = TRUE) }
    idx <- if (tipo == "semillas") NULL else sample(nrow(tb), nrow(tb), replace = TRUE)
    d[r] <- mean(gan_cortes(semillerio(mb, ib), vent, idx)) - mean(gan_cortes(semillerio(ma, ia), vent, idx))
  }
  q <- quantile(d, c(.05, .95))
  data.table(remuestreo = tipo, P_B_gana = round(mean(d > 0) + mean(d == 0) / 2, 3),
             diferencia_media = mill(mean(d)), desde_5pc = mill(q[1]), hasta_95pc = mill(q[2]))
}
if (iguales && ncol(ma) == ncol(mb)) {
  cat("Las dos corridas tienen exactamente los mismos modelos: no hay nada que comparar.\n")
} else {
  t3 <- rbindlist(lapply(c("semillas", "clientes", "semillas y clientes"), remuestreo))
  print(t3)
  cat("\nsemillas: variabilidad por las semillas que tocaron (diagnostico; no es la P del mes).\n")
  cat("clientes: variabilidad por los clientes del mes (otros clientes darian otra ganancia).\n")
  cat("semillas y clientes: las dos juntas. Es la P del mes, la que usa la regla.\n")
  cat("Regla (definitiva desde el 12/11): B reemplaza a A si la P del mes es >= 0,90 en cada mes (ventana 1300 a 3500).\n")
  if (!is.null(ESCALADA)) {
    cat("\nLectura fina (no decide): P del mes con la ventana escalada por BAJA+2,", min(ESCALADA), "a", max(ESCALADA), "con cortes cada 50\n")
    print(remuestreo("semillas y clientes", ESCALADA))
    cat("ganancia promedio de la ventana escalada (millones):", A, "=", mill(mean(gan_cortes(sca, ESCALADA))), " ", B, "=", mill(mean(gan_cortes(scb, ESCALADA))), "\n")
  }
}

# ---- 4. curva de semillas
cat("\n===== 4. CURVA DE SEMILLAS: ganancia promedio de la ventana segun cuantas semillas tiene el semillerio\n")
cat("para cada tamano, 200 semillerios armados con semillas elegidas al azar entre las de la corrida\n")
curva <- function(m, nombre) {
  ks <- unique(c(1, 5, 10, 20, 30, 50, 100)); ks <- ks[ks <= ncol(m)]
  rbindlist(lapply(ks, function(k) {
    v <- replicate(if (k == ncol(m)) 1 else 200, mean(gan_cortes(semillerio(m, sample(ncol(m), k)), VENTANA)))
    data.table(corrida = nombre, semillas = k, media = mill(mean(v)), desvio = if (length(v) > 1) mill(sd(v)) else NA_real_)
  }))
}
print(rbind(curva(ma, A), curva(mb, B)))
cat("Si la media sigue subiendo con las ultimas semillas, sumar semillas todavia aporta.\n")

# ---- 5. semilla por semilla
cat("\n===== 5. SEMILLA POR SEMILLA (diagnostico secundario: calidad de cada modelo suelto, NO decide)\n")
comunes <- intersect(sa, sb)
if (length(comunes) < 2) {
  cat("(menos de 2 semillas en comun)\n")
} else {
  ga1 <- sapply(match(comunes, sa), function(i) mean(gan_cortes(ma[, i], VENTANA)))
  gb1 <- sapply(match(comunes, sb), function(i) mean(gan_cortes(mb[, i], VENTANA)))
  if (isTRUE(all.equal(ga1, gb1))) {
    cat("Las", length(comunes), "semillas en comun dan exactamente lo mismo: son los mismos modelos.\n")
  } else {
    cat("semillas en comun:", length(comunes), "  ", B, "gana en", sum(gb1 > ga1), ",", A, "gana en", sum(gb1 < ga1), "\n")
    cat("ganancia media del modelo suelto:", A, "=", mill(mean(ga1)), "(desvio", mill(sd(ga1)), ")  ",
        B, "=", mill(mean(gb1)), "(desvio", mill(sd(gb1)), ")\n")
    cat("Wilcoxon pareado: p =", signif(suppressWarnings(wilcox.test(gb1, ga1, paired = TRUE))$p.value, 3), "\n")
    cat("Ojo: un modelo suelto mejor no implica un semillerio mejor (ver 9004 vs 9005 en la bitacora).\n")
  }
}

# ---- 6. Public
cat("\n===== 6. PUBLIC EN KAGGLE (se registra, no decide)\n")
# registro acumulado de envios: Kaggle solo muestra los ultimos 200, asi que cada vez se suman al registro
reg_path <- file.path(EXP, "comparaciones", "envios_kaggle.txt")
# lee los envios de la cuenta principal y, si esta configurada en ~/.kaggle2, tambien de la segunda
leer_envios <- function(pre) tryCatch(system(paste(pre, "kaggle competitions submissions -c", COMP, "--page-size 200 2>/dev/null"), intern = TRUE),
                                      error = function(e) character(0))
l <- leer_envios("")
if (file.exists(file.path(Sys.getenv("HOME"), ".kaggle2", "kaggle.json"))) l <- c(l, leer_envios("KAGGLE_CONFIG_DIR=$HOME/.kaggle2"))
l <- grep("exp=[0-9]+ .*envios=[0-9]+.*COMPLETE", l, value = TRUE)
nuevos <- if (length(l)) data.table(
  exp = sub(".*exp=([0-9]+) .*", "\\1", l),
  envios = as.integer(sub(".*envios=([0-9]+).*", "\\1", l)),
  public = as.numeric(sub(".*COMPLETE\\s+([0-9.]+).*", "\\1", l)),
  archivo = sub("^\\s*[0-9]+\\s+(\\S+).*", "\\1", l)) else NULL
reg <- if (file.exists(reg_path)) fread(reg_path, colClasses = c(exp = "character")) else NULL
reg <- rbind(reg, nuevos)
if (!is.null(reg)) reg <- unique(reg, by = c("exp", "archivo"))
if (!is.null(reg) && nrow(reg)) fwrite(reg, reg_path, sep = "\t")
pub <- function(x) if (is.null(reg)) NULL else reg[exp == sub("_.*", "", x), list(public = public[1]), by = envios]   # 9029_jr2 -> 9029
qa <- pub(A); qb <- pub(B)
if (is.null(qa) || is.null(qb) || (nrow(qa) == 0 && nrow(qb) == 0)) cat("(no encontre envios de ninguna de las dos)\n") else {
  t6 <- merge(qa, qb, by = "envios", all = TRUE, suffixes = c("_A", "_B"))
  setorder(t6, envios); setnames(t6, c("public_A", "public_B"), c(A, B))
  print(t6)
  com <- t6[!is.na(get(A)) & !is.na(get(B))]
  cat("\npromedio del Public en los cortes que tienen las dos (", nrow(com), "cortes):",
      A, "=", round(mean(com[[A]]), 2), " ", B, "=", round(mean(com[[B]]), 2), "\n")
}

# ---- 7. coincidencia de clientes elegidos
cat("\n===== 7. COINCIDENCIA DE CLIENTES ELEGIDOS (diagnostico, NO decide)\n")
cat("para cada corte: que proporcion de los primeros N comparten los dos semillerios, y cuantos BAJA+2 hay entre los que elige uno solo.\n")
cat("Como los dos eligen N clientes, la diferencia de ganancia en ese corte es (BAJA+2 solo de B - BAJA+2 solo de A) x 1 M.\n")
oa <- order(-sca); ob <- order(-scb); b2 <- tb$clase_ternaria == "BAJA+2"
t7 <- rbindlist(lapply(c(1500, 2000, 2300, 2900), function(N) {
  ea <- oa[1:N]; eb <- ob[1:N]; solo_a <- setdiff(ea, eb); solo_b <- setdiff(eb, ea)
  data.table(envios = N, comparten_pc = round(100 * length(intersect(ea, eb)) / N, 1), elige_uno_solo = length(solo_a),
             BAJA2_solo_A = sum(b2[solo_a]), BAJA2_solo_B = sum(b2[solo_b]), BAJA2_comunes = sum(b2[intersect(ea, eb)]),
             B_menos_A_M = sum(b2[solo_b]) - sum(b2[solo_a]))
}))
setnames(t7, c("BAJA2_solo_A", "BAJA2_solo_B"), c(paste0("BAJA2_solo_", A), paste0("BAJA2_solo_", B)))
print(t7)
RR

echo
echo "Listo. Comparacion guardada en $OUT"
