#!/bin/bash
# Prediccion final - junta en un solo archivo de texto todo lo de una corrida.
# Uso:   bash resumen_corrida.sh 9002
# Deja el resumen en ~/buckets/b1/exp/WF<exp>/resumen_<exp>.txt (y lo muestra en pantalla).

EXP=$1
if [ -z "$EXP" ]; then echo "Falta el numero de experimento. Ej: bash resumen_corrida.sh 9002"; exit 1; fi

BASE=$HOME/buckets/b1/exp/WF${EXP}
# el notebook con las salidas puede estar en este repo, en PredFinal o (si se corrio por terminal) en la carpeta de la corrida
NBS="$HOME/buckets/b1/labo2026v-modelo-final/${EXP}_739_final_senior.ipynb $HOME/buckets/b1/labo2026v/PredFinal/${EXP}_739_final_senior.ipynb $HOME/buckets/b1/exp/WF${EXP}/corrida_${EXP}.ipynb"
OUT=$BASE/resumen_${EXP}.txt
COMP=labo-1-virtual-2026-analista-jr
DS=/content/datasets/analistajr_competencia_2026.csv.gz
[ -f "$DS" ] || DS=$HOME/datasets/analistajr_competencia_2026.csv.gz

if [ ! -d "$BASE" ]; then echo "No encuentro la carpeta $BASE"; exit 1; fi

