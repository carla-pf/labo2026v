#!/bin/bash
# 9027 (exploración, análogo electoral): 9014 con más peso a 201908-201911. Sube 8 cortes con la cuenta MCD.
# Corre en la jr, que es la única VM con la cuenta MCD (~/.kaggle2).
# Uso (una sola línea):   bash ~/buckets/b1/labo2026v-modelo-final/lanzar_9027.sh
# Log: ~/log_9027.log
REPO=$HOME/buckets/b1/labo2026v-modelo-final
EXP=$HOME/buckets/b1/exp
ok=1
echo "VM: $(hostname) · procesador: $(lscpu | grep 'Model name' | sed 's/.*: *//') · nproc: $(nproc)"
cd "$REPO" 2>/dev/null || { echo "[ERROR] no existe $REPO"; exit 1; }
[ -f 9027_739_final_senior.ipynb ] || { echo "[ERROR] falta 9027_739_final_senior.ipynb"; ok=0; }
[ -f $HOME/.kaggle2/kaggle.json ] || { echo "[ERROR] falta ~/.kaggle2/kaggle.json (cuenta MCD): esto se corre en la jr"; ok=0; }
if pgrep -f jupyter-nbconvert > /dev/null; then
  echo "[ERROR] hay una notebook corriendo en esta VM (no corto nada):"; pgrep -af jupyter-nbconvert | cut -c1-150; ok=0
fi
if ls $EXP/WF9027/corrida_*.ipynb > /dev/null 2>&1; then echo "[ERROR] WF9027 ya tiene una corrida: no la piso"; ok=0; fi
[ $ok = 1 ] || { echo "No se lanzó nada."; exit 1; }

NB="$HOME/.venv/bin/jupyter nbconvert --to notebook --execute --ExecutePreprocessor.kernel_name=ir --ExecutePreprocessor.timeout=-1"
mkdir -p $EXP/WF9027
nohup bash -c "cd $REPO && $NB --output-dir=$EXP/WF9027 --output=corrida_9027.ipynb 9027_739_final_senior.ipynb && KAGGLE_CONFIG_DIR=$HOME/.kaggle2 bash enviar_cortes.sh 9027 1500 2900 200" > $HOME/log_9027.log 2>&1 &
echo "Lanzada a las $(date +%H:%M). Verifico en 30 segundos..."
sleep 30
if pgrep -f "jupyter-nbconvert.*9027_739" > /dev/null; then
  echo "[OK] 9027 está corriendo. Al terminar sube 8 cortes (1500 a 2900) con MCD."
  echo "Para mirar cómo va: tail -3 ~/log_9027.log"
else
  echo "[REVISAR] 9027 no está corriendo. Últimas líneas del log:"; tail -20 $HOME/log_9027.log
fi
