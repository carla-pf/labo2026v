# Entrega final — Carla Pérez Fernández

| | |
|---|---|
| **Materia** | Laboratorio de Implementación I · 2026 · virtual |
| **Carrera** | Maestría en Ciencia de Datos · Universidad Austral |
| **Docentes** | Gustavo Denicolay y Fernando Arrieta |
| **Competencia** | [labo-1-virtual-2026-analista-jr][kaggle] |
| **Mes de predicción** | 202109 |
| **Fecha de entrega** | 15 de noviembre de 2026 |

> [!IMPORTANT]
> **Envío final:** `KA9085_100_1800.csv` · 1800 estímulos ·
> cuenta principal de Kaggle ([carlaperezfernandez][perfil])
>
> Lo genera la notebook [`cpf_final_analista_jr.ipynb`][notebook],
> incluida en esta carpeta. Verificamos que su ejecución completa
> desde cero reproduce exactamente el archivo enviado:
> md5 `dbfa78781de150967de93c6abc5daae7`
> ([Verificación](#verificación)).

*Escribimos en primera persona del plural. Compartimos el porqué
en [Autoría y uso de IA](#autoría-y-uso-de-ia).*

---

## Contenido

1. [Resumen](#resumen)
2. [Punto de partida](#punto-de-partida)
3. [Qué modificamos y por qué](#qué-modificamos-y-por-qué)
4. [Criterio de decisión](#criterio-de-decisión)
5. [Experimentos Colaborativos](#experimentos-colaborativos)
6. [Más allá del workflow](#más-allá-del-workflow)
7. [Método para definir el corte](#método-para-definir-el-corte)
8. [Cómo reproducir](#cómo-reproducir)
9. [Verificación](#verificación)
10. [Autoría y uso de IA](#autoría-y-uso-de-ia)
11. [Archivos y bitácora](#archivos-y-bitácora)

---

## Resumen

Tomamos como base el workflow Senior de la cátedra ([z739][z739]),
adaptado al dataset Junior, y utilizamos los
[hiperparámetros inesperados](#punto-de-partida) y un semillerío
de 100 semillas.

Definimos de antemano un
[criterio para incorporar modificaciones](#criterio-de-decisión):
alcanzar una probabilidad de mejora de al menos 0,90 en la
validación con tres meses (202107, 202105 y 202103), estimada
mediante remuestreo de semillas y clientes.

Dentro del workflow, trabajamos sobre los bloques de
Catastrophe Analysis, data drifting, feature engineering
intrames, histórico y de contexto, meses de entrenamiento
(pandemia), undersampling, canaritos, hiperparámetros y clase.

[Más allá del workflow](#más-allá-del-workflow) y de los
[Experimentos Colaborativos](#experimentos-colaborativos),
probamos la validación con tres meses en lugar de uno,
exploramos la hipótesis electoral y desarrollamos un
[método propio para definir el corte de envíos](#método-para-definir-el-corte).

El modelo final incorpora los hiperparámetros inesperados, el
entrenamiento sin undersampling con `min_data_in_leaf` escalado
a 3555 y un semillerío de 100 semillas. El resto de las etapas
quedó como en el z739: ninguna alternativa cumplió el criterio.

Para definir el corte de 1800 envíos, utilizamos la meseta de
ganancia observada en los meses de validación, expresada en
envíos por BAJA+2, y tres estimaciones de la cantidad de BAJA+2
en 202109. Fijamos este corte antes de conocer el puntaje
público del envío en Kaggle.

El detalle completo de decisiones, corridas y resultados está
en la [bitácora][bitacora].

---

## Punto de partida

Partimos del workflow Senior de la cátedra, [z739][z739]
[🔗 LINKY: archivo exacto en el repo oficial], que adaptamos al
dataset Junior. La adaptación cambió el dataset, la semilla
primigenia (384841), la competencia de Kaggle, los cortes de
envío (los del z739, de 8000 a 12000, son para el dataset
Senior) y los nombres de los archivos.

El workflow de partida incluye variables intrames, lags y
deltas de 1 y 2 meses, tendencia de 6 meses, hojas de Random
Forest como variables, canaritos, undersampling del 20 % de los
CONTINUA, Bayesian Optimization y un semillerío de 10 semillas.
La clase es binaria: BAJA+1 y BAJA+2 cuentan como
positivos.

### Hiperparámetros inesperados

En la [clase 08][libro] (3 de noviembre de 2026), la cátedra
compartió un juego de hiperparámetros para LightGBM que llamó
*inesperados* [🔗 LINKY: captura o mensaje de Zulip], porque van
en contra de lo habitual: pocos árboles con una tasa de
aprendizaje alta, hojas con muchos registros y pocas variables
por árbol.

| Hiperparámetro | Valor |
|---|---|
| Iteraciones | 23 |
| `learning_rate` | 0,34 |
| `num_leaves` | 32 |
| `min_data_in_leaf` | 711 |
| `feature_fraction` | 0,20 |

Los usamos tal como se compartieron. Cuando sacamos el
undersampling, ajustamos `min_data_in_leaf` en proporción (ver
[Qué modificamos y por qué](#qué-modificamos-y-por-qué)).

### Semillerío

Empezamos con 30 semillas por corrida, el mínimo que fijamos a
partir de la clase 08. Después lo llevamos a 100; explicamos por
qué en [Qué modificamos y por qué](#qué-modificamos-y-por-qué).

---

## Qué modificamos y por qué

Todas las P de esta sección salen del remuestreo de semillas y
clientes (ver [Criterio de decisión](#criterio-de-decisión)).
Cada P dice de qué lado está. Cuando una comparación se hizo
solo en 202107, o en otro contexto, lo aclaramos.

| Etapa | z739 | Esta entrega |
|---|---|---|
| Hiperparámetros | Bayesian Optimization | Inesperados |
| Semillerío | 10 semillas | 100 semillas |
| Undersampling | 20 % de los CONTINUA | Sin undersampling |
| `min_data_in_leaf` | 0 (fijo) | 3555 |
| Validación propia | No tiene | 202107, 202105 y 202103 |
| Corte | 8000 a 12000 | 1800 |

### Hiperparámetros inesperados en lugar de la Bayesian

Las dos primeras corridas (9001 con la Bayesian y 9002 con los
inesperados, 10 semillas) no se distinguieron. 9002 tardó 8
minutos contra 39. Con 30 semillas cada una, el modelo suelto
de la Bayesian ganó en 29 de 30 semillas. Los semilleríos, en
cambio, no se distinguen (solo 202107, con undersampling):

- En la ventana de entonces (1300 a 2200), ganaban los
  inesperados: 94,3 M contra 92,9 M; P 0,289 de que gane la
  Bayesian.
- En la ventana definitiva (1300 a 3500), la Bayesian queda
  arriba: 93,9 M contra 93,2 M; P 0,659 de que gane.

La Bayesian no llegó a 0,90 y tarda cinco veces más. Quedaron
los inesperados.

### Sin undersampling, con `min_data_in_leaf` 3555

Los inesperados se eligieron entrenando con el 20 % de los
CONTINUA. Sin undersampling hay 5 veces más CONTINUA. Un
parámetro que cuenta filas hay que escalarlo: 711 × 5 = 3555.
La pregunta la planteó Silvina Muzio en Zulip, y Gustavo la
propuso como experimento [🔗 LINKY: mensaje de Zulip del 25/10].

- Sin undersampling, la validación entrena igual que el modelo
  final, que ya usaba todos los CONTINUA.
- Contra la versión con undersampling y 711, empate: P 0,442 de
  que gane sin undersampling (9023 contra 9016, solo 202107,
  30 semillas).
- La mitad, 1777, no llegó: P 0,655 de que gane 1777 (9024
  contra 9014, solo 202107, con la pandemia afuera).
- Es la decisión con menos respaldo de la entrega. Quedó porque
  forma parte de la candidata que, desde el 13/11, todo lo demás
  tenía que superar.

### Semillerío de 30 a 100

- 07/11: pasamos de 10 a 30 semillas como mínimo. P de que 30
  le gane a 10: 0,629 (9002 contra 9004, solo 202107, ventana
  de 1300 a 2200).
- 12/11: decidimos que, si la ganancia seguía subiendo de 20 a
  30 semillas, no se había llegado a la meseta. Seguía subiendo:
  de 96,6 a 97,0 M en 9014 y de 97,3 a 97,6 M en 9024. En la
  clase 08 la ganancia se estabilizaba desde unas 60 semillas.
- 13/11: desde ahí, todas las corridas usan 100 semillas. Son
  las mismas 100 en todas, así que cada comparación es pareada.
  Con 100, 9014 dio 96,4 M (9029) contra 97,0 M con 30: parte
  de la diferencia era suerte de las semillas.

### Validación propia y corte

Sumamos una celda que valida el semillerío, como en la clase
08: entrena con los meses previos y mide la ganancia en el mes
de validación, para cada semilla y para el semillerío. Al
principio validamos solo en 202107; desde el 13/11, también en
202105 y 202103 (ver
[Más allá del workflow](#más-allá-del-workflow)).
El corte tiene [su propia sección](#método-para-definir-el-corte).

### Lo que probamos y no entró

Cada variante se comparó contra la candidata principal en los
tres meses, con las mismas 100 semillas. P de que gane la
variante, en la suma de los tres meses:

| Variante | P |
|---|---|
| I3: ratios entre las monetarias | 0,784 |
| Rotas con tendencia en lugar de NA | 0,678 |
| IPC + rank de las monetarias | 0,545 |
| V5: clase intermedia | 0,432 |
| H1: valor sobre su promedio | 0,38 |
| Peso electoral | 0,296 |
| Sin `internet` | 0,25 |
| V2: sin canaritos | 0,216 |
| I2: COVID | 0,178 |
| Dólar blue en lugar de IPC | 0,115 |
| V3: otros hiperparámetros | 0,111 |
| Pandemia amplia afuera | 0,049 |
| V1: sin campos clave | 0,009 |
| V4: clase ingenua | 0,007 |

- Rotas: la regla escrita el 13/11 decía que, si seguían
  empatadas, quedaba la más simple (NA). La tendencia tenía que
  ganar con P ≥ 0,90 para quedarse. No llegó, y volvimos a NA,
  como en el z739.
- V4: solo BAJA+2 positivo. V5: BAJA+1 positivo con peso 0,5.
- Limitación: las variantes se compararon contra la candidata
  con las rotas reconstruidas con tendencia, antes de volver a
  NA. Entre las dos versiones cambian solo 29 combinaciones
  variable-mes, pero no lo volvimos a probar.
- Quedaron afuera en 202107, sin confirmar en otros meses: lags
  de 3, 6 y 12 (0,384), ventanas de 3, 6 y 12 (0,505) y 15
  variables de negocio (0,423).

### Una corrección de código

El selector del drifting llamaba a `drift_dolarblue` y
`drift_dolaroficial`, que no existen: las funciones son
`drift_dolar_blue` y `drift_dolar_oficial`. Lo corregimos. Con
IPC esas ramas no se ejecutan, así que no cambia el resultado.

---

## Criterio de decisión

Lo que se sube es el semillerío, así que comparamos semillerío
contra semillerío, no semillas sueltas.

- **Medida:** la ganancia del semillerío, promediada en los
  cortes de 1300 a 3500 envíos de a 100, en cada mes.
- **Remuestreo:** 1000 veces rearmamos los dos semilleríos,
  sorteando semillas con reposición (las mismas para los dos), y
  sorteamos los clientes del mes con reposición (los mismos para
  los dos).
- **P de los tres meses:** sumamos las diferencias de 202107,
  202105 y 202103. La P es la proporción de sorteos en que gana
  la variante.
- **Regla:** la variante reemplaza a la que está si su P de los
  tres meses es de 0,90 o más. Si no, queda la que está. Si
  empatan, la más simple.
- **Alerta:** marcamos el mes en que una opción pierde con P
  menor que 0,30.

**Cuándo lo fijamos.** El umbral de 0,90 lo propusimos el 08/11
y lo confirmamos el 12/11. La ventana de cortes, el 12/11. Los
tres meses de validación y su ventana, el 13/11, antes de
correrlos. Desde el 13/11 decidimos con la P de los tres meses.
Ese cambio recién quedó registrado como decisión el 15/11 a las
11:52, antes de las últimas comparaciones.

**Por qué remuestreamos también clientes.** En 202107 un BAJA+2
vale 975 mil. Una diferencia de 1 M entre dos corridas es un
cliente, y otro mes, con otros clientes, podría darla vuelta.

**Wilcoxon, probado y descartado.** El 07/11 comparábamos
semilla por semilla con Wilcoxon pareado. El 08/11 lo
reemplazamos. 9005 (Bayesian) le ganaba a 9004 (inesperados) en
29 de 30 semillas (p = 0,00000001), pero el semillerío de 9004
ganaba: 94,3 M contra 92,9 M, en la ventana de entonces (1300 a
2200). Wilcoxon mide el modelo suelto, no el semillerío.

**Explorar no es decidir** ([Ioannidis, 2005][ioannidis]). Con
unas 30 comparaciones, por azar unas 3 pasarían la regla en un
solo mes. Lo que sale de explorar es una hipótesis. Se confirma
con evidencia que no se usó para encontrarlo: otro mes.

**El Public no decide.** En la clase 08, la ganancia en
validación, en el Public y en el Private resultaron
independientes entre sí. Lo registramos, pero no elegimos con
él.

---

## Experimentos Colaborativos

Leímos las Recomendaciones Concretas de los
[Experimentos Colaborativos][expcol] y probamos las que tocaban
nuestro pipeline.

**ExpCol 05, Grupo A: pandemia afuera.** Saca 202003 a 202010
del entrenamiento y pone en NA los lags que miran esos meses.
En 202107 le ganó a nuestra referencia: P 0,933 (9014 contra
9004, 30 semillas). Fue nuestra candidata 1. En los otros dos
meses perdió: P 0,017 en 202105 y 0,196 en 202103 contra la
referencia. Contra la candidata principal, P 0,049 en los tres
meses. Con la pandemia afuera quedan pocos meses recientes para
entrenar. La versión restringida (202003 a 202007) tampoco
ganó.

**ExpCol 05: lags de 3, 6 y 12.** El experimento encontró que
perdían contra lags de 1 y 2. Los volvimos a probar, porque
nuestro pipeline cambió (canaritos, medición, semillas). P 0,384
en 202107: no siguió.

**Problema #01, Grupo B: interpolar las rotas.** Promedia el mes
anterior y el siguiente de cada cliente. Con la pandemia adentro
y undersampling: P 0,63 (9015 contra 9004). Con la pandemia
afuera: P 0,213 (9017 contra 9014). Probamos también tendencia y
MICE. Quedó NA.

**Problema #07, Grupo A: entrenar solo con 2021.** Desde 202101
perdió 10,2 M y desde 202103, 12,4 M contra la referencia, en
202107. Con el dataset Junior quedan muy pocos meses.

**ExpCol 16, Grupo B: sin campos clave.** Saca
`numero_de_cliente` y `foto_mes` del modelo. En su pipeline dio
+3,35 M. En el nuestro, P 0,009: perdió 6,3 M en 202105.

**ExpCol 10, Grupo B: otros hiperparámetros.** 256 iteraciones,
64 hojas, `min_data_in_leaf` 2048. P 0,111: perdió 4,5 M en
202107 y ganó en 202105 sin llegar (0,873).

**ExpCol 7, Grupo B.** Encontró que dar más peso a meses viejos
empeora. Lo tomamos como antecedente en contra de la hipótesis
electoral.

**ExpCol 13, Grupo A.** Su `neg_bagging_fraction` de 0,25 quedó
en la lista, pero no llegamos a probarlo.

---

## Más allá del workflow

### Validación con tres meses

Hasta el 12/11 decidíamos con un solo mes, 202107. Sumar
semillas achica solo la parte de semillas del remuestreo. La de
clientes no baja: hace falta otro mes, con otros clientes.

Elegimos 202105 y 202103. Son de 2021, como 202109. Cada uno
entrena hasta dos meses antes, como 202107: es el hueco que hay
al predecir 202109. Y tienen menos BAJA+2 (180 y 176, contra
244), así que prueban las variantes con otra cantidad de bajas.
202106 estaba demasiado pegado a 202107. 202103 es el más débil
de los tres: entrena con menos meses.

Fue la decisión que más cambió el resultado. 202107 tiene la
tasa de BAJA+2 más alta de la serie (0,741 %). Cinco cambios
pasaron la regla en 202107 y perdieron en 202105: pandemia
afuera, dólar blue, sin `internet`, H1 y peso electoral. Un
sexto, el promedio de las dos candidatas, también ganó solo en
202107. Con un solo mes, alguno habría entrado.

### Hipótesis electoral

La clase de 202109 es BAJA+2: el cliente se va en noviembre de
2021. Cae en un contexto electoral y cambiario: elecciones
legislativas de medio término, con PASO el 12/9 y generales en
noviembre. El dataset tiene un solo período electoral: el de
2019, que fue presidencial (PASO el 11/8, cepo en septiembre,
generales en octubre).

Con la tabla de 2019, la señal no fue clara: la tasa de BAJA+2
bajó en las PASO (−28 % en 201908) y subió en 201910 y 201911.
Lo exploramos igual, con peso 3 en las filas de 201908 a 201911.
Es una dosis alta, elegida a propósito para buscar una señal:
ningún mes de validación tiene contexto electoral, así que el 3
no se puede calibrar.

- Sobre la candidata 1: P 0,638 de que gane el peso electoral
  (9027 contra 9029, 202107).
- Sobre la candidata principal: P 0,940 en 202107, pero 0,001 en
  202105 y 0,522 en 202103. P de los tres meses: 0,296.

No entró. Limitaciones: hay un solo período electoral; sacar
plata no es cerrar la cuenta; y el dataset Junior no tiene
saldos en dólares ni plazos fijos.

### Verificación de reproducibilidad

Corrimos la notebook de la entrega desde cero y comparamos cada
archivo de Kaggle con md5 (ver [Verificación](#verificación)).

---

## Método para definir el corte

Dejar afuera un BAJA+2 cuesta 0,975 M. Mandar un estímulo de más
cuesta 0,025 M. Por eso buscamos un corte en la meseta, donde
pasarse un poco cuesta poco.

**1. Meseta en envíos por BAJA+2.** Meseta: los cortes cuya
ganancia, suavizada con la media de 5 cortes, queda a 1 M o
menos del máximo. Los meses tienen distinta cantidad de BAJA+2,
así que la medimos en envíos por BAJA+2.

| Mes | Meseta (envíos) | Por BAJA+2 |
|---|---|---|
| 202107 | 1600 a 2000 | 6,6 a 8,2 |
| 202105 | 1400 a 2400 | 7,8 a 13,3 |
| 202103 | 800 a 1200 | 4,5 a 6,8 |

Son las corridas 9085, 9086 y 9087: el modelo final en cada mes.

**2. Tres estimaciones de BAJA+2 en 202109** (33.080 clientes):

| Estimación | BAJA+2 |
|---|---|
| Tasa de 2021 | 204 |
| Tasa de los últimos tres meses | 216 |
| Probabilidades del modelo | 238 |

- Tasa de 2021: 1.411 BAJA+2 sobre 228.624 clientes (0,617 %).
- Últimos tres meses con clase: 644 sobre 98.616 (0,653 %).
- Probabilidades: la suma en 202109 (417,5), calibrada con
  202107. Con la versión anterior del modelo daba 242, y las
  columnas de la tabla de pérdida se calcularon con 242.

**3. Pérdida por corte.** Para cada corte y cada estimación,
pasamos el corte a envíos por BAJA+2. Leímos cuánto se habría
perdido en cada mes contra su máximo. Promediamos de dos
maneras: los tres meses, y solo 202107 y 202105 (202103 es el
más débil). Con tres estimaciones, son seis pérdidas por corte.

| Corte | Suma de las seis (M) | Peor caso (M) |
|---|---|---|
| 1500 | −8,9 | −2,7 |
| 1600 | −6,6 | −1,7 |
| 1700 | −5,5 | −1,2 |
| 1800 | −5,6 | −1,1 |
| 1900 | −6,5 | −1,5 |
| 2000 | −7,9 | −1,6 |
| 2100 | −8,3 | −1,7 |
| 2200 | −9,6 | −2,1 |
| 2300 | −10,2 | −2,2 |
| 2400 | −10,7 | −2,5 |
| 2500 | −11,6 | −3,0 |
| 2600 | −13,8 | −3,6 |
| 2700 | −15,7 | −4,2 |

- El mejor corte según cada estimación: 1600 (204), 1700 (216)
  y 1900 (242).
- 1800 tiene el peor caso más bajo y la segunda suma más baja.

**4. Decisión.** Elegimos 1800 el 15/11 a las 15:58, antes de
conocer su Public. Lo subimos y lo marcamos como envío final a
las 16:14.

**El Public, solo como registro.** Cortes de 9085 subidos con la
cuenta secundaria, que usamos para explorar:

| Corte | Public |
|---|---|
| 1500 | 90,9 |
| 1700 | 92,0 |
| 1900 | 97,1 |
| 2100 | 92,5 |
| 2300 | 87,6 |
| 2500 | 86,8 |
| 2700 | 81,8 |
| 2900 | 77,3 |

El Public del envío final (1800) es 92,627.

---

## Cómo reproducir

**Entorno:**

- VM de la materia en Google Cloud: 8 vCPU AMD EPYC 7B12, 60 GB
  de memoria.
- Kernel `ir`: R 4.6.1, lightgbm 4.7.0.99, data.table 1.18.6.1.
  La notebook instala los paquetes que falten (`R.utils`,
  `mice`, `lubridate`, `Rcpp`, `DiceKriging`, `mlrMBO`,
  `primes`, `yaml`).
- Dataset original, sin cambios:
  `/content/datasets/analistajr_competencia_2026.csv.gz`
  (90.547.491 bytes, md5 `10dd4969dd7d7cf746ce1331bfd22276`).
- Tiempo: unos 13 minutos.

**Pasos:**

1. Copiar `cpf_final_analista_jr.ipynb` a la VM.
2. Correrla de punta a punta, desde la carpeta donde está:

```bash
jupyter nbconvert --to notebook --execute \
  --ExecutePreprocessor.kernel_name=ir \
  --ExecutePreprocessor.timeout=-1 \
  --output-dir=/content/buckets/b1/exp/WF9088 \
  --output=corrida_9088.ipynb \
  cpf_final_analista_jr.ipynb
```

3. La notebook crea `/content/buckets/b1/exp/WF9088/` y deja un
   CSV por corte, de 1500 a 2700 de a 100, en `kaggle/`.
4. El envío final es el corte 1800:

```bash
md5sum \
  /content/buckets/b1/exp/WF9088/kaggle/KA9088_100_1800.csv
# dbfa78781de150967de93c6abc5daae7
```

- El número de experimento es 9088. Es la configuración de 9085
  con otro número, para no pisar su carpeta. El número cambia el
  nombre del archivo, no su contenido.
- La subida a Kaggle está desactivada
  (`PARAM$kaggle$subir <- FALSE`). Con `TRUE`, sube los CSV; si
  falla, avisa y la notebook sigue.
- La notebook deja además las probabilidades por semilla
  (`prediccion.txt`), la validación en 202107, `PARAM.yml`,
  `canaritos.txt` e `impo.txt`.

---

## Verificación

El 15/11 corrimos esta misma notebook desde cero, desde el
dataset original, como experimento 9088. Comparamos cada CSV
con el generado desde la predicción guardada de 9085, la corrida
de la que salió el envío final. Los 13 archivos dan el mismo
md5:

| Corte | md5 (9085 = 9088) |
|---|---|
| 1500 | `804ac586a03eb2ada2b5cf500a3d5e0d` |
| 1600 | `8643015d8560ca68e4aadf088db1f49f` |
| 1700 | `bc300bd24078365a61797316a0985693` |
| **1800** | **`dbfa78781de150967de93c6abc5daae7`** |
| 1900 | `699744c75c625ff22cf38050030044ca` |
| 2000 | `3644fa2ac980e37d34201036b26e7223` |
| 2100 | `137c6ef24692ec5a1a60f595b6f5adc7` |
| 2200 | `786fdbb38a12e3b81fefbe4988df7341` |
| 2300 | `5e2f098009280fdeff252418f2dbc489` |
| 2400 | `6b223d9a0f510cc7862830568fcf448a` |
| 2500 | `278cebce6307e0969ddce44acf3fa1d2` |
| 2600 | `2e85d5e0aed9c21741e82e93cf92ee9d` |
| 2700 | `b8d1639072a10ec469f90208d43c2042` |

**Criterio.** Mismo orden de clientes, mismos elegidos, misma
ganancia y mismo md5 de cada CSV. Las probabilidades difieren a
partir del decimal 12 (hasta 1,1e-12). LightGBM suma en
paralelo, y la suma en punto flotante no es exactamente
asociativa. Esa diferencia no cambia ningún elegido.

**Antecedentes.** El 13/11 corrimos otra configuración (9029)
en dos VM con el mismo procesador: mismos elegidos y mismo md5
de los archivos de Kaggle. El 15/11 verificamos también la
versión anterior, con las rotas reconstruidas con tendencia
(9084 contra 9031): 9 md5 iguales.

---

## Autoría y uso de IA

Escribimos en primera persona del plural. Las decisiones y su
ejecución son mías, pero ningún saber es estrictamente propio:
este trabajo recoge el workflow y las enseñanzas de la cátedra,
los Experimentos Colaborativos de compañeras y compañeros, y las
decisiones que otras personas han tomado antes. A todas ellas,
gracias.

Usamos asistentes de IA de Anthropic:

- **Claude** (claude.ai): discusión del diseño experimental,
  revisión crítica de la lectura de resultados, búsqueda de
  literatura y revisión de la redacción.
- **Claude Code**: escritura y ejecución de código y scripts en
  las máquinas virtuales, control de versiones y registro en la
  bitácora.

Todas las decisiones las tomé yo, con criterios fijados antes de
ver los resultados, y quedaron registradas con fecha en la
bitácora. El entorno de trabajo con Claude Code está documentado
en [`CLAUDE.md`][claudemd].

---

## Archivos y bitácora

| Archivo | Qué es |
|---|---|
| [`cpf_final_analista_jr.ipynb`][notebook] | Genera los CSV |
| `PARAM.yml` | Parámetros de la corrida 9088 |
| `README.md` | Este archivo |

- La notebook es la de 9085 con cuatro cambios: el número de
  experimento (9088), el selector del drifting corregido, los
  cortes (1500 a 2700) y la subida a Kaggle desactivada.
- `PARAM.yml` es el que grabó la verificación (md5
  `aeed581972db389bed3dcf9f12b2aa68`).

La [bitácora][bitacora] tiene todo lo demás: las decisiones con
fecha, hora y porqué, el catálogo de cambios, la tabla de todas
las corridas, la lectura de cada bloque y los scripts de
comparación [🔗 LINKY: carpeta de scripts en el fork].

[kaggle]: https://www.kaggle.com/competitions/labo-1-virtual-2026-analista-jr
[perfil]: https://www.kaggle.com/carlaperezfernandez
[notebook]: cpf_final_analista_jr.ipynb
[libro]: https://storage.googleapis.com/open-courses/austral2026-5da5/labo1-virtual/Austral_labo2026-VIRTUAL.pdf
[expcol]: https://docs.google.com/presentation/d/13GXCXtlAEPEpR4z4gyxc06exZnh06w_IEbt8dPjA2sY/edit?usp=sharing
[repo-catedra]: https://github.com/labo-imp/labo2026v
[ioannidis]: https://doi.org/10.1371/journal.pmed.0020124
[z739]: LINKY
[bitacora]: LINKY
[claudemd]: LINKY
