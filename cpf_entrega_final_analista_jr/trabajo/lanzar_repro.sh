#!/bin/bash
# Verificacion de reproducibilidad de la entrega, version con rotas en NA, en la jr2 (9085 tambien corrio en la jr2, el 15/11; la jr esta apagada).
# Corre la MISMA notebook de la carpeta de entrega (~/buckets/b1/labo2026v/cpf_entrega_final_analista_jr) desde el
# dataset original (experimento 9088, fijo en la notebook, para no pisar WF9085). Genera los CSV de 1500 a 2700 de a 100 en WF9088/kaggle
# y no sube nada (PARAM$kaggle$subir <- FALSE). Al terminar:
#   1. compara con verificar_repro.sh cada CSV contra el de 9085, corte por corte (md5), y las predicciones;
#   2. copia el PARAM.yml de la re-corrida a la carpeta de entrega.
# Tarda unos 12 a 15 minutos en la jr2 (9085 tardo 12; la verificacion con tendencia, 9084, tardo 15 en la jr).
# Uso (una sola linea):   bash ~/buckets/b1/labo2026v-modelo-final/lanzar_repro.sh
# Log: ~/log_repro_na.log   ·   Resultado: ~/buckets/b1/exp/comparaciones/repro_9085_vs_9088.txt

REPO=$HOME/buckets/b1/labo2026v-modelo-final
ENTREGA=$HOME/buckets/b1/labo2026v/cpf_entrega_final_analista_jr
NBK=cpf_final_analista_jr.ipynb
EXP=$HOME/buckets/b1/exp
N=9088
A=9085
CORTES="$(seq -s ' ' 1500 100 2700)"

echo "VM: $(hostname | sed 's/\..*//') · procesador: $(lscpu | grep 'Model name' | sed 's/.*: *//') · nproc: $(nproc) · memoria: $(free -g | awk '/Mem:/{print $2}') GB"
ok=1
cd "$REPO" 2>/dev/null || { echo "[ERROR] no existe $REPO"; exit 1; }
[ -f verificar_repro.sh ] || { echo "[ERROR] falta verificar_repro.sh"; ok=0; }
[ -f "$ENTREGA/$NBK" ] || { echo "[ERROR] falta $ENTREGA/$NBK"; ok=0; }
if [ -f "$ENTREGA/$NBK" ]; then
  grep -q 'PARAM\$experimento <- 9088' "$ENTREGA/$NBK" || { echo "[ERROR] la notebook no tiene PARAM\$experimento <- 9088: podria pisar otra carpeta"; ok=0; }
  grep -q 'PARAM\$CA\$metodo <- \\"MachineLearning\\"' "$ENTREGA/$NBK" || { echo "[ERROR] la notebook no tiene las rotas en NA (MachineLearning)"; ok=0; }
  grep -q 'PARAM\$kaggle\$subir <- FALSE' "$ENTREGA/$NBK" || { echo "[ERROR] la notebook no tiene PARAM\$kaggle\$subir <- FALSE: subiria a Kaggle"; ok=0; }
  grep -q 'seq(1500, 2700, by = 100)' "$ENTREGA/$NBK" || { echo "[ERROR] la notebook no genera los cortes 1500 a 2700"; ok=0; }
  echo "notebook de la entrega: $ENTREGA/$NBK (md5 $(md5sum "$ENTREGA/$NBK" | cut -c1-32))"
fi
for f in prediccion.txt prediccion_validacion.txt; do [ -f $EXP/WF$A/$f ] || { echo "[ERROR] falta $EXP/WF$A/$f"; ok=0; }; done
[ -f $EXP/comparaciones/clase_202107.txt ] || { echo "[ERROR] falta comparaciones/clase_202107.txt"; ok=0; }
[ -f /content/datasets/analistajr_competencia_2026.csv.gz ] || { echo "[ERROR] falta el dataset"; ok=0; }
[ -x $HOME/.venv/bin/jupyter ] || { echo "[ERROR] falta ~/.venv/bin/jupyter"; ok=0; }
if pgrep -f "[j]upyter-nbconvert|[c]orrer_por_semilla" > /dev/null; then
  echo "[ERROR] ya hay algo corriendo en esta VM:"; pgrep -af "[j]upyter-nbconvert|[c]orrer_por_semilla" | cut -c1-150; ok=0
fi
if [ -e $EXP/WF$N ]; then echo "[ERROR] ya existe $EXP/WF$N: no la piso"; ok=0; fi
[ $ok = 1 ] || { echo "No se lanzo nada."; exit 1; }

NB="$HOME/.venv/bin/jupyter nbconvert --to notebook --execute --ExecutePreprocessor.kernel_name=ir --ExecutePreprocessor.timeout=-1"
RES=$EXP/comparaciones/repro_${A}_vs_${N}.txt
CMD="cd $ENTREGA ; echo \"=== $N empieza \$(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina)\" ; mkdir -p $EXP/WF$N && $NB --output-dir=$EXP/WF$N --output=corrida_$N.ipynb $NBK && echo \"=== $N termino \$(TZ=America/Argentina/Buenos_Aires date +%H:%M)\" && cp $EXP/WF$N/PARAM.yml $ENTREGA/PARAM.yml && echo \"PARAM.yml copiado a la carpeta de entrega\" && cd $REPO && CORTES=\"$CORTES\" bash verificar_repro.sh $A $N | tee $RES"

LOG=$HOME/log_repro_na.log
nohup bash -c "$CMD" > "$LOG" 2>&1 &
echo "Lanzada a las $(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina). Verifico en 30 segundos..."
sleep 30
if pgrep -f "[j]upyter-nbconvert.*$NBK" > /dev/null; then
  echo "[OK] la notebook de la entrega esta corriendo como $N. Termina en unos 12 a 15 minutos (hacia las $(TZ=America/Argentina/Buenos_Aires date -d '+20 min' +%H:%M))."
  echo "Al terminar compara los 13 CSV (1500 a 2700) contra $A y deja el resultado en $RES"
  echo "Para ver el resultado:   tail -30 $LOG"
else
  echo "[REVISAR] no esta corriendo. Ultimas lineas del log:"; tail -20 "$LOG"
fi
