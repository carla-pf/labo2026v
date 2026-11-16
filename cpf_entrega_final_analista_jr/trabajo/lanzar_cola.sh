#!/bin/bash
# Cola de corridas del 13/11, una por VM. Corre todo de a una, en segundo plano, y verifica que arrancó.
# Uso (una sola línea):   bash ~/buckets/b1/labo2026v-modelo-final/lanzar_cola.sh jr      (o jr2)
#   jr2: 9029 (WF9029_jr2), 9104, 9114, 9123, 9025 + enviar_cortes
#   jr : 9029 (WF9029_jr),  9204, 9214, 9223, 9026 + enviar_cortes
# Entre corridas va ";" (si una falla, sigue la próxima); "&&" solo entre una notebook y su enviar_cortes.
# Log: ~/log_cola_<vm>.log

VM=$1
REPO=$HOME/buckets/b1/labo2026v-modelo-final
EXP=$HOME/buckets/b1/exp
case "$VM" in
  jr2) COLA="9104 9114 9123"; CON_KAGGLE=9025 ;;
  jr)  COLA="9204 9214 9223"; CON_KAGGLE=9026 ;;
  *) echo "[ERROR] Falta la VM. Uso: bash $REPO/lanzar_cola.sh jr   (o jr2)"; exit 1 ;;
esac

echo "VM: $VM · procesador: $(lscpu | grep 'Model name' | sed 's/.*: *//') · nproc: $(nproc) · memoria: $(free -g | awk '/Mem:/{print $2}') GB"

ok=1
cd "$REPO" 2>/dev/null || { echo "[ERROR] no existe $REPO"; exit 1; }
for n in 9029 $COLA $CON_KAGGLE; do
  [ -f ${n}_739_final_senior.ipynb ] || { echo "[ERROR] falta ${n}_739_final_senior.ipynb"; ok=0; }
done
[ -f /content/datasets/analistajr_competencia_2026.csv.gz ] || { echo "[ERROR] falta el dataset"; ok=0; }
[ -x $HOME/.venv/bin/jupyter ] || { echo "[ERROR] falta ~/.venv/bin/jupyter"; ok=0; }
[ -f $HOME/.kaggle/kaggle.json ] || { echo "[ERROR] falta ~/.kaggle/kaggle.json (lo usa enviar_cortes.sh)"; ok=0; }
if pgrep -f jupyter-nbconvert > /dev/null; then
  echo "[ERROR] ya hay una notebook corriendo en esta VM:"; pgrep -af jupyter-nbconvert | cut -c1-150; ok=0
fi
for d in WF9029_$VM $(for n in $COLA $CON_KAGGLE; do echo WF$n; done); do
  if ls $EXP/$d/corrida_*.ipynb > /dev/null 2>&1; then echo "[ERROR] $d ya tiene una corrida: no la piso"; ok=0; fi
done
[ $ok = 1 ] || { echo "No se lanzó nada."; exit 1; }

NB="$HOME/.venv/bin/jupyter nbconvert --to notebook --execute --ExecutePreprocessor.kernel_name=ir --ExecutePreprocessor.timeout=-1"
CMD="cd $REPO && mkdir -p $EXP/WF9029_$VM && echo \"=== 9029 empieza \$(date +%H:%M)\" && VM=$VM $NB --output-dir=$EXP/WF9029_$VM --output=corrida_9029.ipynb 9029_739_final_senior.ipynb"
for n in $COLA; do
  CMD="$CMD ; echo \"=== $n empieza \$(date +%H:%M)\" ; $NB --output-dir=$EXP/WF$n --output=corrida_$n.ipynb ${n}_739_final_senior.ipynb"
done
n=$CON_KAGGLE
CMD="$CMD ; echo \"=== $n empieza \$(date +%H:%M)\" ; $NB --output-dir=$EXP/WF$n --output=corrida_$n.ipynb ${n}_739_final_senior.ipynb && bash enviar_cortes.sh $n 1500 2900 200"
CMD="$CMD ; echo \"=== cola terminada \$(date +%H:%M)\""

LOG=$HOME/log_cola_$VM.log
nohup bash -c "$CMD" > "$LOG" 2>&1 &
echo "Lanzada a las $(date +%H:%M). Verifico en 30 segundos..."
sleep 30
if pgrep -f "jupyter-nbconvert.*9029_739" > /dev/null; then
  echo "[OK] 9029 está corriendo (carpeta WF9029_$VM). Después siguen: $COLA $CON_KAGGLE."
  echo "Para mirar cómo va: tail -3 $LOG"
else
  echo "[REVISAR] 9029 no está corriendo. Últimas líneas del log:"; tail -20 "$LOG"
fi
