# Prueba de enmascarado del Catastrophe Analysis (no entrena LightGBM).
#
# Idea: en meses sanos se borran a proposito las variables que se rompen en los meses reales,
# se reconstruyen con cada metodo y se compara contra el valor verdadero. Dice que metodo
# imputa mejor antes de gastar una corrida. Imputar mejor no garantiza ganar mas: la decision
# sigue saliendo de comparar_corridas.sh.
#
# Uso (desde el repo):
#   Rscript prueba_enmascarado.R            prueba completa
#   Rscript prueba_enmascarado.R rapido     un mes y tres variables, para medir tiempo y memoria
# Deja resultados en ~/buckets/b1/exp/CA_enmascarado/ (o en la carpeta del segundo argumento).

suppressMessages({ library(data.table); library(mice) })

args   <- commandArgs(trailingOnly = TRUE)
RAPIDO <- length(args) >= 1 && args[1] == "rapido"
SALIDA <- if (length(args) >= 2) args[2] else path.expand("~/buckets/b1/exp/CA_enmascarado")
dir.create(SALIDA, recursive = TRUE, showWarnings = FALSE)

P <- list(
  dataset      = "/content/datasets/analistajr_competencia_2026.csv.gz",
  # meses sanos para enmascarar: fuera de la pandemia y con vecinos sanos para estas variables
  meses_prueba = c(201912, 202102, 202104),
  # mes de pandemia sano para estas variables: los meses normales pueden dar una precision
  # optimista para 202006, que tiene vecinos atipicos. Se eligio 202007 porque el perfil de sus
  # vecinos (202005, 202008, 202009) es el mas parecido al de los vecinos de 202006 (distancia
  # 2,09 contra 2,77 de 202005). Ojo: su vecino 202006 esta roto, asi que tiene un vecino sano
  # menos que el 202006 real.
  meses_pandemia = c(202007),
  k_tend       = 3,     # meses a cada lado para "tendencia" (como PARAM$CA$k de la notebook)
  k_hist       = 3,     # hasta cuantos meses se busca el valor sano anterior/siguiente del cliente
  semilla      = 7,     # misma semilla de mice que la notebook
  mincor       = 0.2,   # correlacion minima para elegir predictores de la misma fila
  max_pred     = 12,    # tope de predictores de la misma fila en la version liviana
  minbucket    = 50     # hoja minima de CART
)

# Variantes de MICE. "liviano": historia del cliente + hasta max_pred variables de la fila
# (correlacion >= mincor). "todos": historia + todas las variables completas de la fila.
# ventana: meses sanos a cada lado del mes enmascarado con los que aprende la imputacion.
# CART usa "cartliviano" (definido abajo): el mismo metodo que mice.impute.cart sin su problema
# de memoria.
VARIANTES <- list(
  pmm        = list(metodo = "pmm",         ventana = 2, pred = "liviano"),
  cart       = list(metodo = "cartliviano", ventana = 2, pred = "liviano"),
  pmm_6m     = list(metodo = "pmm",         ventana = 6, pred = "liviano"),
  cart_6m    = list(metodo = "cartliviano", ventana = 6, pred = "liviano"),
  pmm_todos  = list(metodo = "pmm",         ventana = 2, pred = "todos"),
  cart_todos = list(metodo = "cartliviano", ventana = 2, pred = "todos")
)
# En el modo rapido se suma el CART original de mice, para verificar que "cartliviano" imputa
# con la misma distribucion. Se saltea en variables casi binarias (es donde explota la memoria).
if (RAPIDO) VARIANTES$cart_mice <- list(metodo = "cart", ventana = 2, pred = "liviano")
SIN_CART_MICE <- c("internet")

