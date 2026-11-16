#!/bin/bash
# Tanda de confirmaciones sobre la candidata 2 (13/11), una cola por VM. Corre de a una, en segundo plano, y verifica que arrancó.
# Uso (una sola línea):   bash ~/buckets/b1/labo2026v-modelo-final/lanzar_cola3.sh jr      (o jr2)
#   jr2: 9044 (dólar blue, 202105) · 9046 (rank de monetarias, 202105) · 9049 (sin internet, 202105) · 9048 (sin internet, 202107, Kaggle CF)
#   jr : 9045 (dólar blue, 202103) · 9047 (rank de monetarias, 202103) · 9050 (sin internet, 202103) · 9051 (electoral, 202107, Kaggle MCD)
# Las de 202105 y 202103 no tienen modelo final ni Kaggle (solo validación). Las de 202107 suben 8 cortes (1500 a 2900 de a 200).
# Entre corridas va ";" (si una falla, sigue la próxima); "&&" solo entre una corrida y su enviar_cortes.
# Log: ~/log_cola3_<vm>.log

VM=$1
REPO=$HOME/buckets/b1/labo2026v-modelo-final
EXP=$HOME/buckets/b1/exp
case "$VM" in
  jr2) COLA="9044 9046 9049"; CON_KAGGLE=9048; KAG="";                                 CUENTA="CF (~/.kaggle)";   CRED=$HOME/.kaggle/kaggle.json ;;
  jr)  COLA="9045 9047 9050"; CON_KAGGLE=9051; KAG="KAGGLE_CONFIG_DIR=$HOME/.kaggle2"; CUENTA="MCD (~/.kaggle2)"; CRED=$HOME/.kaggle2/kaggle.json ;;
  *) echo "[ERROR] Falta la VM. Uso: bash $REPO/lanzar_cola3.sh jr   (o jr2)"; exit 1 ;;
esac

echo "VM: $VM · procesador: $(lscpu | grep 'Model name' | sed 's/.*: *//') · nproc: $(nproc) · memoria: $(free -g | awk '/Mem:/{print $2}') GB · Kaggle: $CUENTA"

ok=1
cd "$REPO" 2>/dev/null || { echo "[ERROR] no existe $REPO"; exit 1; }
git log -1 --format='repo en el commit %h (%s)' | cut -c1-120
for n in $COLA $CON_KAGGLE; do
  [ -f ${n}_739_final_senior.ipynb ] || { echo "[ERROR] falta ${n}_739_final_senior.ipynb (¿hiciste git pull?)"; ok=0; }
done
[ -f /content/datasets/analistajr_competencia_2026.csv.gz ] || { echo "[ERROR] falta el dataset"; ok=0; }
[ -x $HOME/.venv/bin/jupyter ] || { echo "[ERROR] falta ~/.venv/bin/jupyter"; ok=0; }
[ -f "$CRED" ] || { echo "[ERROR] falta $CRED (lo usa enviar_cortes.sh)"; ok=0; }
# [j] para que pgrep no se encuentre a sí mismo
if pgrep -f "[j]upyter-nbconvert|[c]orrer_por_semilla" > /dev/null; then
  echo "[ERROR] ya hay algo corriendo en esta VM:"; pgrep -af "[j]upyter-nbconvert|[c]orrer_por_semilla" | cut -c1-150; ok=0
fi
for n in $COLA $CON_KAGGLE; do
  if ls $EXP/WF$n/corrida_*.ipynb > /dev/null 2>&1; then echo "[ERROR] WF$n ya tiene una corrida: no la piso"; ok=0; fi
done
[ $ok = 1 ] || { echo "No se lanzó nada."; exit 1; }

NB="$HOME/.venv/bin/jupyter nbconvert --to notebook --execute --ExecutePreprocessor.kernel_name=ir --ExecutePreprocessor.timeout=-1"
CMD="cd $REPO"
for n in $COLA; do
  CMD="$CMD ; echo \"=== $n empieza \$(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina)\" ; mkdir -p $EXP/WF$n && $NB --output-dir=$EXP/WF$n --output=corrida_$n.ipynb ${n}_739_final_senior.ipynb"
done
n=$CON_KAGGLE
CMD="$CMD ; echo \"=== $n empieza \$(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina)\" ; mkdir -p $EXP/WF$n && $NB --output-dir=$EXP/WF$n --output=corrida_$n.ipynb ${n}_739_final_senior.ipynb && $KAG bash enviar_cortes.sh $n 1500 2900 200"
CMD="$CMD ; echo \"=== cola terminada \$(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina)\""

LOG=$HOME/log_cola3_$VM.log
nohup bash -c "$CMD" > "$LOG" 2>&1 &
PRIMERA=$(echo $COLA | cut -d' ' -f1)
echo "Lanzada a las $(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina). Verifico en 30 segundos..."
sleep 30
if pgrep -f "[j]upyter-nbconvert.*${PRIMERA}_739" > /dev/null; then
  echo "[OK] $PRIMERA está corriendo. Después siguen: $(echo $COLA | cut -d' ' -f2-) y $CON_KAGGLE (con Kaggle)."
  echo "Para mirar cómo va: tail -3 $LOG"
else
  echo "[REVISAR] $PRIMERA no está corriendo. Últimas líneas del log:"; tail -20 "$LOG"
fi
