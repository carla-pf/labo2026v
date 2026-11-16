#!/bin/bash
# Confirmaciones del FE y del electoral en 202105 y 202103 (14/11), sobre la candidata 2 con IPC, sin Kaggle. Una cola por VM.
# Uso (una sola línea):   bash ~/buckets/b1/labo2026v-modelo-final/lanzar_cola5.sh jr      (o jr2)
#   jr2 (202105, contra 9123): 9064 (I3) · 9060 (H1) · 9062 (I2) · 9066 (electoral)
#   jr  (202103, contra 9223): 9065 (I3) · 9061 (H1) · 9063 (I2) · 9067 (electoral)
# Mismas 100 semillas de 9123 y 9223. Entre corridas va ";" (si una falla, sigue la próxima).
# Log: ~/log_cola5_<vm>.log

VM=$1
REPO=$HOME/buckets/b1/labo2026v-modelo-final
EXP=$HOME/buckets/b1/exp
case "$VM" in
  jr2) COLA="9064 9060 9062 9066"; KAG="";                                 CUENTA="CF (~/.kaggle)";   CRED=$HOME/.kaggle/kaggle.json ;;
  jr)  COLA="9065 9061 9063 9067"; KAG="KAGGLE_CONFIG_DIR=$HOME/.kaggle2"; CUENTA="MCD (~/.kaggle2)"; CRED=$HOME/.kaggle2/kaggle.json ;;
  *) echo "[ERROR] Falta la VM. Uso: bash $REPO/lanzar_cola5.sh jr   (o jr2)"; exit 1 ;;
esac

echo "VM: $VM · procesador: $(lscpu | grep 'Model name' | sed 's/.*: *//') · nproc: $(nproc) · memoria: $(free -g | awk '/Mem:/{print $2}') GB · Kaggle: $CUENTA"

ok=1
cd "$REPO" 2>/dev/null || { echo "[ERROR] no existe $REPO"; exit 1; }
git log -1 --format='repo en el commit %h (%s)' | cut -c1-120
for n in $COLA; do
  [ -f ${n}_739_final_senior.ipynb ] || { echo "[ERROR] falta ${n}_739_final_senior.ipynb (¿hiciste git pull?)"; ok=0; }
done
[ -f /content/datasets/analistajr_competencia_2026.csv.gz ] || { echo "[ERROR] falta el dataset"; ok=0; }
[ -f $HOME/buckets/b1/datasets/externos/covid_mensual.csv ] || { echo "[ERROR] falta covid_mensual.csv (lo usa 9059; se arma con Rscript covid_mensual.R)"; ok=0; }
[ -x $HOME/.venv/bin/jupyter ] || { echo "[ERROR] falta ~/.venv/bin/jupyter"; ok=0; }
# [j] para que pgrep no se encuentre a sí mismo
if pgrep -f "[j]upyter-nbconvert|[c]orrer_por_semilla" > /dev/null; then
  echo "[ERROR] ya hay algo corriendo en esta VM:"; pgrep -af "[j]upyter-nbconvert|[c]orrer_por_semilla" | cut -c1-150; ok=0
fi
for n in $COLA; do
  if ls $EXP/WF$n/corrida_*.ipynb > /dev/null 2>&1; then echo "[ERROR] WF$n ya tiene una corrida: no la piso"; ok=0; fi
done
[ $ok = 1 ] || { echo "No se lanzó nada."; exit 1; }

NB="$HOME/.venv/bin/jupyter nbconvert --to notebook --execute --ExecutePreprocessor.kernel_name=ir --ExecutePreprocessor.timeout=-1"
CMD="cd $REPO"
for n in $COLA; do
  CMD="$CMD ; echo \"=== $n empieza \$(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina)\" ; mkdir -p $EXP/WF$n && $NB --output-dir=$EXP/WF$n --output=corrida_$n.ipynb ${n}_739_final_senior.ipynb"
done
CMD="$CMD ; echo \"=== cola terminada \$(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina)\""

LOG=$HOME/log_cola5_$VM.log
nohup bash -c "$CMD" > "$LOG" 2>&1 &
PRIMERA=$(echo $COLA | cut -d' ' -f1)
echo "Lanzada a las $(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina). Verifico en 30 segundos..."
sleep 30
if pgrep -f "[j]upyter-nbconvert.*${PRIMERA}_739" > /dev/null; then
  echo "[OK] $PRIMERA está corriendo. Después siguen: $(echo $COLA | cut -d' ' -f2-). Sin Kaggle."
  echo "Para mirar cómo va: tail -3 $LOG"
else
  echo "[REVISAR] $PRIMERA no está corriendo. Últimas líneas del log:"; tail -20 "$LOG"
fi