# CART de mice (mice.impute.cart, version 3.19.0) con un solo cambio: el original arma, para
# cada fila a imputar, una copia de todos los donantes de su hoja
# (lapply(nodes, function(s) yobs[leafnr == s])). Con variables casi binarias el arbol tiene
# pocas hojas enormes y eso son miles de millones de numeros (56 GB en 9020, 39 GB aca con
# internet). Aca se recorre hoja por hoja: cada fila a imputar sortea su propio donante,
# independiente y con reposicion, dentro de su hoja. Misma distribucion que el original; los
# numeros sorteados no coinciden con los de mice para la misma semilla.
mice.impute.cartliviano <- function(y, ry, x, wy = NULL, minbucket = 5, cp = 1e-04, ...) {
  if (is.null(wy)) wy <- !ry
  if (is.factor(y)) stop("cartliviano: solo variables numericas")
  minbucket <- max(1, minbucket)
  if (dim(x)[2] == 0) { x <- cbind(x, 1); dimnames(x) <- list(NULL, "int") }
  xobs <- data.frame(x[ry, , drop = FALSE])
  xmis <- data.frame(x[wy, , drop = FALSE])
  yobs <- y[ry]
  fit <- rpart::rpart(yobs ~ ., data = cbind(yobs, xobs), method = "anova",
                      control = rpart::rpart.control(minbucket = minbucket, cp = cp, ...))
  leafnr <- as.numeric(row.names(fit$frame))[fit$where]   # hoja de cada donante
  fit$frame$yval <- as.numeric(row.names(fit$frame))      # predict devuelve el numero de hoja
  nodes <- predict(object = fit, newdata = xmis)
  impute <- numeric(length(nodes))
  for (s in unique(nodes)) {
    filas <- which(nodes == s)
    pool <- yobs[leafnr == s]
    impute[filas] <- pool[sample.int(length(pool), length(filas), replace = TRUE)]
  }
  impute
}

# Pares rotos: la misma lista que Corregir_Rotas() de la notebook. Las variables que el
# dataset Jr no tiene se descartan (la notebook tambien las saltea).
PARES <- list(
  list("active_quarter", 202006), list("internet", 202006),
  list("mrentabilidad", c(201905, 201910, 202006)), list("mrentabilidad_annual", c(201905, 201910, 202006)),
  list("mcomisiones", c(201905, 201910, 202006)),
  list("mactivos_margen", c(201905, 201910, 202006)), list("mpasivos_margen", c(201905, 201910, 202006)),
  list("mcuentas_saldo", 202006), list("ctarjeta_debito_transacciones", 202006), list("mautoservicio", 202006),
  list("ctarjeta_visa_transacciones", 202006), list("mtarjeta_visa_consumo", 202006),
  list("ctarjeta_master_transacciones", 202006), list("mtarjeta_master_consumo", 202006),
  list("ctarjeta_visa_debitos_automaticos", 201904), list("mttarjeta_visa_debitos_automaticos", 201904),
  list("ccajeros_propios_descuentos", c(201910, 202002, 202006, 202009, 202010, 202102)),
  list("mcajeros_propios_descuentos", c(201910, 202002, 202006, 202009, 202010, 202102)),
  list("ctarjeta_visa_descuentos", c(201910, 202002, 202006, 202009, 202010, 202102)),
  list("mtarjeta_visa_descuentos", c(201910, 202002, 202006, 202009, 202010, 202102)),
  list("ctarjeta_master_descuentos", c(201910, 202002, 202006, 202009, 202010, 202102)),
  list("mtarjeta_master_descuentos", c(201910, 202002, 202006, 202009, 202010, 202102)),
  list("ccomisiones_otras", c(201905, 201910, 202006)), list("mcomisiones_otras", c(201905, 201910, 202006)),
  list("cextraccion_autoservicio", 202006), list("mextraccion_autoservicio", 202006),
  list("ccheques_depositados", 202006), list("mcheques_depositados", 202006),
  list("ccheques_emitidos", 202006), list("mcheques_emitidos", 202006),
  list("ccheques_depositados_rechazados", 202006), list("mcheques_depositados_rechazados", 202006),
  list("ccheques_emitidos_rechazados", 202006), list("mcheques_emitidos_rechazados", 202006),
  list("tcallcenter", 202006), list("ccallcenter_transacciones", 202006),
  list("thomebanking", 202006), list("chomebanking_transacciones", c(201910, 202006)),
  list("ccajas_transacciones", 202006), list("ccajas_consultas", 202006),
  list("ccajas_depositos", c(202006, 202105)), list("ccajas_extracciones", 202006), list("ccajas_otras", 202006),
  list("catm_trx", 202006), list("matm", 202006), list("catm_trx_other", 202006), list("matm_other", 202006)
)

