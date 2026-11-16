#!/bin/bash
# Cola 7 (15/11), solo en la jr2: la clase binaria sobre la candidata 2 (IPC), cada variante en los tres meses,
# con las mismas 100 semillas que su referencia (9031 en 202107, 9123 en 202105, 9223 en 202103).
#   V4 clase ingenua (positivos solo BAJA+2; BAJA+1 negativo):      9078 (202107) · 9079 (202105) · 9080 (202103)
#   V5 clase intermedia (BAJA+1 y BAJA+2 positivos, BAJA+1 peso 0,5): 9081 (202107) · 9082 (202105) · 9083 (202103)
# Orden: V4 completa y despues V5 completa. Ninguna sube a Kaggle desde la jr2 (las de 202107 se suben desde la jr con MCD).
# Entre corridas va ";" (si una falla, sigue la próxima).
# Uso (una sola línea):   bash ~/buckets/b1/labo2026v-modelo-final/lanzar_cola7.sh
# Log: ~/log_cola7_jr2.log

REPO=$HOME/buckets/b1/labo2026v-modelo-final
EXP=$HOME/buckets/b1/exp
COLA="9078 9079 9080 9081 9082 9083"
CON_KAGGLE=""

echo "VM: $(hostname | sed 's/\..*//') · procesador: $(lscpu | grep 'Model name' | sed 's/.*: *//') · nproc: $(nproc) · memoria: $(free -g | awk '/Mem:/{print $2}') GB"
ok=1
cd "$REPO" 2>/dev/null || { echo "[ERROR] no existe $REPO"; exit 1; }
git log -1 --format='repo en el commit %h (%s)' | cut -c1-120
for n in $COLA; do [ -f ${n}_739_final_senior.ipynb ] || { echo "[ERROR] falta ${n}_739_final_senior.ipynb"; ok=0; }; done
[ -f /content/datasets/analistajr_competencia_2026.csv.gz ] || { echo "[ERROR] falta el dataset"; ok=0; }
[ -x $HOME/.venv/bin/jupyter ] || { echo "[ERROR] falta ~/.venv/bin/jupyter"; ok=0; }
if pgrep -f "[j]upyter-nbconvert|[c]orrer_por_semilla" > /dev/null; then
  echo "[ERROR] ya hay algo corriendo en esta VM:"; pgrep -af "[j]upyter-nbconvert|[c]orrer_por_semilla" | cut -c1-150; ok=0
fi
for n in $COLA; do if ls $EXP/WF$n/corrida_*.ipynb > /dev/null 2>&1; then echo "[ERROR] WF$n ya tiene una corrida: no la piso"; ok=0; fi; done
[ $ok = 1 ] || { echo "No se lanzó nada."; exit 1; }

NB="$HOME/.venv/bin/jupyter nbconvert --to notebook --execute --ExecutePreprocessor.kernel_name=ir --ExecutePreprocessor.timeout=-1"
CMD="cd $REPO"
for n in $COLA; do
  CMD="$CMD ; echo \"=== $n empieza \$(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina)\" ; mkdir -p $EXP/WF$n && $NB --output-dir=$EXP/WF$n --output=corrida_$n.ipynb ${n}_739_final_senior.ipynb"
  case " $CON_KAGGLE " in *" $n "*) CMD="$CMD && bash enviar_cortes.sh $n 1500 2900 200" ;; esac
done
CMD="$CMD ; echo \"=== cola terminada \$(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina)\""

LOG=$HOME/log_cola7_jr2.log
nohup bash -c "$CMD" > "$LOG" 2>&1 &
echo "Lanzada a las $(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina). Verifico en 30 segundos..."
sleep 30
if pgrep -f "[j]upyter-nbconvert.*9078_739" > /dev/null; then
  echo "[OK] 9078 (V4, 202107) está corriendo. Después siguen: 9079 9080 (V4) · 9081 9082 9083 (V5)."
  echo "No sube nada a Kaggle."
  echo "Corriendo ahora:"; pgrep -af "[j]upyter-nbconvert" | sed 's/.*--output=//' | cut -c1-80
  echo "Para mirar cómo va: tail -3 $LOG"
else
  echo "[REVISAR] 9078 no está corriendo. Últimas líneas del log:"; tail -20 "$LOG"
fi
