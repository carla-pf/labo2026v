#!/bin/bash
# z728_final_junior_power de la cátedra (Gustavo, 13/11) como 9068, en la jr, tal cual la publicó
# (sus semillas, su grid, su FE; solo cambia el número de experimento: 9110 -> 9068).
# Sube a Kaggle desde la notebook (cortes 1700 a 2300) con la cuenta MCD: KAGGLE_CONFIG_DIR=~/.kaggle2.
# Uso (una sola línea):   bash ~/buckets/b1/labo2026v-modelo-final/lanzar_z728.sh
# Log: ~/log_z728.log

REPO=$HOME/buckets/b1/labo2026v-modelo-final
EXP=$HOME/buckets/b1/exp
N=9068
NBF=${N}_728_final_junior_power.ipynb
CRED=$HOME/.kaggle2/kaggle.json

echo "VM: $(hostname | sed 's/\..*//') · procesador: $(lscpu | grep 'Model name' | sed 's/.*: *//') · nproc: $(nproc) · memoria: $(free -g | awk '/Mem:/{print $2}') GB · Kaggle: MCD (~/.kaggle2)"
ok=1
cd "$REPO" 2>/dev/null || { echo "[ERROR] no existe $REPO"; exit 1; }
git log -1 --format='repo en el commit %h (%s)' | cut -c1-120
[ -f $NBF ] || { echo "[ERROR] falta $NBF"; ok=0; }
[ -f /content/datasets/analistajr_competencia_2026.csv.gz ] || { echo "[ERROR] falta el dataset"; ok=0; }
[ -d /content/buckets/b1/exp ] || { echo "[ERROR] no existe /content/buckets/b1/exp (la notebook escribe ahí)"; ok=0; }
[ -x $HOME/.venv/bin/jupyter ] || { echo "[ERROR] falta ~/.venv/bin/jupyter"; ok=0; }
[ -f "$CRED" ] || { echo "[ERROR] falta $CRED (cuenta MCD)"; ok=0; }
[ -x $HOME/.venv/bin/kaggle ] || command -v kaggle > /dev/null || { echo "[ERROR] no encuentro el comando kaggle"; ok=0; }
if pgrep -f "[j]upyter-nbconvert|[c]orrer_por_semilla" > /dev/null; then
  echo "[ERROR] ya hay algo corriendo en esta VM:"; pgrep -af "[j]upyter-nbconvert|[c]orrer_por_semilla" | cut -c1-150; ok=0
fi
if ls $EXP/WF$N/corrida_*.ipynb > /dev/null 2>&1; then echo "[ERROR] WF$N ya tiene una corrida: no la piso"; ok=0; fi
[ $ok = 1 ] || { echo "No se lanzó nada."; exit 1; }

NB="$HOME/.venv/bin/jupyter nbconvert --to notebook --execute --ExecutePreprocessor.kernel_name=ir --ExecutePreprocessor.timeout=-1"
# PATH con ~/.venv/bin para que el system("kaggle ...") de la notebook encuentre el comando; KAGGLE_CONFIG_DIR = MCD
CMD="cd $REPO ; export PATH=$HOME/.venv/bin:\$PATH KAGGLE_CONFIG_DIR=$HOME/.kaggle2 ; echo \"=== $N empieza \$(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina)\" ; mkdir -p $EXP/WF$N && $NB --output-dir=$EXP/WF$N --output=corrida_$N.ipynb $NBF ; echo \"=== terminada \$(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina)\""

LOG=$HOME/log_z728.log
nohup bash -c "$CMD" > "$LOG" 2>&1 &
echo "Lanzada a las $(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina). Verifico en 30 segundos..."
sleep 30
if pgrep -f "[j]upyter-nbconvert.*${N}_728" > /dev/null; then
  echo "[OK] $N (z728 de la cátedra) está corriendo. Tarda unas 1,5 h (grid de 65 min + 20 semillas) y sube 7 cortes con MCD."
  echo "Corriendo ahora:"; pgrep -af "[j]upyter-nbconvert" | sed 's/.*--output=//' | cut -c1-80
  echo "Para mirar cómo va: tail -3 $LOG"
else
  echo "[REVISAR] $N no está corriendo. Últimas líneas del log:"; tail -20 "$LOG"
fi