# ---------------------------------------------------------------- utilidades
slog  <- function(x) sign(x) * log1p(abs(x))     # achica los montos sin perder el signo
islog <- function(z) sign(z) * expm1(abs(z))      # vuelta exacta
mes_idx <- function(f) (f %/% 100) * 12 + (f %% 100 - 1)
idx_mes <- function(i) (i %/% 12) * 100 + i %% 12 + 1
memoria_mb <- function() sum(gc()[, 6])           # maximo usado por R desde el ultimo gc(reset = TRUE)

# Valor sano mas cercano del mismo cliente hacia atras (o > 0 filas antes) o adelante.
vecino_sano <- function(dt, v, direccion, kmax) {
  x <- dt[[v]]; cli <- dt$numero_de_cliente
  out <- rep(NA_real_, nrow(dt))
  tipo <- if (direccion == "ant") "lag" else "lead"
  for (o in kmax:1) {                              # el mas cercano pisa al mas lejano
    y <- shift(x, o, type = tipo); cy <- shift(cli, o, type = tipo)
    y[is.na(cy) | cy != cli] <- NA
    out <- ifelse(is.na(y), out, y)
  }
  out
}

# Interpolar y tendencia: misma cuenta que imputar_CA() de la notebook (celda del CA).
imputar_clasico <- function(dt, v, filas, metodo, k) {
  x <- dt[[v]]; cli <- dt$numero_de_cliente; mes <- mes_idx(dt$foto_mes)
  vecino <- function(o) {
    tipo <- if (o < 0) "lag" else "lead"
    y <- shift(x, abs(o), type = tipo); mismo <- shift(cli, abs(o), type = tipo) == cli
    y[is.na(mismo) | !mismo] <- NA
    list(y = y[filas], x = (shift(mes, abs(o), type = tipo) - mes)[filas])
  }
  offs <- if (metodo == "interpolar") c(-1, 1) else c(-(k:1), 1:k)
  n <- sx <- sy <- sxx <- sxy <- numeric(length(filas))
  for (o in offs) {
    w <- vecino(o); y <- w$y; xx <- w$x; a <- !is.na(y)
    y[!a] <- 0; xx[!a] <- 0
    n <- n + a; sx <- sx + xx; sy <- sy + y; sxx <- sxx + xx^2; sxy <- sxy + xx * y
  }
  val <- ifelse(n >= 1, sy / pmax(n, 1), NA_real_)
  if (metodo == "tendencia") {
    den <- n * sxx - sx^2
    val <- ifelse(n >= 2 & den > 0, (sy * sxx - sx * sxy) / den, val)
  }
  val
}

