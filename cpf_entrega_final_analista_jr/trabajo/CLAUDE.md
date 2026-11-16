# Contexto para Claude Code: modelo final de Carla (LI1, MCD Austral 2026)

Este repo es la solución final de Carla Pérez Fernández para la competencia Kaggle `labo-1-virtual-2026-analista-jr` (Laboratorio de Implementación I, Analista Jr, future 202109). La final es individual.

Leer antes de hacer nada: `README.md` (archivos y cómo se usan) y `BITACORA.md` (requisitos, regla de comparación, decisiones con fecha y porqué, catálogo de cambios, tabla de corridas, lecturas, ideas y pendientes).

## Trazabilidad de las candidatas (13/11)

Etiquetas fijas: **PA-afuera** (pandemia amplia afuera: 202003 a 202010 fuera del entrenamiento y los lags que la miran en NA), **PR-afuera** (pandemia restringida afuera: 202003 a 202007) y **P-adentro**. Nunca "pandemia afuera" a secas.

| Rol | Corrida | Qué es |
|---|---|---|
| Referencia | 9030 | 9004 con 100 semillas: P-adentro, rotas en NA, con undersampling (20 % de CONTINUA), `min_data_in_leaf` 711 |
| Candidata 1 | 9029 | 9014 con 100 semillas: PA-afuera, rotas en NA, sin undersampling, `min_data_in_leaf` 3555 |
| Candidata 2 | 9031 | 9023 con 100 semillas: P-adentro, rotas corregidas con tendencia, sin undersampling, `min_data_in_leaf` 3555 |

**Desde el 13/11 a la tarde: la candidata 2 (9031) es la principal y la candidata 1 (9029) queda como alternativa, sin sumarle cambios** (ver Decisiones del 13/11).

En las dos tablas que siguen, la P es la probabilidad de que gane **lo elegido**, en "semillas y clientes", en 202107, con la ventana 1300 a 3500, salvo que se aclare otra cosa. Cuando el contexto de la comparación no es el de la candidata (por ejemplo, con undersampling), se dice.

**Candidata 1 (9029): PA-afuera, rotas en NA, sin undersampling**

| Característica | Lo elegido | Contra qué se probó |
|---|---|---|
| Semillas | 100 | 10 semillas: P 0,629 de que 30 le gane a 10 (9002 contra 9004, con la ventana vieja 1300 a 2200). 30 semillas: 97,0 (9014) contra 96,4 con 100 (9029), sin P. |
| Hiperparámetros | inesperados | Bayesiana (9005 contra 9004): 0,341. Contexto: P-adentro, con undersampling. |
| `min_data_in_leaf` | 3555 (711 × 5, escalado al sacar el undersampling) | 1777 (9024 contra 9014): 0,345. Con undersampling y P-adentro, 355 (9006) le ganó a 711 con P 0,912 (pasó la regla), y 1777 es la versión escalada de 355 (355 × 5). 1422 (9007 contra 9004): 0,348, con undersampling. Es la característica menos respaldada. |
| Pandemia | PA-afuera | P-adentro: 0,876 sin undersampling (9013 contra 9014) y 0,882 con undersampling (9004 contra 9008). PR-afuera: 0,763 con undersampling (9008 contra 9011). Contra 9004 (P-adentro, con undersampling): PR-afuera (9011, P 0,722 de que gane 9011), solo 2021 (9010: −10,2 M), desde 202103 (9012: −12,4 M) y PA-afuera con tendencia (9009, P 0,695 de que gane 9009). |
| Rotas | NA | Interpolar (9017 contra 9014): 0,787. Tendencia (9018 contra 9014): 0,814. MICE no se probó con PA-afuera. |
| Undersampling | sin, con `min_data_in_leaf` escalado | Con 20 % de CONTINUA (9008 contra 9014): 0,743. |
| `internet` | tal cual | Sin `internet` (9025, 30 semillas): pendiente; 98,9 contra 97,0 de 9014, sin P. |
| Drifting | IPC | Bloque de drifting del 13/11 (9036 a 9039 y desempates 9040 a 9043). |

**Candidata 2 (9031): P-adentro, rotas corregidas con tendencia, sin undersampling**

