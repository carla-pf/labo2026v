# Modelo final · Analista Jr

Laboratorio de Implementación I, MCD Universidad Austral, cohorte virtual 2026. Competencia Kaggle `labo-1-virtual-2026-analista-jr`, se predice `future = 202109`.

Este es el repositorio de trabajo: todas las corridas, los scripts de comparación y la bitácora con que se llegó a la solución final. Parte de una copia sin cambios del notebook de la cátedra (`PredFinal/z739_final_senior.ipynb` de `labo-imp/labo2026v`), y el historial de commits muestra qué se cambió y por qué, paso a paso.

## Dónde está cada cosa

| Para | Ir a |
|---|---|
| Reproducir la entrega final (notebook, entorno, comando y md5 del archivo subido a Kaggle) | [README de la entrega](https://github.com/carla-pf/labo2026v/tree/main/cpf_entrega_final_analista_jr) |
| Las corridas: qué tiene cada una, contra qué se comparó, mes de validación, ganancia y Public | [BITACORA.md](BITACORA.md), tabla "Corridas" y las lecturas de cada tanda |
| Las decisiones, con fecha, hora y porqué | [BITACORA.md](BITACORA.md), tabla "Decisiones" |
| Cómo se comparan dos corridas y cuándo una reemplaza a otra | [BITACORA.md](BITACORA.md), "Cómo se comparan las corridas" |

La entrega final es la candidata 9085: pandemia adentro, rotas en NA, sin undersampling, `min_data_in_leaf` 3555, drifting por IPC, hiperparámetros inesperados, 100 semillas y corte 1800 (`KA9085_100_1800.csv`). La notebook de la entrega se volvió a correr desde cero como 9088 y dio los mismos archivos de Kaggle, con el mismo md5 (ver "Reproducibilidad de la entrega" en la bitácora).

## Archivos

| Archivo | Qué es |
|---|---|
| `9001_739_final_senior.ipynb` a `9087_739_final_senior.ipynb` | Una notebook por corrida, todas derivadas del z739 Senior adaptado al dataset Jr. No hay 9028; 9084 y 9088 son las re-corridas de la notebook de la entrega |
| `9104`, `9114`, `9123` (`_739_final_senior.ipynb`) | Referencia, candidata 1 y candidata 2 validadas en 202105 |
| `9204`, `9214`, `9223` (`_739_final_senior.ipynb`) | Referencia, candidata 1 y candidata 2 validadas en 202103 |
| `9068_728_final_junior_power.ipynb` | El z728 Junior Power de la cátedra, corrido tal cual como 9068 |
| `cpf_final_analista_jr_tendencia_9084.ipynb`, `_PARAM.yml`, `_md5.txt` | Respaldo de la notebook de la entrega en su versión con las rotas por tendencia (antes del cambio a NA del 15/11), su `PARAM.yml` y los md5 de la verificación 9031 contra 9084 |
| `resumen_corrida.sh` | Resumen de una corrida terminada, con una sección de controles que marca [OK] o [REVISAR] |
| `comparar_corridas.sh` | Compara dos corridas en un mes: remuestreo de semillas y clientes (P del mes), curva de cortes, curva de semillas y Public |
| `comparar_tres_meses.sh` | P de los tres meses: probabilidad de que B le gane a A en la suma de 202107, 202105 y 202103, remuestreando dentro de cada mes |
| `mirar.sh` | Mirada rápida a varias corridas (AUC, ganancia 1300 a 3500, meseta), sin remuestreo: no decide |
| `diagnostico_semillas.sh` | ANOVA de la ganancia por configuración y semilla, para ver cuánto pesa el azar de cada modelo |
| `enviar_cortes.sh` | Sube a Kaggle cortes nuevos de una corrida terminada desde su `prediccion.txt`, sin volver a entrenar |
| `correr_por_semilla.sh` | Semillerío en modo por semilla: cada semilla es una corrida completa de la notebook |
| `lanzar_9027.sh`, `lanzar_cola.sh` a `lanzar_cola8.sh`, `lanzar_z728.sh` | Scripts que lanzaron cada tanda de corridas en las VM, con sus controles previos |
| `lanzar_repro.sh`, `verificar_repro.sh` | Re-corrida de la notebook de la entrega y comparación con la corrida original, corte por corte, por md5 |
| `prueba_enmascarado.R`, `verificaciones/` | Prueba de enmascarado del Catastrophe Analysis (11/11) y sus resultados |
| `covid_mensual.R` | Serie mensual de COVID para la variable de contexto I2 (13/11) |
| `BITACORA.md` | Requisitos, criterios, decisiones, catálogo de cambios, corridas, lecturas, ideas y pendientes |
| `CLAUDE.md` | Contexto del entorno para Claude Code: rutas, cuentas de Kaggle, herramientas y cómo se decide |

## Nombres

- **Código de corrida:** `9` (predicción final, como numera la cátedra) + número correlativo. Las corridas validadas en 202105 y 202103 llevan 91XX y 92XX. El código no describe qué se tocó; eso está en la tabla de corridas de la bitácora.
- **Notebook:** `<código>_<notebook de la cátedra sin la z>.ipynb`, por ejemplo `9001_739_final_senior.ipynb`.
- **Salidas:** `~/buckets/b1/exp/WF<código>/` (modelos, `prediccion.txt`, `prediccion_validacion.txt`, `PARAM.yml`, carpeta `kaggle/`). Comparaciones: `~/buckets/b1/exp/comparaciones/`.
- **Archivos para Kaggle:** `KA<código>_<cantidad de semillas>_<corte>.csv`, por ejemplo `KA9085_100_1800.csv`. Descripción del envío: `exp=<código> semillas=<cantidad> envios=<corte>`.

## Cómo correr una corrida

```bash
cd ~/buckets/b1/labo2026v-modelo-final
mkdir -p ~/buckets/b1/exp/WF9085
nohup ~/.venv/bin/jupyter nbconvert --to notebook --execute --ExecutePreprocessor.kernel_name=ir --ExecutePreprocessor.timeout=-1 --output-dir=$HOME/buckets/b1/exp/WF9085 --output=corrida_9085.ipynb 9085_739_final_senior.ipynb > ~/log_9085.txt 2>&1 &
```

Después: `bash resumen_corrida.sh 9085` deja el resumen en `WF9085/`; `bash comparar_corridas.sh 9031 9085` compara en 202107 (ventana 1300 a 3500 por defecto; otro mes con `MES=202105 bash comparar_corridas.sh 9123 9086`); `bash comparar_tres_meses.sh 9031 9085 9123 9086 9223 9087` da la P de los tres meses (A y B de 202107, 202105 y 202103). Los archivos que dejan y cómo se leen están en la bitácora.

Para reproducir la entrega final no hace falta nada de esto: alcanza con la notebook de la [carpeta de la entrega](https://github.com/carla-pf/labo2026v/tree/main/cpf_entrega_final_analista_jr), que corre desde el dataset original.