# MICE para una variable y un mes, con historia del cliente y predictores de la misma fila.
imputar_mice <- function(dt, v, M, enmascaradas, var) {
  iM  <- mes_idx(M)
  ven <- idx_mes(c((iM - var$ventana):(iM - 1), (iM + 1):(iM + var$ventana)))
  ftr <- which(dt$foto_mes %in% ven & !is.na(dt[[v]]))  # aprende con filas sanas de los vecinos
  fM  <- which(dt$foto_mes == M)
  todas <- c(ftr, fM)

  ant <- vecino_sano(dt, v, "ant", P$k_hist)[todas]
  sig <- vecino_sano(dt, v, "sig", P$k_hist)[todas]
  falta <- as.integer(is.na(ant)) + as.integer(is.na(sig))
  ant2 <- ifelse(is.na(ant), sig, ant); sig2 <- ifelse(is.na(sig), ant, sig)
  med <- median(dt[[v]][ftr])
  ant2[is.na(ant2)] <- med; sig2[is.na(sig2)] <- med
  X <- data.frame(h_ant = slog(ant2), h_sig = slog(sig2), h_falta = falta)

  # predictores de la misma fila: numericos, completos en estas filas, ni enmascarados ni rotos
  fuera <- c("numero_de_cliente", "foto_mes", "clase_ternaria", enmascaradas)
  cand <- setdiff(names(dt), fuera)
  cand <- cand[vapply(cand, function(cc) is.numeric(dt[[cc]]) && !anyNA(dt[[cc]][todas]), TRUE)]
  cand <- cand[vapply(cand, function(cc) data.table::uniqueN(dt[[cc]][ftr]) > 1, TRUE)]
  if (var$pred == "liviano" && length(cand)) {
    ytr <- slog(dt[[v]][ftr])
    r <- vapply(cand, function(cc) abs(suppressWarnings(cor(slog(dt[[cc]][ftr]), ytr))), 0)
    r[is.na(r)] <- 0
    cand <- head(names(sort(r[r >= P$mincor], decreasing = TRUE)), P$max_pred)
  }
  for (cc in cand) X[[paste0("f_", cc)]] <- slog(dt[[cc]][todas])

  df <- data.frame(y = c(slog(dt[[v]][ftr]), rep(NA_real_, length(fM))), X)
  meth <- setNames(c(var$metodo, rep("", ncol(X))), names(df))
  pm <- matrix(0, ncol(df), ncol(df), dimnames = list(names(df), names(df)))
  pm["y", -1] <- 1
  correr <- function(ridge) mice(df, method = meth, predictorMatrix = pm, m = 1, maxit = 1,
                                 seed = P$semilla, printFlag = FALSE, ridge = ridge,
                                 minbucket = P$minbucket)
  ridge <- 1e-5
  imp <- tryCatch(correr(ridge), error = function(e) NULL)
  if (is.null(imp)) { ridge <- 1e-3; imp <- tryCatch(correr(ridge), error = function(e) e) }
  if (inherits(imp, "error"))
    return(list(val = rep(NA_real_, length(fM)), npred = ncol(X), nfilas = length(ftr),
                ridge = ridge, eventos = NA_integer_, error = conditionMessage(imp)))
  val <- islog(complete(imp)$y[(length(ftr) + 1):nrow(df)])
  list(val = val, npred = ncol(X), nfilas = length(ftr), ridge = ridge,
       eventos = if (is.null(imp$loggedEvents)) 0L else nrow(imp$loggedEvents), error = "")
}

medir <- function(real, imp) {
  ok <- !is.na(imp); e <- abs(imp[ok] - real[ok])
  ingenuo <- mean(abs(real - median(real)))       # error de imputar con la mediana del mes
  data.table(
    n = length(real), llenos = mean(ok),
    error_mediano = median(e), error_medio = mean(e),
    error_rel = if (ingenuo > 0) mean(e) / ingenuo else NA_real_,   # < 1: mejor que la mediana
    spearman = suppressWarnings(cor(real[ok], imp[ok], method = "spearman")),
    ceros_real = mean(real == 0), ceros_imp = mean(imp[ok] == 0),
    media_real = mean(real), media_imp = mean(imp[ok]),
    p10_real = unname(quantile(real, 0.1)), p10_imp = unname(quantile(imp[ok], 0.1)),
    p50_real = median(real), p50_imp = median(imp[ok]),
    p90_real = unname(quantile(real, 0.9)), p90_imp = unname(quantile(imp[ok], 0.9))
  )
}

# ---------------------------------------------------------------- datos
t_inicio <- Sys.time()
d <- fread(P$dataset, showProgress = FALSE)
setorder(d, numero_de_cliente, foto_mes)
campos <- intersect(vapply(PARES, function(p) p[[1]], ""), names(d))
cat("variables rotas que existen en el dataset:", length(campos), "de", length(PARES), "\n")

