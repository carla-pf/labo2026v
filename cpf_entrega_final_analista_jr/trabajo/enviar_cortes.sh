#!/bin/bash
# Sube a Kaggle cortes nuevos de una corrida que ya termino, SIN volver a entrenar.
# Usa la prediccion del future (202109) que la corrida dejo en WF<exp>/prediccion.txt,
# ordena por prob (igual que la notebook) y marca los primeros <envios>.
# Los archivos y el mensaje de Kaggle tienen el mismo formato que la notebook,
# asi resumen_corrida.sh y comparar_corridas.sh los encuentran.
# Saltea los cortes que ya tienen archivo en WF<exp>/kaggle (ya se subieron).
#
# Uso:   bash enviar_cortes.sh <exp> <desde> <hasta> <paso>
# Ej.:   bash enviar_cortes.sh 9006 2300 3500 100
# Cuentas: sube con la cuenta principal de la VM (CF). Si un envio falla (por ejemplo, se agoto el cupo)
# y la VM tiene la segunda cuenta configurada en ~/.kaggle2 (MCD), reintenta ese corte con MCD y
# sigue con MCD el resto. Para usar MCD desde el principio:
#   KAGGLE_CONFIG_DIR=$HOME/.kaggle2 bash enviar_cortes.sh 9006 2900 3500 100
# Para varias corridas seguidas y poder cerrar la terminal:
#   cd ~/buckets/b1/labo2026v-modelo-final && nohup bash -c 'for e in 9004 9005 9006 9007; do bash enviar_cortes.sh $e 2300 3500 100; done' > ~/envios_cortes.log 2>&1 &
# Carpeta distinta de WF<exp> (por ejemplo 9029, que corrio en las dos VM: WF9029_jr y WF9029_jr2):
#   CARPETA=WF9029_jr2 bash enviar_cortes.sh 9029 1500 2900 200
# Sin CARPETA se usa WF<exp>, como siempre.

E=$1; DESDE=$2; HASTA=$3; PASO=$4
if [ -z "$E" ] || [ -z "$DESDE" ] || [ -z "$HASTA" ] || [ -z "$PASO" ]; then
  echo "Uso: bash enviar_cortes.sh <exp> <desde> <hasta> <paso>   Ej: bash enviar_cortes.sh 9006 2300 3500 100"; exit 1
fi

WF=$HOME/buckets/b1/exp/${CARPETA:-WF$E}
if [ ! -f "$WF/prediccion.txt" ]; then echo "No encuentro $WF/prediccion.txt"; exit 1; fi

Rscript - "$WF" "$E" "$DESDE" "$HASTA" "$PASO" labo-1-virtual-2026-analista-jr <<'RR'
suppressMessages(library(data.table))
arg <- commandArgs(trailingOnly = TRUE)
WF <- arg[1]; E <- arg[2]; COMP <- arg[6]
cortes <- seq(as.integer(arg[3]), as.integer(arg[4]), by = as.integer(arg[5]))

tb <- fread(file.path(WF, "prediccion.txt"))
nsem <- length(grep("^prob_[0-9]+$", names(tb)))
setorder(tb, -prob)   # igual que la notebook
cuenta_de <- function(pre) {
  u <- grep("username", suppressWarnings(system(paste(pre, "kaggle config view 2>/dev/null"), intern = TRUE)), value = TRUE)
  if (length(u)) sub(".*username:\\s*", "", u[1]) else "?"
}
segunda <- file.path(Sys.getenv("HOME"), ".kaggle2", "kaggle.json")
pre <- ""   # prefijo del comando kaggle: "" = cuenta principal; "KAGGLE_CONFIG_DIR=..." = segunda cuenta
cat("corrida", E, " semillas:", nsem, " clientes:", nrow(tb), " cortes pedidos:", length(cortes), " cuenta Kaggle:", cuenta_de(pre), "\n")

dir.create(file.path(WF, "kaggle"), showWarnings = FALSE)
for (envios in cortes) {
  archivo <- file.path(WF, "kaggle", paste0("KA", E, "_", nsem, "_", envios, ".csv"))
  if (file.exists(archivo)) { cat(envios, ": ya estaba subido, lo salteo\n"); next }
  tb[, Predicted := 0L]
  tb[1:envios, Predicted := 1L]
  fwrite(tb[, list(numero_de_cliente, Predicted)], file = archivo, sep = ",")
  linea <- paste0("kaggle competitions submit -c ", COMP, " -f ", archivo,
                  " -m 'exp=", E, " semillas=", nsem, " envios=", envios, "'")
  subir <- function() {
    Sys.sleep(30)
    salida <- tryCatch(suppressWarnings(system(paste(pre, linea, "2>&1"), intern = TRUE)), error = function(e) as.character(e))
    list(ok = any(grepl("Successfully submitted", salida)), salida = salida)
  }
  r <- subir()
  if (!r$ok && pre == "" && file.exists(segunda)) {
    pre <- paste0("KAGGLE_CONFIG_DIR=", dirname(segunda))
    cat(envios, ": fallo con la cuenta principal (", tail(r$salida, 1), "); sigo con", cuenta_de(pre), "\n")
    r <- subir()
  }
  salida <- r$salida; ok <- r$ok
  if (!ok) file.remove(archivo)   # si no se subio, se borra el archivo para poder reintentarlo
  cat(envios, ":", if (ok) "subido" else paste("NO SUBIDO:", tail(salida, 1)), "\n")
}
cat("Listo", E, "\n")
RR