{
echo "===== RESUMEN CORRIDA $EXP   $(date '+%F %T')   VM: $(hostname)"
echo
echo "===== 0. CONTROLES: la corrida hizo lo que se le pidio?"
python3 -I - "$BASE" "$HOME/buckets/b1/exp/comparaciones/envios_kaggle.txt" "$EXP" $NBS <<'PY'
import json, sys, os, re
base, reg, exp, nbs = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
mejor, nb, nejec = None, None, -1
for f in nbs:
    try: x = json.load(open(f))
    except Exception: continue
    n = sum(1 for c in x['cells'] if c['cell_type'] == 'code' and c.get('execution_count'))
    if n >= nejec: mejor, nb, nejec = f, x, n
alertas = []
def fila(nombre, valor, ok=None):
    marca = '' if ok is None else ('  [OK]' if ok else '  [REVISAR]')
    if ok is False: alertas.append(nombre)
    print(f"{nombre:<28} {valor}{marca}")
if nb is None:
    print("(no encontre el notebook de la corrida)"); sys.exit()
def txt(o):
    if o.get('output_type') == 'stream': return ''.join(o.get('text', ''))
    if o.get('output_type') == 'error': return 'ERROR: ' + o.get('ename', '') + ' ' + o.get('evalue', '')
    return ''.join(o.get('data', {}).get('text/plain', ''))
celdas = [c for c in nb['cells'] if c['cell_type'] == 'code']
src = '\n'.join(''.join(c['source']) for c in celdas)
salida = '\n'.join(txt(o) for c in celdas for o in c.get('outputs', []))
nerr = sum(1 for c in celdas for o in c.get('outputs', []) if o.get('output_type') == 'error')
ejec = sum(1 for c in celdas if c.get('execution_count'))
fila('celdas ejecutadas', f"{ejec} de {len(celdas)}", ejec == len(celdas))
fila('celdas con error', nerr, nerr == 0)
def asign(var):   # ultima asignacion de una variable en el codigo
    m = re.findall(re.escape(var) + r'\s*(?:<-|=)\s*([^\n#]+)', src)
    return m[-1].strip() if m else '(no se asigna)'
sem = asign('PARAM$FT$semillerio')
nmod = len(os.listdir(os.path.join(base, 'modelos'))) if os.path.isdir(os.path.join(base, 'modelos')) else 0
try: semn = int(float(sem.split()[0]))
except Exception: semn = None
fila('semillas pedidas / modelos', f"{sem} / {nmod}", semn is not None and semn == nmod)
fila('undersampling (training_pct)', asign('PARAM$trainingstrategy$training_pct'))
for nombre in ['training', 'final_train']:
    asigs = re.findall(r'PARAM\$trainingstrategy\$' + nombre + r'\s*<-\s*(c\([^)]*\)|setdiff\([^\n]*)', src)
    if not asigs: continue
    ult_c = [x for x in asigs if x.startswith('c(')]
    meses = re.findall(r'\d{6}', ult_c[-1]) if ult_c else []
    extra = '  y despues ' + asigs[-1].split('#')[0].strip() if asigs[-1].startswith('setdiff') else ''
    fila('meses ' + nombre, (f"{len(meses)} meses, {meses[0]} a {meses[-1]}" if meses else '?') + extra)
if 'PARAM$pandemia' in src:
    fila('pandemia excluida', asign('PARAM$pandemia'))
for l in re.findall(r'E05-[A-Z]+: [^\n]+', salida)[:2]:
    fila('lags en NA', l.strip())
hp = {k: asign('param_final$' + k) for k in ['min_data_in_leaf', 'num_leaves', 'num_iterations', 'learning_rate', 'feature_fraction']}
fila('hiperparametros fijados', ', '.join(f"{k} {v}" for k, v in hp.items() if v != '(no se asigna)') or '(los de la bayesiana)')
ca = asign('PARAM$CA$metodo')
fila('CA: metodo', ca)
lineas_ca = re.findall(r'CA [a-z_]+ : (\S+)  meses ([0-9 ]+?)  reconstruidos: (\d+)(?: de (\d+))?', salida)
if lineas_ca:
    nums = [int(x[2]) for x in lineas_ca]
    fila('CA: variables reconstruidas', f"{len(lineas_ca)}  (minimo {min(nums)}, maximo {max(nums)})", min(nums) > 0)
    tot = [(x[0], int(x[2]), int(x[3])) for x in lineas_ca if x[3]]
    if tot:
        peor = min(tot, key=lambda t: t[1] / t[2])
        fila('CA: peor proporcion', f"{peor[0]} {peor[1]} de {peor[2]} ({100*peor[1]/peor[2]:.0f} %)", peor[1] / peor[2] > 0.5)
for l in re.findall(r'MICE (?:tardo|[a-z_]+ : imputa)[^\n]*', salida)[:2]:
    fila('MICE', l.strip())
auc = None
try:
    for l in open(os.path.join(base, 'PARAM.yml')):
        if re.match(r'\s+AUC:', l): auc = l.split(':')[1].strip(); break
except Exception: pass
fila('AUC de validacion guardado', auc or '(no esta PARAM.yml)', auc is not None)
nk = len(os.listdir(os.path.join(base, 'kaggle'))) if os.path.isdir(os.path.join(base, 'kaggle')) else 0
fila('archivos para Kaggle', nk, nk > 0)
try:
    nreg = sum(1 for l in open(reg) if l.split('\t')[0] == exp)
    fila('envios en el registro', f"{nreg} (se actualiza al comparar)")
except Exception: pass
print('\nRESULTADO DE LOS CONTROLES:', 'todo OK' if not alertas else 'REVISAR: ' + ', '.join(alertas))
PY
echo
echo "===== 1. ARCHIVOS EN WF${EXP}"
ls -la --time-style='+%F %T' "$BASE"
echo "modelos del semillerio: $(ls "$BASE"/modelos 2>/dev/null | wc -l)"
echo "archivos para Kaggle:   $(ls "$BASE"/kaggle 2>/dev/null | wc -l)"
echo
echo "===== 2. VALIDACION 202107 (archivo de la notebook: solo cortes 1300 a 2200; la curva completa esta en la seccion 9)"
cat "$BASE/validacion_cortes.txt" 2>/dev/null || echo "(no esta validacion_cortes.txt)"
echo
echo "===== 3. PARAM.yml, seccion out (validacion y mejores hiperparametros)"
if [ -f "$BASE/PARAM.yml" ]; then
  awk '/^out:/{p=1} p' "$BASE/PARAM.yml"
  echo "--- semillas usadas:"
  awk '/^FT:/{p=1;next} p&&/^[^ ]/{p=0} p' "$BASE/PARAM.yml"
else
  echo "(no esta PARAM.yml: la corrida no llego al final)"
fi
echo
echo "===== 4. MEJORES DE LA BAYESIANA (solo si hubo bayesiana)"
head -6 "$BASE/BO_log.txt" 2>/dev/null || echo "(sin BO_log.txt)"
echo
echo "===== 5. IMPORTANCIA DE VARIABLES (primeras 25)"
head -26 "$BASE/impo.txt" 2>/dev/null || echo "(sin impo.txt)"
echo
echo "===== 6. prediccion.txt (encabezado y filas)"
if [ -f "$BASE/prediccion.txt" ]; then head -1 "$BASE/prediccion.txt"; echo "filas: $(($(wc -l < "$BASE/prediccion.txt") - 1))"; else echo "(sin prediccion.txt)"; fi
echo
echo "===== 7. NOTEBOOK: horas, errores y salidas clave"
python3 -I - $NBS <<'PY'
import json, sys
# de los notebooks que existan, uso el que tiene mas celdas ejecutadas
mejor, nb, nejec = None, None, -1
for f in sys.argv[1:]:
    try: x = json.load(open(f))
    except Exception: continue
    n = sum(1 for c in x['cells'] if c['cell_type'] == 'code' and c.get('execution_count'))
    if n >= nejec: mejor, nb, nejec = f, x, n  # si empatan, gana el ultimo (la corrida por terminal)
if nb is None:
    print("(no encontre el notebook de la corrida)"); sys.exit()
print("notebook:", mejor)
def txt(o):
    if o.get('output_type') == 'stream': return ''.join(o.get('text', ''))
    if o.get('output_type') == 'error': return 'ERROR: ' + o.get('ename', '') + ' ' + o.get('evalue', '')
    d = o.get('data', {})
    return ''.join(d.get('text/plain', ''))
celdas = [c for c in nb['cells'] if c['cell_type'] == 'code']
corridas = [c for c in celdas if c.get('execution_count')]
print("celdas de codigo:", len(celdas), " ejecutadas:", len(corridas))
horas = [txt(o).strip() for c in celdas if ''.join(c['source']).startswith('format(Sys.time()') for o in c.get('outputs', [])]
print("hora inicio / fin (UTC):", horas)
claves = ['param_final', '# Estimacion del semillerio', 'print(PARAM$out$lgbm$mejores', '# genero archivos con los']
for c in celdas:
    src = ''.join(c['source'])
    salida = '\n'.join(txt(o) for o in c.get('outputs', []))
    if any(o.get('output_type') == 'error' for o in c.get('outputs', [])) or 'Error' in salida:
        print('\n--- CELDA CON ERROR:\n' + src[:300] + '\n>>> ' + salida[-1500:])
    if any(src.startswith(k) for k in claves) and salida.strip():
        print('\n--- ' + src.splitlines()[0] + '\n' + salida[-3000:])
PY
echo
echo "===== 8. ENVIOS EN KAGGLE DE ESTA CORRIDA (cuenta: $(kaggle config view 2>/dev/null | grep username | awk '{print $3}'))"
kaggle competitions submissions -c $COMP 2>/dev/null | head -2
kaggle competitions submissions -c $COMP 2>/dev/null | grep "exp=${EXP} " || echo "(no encontre envios con exp=${EXP})"
echo
echo "===== 9. 202107: CURVA DE GANANCIA Y A QUIENES LES MANDAMOS EL ESTIMULO (cortes 1300 a 3500)"
if [ -f "$BASE/prediccion_validacion.txt" ]; then
Rscript - "$BASE/prediccion_validacion.txt" "$DS" <<'RR'
suppressMessages(library(data.table))
options(width = 200)
a <- commandArgs(trailingOnly = TRUE)
pred <- fread(a[1])
clase <- fread(a[2], select = c("numero_de_cliente", "foto_mes", "clase_ternaria"))[foto_mes == 202107]
tb <- clase[pred, on = "numero_de_cliente"]
setorder(tb, -prob)
tb[, pos := .I]
total_b2 <- tb[clase_ternaria == "BAJA+2", .N]
cat("clientes en 202107:", nrow(tb), "  BAJA+2:", total_b2, "  BAJA+1:", tb[clase_ternaria == "BAJA+1", .N], "\n\n")
gac <- cumsum(ifelse(tb$clase_ternaria == "BAJA+2", 975000, -25000))
cc <- seq(1000, 5000, by = 100); g <- gac[cc]; su <- as.numeric(frollmean(g, 5, align = "center"))
mx <- max(su, na.rm = TRUE); mes <- cc[!is.na(su) & su >= mx - 1e6]
cat("ganancia promedio de los cortes 1300 a 3500:", round(mean(gac[seq(1300, 3500, by = 100)]) / 1e6, 2), "M\n")
cat("maximo suavizado (5 cortes):", round(mx / 1e6, 1), "M en", cc[which.max(su)], "  meseta:", min(mes), "a", max(mes), "\n\n")
res <- rbindlist(lapply(seq(1300, 3500, by = 100), function(k) tb[pos <= k, list(
  envios = k,
  enviados_BAJA2 = sum(clase_ternaria == "BAJA+2"),
  enviados_BAJA1 = sum(clase_ternaria == "BAJA+1"),
  enviados_CONTINUA = sum(clase_ternaria == "CONTINUA"),
  BAJA2_sin_enviar = total_b2 - sum(clase_ternaria == "BAJA+2"),
  ganancia = sum(ifelse(clase_ternaria == "BAJA+2", 975000, -25000)))]))
print(res)
cat("\nposicion de los BAJA+2 en el ranking (cuantiles):\n")
print(quantile(tb[clase_ternaria == "BAJA+2", pos], c(.1, .25, .5, .75, .9)))
fwrite(tb[, list(numero_de_cliente, clase_ternaria, prob, pos)], sub("prediccion_validacion.txt", "validacion_detalle.txt", a[1]), sep = "\t")
cat("\ndetalle cliente por cliente en validacion_detalle.txt\n")
RR
else
  echo "(sin prediccion_validacion.txt)"
fi
echo
echo "===== 10. 202107: GANANCIA DE CADA SEMILLA POR SEPARADO (si la corrida la guardo)"
if [ -f "$BASE/validacion_semillas.txt" ]; then
Rscript - "$BASE/validacion_semillas.txt" <<'RR'
suppressMessages(library(data.table))
options(width = 200)
v <- fread(commandArgs(trailingOnly = TRUE)[1])
cat("ganancia por corte, semillas sueltas (millones):\n")
print(v[, list(media = round(mean(ganancia) / 1e6, 2), desvio = round(sd(ganancia) / 1e6, 2),
               minimo = round(min(ganancia) / 1e6, 2), maximo = round(max(ganancia) / 1e6, 2)), by = envios])
cat("\nAUC y maximo de los cortes, por semilla (millones):\n")
if ("auc" %in% names(v)) print(v[, list(auc = round(auc[1], 4), maximo = round(max(ganancia) / 1e6, 2)), by = semilla]) else print(v[, list(maximo = round(max(ganancia) / 1e6, 2)), by = semilla])
RR
else
  echo "(sin validacion_semillas.txt: la corrida no guardaba la validacion por semilla)"
fi
} 2>&1 | tee "$OUT"

echo
echo "Listo. Resumen guardado en $OUT"