# 1. como la notebook: los meses rotos reales a NA (no sirven de vecinos ni de donantes)
for (p in PARES) if (p[[1]] %in% names(d)) d[foto_mes %in% p[[2]], (p[[1]]) := NA]

meses <- c(P$meses_prueba, P$meses_pandemia)
vars_prueba <- campos
if (RAPIDO) { meses <- meses[1]; vars_prueba <- c("mrentabilidad", "ctarjeta_visa_transacciones", "internet") }

res <- list()
CONTROLES <- character(0)
for (M in meses) {
  cat("\n===== mes enmascarado", M, "\n")
  real <- d[foto_mes == M, ..campos]
  dm <- copy(d)
  dm[foto_mes == M, (campos) := NA]               # se enmascaran juntas, como en un mes roto
  fM <- which(dm$foto_mes == M)

  # control: en dm, los pares rotos reales tienen que estar en NA (ningun cero falso como vecino)
  npares <- 0L; ceros <- 0L; nas <- 0L; esperado <- 0L
  for (p in PARES) if (p[[1]] %in% names(dm)) for (mr in p[[2]]) {
    f <- dm$foto_mes == mr
    if (!any(f)) next
    npares <- npares + 1L
    ceros <- ceros + sum(dm[[p[[1]]]][f] == 0, na.rm = TRUE)
    nas <- nas + sum(is.na(dm[[p[[1]]]][f]))
    esperado <- esperado + sum(f)
  }
  ok <- ceros == 0L && nas == esperado
  CONTROLES <- c(CONTROLES, sprintf(
    "%s mes enmascarado %d: pares rotos %d, ceros en esos pares %d (tiene que dar 0), NA %d de %d (filas x pares)",
    if (ok) "[OK]     " else "[REVISAR]", M, npares, ceros, nas, esperado))
  cat(tail(CONTROLES, 1), "\n")

  for (v in vars_prueba) {
    r <- real[[v]]
    entero <- is.integer(d[[v]])
    redondear <- function(x) if (entero) round(x) else x
    otros <- c(campos)                            # todas enmascaradas: ninguna sirve de predictor

    # referencias: cero (lo que muestra un mes roto) y mediana de los meses vecinos
    vecinos <- d$foto_mes %in% idx_mes(mes_idx(M) + c(-2, -1, 1, 2))
    res[[length(res) + 1]] <- cbind(data.table(mes = M, variable = v, metodo = "cero"), medir(r, rep(0, length(r))))
    res[[length(res) + 1]] <- cbind(data.table(mes = M, variable = v, metodo = "mediana_vecinos"),
                                    medir(r, rep(median(d[[v]][vecinos], na.rm = TRUE), length(r))))
    for (mt in c("interpolar", "tendencia")) {
      val <- redondear(imputar_clasico(dm, v, fM, mt, P$k_tend))
      res[[length(res) + 1]] <- cbind(data.table(mes = M, variable = v, metodo = mt), medir(r, val))
    }
    for (nv in names(VARIANTES)) {
      if (nv == "cart_mice" && v %in% SIN_CART_MICE) next
      gc(reset = TRUE); t0 <- Sys.time()
      out <- imputar_mice(dm, v, M, otros, VARIANTES[[nv]])
      seg <- as.numeric(difftime(Sys.time(), t0, units = "secs")); mb <- memoria_mb()
      res[[length(res) + 1]] <- cbind(
        data.table(mes = M, variable = v, metodo = nv), medir(r, redondear(out$val)),
        data.table(predictores = out$npred, filas_aprende = out$nfilas, ridge = out$ridge,
                   eventos_mice = out$eventos, segundos = round(seg, 1), memoria_mb = round(mb),
                   error = out$error))
      cat(sprintf("%-36s %-11s %5.1f s  %6.0f MB  pred %2d  filas %6d %s\n",
                  v, nv, seg, mb, out$npred, out$nfilas, out$error))
    }
  }
  rm(dm); gc(verbose = FALSE)
}