| Característica | Lo elegido | Contra qué se probó |
|---|---|---|
| Semillas | 100 | 30 semillas: 94,7 (9023) contra 95,0 con 100 (9031), sin P. |
| Pandemia | P-adentro | PA-afuera (9014 contra 9023): 0,196, pierde en 202107. Sin remuestreo, se da vuelta en 202105 (53,1 contra 47,8) y en 202103 (40,7 contra 39,0), con 100 semillas. |
| Rotas | tendencia | NA sin undersampling: **empate** (9013 contra 9023, P 0,566). El 0,803 (9004 contra 9016) era con undersampling, igual que interpolar (9015 contra 9016: 0,837), MICE CART (9021: 0,564) y MICE PMM (9022: 0,780). Si las dos siguen empatadas al final, gana la más simple (NA). |
| Undersampling | sin, con `min_data_in_leaf` escalado | Con 20 % de CONTINUA (9016 contra 9023): 0,442, empate. Compara "sin + 3555" contra "con + 711". |
| `min_data_in_leaf` | 3555 | No se probó con P-adentro sin undersampling. Con P-adentro y con undersampling, 355 (9006) le ganó a 711 con P 0,912. |
| `internet` | tal cual | Sin `internet` (9026, 30 semillas): pendiente; 97,1 contra 94,7 de 9023, sin P. |
| Drifting | IPC | Bloque de drifting del 13/11 (9032 a 9035). |

## Fechas
- Dom 15/11 23:58: link a la carpeta de la solución reproducible en Zulip. 23:59: cierra Kaggle; el envío final se marca a mano en la cuenta CF (solo esa cuenta cuenta para la nota).
- El cupo de Kaggle (100 por cuenta) se renueva todos los días a las 21:00 (hora de Argentina).
- Política de cupo (13/11): el cupo de CF del domingo (se renueva el sábado a las 21:00) se reserva para el armado final. Hasta entonces, en CF solo lo que puede ser candidato; todo lo exploratorio va a MCD (solo está en la jr). Domingo: decisión a las 18:00 con la tabla de la bitácora, todo subido y marcado en CF a las 20:00. La renovación del domingo a las 21:00 es solo un colchón para algo excepcional; si no, entre las 21:00 y las 23:58 solo se pone el link en Zulip.

## Dónde está cada cosa (VM)
- Repo: `~/buckets/b1/labo2026v-modelo-final` (en el bucket, compartido entre las VM jr y jr2).
- Corridas: `~/buckets/b1/exp/WF<exp>/` (predicción, validación, resumen, kaggle/). Comparaciones: `~/buckets/b1/exp/comparaciones/` (`envios_kaggle.txt` es el registro acumulado del Public: no moverlo). Las comparaciones que Carla ya bajó las mueve ella a `comparaciones/descargados/`: buscarlas ahí también. `envios_kaggle.txt` y `clase_202107.txt` están siempre en `comparaciones/` y nunca se mueven a `descargados/`, porque los scripts los buscan ahí.
- Dataset: `/content/datasets/analistajr_competencia_2026.csv.gz`.
- Notebooks de la cátedra (originales, solo lectura): `~/buckets/b1/labo2026v/PredFinal/` (z729 Junior, z739 Senior, z719 Gerencial).
- Kaggle: cuenta principal CF (`carlaperezfernandez`, en `~/.kaggle`); segunda cuenta MCD (`carlapf`, en `~/.kaggle2`, configurada en la jr). La nota sale solo de CF; MCD es para explorar.

## Entorno de reproducción
- VM de Google Cloud con 8 vCPU (AMD EPYC 7B12) y 60 GB de memoria; dos VM iguales, jr y jr2, que comparten el bucket `b1`.
- R 4.6.1, lightgbm 4.7.0.99, data.table 1.18.6.1. Las notebooks corren con el kernel `ir` de Jupyter (`~/.venv/bin/jupyter`).
- Dataset: `/content/datasets/analistajr_competencia_2026.csv.gz` (90.547.491 bytes, md5 10dd4969dd7d7cf746ce1331bfd22276).
- Todo comando empieza con `cd ~/buckets/b1/labo2026v-modelo-final`. Lo que queda corriendo va con `nohup bash -c 'cd ~/buckets/b1/labo2026v-modelo-final && ...' > ~/log.log 2>&1 &`.
- Las VM se nombran jr y jr2, sin IP (las IP son temporales).

