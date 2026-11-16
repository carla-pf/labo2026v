#!/bin/bash
# Cola del bloque de drifting (13/11), una por VM. Corre todo de a una, en segundo plano, y verifica que arrancó.
# Uso (una sola línea):   bash ~/buckets/b1/labo2026v-modelo-final/lanzar_cola2.sh jr      (o jr2)
#   jr2: 9032 9033 9034 9035 (drifting sobre 9031) · 9040 (empates azar 1) · 9043 (D3b, por semilla)   Kaggle: CF
#   jr : 9036 9037 9038 9039 (drifting sobre 9029) · 9041 (empates azar 2) · 9042 (D3a, por semilla)   Kaggle: MCD
# Entre corridas va ";" (si una falla, sigue la próxima); "&&" solo entre una corrida y su enviar_cortes.
# Kaggle: 8 cortes (1500 a 2900 de a 200). jr2 en modo normal (CF); jr forzado a MCD (~/.kaggle2).
# Log: ~/log_cola2_<vm>.log

VM=$1
REPO=$HOME/buckets/b1/labo2026v-modelo-final
EXP=$HOME/buckets/b1/exp
case "$VM" in
  jr2) COLA="9032 9033 9034 9035 9040"; POR_SEMILLA=9043; KAG="";                                 CUENTA="CF (~/.kaggle)";   CRED=$HOME/.kaggle/kaggle.json ;;
  jr)  COLA="9036 9037 9038 9039 9041"; POR_SEMILLA=9042; KAG="KAGGLE_CONFIG_DIR=$HOME/.kaggle2"; CUENTA="MCD (~/.kaggle2)"; CRED=$HOME/.kaggle2/kaggle.json ;;
  *) echo "[ERROR] Falta la VM. Uso: bash $REPO/lanzar_cola2.sh jr   (o jr2)"; exit 1 ;;
esac

echo "VM: $VM · procesador: $(lscpu | grep 'Model name' | sed 's/.*: *//') · nproc: $(nproc) · memoria: $(free -g | awk '/Mem:/{print $2}') GB · Kaggle: $CUENTA"

ok=1
cd "$REPO" 2>/dev/null || { echo "[ERROR] no existe $REPO"; exit 1; }
git log -1 --format='repo en el commit %h (%s)' | cut -c1-120
for n in $COLA $POR_SEMILLA; do
  [ -f ${n}_739_final_senior.ipynb ] || { echo "[ERROR] falta ${n}_739_final_senior.ipynb (¿hiciste git pull?)"; ok=0; }
done
[ -f correr_por_semilla.sh ] || { echo "[ERROR] falta correr_por_semilla.sh"; ok=0; }
[ -f /content/datasets/analistajr_competencia_2026.csv.gz ] || { echo "[ERROR] falta el dataset"; ok=0; }
[ -x $HOME/.venv/bin/jupyter ] || { echo "[ERROR] falta ~/.venv/bin/jupyter"; ok=0; }
[ -f "$CRED" ] || { echo "[ERROR] falta $CRED (lo usa enviar_cortes.sh)"; ok=0; }
# [j] para que pgrep no se encuentre a sí mismo
if pgrep -f "[j]upyter-nbconvert|[c]orrer_por_semilla" > /dev/null; then
  echo "[ERROR] ya hay algo corriendo en esta VM:"; pgrep -af "[j]upyter-nbconvert|[c]orrer_por_semilla" | cut -c1-150; ok=0
fi
for n in $COLA; do
  if ls $EXP/WF$n/corrida_*.ipynb > /dev/null 2>&1; then echo "[ERROR] WF$n ya tiene una corrida: no la piso"; ok=0; fi
done
if ls -d $EXP/WF$POR_SEMILLA/semilla_* > /dev/null 2>&1; then echo "[ERROR] WF$POR_SEMILLA ya tiene semillas: no las piso"; ok=0; fi
[ $ok = 1 ] || { echo "No se lanzó nada."; exit 1; }

NB="$HOME/.venv/bin/jupyter nbconvert --to notebook --execute --ExecutePreprocessor.kernel_name=ir --ExecutePreprocessor.timeout=-1"
CMD="cd $REPO"
for n in $COLA; do
  CMD="$CMD ; echo \"=== $n empieza \$(date +%H:%M)\" ; mkdir -p $EXP/WF$n && $NB --output-dir=$EXP/WF$n --output=corrida_$n.ipynb ${n}_739_final_senior.ipynb && $KAG bash enviar_cortes.sh $n 1500 2900 200"
done
n=$POR_SEMILLA
CMD="$CMD ; echo \"=== $n (por semilla) empieza \$(date +%H:%M)\" ; bash correr_por_semilla.sh $n 100 && $KAG bash enviar_cortes.sh $n 1500 2900 200"
CMD="$CMD ; echo \"=== cola terminada \$(date +%H:%M)\""

LOG=$HOME/log_cola2_$VM.log
nohup bash -c "$CMD" > "$LOG" 2>&1 &
PRIMERA=$(echo $COLA | cut -d' ' -f1)
echo "Lanzada a las $(date +%H:%M). Verifico en 30 segundos..."
sleep 30
if pgrep -f "[j]upyter-nbconvert.*${PRIMERA}_739" > /dev/null; then
  echo "[OK] $PRIMERA está corriendo. Después siguen: $(echo $COLA | cut -d' ' -f2-) y $POR_SEMILLA (por semilla)."
  echo "Para mirar cómo va: tail -3 $LOG"
else
  echo "[REVISAR] $PRIMERA no está corriendo. Últimas líneas del log:"; tail -20 "$LOG"
fi
