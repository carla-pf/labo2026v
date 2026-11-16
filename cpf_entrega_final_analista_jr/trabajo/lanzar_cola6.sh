#!/bin/bash
# Cola 6 (14/11), solo en la jr2: tres variantes sobre la candidata 2 (IPC), cada una en los tres meses,
# con las mismas 100 semillas que su referencia (9031 en 202107, 9123 en 202105, 9223 en 202103).
#   V1 sin campos clave (numero_de_cliente y foto_mes fuera de campos_buenos): 9069 (202107) · 9070 (202105) · 9071 (202103)
#   V2 sin canaritos:                                                         9072 (202107) · 9073 (202105) · 9074 (202103)
#   V3 hiperparametros de Maylen (ExpCol 10 B):                               9075 (202107) · 9076 (202105) · 9077 (202103)
# Orden: V1 completa, V2 completa, V3 completa. Las de 202107 suben 8 cortes (1500 a 2900 de a 200) con CF apenas terminan.
# Entre corridas va ";" (si una falla, sigue la próxima); "&&" solo entre una corrida y su enviar_cortes.
# Uso (una sola línea):   bash ~/buckets/b1/labo2026v-modelo-final/lanzar_cola6.sh
# Log: ~/log_cola6_jr2.log

REPO=$HOME/buckets/b1/labo2026v-modelo-final
EXP=$HOME/buckets/b1/exp
COLA="9069 9070 9071 9072 9073 9074 9075 9076 9077"
CON_KAGGLE="9069 9072 9075"
CRED=$HOME/.kaggle/kaggle.json

echo "VM: $(hostname | sed 's/\..*//') · procesador: $(lscpu | grep 'Model name' | sed 's/.*: *//') · nproc: $(nproc) · memoria: $(free -g | awk '/Mem:/{print $2}') GB · Kaggle: CF (~/.kaggle)"
ok=1
cd "$REPO" 2>/dev/null || { echo "[ERROR] no existe $REPO"; exit 1; }
git log -1 --format='repo en el commit %h (%s)' | cut -c1-120
for n in $COLA; do [ -f ${n}_739_final_senior.ipynb ] || { echo "[ERROR] falta ${n}_739_final_senior.ipynb"; ok=0; }; done
[ -f /content/datasets/analistajr_competencia_2026.csv.gz ] || { echo "[ERROR] falta el dataset"; ok=0; }
[ -x $HOME/.venv/bin/jupyter ] || { echo "[ERROR] falta ~/.venv/bin/jupyter"; ok=0; }
[ -f "$CRED" ] || { echo "[ERROR] falta $CRED (lo usa enviar_cortes.sh)"; ok=0; }
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

LOG=$HOME/log_cola6_jr2.log
nohup bash -c "$CMD" > "$LOG" 2>&1 &
echo "Lanzada a las $(TZ=America/Argentina/Buenos_Aires date +%H:%M) (hora argentina). Verifico en 30 segundos..."
sleep 30
if pgrep -f "[j]upyter-nbconvert.*9069_739" > /dev/null; then
  echo "[OK] 9069 (V1, 202107) está corriendo. Después siguen: 9070 9071 (V1) · 9072 9073 9074 (V2) · 9075 9076 9077 (V3)."
  echo "Suben 8 cortes con CF al terminar: $CON_KAGGLE."
  echo "Corriendo ahora:"; pgrep -af "[j]upyter-nbconvert" | sed 's/.*--output=//' | cut -c1-80
  echo "Para mirar cómo va: tail -3 $LOG"
else
  echo "[REVISAR] 9069 no está corriendo. Últimas líneas del log:"; tail -20 "$LOG"
fi