## Referencia y candidatas por etapa (13/11)
De acá en adelante, todo se compara con 100 semillas.

| Etapa | Mes de validación | Referencia (9004) | Candidata pandemia afuera (9014) | Candidata pandemia adentro, tendencia (9023) |
|---|---|---|---|---|
| 30 semillas | 202107 | 9004 | 9014 | 9023 |
| 100 semillas | 202107 | 9030 | 9029 | 9031 |
| 100 semillas | 202105 | 9104 | 9114 | 9123 |
| 100 semillas | 202103 | 9204 | 9214 | 9223 |

## Cómo se decide (resumen; el detalle está en la bitácora)
- Se compara semillerío contra semillerío con `comparar_corridas.sh A B` (remuestreo de semillas y clientes de 202107). Regla: B reemplaza a A si P(B gana) >= 0,90 en "semillas y clientes". Ventana de cortes para resumir en 202107: 1300 a 3500 (las dos definitivas desde el 12/11). Con unas 30 comparaciones, por azar pasarían unas 3: lo que pasa la regla es candidato a confirmar. La ventana de un mes de validación nuevo se define antes de correrlo.
- El Public de Kaggle se registra pero no decide. El corte final sale de la meseta de validación, no del pico del Public.
- Explorar y decidir son cosas distintas (Ioannidis 2005): lo que sale de explorar es hipótesis; confirmar con evidencia nueva (otras semillas, otro mes).
- Bloques del workflow en orden (CA, drifting, FE, pandemia/meses, RF, canaritos, undersampling, hiperparámetros, semillerío, corte). Si dos opciones empatan, siguen las dos; cruces 2 × 2 solo donde hay un mecanismo de interacción.

## Herramientas del repo
- Correr una notebook: `~/.venv/bin/jupyter nbconvert --to notebook --execute --ExecutePreprocessor.kernel_name=ir --ExecutePreprocessor.timeout=-1 --output-dir=$HOME/buckets/b1/exp/WF<exp> --output=corrida_<exp>.ipynb <exp>_739_final_senior.ipynb`. Las notebooks nuevas no suben a Kaggle solas (`PARAM$kaggle$cortes <- c()`).
- `enviar_cortes.sh <exp> <desde> <hasta> <paso>`: sube cortes desde la predicción guardada (CF; si se agota, sigue con MCD). Hoy se suben 8 cortes por corrida exploratoria: 1500 a 2900 de a 200.
- `resumen_corrida.sh <exp>`: resumen con sección 0 de controles ([OK]/[REVISAR]).
- `comparar_corridas.sh <A> <B> [desde hasta]`: comparación con remuestreo.
- `mirar.sh <exp> ...`: mirada rápida (AUC, ganancia 1300-3500, meseta), sin remuestreo.

## Estado al 12/11 (noche)
- Referencia: 9004. Dos candidatas, sin elegir todavía; los cambios futuros se prueban contra las dos:
  - pandemia afuera (amplia, ExpCol 05 A), rotas en NA, sin undersampling: 9014 (P 0,933 contra 9004; a confirmar).
  - pandemia adentro, rotas corregidas con tendencia, sin undersampling: 9023. Empata con 9016 (P 0,442) y pierde con 9014 sin llegar a la regla (P 0,196). Falta que Carla confirme 9023 o 9016.
- Bloque Catastrophe Analysis: MICE descartado (12/11); con la pandemia adentro, tendencia. Falta `internet`: sacarla o NA desde 202010.
- 9024 (9014 con `min_data_in_leaf` 1777): P 0,655 contra 9014, no llega.
- 13/11: 9014 con 100 semillas en las dos VM para comparar el md5 (reproducibilidad del pipeline). Sábado 14/11: candidato definitivo. Validación en otros meses con 100 semillas y la ventana definida antes (ver la evolución de la clase en la bitácora).