# ---------------------------------------------------------------- salida
tabla <- rbindlist(res, fill = TRUE)
tabla[, grupo := ifelse(mes %in% P$meses_pandemia, "pandemia", "normal")]
setcolorder(tabla, "grupo")
fwrite(tabla, file.path(SALIDA, if (RAPIDO) "enmascarado_rapido.csv" else "enmascarado_detalle.csv"))

orden <- c("cero", "mediana_vecinos", "interpolar", "tendencia", names(VARIANTES))
resumir <- function(tb) tb[, .(
  error_rel_mediano = median(error_rel, na.rm = TRUE),   # mediana sobre variables y meses
  spearman_medio    = mean(spearman, na.rm = TRUE),
  dif_ceros_media   = mean(abs(ceros_imp - ceros_real), na.rm = TRUE),
  llenos_min        = min(llenos),
  segundos_total    = sum(segundos, na.rm = TRUE),
  memoria_max_mb    = if (all(is.na(memoria_mb))) NA_real_ else max(memoria_mb, na.rm = TRUE),
  fallas            = sum(error != "", na.rm = TRUE)
), by = metodo][match(orden, metodo)][!is.na(metodo)]

arch <- file.path(SALIDA, if (RAPIDO) "enmascarado_rapido.txt" else "enmascarado_resumen.txt")
sink(arch)
cat("===== PRUEBA DE ENMASCARADO DEL CA   ", format(Sys.time()), "  VM:", Sys.info()[["nodename"]], "\n")
cat("meses enmascarados:", meses, "   variables:", length(vars_prueba), "\n\n")
cat("===== 0. CONTROLES\n")
cat(CONTROLES, sep = "\n")
cat("\n")
cat("error_rel: error medio / error de imputar con la mediana del mes (< 1 es mejor que la mediana)\n")
cat("dif_ceros: diferencia entre la proporcion de ceros imputada y la real (un cero de mas parece un cliente que se va)\n")
cat("cart, cart_6m y cart_todos usan cartliviano (no mice.impute.cart); su verificacion contra el original esta en\n")
cat("la bitacora (decision del 11/11 y \"Prueba de enmascarado del CA\") y en verificaciones/enmascarado_rapido.txt\n")
for (g in c("normal", "pandemia")) {
  tg <- tabla[grupo == g]
  if (!nrow(tg)) next
  cat("\n\n########## MESES", toupper(g), ":", unique(tg$mes), "\n\n")
  print(resumir(tg))
  cat("\n===== POR VARIABLE: error_rel (mediana sobre los meses del grupo)\n")
  print(dcast(tg[metodo %in% c("tendencia", "pmm", "cart")], variable ~ metodo,
              value.var = "error_rel", fun.aggregate = median))
}
if ("cart_mice" %in% tabla$metodo) {
  cat("\n\n===== VERIFICACION DE cartliviano CONTRA mice.impute.cart (mismos datos y predictores)\n")
  cat("lo imputado tiene que tener distribucion parecida; la columna real es el valor verdadero\n\n")
  vs <- unique(tabla[metodo == "cart_mice", variable])
  comp <- tabla[metodo %in% c("cart", "cart_mice") & variable %in% vs,
                .(mes, variable, metodo, media_imp, p10_imp, p50_imp, p90_imp, ceros_imp,
                  segundos, memoria_mb)]
  real <- unique(tabla[variable %in% vs, .(mes, variable, metodo = "real", media_imp = media_real,
                  p10_imp = p10_real, p50_imp = p50_real, p90_imp = p90_real, ceros_imp = ceros_real,
                  segundos = NA_real_, memoria_mb = NA_real_)])
  print(setorder(rbind(comp, real), mes, variable, metodo))
}
cat("\ntiempo total:", format(Sys.time() - t_inicio), "\n")
sink()
cat(readLines(arch), sep = "\n")
