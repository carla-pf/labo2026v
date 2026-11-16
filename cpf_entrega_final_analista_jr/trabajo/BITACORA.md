# Bitácora del modelo final

**Formato (desde el 11/11):** las ganancias (en millones y en el Public) van con un decimal. Las P y los p se escriben con su valor original, sin redondear (como mínimo dos decimales: 0,93, nunca 0,9). Quedan como están el valor de un BAJA+2, los AUC (cuatro decimales) y los hiperparámetros.

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

## Requisitos de la cátedra (libro de la asignatura y Hoja de Ruta)

- Carpeta creada solo para la entrega, en el repositorio público de la materia, con los scripts y archivos de parámetros que generan **exactamente** el archivo subido a Kaggle a partir del dataset original. Fecha límite: 15/11, 23:58, link en Zulip.
- La nota sale solo del **Private Leaderboard**. El envío final se elige a mano en Kaggle antes del 15/11 a las 23:59:59; si no, Kaggle elige el mejor del Public.
- No alcanza con correr las conclusiones de los experimentos colaborativos: hay que leer la Recomendación Concreta de cada experimento (grupos A y B), decidir cada etapa del workflow y hacer modificaciones sustantivas a la solución oficial.
- Entrenar con la mayor cantidad de meses posible (los experimentos colaborativos usan un subconjunto).

## Criterios de trabajo

- **No elegir por el Public.** En la clase 08, con un modelo fijo y 125 semillas, la ganancia en 5-fold CV, en el Public y en el Private resultaron independientes entre sí: elegir la semilla o el envío por el Public es en buena parte azar. El Public se registra, pero no decide.
- **Comparar con varias semillas y una probabilidad.** Entre modelos distintos sí hay diferencia, pero las nubes de semillas se superponen. Las comparaciones se reportan como "M2 supera a M1 con probabilidad p", no con una corrida de cada uno. Lo que se compara es el **semillerío**, que es lo que se sube (ver "Cómo se comparan las corridas").
- **Semillerío siempre.** Promediar las probabilidades de muchas semillas reduce la variabilidad y además sube la ganancia esperada (en la clase 08, unos 500 mil solo por semillerío).
- **Decidir con validación propia,** no con el Public. Cada corrida calcula AUC y ganancia del semillerío en 202107.
- **Pocos candidatos, decididos de antemano.** Antes de correr una tanda, se decide qué entra y con qué regla se elige. Lo que no está en la lista no se corre.

## Cómo se comparan las corridas

Cada corrida deja, en validación (202107):
- La probabilidad de cada semilla para cada cliente (`prediccion_validacion.txt`). Con eso se puede rearmar cualquier semillerío y cualquier corte sin volver a entrenar.
- AUC y ganancia del semillerío para cada corte de 1300 a 2200 (`validacion_cortes.txt`) y de cada semilla por separado (`validacion_semillas.txt`).
- A quiénes se les mandó el estímulo en cada corte (lo arma `resumen_corrida.sh`).

**Medida:** ganancia del semillerío en 202107, **promediada sobre una ventana de cortes**, de a 100. Es más estable que el máximo, que depende de un solo corte. Hasta el 08/11 la ventana fue 1300 a 2200; desde el 09/11 es **1300 a 3500**, todos los cortes que se suben (decisión provisoria, ver Decisiones).

`comparar_corridas.sh A B` (desde el 08/11) arma, para dos corridas:
1. El semillerío completo: AUC y ganancia por corte.
2. La curva de cortes de 1000 a 5000, cruda y suavizada (promedio de 5 cortes), con la meseta.
3. **El remuestreo:** 1000 veces se rearman los semilleríos de A y de B (sorteando semillas con reposición; las mismas para las dos si comparten semillas) y se sortean los clientes de 202107 con reposición (los mismos para las dos). Sale la probabilidad de que B gane a A y el rango de la diferencia (5 % a 95 %), por semillas, por clientes y por las dos cosas juntas.
4. La curva de semillas: cuánto mejora el semillerío al pasar de 1 a 5, 10, 20, 30 semillas.
5. Semilla por semilla con Wilcoxon pareado, solo como diagnóstico.
6. El Public de todos los cortes subidos.

**Regla (propuesta el 08/11, a confirmar):** B reemplaza a A si la **probabilidad de que B gane, remuestreando semillas y clientes, es de 0,90 o más.** Si no, queda la más simple o la más barata. El Public se registra pero no entra en la regla.

**Por qué cambió la regla (08/11).** La regla del 07/11 comparaba semilla por semilla (Wilcoxon pareado). Con los resultados de 9001 a 9007 se vio que eso mide la calidad del modelo suelto, no la del semillerío:
- 9005 (Bayesian, 30 semillas) gana a 9004 (inesperados, 30 semillas) en 29 de 30 semillas, con p = 0,00000001. Con la regla vieja la reemplazaría. Pero el semillerío de 9004 gana: 94,3 M contra 92,9 M.
- Los modelos de la Bayesian son fuertes y muy parecidos entre sí: el semillerío casi no les suma (+0,5 M). Los de los inesperados son más débiles y distintos entre sí: el semillerío les suma mucho (+7 M). Es lo que mostró la clase 08.
- Lo que se sube a Kaggle es el semillerío, así que la regla tiene que comparar semilleríos.

Se suman los clientes al remuestreo porque, en 202107, un BAJA+2 vale 975 mil: diferencias de 1 M entre corridas son un cliente, y otro mes con otros clientes podría darlas vuelta.

**Explorar y decidir son cosas distintas** (Ioannidis, *Why Most Published Research Findings Are False*, 2005, compartido por Gustavo el 09/11): se explora todo lo que se quiera, pero lo que sale de explorar es una hipótesis. La decisión se toma con la regla fijada antes de mirar, y conviene confirmar con evidencia que no se usó para encontrar el hallazgo (otro mes de validación, semillas nuevas). Con muchas corridas, alguna gana por azar.

**Limitaciones:** un solo mes de validación; y si una corrida eligió sus hiperparámetros mirando 202107 (como la Bayesian Optimization de 9001), su validación sale optimista. Ver pendientes: segundo mes de validación.

### Validación en otros meses (13/11)

Hasta el 12/11 todo se decidió con un solo mes, 202107. Sumar semillas achica solo la parte de semillas del remuestreo; la parte de clientes no baja (ver "Cuánto podemos detectar"): hace falta otro mes, con otros clientes. Desde el 13/11, la referencia (9004) y las candidatas (9014 y 9023) se validan también en 202105 y en 202103, con 100 semillas.

**Por qué esos meses.** Cada mes de validación entrena hasta dos meses antes, como 202107 entrena hasta 202105: la clase BAJA+2 de un mes se conoce dos meses después, así que ese hueco es el que hay al predecir 202109.

| Mes | Entrena hasta | Clientes | BAJA+2 | % BAJA+2 | Se usa | Por qué |
|---|---|---|---|---|---|---|
| 202107 | 202105 | 32.938 | 244 | 0,741 | sí (ya estaba) | El mes más cercano a 202109. |
| 202106 | 202104 | 32.891 | 220 | 0,669 | no | Demasiado pegado a 202107: comparte casi todo el entrenamiento y una cantidad de bajas parecida. No sería evidencia nueva. |
| **202105** | 202103 | 32.787 | 180 | 0,549 | **sí** | De 2021, como 202107 y 202109; respeta el hueco de dos meses; tiene menos BAJA+2 (180 contra 244), así que prueba las candidatas con otra cantidad de bajas. |
| 202104 | 202102 | 32.672 | 221 | 0,676 | no | Cantidad de bajas parecida a 202107 (221), y queda entre los dos elegidos: con 202105 y 202103 se alterna y los entrenamientos se superponen menos. |
| **202103** | 202101 | 32.605 | 176 | 0,540 | **sí** | De 2021; 176 BAJA+2, otra cantidad de bajas. Es el más débil de los tres (abajo). |
| 202003 a 202010 (pandemia) y el resto de 2020 | — | — | — | 0,14 a 0,45 | no | 9014 saca la pandemia amplia del entrenamiento, así que validar ahí mediría otra cosa; son meses atípicos (202006 roto, tasa de bajas mucho más baja) y la competencia predice un mes de 2021. |

**La contra de 202103: es el más débil de los tres meses.**
- Entrenamiento más corto: hasta 202101. Con la pandemia amplia afuera, 9214 entrena solo con 2019, 202001, 202002, 202011, 202012 y 202101.
- Las hojas de Random Forest y los canaritos usan la clase, así que se corrieron para atrás la misma distancia que con 202107 (si no, verían el mes de validación). En 202103 entrenan con 202009 a 202011 y los canaritos validan en 202101. 202009 y 202010 están dentro de la pandemia amplia, que 9214 saca del entrenamiento principal pero no de estas dos partes. Carla decidió el 13/11 mantener la misma distancia antes que achicarlas a 202011 (que dejaría muy pocos datos).
- Por eso, si 202103 contradice a 202107 y 202105, pesa menos.

**Ventana (definida el 13/11, antes de correr).**
- **Decide la general:** 1300 a 3500 de a 100, con P de los tres meses ≥ 0,90 (desde la elección entre las dos candidatas, el 13/11; registrado el 15/11, ver Decisiones). Es la misma de 202107: no se eligió mirando resultados y deja comparar los meses entre sí.
- **Lectura fina, que no decide:** la ventana escalada por BAJA+2, con los mismos envíos por BAJA+2 que en 202107 (1300 / 244 = 5,3 y 3500 / 244 = 14,3): **1000 a 2600 en 202105** (180 BAJA+2) y **900 a 2500 en 202103** (176), con cortes cada 50. Sirve para ver si la diferencia está en la zona donde se va a cortar.
- **Advertencia:** en los meses con menos BAJA+2, la ventana general se extiende más allá de la meseta. En 202105, 3500 envíos son 19,4 por BAJA+2 (en 202107, 14,3): los cortes altos, donde todas las corridas caen, pesan más y diluyen las diferencias, así que la P de ese mes tiende a acercarse a 0,5. Por eso se mira también la escalada.

**Las dos P** (estos nombres se usan desde el 13/11 en la bitácora, en los scripts y en los documentos):
- **P del mes:** la de siempre. Probabilidad de que el semillerío de B le gane al de A en ese mes, remuestreando semillas y clientes de ese mes. Hay una por mes (202107, 202105 y 202103). Se informa al lado de la P de los tres meses, y el mes que pierde con P < 0,30 se marca.
- **P de los tres meses:** se suman las ganancias de 202107, 202105 y 202103 (el promedio de la ventana de cada mes) y se calcula la probabilidad de que B gane en la suma, remuestreando semillas y clientes dentro de cada mes. Es la que decide, con P ≥ 0,90 (desde la elección entre las dos candidatas, el 13/11; registrado el 15/11).
- Son dos cosas distintas: la P del mes responde "¿gana en este mes?"; la P de los tres meses, "¿gana en el total?". Una corrida puede ganar por poco en los tres meses sin que ninguna P del mes llegue a 0,90, y la de los tres meses sí.
- Ninguna de las dos es la P "solo semillas" (que remuestrea solo las semillas y deja fijos los clientes); esa sigue saliendo en `comparar_corridas.sh` como diagnóstico.

## Decisiones

| Fecha | Decisión | Por qué |
|---|---|---|
| 04/11 | Partir del workflow del Senior (`PredFinal/z739`) y no del Junior (`PredFinal/z729`) | El Senior contiene todas las etapas del Junior y suma variables intra-mes, tendencia de 6 meses, variables con hojas de Random Forest, canaritos, Bayesian Optimization y semillerío. Arma `param_final` parámetro por parámetro, sin el error del `c()` del Junior. El "pipeline Junior" se puede expresar como cambios sobre el Senior (apagar etapas), así que alcanza con una sola numeración. |
| 04/11 | Una sola numeración (9 + correlativo) y un catálogo de cambios | Con 17 experimentos colaborativos y combinaciones entre ellos, un dígito por factor (como el 5FCD del ExpCol 05) no escala. El código identifica la corrida; la bitácora dice qué tiene. |
| 04/11 | Primero la base (9001) y la base con los hiperparámetros de la clase 08 (9002) | 9001 es el punto de comparación de todo lo que sigue. 9002 prueba la pregunta de la clase 08: los hiperparámetros óptimos de un LightGBM solo no tienen por qué ser los de un LightGBM dentro de un semillerío. |
| 04/11 | 10 semillas para empezar | Más rápido. Las semillas salen de la primigenia (384841) en el mismo orden, así que al pasar a 30 o más se reutilizan los modelos ya entrenados. |
| 04/11 | Cortes de 1300 a 2200, de a 100 | En el ExpCol 05 el máximo cayó casi siempre entre 1500 y 2200, varias veces en el borde de 1500. Los cortes del notebook Senior (8000 a 12000) son para su dataset. |
| 04/11 | Celda de validación del semillerío en 202107 | Da AUC y ganancia propios de cada corrida sin mirar el Public. En 9001 la estimación sale algo optimista, porque la Bayesian Optimization eligió mirando 202107. |
| 04/11 | Archivos de Kaggle sin "s" y con el experimento en la descripción | Mismo criterio que en el ExpCol 05. |
| 04/11 | Clase binaria: positivos BAJA+1 y BAJA+2 | Es la que trae el notebook y la que la cátedra mostró que funciona mejor (clase 07): BAJA+1 se parece más a BAJA+2 que a CONTINUA. |
| 04/11 | Trabajar en un repositorio propio (`labo2026v-modelo-final`) y copiar la versión final al fork de la materia | Separa el trabajo del modelo final del repositorio de la cátedra. El libro pide la entrega en una carpeta creada para eso en el repositorio de la materia: al cerrar se copia ahí (confirmar con la cátedra si alcanza con el repo propio). |
| 07/11 | 9006 y 9007 (`min_data_in_leaf` a la mitad y al doble) | Usan las mismas 30 semillas que 9004, así que se comparan con ella semilla por semilla. |
| 07/11 | 30 semillas como mínimo en todas las corridas nuevas | Con 10 semillas el resultado todavía depende de cuáles tocaron (clase 08). |
| 07/11 | 9005: la línea Bayesian con 30 semillas | Con las dos líneas abiertas y 30 semillas como mínimo, 9005 es la pareja de 9004 (inesperados con 30). |
| 07/11 | No se elige todavía entre Bayesian e inesperados | Las dos líneas siguen abiertas: hay cupo de envíos (100 por día y por cuenta) y las corridas son cortas. |
| 07/11 | Regla de comparación: Wilcoxon pareado por semilla sobre la ganancia promedio de cortes en 202107 | Reemplazada el 08/11. |
| 10/11 | `CLAUDE.md` en el repo: contexto y forma de trabajo para seguir con Claude Code en la VM | Menos fricción: Claude corre los comandos y hace los commits en la VM, con permiso de Carla, en lugar de bundles y copiar y pegar. |
| 11/11 | Correr MICE liviano sobre 9004: 9021 con CART (jr2) y 9022 con PMM (jr), las dos con 8 cortes subidos por la notebook. Se comparan contra 9016 (tendencia) y 9004 (NA), y entre sí | Lo decidido el 11/11: antes de cerrar el bloque CA se prueba MICE con PMM y con CART. La prueba de enmascarado mostró que MICE no reconstruye valor por valor mejor que interpolar o tendencia (`error_rel` 0,66 a 0,75 contra 0,41 a 0,48), pero sí conserva mejor la distribución (proporción de ceros casi exacta); qué le sirve más a LightGBM solo lo responde una corrida. Las dos con el mismo diseño de imputación: lo único que cambia es el método. Se suben los cortes desde la notebook para tenerlos sin un paso aparte. |
| 11/11 | MICE con CART se hace con `cartliviano` (función propia en `prueba_enmascarado.R`) y no con `mice.impute.cart` | El CART de mice copia, para cada fila a imputar, todos los donantes de su hoja; con variables casi binarias (`internet`, 90 % de unos) las hojas son enormes: 39,4 GB en el modo rápido y, casi seguro, la causa de los 56 GB de 9020. `cartliviano` usa el mismo árbol y cada fila sortea su propio donante, independiente y con reposición, dentro de su hoja (condición de Carla: no un donante por hoja, que aplanaría la variabilidad). Verificado contra el original con los mismos datos: da una distribución equivalente de lo imputado (las diferencias entre las dos versiones son menores que las de cada una contra el valor real; ver "Prueba de enmascarado del CA"). Memoria máxima 2,4 GB y más rápido. |
| 11/11 | El bloque Catastrophe Analysis no se cierra. Dos candidatas: **pandemia adentro** (mejor hoy: 9016, CA con tendencia) y **pandemia afuera** (9014, CA en NA). Antes de cerrar el bloque se prueba MICE con PMM y con CART; con qué candidata se sigue, y si la pandemia entra o no, se decide después de ver MICE | Sobre 9014, reconstruir con interpolar o tendencia no suma (P 0,213 y 0,186): con la pandemia afuera, por ahora, NA. Pero ahí el CA toca solo 14 pares variable-mes, todos de 2019 (201904, 201905 y 201910), y la diferencia (unos 2 M, con rangos que cruzan el cero) es más probablemente ruido que un efecto: con la pandemia afuera el CA casi no tiene dónde actuar; la interacción CA × pandemia queda como hipótesis, porque el mes que pesa es 202006 (15 variables), que solo entra con la pandemia adentro. Sobre 9004 reconstruir sí sumaba (9016 tendencia +1,7 M, P 0,80). Hipótesis: la pandemia se excluyó porque no se la corregía; si se la corrige bien, quizás convenga incluirla. |
| 12/11 | Vocabulario: "pandemia adentro" / "pandemia afuera (amplia o restringida)", "con undersampling" / "sin undersampling", "referencia" (9004) y "candidatas". No se usan "camino", "régimen" ni "base" para las candidatas | Decisión de Carla: cada cosa se nombra por lo que cambia. Se corrigieron esas palabras en la bitácora y en `CLAUDE.md`; los resultados y las fechas quedan como estaban. |
| 12/11 | MICE se descarta: con la pandemia adentro, las rotas se corrigen con tendencia | Empata con tendencia (P de que MICE le gane a 9016: 9021 con CART 0,436; 9022 con PMM 0,220), la prueba de enmascarado muestra que tendencia acierta más valor por valor (`error_rel` 0,41 a 0,48 contra 0,66 a 0,75) y, ante un empate, gana lo simple. |
| 12/11 | Referencia: 9004. Dos candidatas, sin elegir todavía; los cambios futuros se prueban contra las dos. Pandemia afuera (amplia, receta del ExpCol 05 A), rotas en NA, sin undersampling: 9014. Pandemia adentro, rotas corregidas con tendencia, sin undersampling: 9023 (hasta que se lea, la provisoria es 9016) | Ninguna le gana a la otra con la regla. 9014 pasa la regla contra 9004 (P 0,933), pero es una sola comparación; con la pandemia adentro, tendencia es lo mejor que hay (9016 contra 9004, P 0,803). |
| 12/11 | `internet` va en el bloque CA, no en drifting (el drifting es solo para las monetarias). Opciones a evaluar: sacarla, o NA desde el salto, 202010 (confirmado con el conteo de ceros) | Desde 202010 cambia de definición: pasa de un indicador 0/1 con 6 a 10 % de ceros a valores de 0 a 4 con 95,6 a 97,5 % de ceros, también en 202107 (validación) y 202109 (future). Es un dato roto que sigue, no un efecto de la inflación. |
| 12/11 | Ventana en 202107: 1300 a 3500 (deja de ser provisoria). Umbral de la regla: P ≥ 0,90. La ventana de los meses de validación nuevos se define antes de correrlos | Con unas 30 comparaciones, por azar pasarían alrededor de 3: 9014 (P 0,933) y 9006 (P 0,912) son candidatas a confirmar, no certezas. Definir la ventana antes de correr evita elegirla mirando los resultados. |
| 12/11 | Semillas: si de 20 a 30 la curva de semillas sigue subiendo, no se llegó a la meseta. Las corridas de validación en otros meses van con 100 semillas | En 9014 la curva sube de 96,6 a 97,0 M de 20 a 30 semillas (9024: de 97,3 a 97,6). En la clase 08 la ganancia se estabilizaba desde unas 60. |
| 12/11 | Reproducibilidad: el 13/11 se corre 9014 con 100 semillas en las dos VM y se compara el md5 de la predicción. Prueba el pipeline, no la configuración. El candidato definitivo se arma el sábado 14/11 | Si el md5 coincide, la entrega se reproduce en otra máquina. Procesador de la jr2: AMD EPYC 7B12, 8 procesadores (`lscpu`, `nproc`); falta confirmar el de la jr, porque un procesador distinto puede cambiar el resultado sin que el pipeline esté mal. |
| 13/11 | Meses de validación nuevos: 202105 (entrena hasta 202103) y 202103 (entrena hasta 202101) | Son de 2021, respetan el hueco de dos meses, 202106 está demasiado pegado a 202107, y los dos tienen menos BAJA+2 (180 y 176 contra 244), así que prueban las candidatas con otra cantidad de bajas. Detalle, y por qué no 202106, 202104 ni la pandemia, en "Validación en otros meses (13/11)". |
| 13/11 | Ventana: decide la general, 1300 a 3500 con P de los tres meses ≥ 0,90 (corregido el 15/11: decía "P ≥ 0,90 en cada mes"; ver Decisiones del 15/11). Como lectura fina, la escalada por BAJA+2 (1000 a 2600 en 202105; 900 a 2500 en 202103), con cortes cada 50 | Definidas antes de correr. La general es la misma regla que en 202107; la escalada mira la zona donde se va a cortar, porque con menos BAJA+2 la general se extiende más allá de la meseta. |
| 13/11 | Dos P con nombre propio: "P del mes" (la de siempre, remuestreo de semillas y clientes dentro de un mes) y "P de los tres meses" (ganancias de 202107, 202105 y 202103 sumadas, con remuestreo dentro de cada mes) | Responden preguntas distintas (¿gana en este mes? / ¿gana en el total?). Ninguna es la de "solo semillas". Los nombres se usan igual en la bitácora, los scripts y los documentos. |
| 13/11 | 100 semillas en todas las corridas nuevas. Referencia 9004; candidatas 9014 y 9023 | Decisión del 12/11: si de 20 a 30 semillas la curva sigue subiendo, no se llegó a la meseta (9014 sube de 96,6 a 97,0). |
| 13/11 | En 202103, las hojas de Random Forest y los canaritos se corren para atrás la misma distancia que con 202107 (entrenan con 202009 a 202011), aunque 202009 y 202010 caen en la pandemia amplia | Mantiene la misma distancia al mes de validación en los tres meses. Queda como limitación de 202103, junto con el entrenamiento más corto: es el más débil de los tres meses. |
| 13/11 | Reproducibilidad: 9029 (9014 con 100 semillas) corre en las dos VM, cada una en su carpeta (WF9029_jr y WF9029_jr2). Se comparan los md5 de `prediccion.txt` y de `prediccion_validacion.txt` | Los dos archivos cubren el modelo final (lo que se sube) y la validación (lo que decide); un archivo de Kaggle solo mostraría el orden del corte. Las dos VM tienen el mismo procesador (AMD EPYC 7B12, 8 procesadores). |
| 13/11 | `internet`: se prueba primero sacarla, sobre las dos candidatas (9025 = 9014 sin internet; 9026 = 9023 sin internet, 30 semillas, 8 cortes) | Primera de las dos opciones del 12/11; NA desde 202010 queda pendiente. |
| 13/11 | Reproducibilidad: **la solución es reproducible.** Criterio adoptado: mismo orden de clientes, mismos elegidos y misma ganancia (en lugar del md5 idéntico de las probabilidades). El archivo de Kaggle (solo 0 y 1) tiene que dar el mismo md5 en las dos VM; ese md5 va en la entrega | Detalle en "Reproducibilidad: 9029 en las dos VM (13/11)". La diferencia entre VM es de 1,5e-14 y viene del cálculo en paralelo de LightGBM, no del hardware. |
| 13/11 | Análogo electoral: con la tabla de 2019 no se cumple la condición de "algo muy claro" (la tasa de BAJA+2 bajó en las PASO de 2019). Queda como idea, y se corre una sola exploración sobre 9014: 9027, con peso 3 en 201908 a 201911, 100 semillas (las mismas de 9029), 8 cortes con MCD. No entra en el candidato | El contexto de 202109 (elecciones, cepo, fin de la segunda ola) existe aunque la cátedra no haya elegido el mes a propósito, y la clase la determina noviembre de 2021. Detalle y justificación del peso en "Análogo electoral (13/11)". |
| 13/11 | Corte de 202109: no se fija todavía. Se decide después de ver si la meseta, medida en envíos por BAJA+2, se mantiene en 202105 y 202103. Zona provisoria: 2100 a 2400 | Las dos estimaciones del documento del 13/11 dan unos 2000 (por la tasa de BAJA+2 de 2021) y unos 2400 (por las probabilidades de 9014). |
| 13/11 | Criterios para elegir el envío final, definidos antes de ver los resultados finales (tabla en "Cómo se elige el envío final (13/11)"). El domingo a las 18:00 se elige con la tabla | Definir los criterios antes evita elegirlos mirando qué candidata gana. |
| 13/11 | Cupo de Kaggle: el cupo de CF del domingo (se renueva el sábado a las 21:00) se reserva para el armado final; hasta entonces, en CF solo lo que puede ser candidato, y todo lo exploratorio va a MCD. Domingo: decisión a las 18:00 con la tabla, todo subido y marcado en CF a las 20:00. La renovación del domingo a las 21:00 es solo un colchón para algo excepcional; si no, entre las 21:00 y las 23:59 solo se pone el link en Zulip (antes de las 23:58) | El envío final tiene que ser un archivo subido con CF; reservar el cupo evita quedarse sin envíos para el corte exacto. |
| 13/11 | Candidata 2, rotas: tendencia contra NA sin undersampling da empate (9013 contra 9023, P 0,566). Si las dos siguen empatadas al final, gana la más simple (NA). Etiquetas fijas: PA-afuera, PR-afuera y P-adentro | El 0,803 de tendencia (9004 contra 9016) era con undersampling: no vale para la candidata 2, que no lo tiene. Ante un empate, lo más simple tiene menos piezas que puedan fallar en 202109. Las etiquetas evitan confundir la pandemia amplia con la restringida. |
| 13/11 | Bloque de drifting sobre las dos candidatas, 100 semillas, 202107: ninguno (contraria), dólar blue, IPC + rank_cero_fijo sobre monetarias e IPC + rank sobre monetarias y 8 cantidades transaccionales (9032 a 9035 sobre 9031; 9036 a 9039 sobre 9029). IPC solo ya está: 9029 y 9031. La ganadora se confirma en 202105 y 202103 | Recorre las opciones del bloque contra la que ya tienen las dos candidatas. Las cantidades transaccionales también crecen con la actividad de 2021 (ver Ideas del 13/11). |
| 13/11 | Regla de drifting: agregar, nunca borrar. Dividir por IPC o por dólar reemplaza la columna (es reversible); el rank se agrega como `<campo>_rank` y la original queda deflactada | El rank no es reversible: si reemplaza, el modelo pierde el valor. Se arregló además el switch, que llamaba a `drift_dolarblue` y `drift_dolaroficial` (no existen; las funciones son `drift_dolar_blue` y `drift_dolar_oficial`). |
| 13/11 | Empates del rank, sobre 9039 (IPC + rank de monetarias y cantidades, PA-afuera): average, sin azar (9039); azar con set.seed fijo, dos semillas (9040 y 9041); azar distinto en cada semilla del semillerío, con el RF recalculado en cada una (9042, D3a) o calculado una vez sin las columnas de rank (9043, D3b). El set.seed del desempate guarda y restaura el estado del azar | Así lo único distinto de 9039 es el desempate (verificado: mismas 100 semillas de 9029 y mismos canaritos). La comparación limpia del desempate por semilla es 9042 contra 9039; 9043 contra 9039 mezcla el desempate con el RF sin rank. |
| 13/11 | Kaggle del bloque de drifting: 8 cortes (1500 a 2900 de a 200); la jr2 sube con CF y la jr con MCD (la segunda cuenta solo está en la jr). Lo que no entre se sube el viernes después de las 21:00; no se toca el cupo de CF que se renueva el sábado a las 21:00 | Cumple la política de cupo del 13/11. |
| 13/11 | `WF9029` es un enlace simbólico a `WF9029_jr2` (`ln -s WF9029_jr2 WF9029` en `~/buckets/b1/exp`, 12:44 hora argentina). Las dos carpetas reales (`WF9029_jr` y `WF9029_jr2`) quedan como están | 9029 corrió en las dos VM por la prueba de reproducibilidad y no había `WF9029`: `comparar_corridas.sh 9029 9027` fallaba. Con el enlace, 9029 se usa como cualquier corrida en `comparar_corridas.sh`, `comparar_tres_meses.sh`, `mirar.sh` y `enviar_cortes.sh` (este último ve los 8 cortes ya subidos de la jr2 y los saltea). Las dos carpetas son idénticas en lo que importa: mismos elegidos y mismo md5 del archivo de Kaggle en los 8 cortes. |
| 13/11 | **La candidata 2 (9031, P-adentro) pasa a ser la principal.** No pierde en ningún mes (P del mes contra la referencia: 0,756 / 0,730 / 0,475) y le gana a la candidata 1 en la suma de los tres meses (P 0,951), con la marca de que en 202107 pierde con ella (0,166). La candidata 1 (9029, PA-afuera) queda como alternativa, sin sumarle cambios | Marco de CazaTalentos: la candidata 1 ganó el torneo donde se eligieron sus piezas (202107) y no lo sostuvo en la nueva ronda (202105: P 0,017 contra la referencia; 202103: 0,196). Elegir por un torneo y confirmar con otro es la diferencia entre explorar y decidir (Ioannidis 2005). |
| 13/11 | Desempates del rank: si de acá en adelante entra un rank, desempata con azar y semilla fija. Las cantidades no entran en el rank por ahora | El azar le ganó a average las cuatro veces (P 0,862 a 0,955). Promediar el azar en cada semilla (9042, 4,4 h) no le ganó a una semilla fija. Con average, las cantidades empeoraron en las dos candidatas, y con azar no mostraron ventaja contra 9029 sin rank. |
| 13/11 | El corte de 202109 no sale de un solo número de envíos por BAJA+2: la meseta va de 4,5 a 13,9 según el mes y la configuración. Se decide el sábado | Mesetas del documento de lectura del 13/11 (202107, 202105 y 202103). |
| 13/11 | Tanda de confirmaciones sobre la candidata 2, 100 semillas (las mismas de 9031): dólar blue en 202105 y 202103 (9044, 9045); IPC + rank de monetarias con empates average, exactamente como 9034, en 202105 y 202103 (9046, 9047), contra 9123 y 9223; sin `internet` en 202107 con 8 cortes (9048), en 202105 (9049) y en 202103 (9050); electoral con peso 3 en 201908 a 201911, en 202107 con 8 cortes (9051, exploración). Kaggle: jr2 con CF y jr con MCD. Además, sin correr nada: promedio de las probabilidades de 9029 y 9031 (y de 9114 con 9123, y de 9214 con 9223) contra 9031 en los tres meses | Lo que pasó la regla o se acercó en 202107 se confirma en otros meses antes de entrar (dólar blue 0,913; rank de monetarias 0,739; sin `internet` 0,862 con 30 semillas). El rank va con average para confirmar lo mismo que se probó. El electoral se explora sobre la principal. El FE queda para después. |
| 13/11 | **Drifting: queda el IPC** en la candidata 2. El dólar blue gana solo en 202107 (P del mes 0,921 / 0,058 / 0,042; P de los tres meses 0,115) y el rank de monetarias empata (0,752 / 0,371 / 0,440; tres meses 0,545) | Regla del bloque: si ni el dólar blue ni el rank se confirman, queda el IPC. Ante el empate, lo más simple: el rank agrega 25 columnas y una decisión de desempate. Ver "Confirmación del drifting en 202105 y 202103 (13/11)". |
| 13/11 | **Patrón de 202107:** PA-afuera, el dólar blue y el promedio de las candidatas ganaron solo en 202107 y perdieron en los otros dos meses. Sin `internet` repitió el patrón (0,936 en 202107, 0,021 en 202105). 202107 es el mes más atípico y premia cambios que no se sostienen: la validación en tres meses evitó cuatro falsos ganadores. Lo que gane solo en 202107 no entra | 202107 tiene el % de BAJA+2 más alto de la serie (0,741 %). Con unas 30 comparaciones, por azar pasan unas 3 la regla en un mes: la confirmación en 202105 y 202103 es la que separa una mejora de una casualidad (Ioannidis 2005). |
| 13/11 | Bloque de FE sobre la candidata 2 con IPC, 100 semillas (las mismas de 9031), 202107, 8 cortes: H0 contraria sin lags, deltas ni tendencias (9052); H1 valor / promedio de los 6 meses anteriores y máximo / promedio (9053); H2 lags y deltas de 3, 6 y 12 (9054); H3 tendencia, mínimo y máximo en ventanas de 3, 6 y 12 (9055); I0 contraria sin las intra-mes de la cátedra (9056); I1 variables de negocio (9057); I3 ratios entre pares de las 25 monetarias del mes, sin lags (9058); I2 COVID del AMBA y nacional, del mes y del anterior (9059). Regla: agregamos, nunca borramos; H0 e I0 solo miden cuánto aportan las variables que sacan | H2: en ExpCol 05 A los lags largos perdieron contra lags 1 y 2 (entre −3,2 y −5,6 M, p 0,002), también con los lags de la pandemia en NA; se reprueban porque cambiaron el pipeline (canaritos), la medición (tres meses con remuestreo) y las semillas (100). Si H2 gana, se reprueba P-adentro contra PA-afuera con lags largos. H3 suma también mínimo y máximo en la ventana de 6. |
| 13/11 | COVID (I2): fuente principal, los partes diarios del Ministerio de Salud por provincia, copia de Sistemas Mapache (github.com/SistemasMapache/Covid19arData, CC BY 4.0; la serie está en la planilla que enlaza el repo, del 02/03/2020 al 09/11/2021). AMBA = CABA + provincia de Buenos Aires completa; población: proyecciones 2020 del INDEC. Our World in Data queda solo como comparación. El script `covid_mensual.R` cita las fuentes y arma `datasets/externos/covid_mensual.csv` | Mapache es diario y por fecha del parte (lo que se sabía ese mes). OWID tomó desde 2023 la serie de la OMS, semanal y con las muertes reasignadas: el total coincide (al 30/09/2021, 5.318.508 contra 5.256.902 casos y 116.434 contra 115.179 muertes), pero mes a mes los casos difieren entre 0,73 y 1,19 veces y las muertes entre 0,35 y 3,20 veces. Correlación mensual: casos 0,984, muertes 0,865. AMBA y nacional van juntos (correlación 0,93 en casos y 0,96 en muertes) por si el AMBA, donde está la mayoría de los clientes, explica algo que la nacional no. |
| 14/11 | z728_final_junior_power (PredFinal, publicado por Gustavo el 13/11): leído y no adoptado | Tiene 20 semillas y elige los hiperparámetros con una grid por AUC en 202107; con 100 semillas tardaría unas 3,5 h; no guarda la validación por semilla, así que no se puede comparar con la regla sin adaptarlo. Además, desde el sábado a las 12:00 no se abren bloques nuevos. Queda como referencia: confirma semillerío, IPC y entrenar sin undersampling. |
| 14/11 | Confirmaciones en 202105 y 202103, sin Kaggle, mismas 100 semillas de 9123 y 9223: H1 (9060, 9061), I2 (9062, 9063), I3 (9064, 9065) y peso electoral 3 en 201908 a 201911 (9066, 9067). jr2: 202105; jr: 202103 (`lanzar_cola5.sh`) | H1 pasó la regla en 202107 (0,932); I2 (0,897), I3 (0,888) y el electoral (0,940) quedaron cerca o la pasaron. Por el patrón de 202107, nada entra sin confirmarse en los otros dos meses. H2, H3 e I1 quedan afuera (empatan y suman muchas columnas). |
| 14/11 | Kaggle: los 28 cortes pendientes de CF (9052 desde el 2300, 9054, 9056 y 9059) se suben con el cupo de CF del sábado, que vence a las 21:00. El cupo que se renueva el sábado a las 21:00 queda reservado para el armado final | El cupo del viernes se agotó a las 16:05 (100 envíos). El Public se registra pero no decide. |
| 14/11 | Fork `~/buckets/b1/labo2026v`: el remoto `origin` ya no tiene el token en la URL (`git remote set-url`). Verificado: el token no está en ningún archivo, versionado o no, ni en el historial del fork ni de este repo | El fork se hace público o recibe la copia para la entrega. |
| 15/11 | Se revisó la redacción de la bitácora para que fuera consistente, también en el historial del repositorio, sin cambiar decisiones ni resultados. | Por eso cambiaron los hashes de los commits desde el 07/11, y 21 de ellos perdieron la firma SSH. Las fechas y la autoría no cambiaron. |
| 15/11 11:11 a 11:19 | Registro: los 16 cortes de 9078 y 9081 (V4 y V5, 8 cortes cada una, 1500 a 2900 de a 200) salieron por CF y no por MCD, con el cupo reservado para el armado final. Desde entonces, toda línea de subida exploratoria fuerza MCD (`KAGGLE_CONFIG_DIR=~/.kaggle2`) y muestra la cuenta en la salida | La línea de subida no fijaba la cuenta, y `enviar_cortes.sh` usa CF salvo que CF falle. Quedaron 68 envíos de CF hasta el domingo a las 21:00, suficientes para el armado final. |
| 15/11 11:52 | Reglas fijadas antes de ver los resultados. Candidata 2 contra la referencia: rige la misma regla que con cualquier variante, con la candidata 2 como A; la referencia la reemplaza solo si le gana con P de los tres meses ≥ 0,90. Rotas, NA contra tendencia: como está escrito desde el 13/11, la tendencia se queda solo si le gana a NA con P de los tres meses ≥ 0,90; si no, NA | Al revisar la bitácora el 15/11 se detectaron dos faltas. Desde la elección entre las dos candidatas (13/11) se decidió con la P de los tres meses, y ese cambio no quedó registrado como decisión (la bitácora seguía diciendo que decidía la P de cada mes). Y faltaba comparar la candidata 2 con la referencia con la P de los tres meses: solo estaban las P del mes (0,756, 0,730 y 0,475, a favor de la candidata 2). |
| 15/11 12:05 | La referencia (9030, 9104 y 9204) no reemplaza a la candidata 2 (9031, 9123 y 9223): P de los tres meses 0,255 de que gane la referencia (P del mes 0,244 / 0,270 / 0,525) | Regla de las 11:52. La candidata 2 queda arriba en los tres meses (+1,1, +1,0 y +0,3 M). Si se hubiera tomado la referencia como base, la candidata 2 no habría llegado a 0,90 (P 0,745) y quedaría la referencia: la diferencia, unos 2 M en la suma de los tres meses, equivale a unos dos BAJA+2, y con estos datos no se distinguen. Ver "Candidata 2 contra la referencia, con la P de los tres meses (15/11)". |
| 15/11 14:17 | **Rotas en NA, no tendencia.** P 0,678 de que gane la tendencia en los tres meses (0,426 / 0,896 / 0,449): no llega a 0,90, así que queda NA. La candidata final es la versión NA de la candidata 2: 9085 (202107), 9086 (202105) y 9087 (202103), copias de 9031, 9123 y 9223 con una sola línea cambiada (`PARAM$CA$metodo <- "MachineLearning"`) y las mismas 100 semillas | El 13/11 quedó escrito que, si la tendencia y NA seguían empatadas al final, ganaba la más simple (NA). Teníamos esa regla y se nos pasó por alto: la candidata 2 siguió con tendencia sin haber resuelto el empate, que venía de una sola comparación con 30 semillas y solo en 202107 (P 0,566). Se ratificó a las 11:52, antes de correr la comparación. Con la lógica general de la regla (la que está se queda salvo que el retador gane con 0,90) habría quedado la tendencia; se aplicó la regla específica de las rotas porque estaba escrita antes. Ver "Rotas: NA contra tendencia sobre la candidata 2 (15/11)". |
| 15/11 15:58 | **Corte de 202109: 1800 envíos**, decidido antes de conocer su Public | Mesetas de la versión NA en envíos por BAJA+2 (202107: 6,6 a 8,2; 202105: 7,8 a 13,3; 202103: 4,5 a 6,8) y tres estimaciones de BAJA+2 en 202109 (204, 216 y 238). Con la tabla de pérdida por corte, 1800 tiene el peor caso más bajo (−1,1 M) y la segunda suma más baja (−5,6 M; 1700, −5,5 M). Detalle en "Corte de 202109 con la versión NA (15/11)". |
| 15/11 16:14 | **Envío final marcado en CF:** `KA9085_100_1800.csv`, md5 `dbfa78781de150967de93c6abc5daae7` | Es el corte de las 15:58 sobre la predicción de 9085. La notebook de la entrega reproduce el mismo archivo desde cero (9088; ver "Reproducibilidad de la entrega (15/11)"). |
| 15/11 17:26 | La entrega pública va toda al fork `labo2026v`: carpeta de entrega, bitácora, README general, `CLAUDE.md` sin lo interno, scripts y notebooks. El repositorio de trabajo queda privado | Separa lo que se entrega del trabajo interno. El respaldo del historial y el reflog quedan como están hasta después de la entrega. |
| 15/11 18:32 | Además de la cuenta principal (carlaperezfernandez), se usó una segunda cuenta de Kaggle (carlapf), creada el 31/10/2026, para subir cortes exploratorios cuando el cupo diario de la cuenta principal resultaba insuficiente, desde el período de los Experimentos Colaborativos. Se usó hasta el 15/11. La nota sale solo de la cuenta principal, donde se marcó el envío final. | Registro para la entrega. |
| 13/11 | De acá en adelante, todo se compara con 100 semillas. Esquema de referencia y candidatas por etapa en "Referencia y candidatas por etapa (13/11)" | Con 30 semillas la curva todavía sube (9029 da 96,4 con 100 contra 97,0 de 9014 con 30): parte de la diferencia era suerte de las semillas. |
| 09/11 | Controles automáticos en cada resumen (`resumen_corrida.sh`, sección 0) y `mirar.sh` para mirar una tanda en curso | Idea de Carla: los chequeos que se hacían a mano (que el CA reconstruyó, que se excluyeron los meses pedidos, que están las 30 semillas…) quedan escritos en cada resumen con [OK] o [REVISAR]. Da calidad y trazabilidad a la bitácora y a la reproducibilidad. El resumen y la mirada rápida usan la ventana 1300 a 3500 calculada desde `prediccion_validacion.txt`; no hace falta tocar las notebooks (su `validacion_cortes.txt` sigue siendo de 1300 a 2200). |
| 09/11 | Bloque Catastrophe Analysis, siguiendo el orden del workflow: interpolar (`CA-INT`, receta del #01 B) y tendencia (`CA-TEND`), cada uno sobre 9004 y sobre 9014 | Pandemia adentro y pandemia afuera (criterio de interacciones): con 9014 la pandemia amplia queda afuera y el CA solo pesa en 201904, 201905, 201910, 202002 y 202102 (corregido el 11/11: en el dataset Jr solo 201904, 201905 y 201910; 202002 y 202102 tienen rotas solo variables que el Jr no tiene, ver la lectura del CA sobre 9014); con 9004 pesa en todos los meses rotos. Se descartan dejar los ceros (un cero falso parece un cliente que deja de operar), el último valor y excluir meses o variables (pierden información). MICE se prueba con PMM y con CART (9019 y 9020, sobre 9004, donde el CA pesa más), con la función corregida: la de la notebook no pone NA antes de imputar (no imputa nada) y llama a `complete()` sobre el dataset en vez del resultado de `mice()`; además, con "sample" sortea valores al azar. Desde estas corridas se suben 8 cortes por corrida (1500 a 2900, de a 200) para no gastar todo el cupo: la decisión sale de la validación, que usa todos los cortes. |
| 09/11 | Ventana de cortes para comparar: 1300 a 3500 (provisoria) | Son todos los cortes que se suben a Kaggle, así que no está elegida mirando los resultados. La alternativa 1800 a 2800 cubre mejor las mesetas, pero se propuso después de verlas (el riesgo que señala Ioannidis, 2005, que Gustavo compartió el 09/11). Incluye la zona de caída después de 3000, que diluye las diferencias. Carla la decide antes del repaso detenido del workflow, y se revisa ahí. Los archivos de comparación llevan desde ahora la ventana en el nombre. |
| 09/11 | Correr 9014, la celda que faltaba del 2 × 2 pandemia × undersampling | Criterio de interacciones del 08/11: los dos bloques tocan qué filas entran al entrenamiento. Con las cuatro celdas se ve si los efectos se suman, se pisan o se potencian. |
| 08/11 | La jr corre 9011 y 9012 (completan el bloque pandemia) y 9013 (`TS-SINUS` + `MDL-US`) mientras la jr2 corre 9008 a 9010. Envíos de todos los cortes (1300 a 3500): 9008 y 9009 con CF; 9010 a 9013 con MCD | Usar a la vez las dos VM y el cupo de las dos cuentas. La nota sale solo de CF: MCD es para explorar. 9013 es la primera corrida cuya validación entrena igual que el modelo que se sube. |
| 08/11 | Bloque pandemia: 9008 (`E05-A`), 9009 (`E05-A` + `E05-TEND`) y 9010 (`TS-2021`), todas contra 9004 | Son las Recomendaciones Concretas ya publicadas que tocan la misma etapa (qué hacer con los meses de pandemia). El Grupo B del ExpCol 05 todavía no publicó la suya. Las corridas no suben a Kaggle: los cortes se eligen con la curva de validación y se suben con `enviar_cortes.sh`. |
| 08/11 | Nueva regla: semillerío contra semillerío, con remuestreo de semillas y clientes (probabilidad de 0,90 o más, a confirmar) | La comparación por semilla favorece a los modelos fuertes aunque su semillerío no sea mejor (9004 contra 9005). Ver "Cómo se comparan las corridas". |
| 07/11 | Volver a correr solo la validación de 9001 y 9002, sin subir a Kaggle | Para tener la validación por semilla de las cuatro corridas. El modelo final no cambia: se reutilizan la Bayesian Optimization y los modelos guardados. |
| 04/11 | Envíos desde la cuenta principal de Kaggle | La nota se toma de esa cuenta. Cada corrida sube 10 envíos (el semillerío en 10 cortes), dentro del cupo diario. |
| 07/11 | Subir los cortes 2300 a 3500 de 9004 a 9007 sin volver a entrenar (`enviar_cortes.sh`) | En validación los máximos caen fuera del rango 1300 a 2200 (2071, 2532, 2565). La predicción del future ya está guardada, así que alcanza con cortar más arriba. Se registra el Public, que no decide; el corte final se elige con la curva de validación. |

## Catálogo de cambios

Cada corrida es la base más una lista de estos cambios.

| Cambio | Origen | Qué hace |
|---|---|---|
| `JR` | adaptación | Dataset Jr, semilla 384841, competencia Jr, cortes 1300–2200, nombres de archivos. Lo tienen todas las corridas. |
| `VAL` | clase 08 | Semillerío entrenado con los meses de training y evaluado en 202107 (AUC y ganancia por corte). Lo tienen todas las corridas. Desde 9003 guarda además el AUC y la ganancia de cada semilla por separado (`validacion_semillas.txt`), para Wilcoxon pareado por semilla. |
| `HP-INESP` | clase 08 | Sin Bayesian Optimization. "Parámetros inesperados" del 100-semillerío (slide de la clase 08): 23 iteraciones, learning rate 0,34, 32 hojas, `min_data_in_leaf` 711, `feature_fraction` 0,20, sin extra trees. |
| `SEM30` | clase 08 | Semillerío de 30 semillas (las primeras 10 son las mismas que con 10). |
| `MDL355` / `MDL1422` | exploración | `min_data_in_leaf` a la mitad (355) o al doble (1422) del valor de los parámetros inesperados (711). En el ExpCol 05 este parámetro quedaba en el borde de la grilla. |
| `MDL-US` | pregunta de Silvina Muzio en Zulip (25/10) y 9003 | `min_data_in_leaf` 3555 = 711 × 5: los hiperparámetros inesperados se eligieron con el 20 % de los CONTINUA, y un parámetro que cuenta filas hay que escalarlo si se entrena con todos. Gustavo lo propuso como experimento: "¿cómo se deben transformar los hiperparámetros luego del undersampling?" |
| `CA-INT` | Problema #01, Grupo B (receta) | Catastrophe Analysis: primero todas las variables rotas a NA (como el Senior), y después cada valor roto se reconstruye con el promedio del mes anterior y el siguiente del mismo cliente; si uno de los dos también está roto o falta, usa el otro. Distinto del "EstadisticaClasica" de la notebook, que interpola sin poner antes los NA y entonces promedia con los ceros de un mes vecino roto (202009 y 202010, por ejemplo). |
| `CA-TEND` | decisión propia | Como `CA-INT`, pero con una recta por mínimos cuadrados con hasta 3 meses sanos a cada lado (distancia real en meses), evaluada en el mes roto. Con los 3 meses de cada lado, la recta en el centro es el promedio de esos 6 meses; la tendencia pesa cuando de un lado faltan meses. |
| `CA-PMM` / `CA-CART` | decisión propia (la notebook trae MICE, con errores) | Variables rotas a NA y después MICE, imputándolas juntas con las otras variables de la misma fila: PMM (regresión lineal; copia el valor real de un cliente con predicción parecida, 5 iteraciones) o CART (árboles, 2 iteraciones por tiempo). Predictores: columnas numéricas sin NA más las propias variables rotas; nunca `numero_de_cliente` ni `clase_ternaria` (sería filtrar la clase). Solo se reemplazan los meses rotos. Corrige los dos errores de la función de la notebook. |
| `CA-PMM-L` / `CA-CART-L` | decisión propia (corrige `CA-PMM` / `CA-CART`, desde el 11/11) | MICE liviano, como en la prueba de enmascarado: variables rotas a NA y después, mes roto por mes roto, la imputación aprende con las filas sanas de ±2 meses. Predictores: el valor sano anterior y siguiente del mismo cliente (hasta 3 meses) y hasta 12 variables de la fila con correlación ≥ 0,2; ninguna variable rota (no se predicen entre sí), nunca `numero_de_cliente` ni `clase_ternaria`. Una pasada (`maxit` 1), semilla de mice 7. PMM, o CART con `cartliviano` (hoja mínima 50). Deja `CA_control.txt` con cada par variable-mes (a llenar, llenos, media y ceros contra los vecinos, predictores, `ridge`, tiempo, memoria). |
| `TS-SINUS` | validación | Sin undersampling de los CONTINUA en training (`training_pct` 1.0). Solo afecta la estimación en validación: el Final Training ya usa todos los CONTINUA. Por eso la validación de 9003 se parece más al modelo que se sube que la de 9002. |
| `E05-A` | ExpCol 05, Grupo A | Recomendación Concreta del Grupo A: excluye la pandemia amplia (202003 a 202010) del training y del entrenamiento final, y pone en NA los lags y delta lags que apuntan a esos meses, en todas las filas (también validación y future). Los lags del Senior ya son los recomendados (1 y 2, sin 3, 6 ni 12). |
| `E05-TEND` | decisión propia | Además de `E05-A`, pone en NA la tendencia de 6 meses cuando su ventana toca un mes de pandemia (filas de 202003 a 202103). El ExpCol 05 no tenía tendencia: es la pregunta que había quedado abierta. |
| `TS-2021` | Problema #07, Grupo A | Entrena solo con 2021: training 202101 a 202105, entrenamiento final 202101 a 202107. Es la "opción prudente" de su Recomendación Concreta (la principal, desde 202103, deja 3 meses de training en el Jr). Ellos lo probaron con el dataset gerencial. |
| `E05-R` | ExpCol 05, Grupo A | Como `E05-A`, con la pandemia restringida (202003 a 202007), la otra definición que probó el experimento. |
| `TS-2103` | Problema #07, Grupo A | La receta principal del #07 A: training 202103 a 202105, entrenamiento final 202103 a 202107. |
| `E07-…`, `E16-…` | otros ExpCol | Según la Recomendación Concreta de cada experimento. |

## Corridas

| Código | Deriva de | Cambios | VM | Inicio | Estado | Validación 202107 | Public |
|---|---|---|---|---|---|---|---|
| 9001 | z739 | `JR` + `VAL` (con Bayesian Optimization del Senior) | jr2 (estándar) | 04/11 21:25 | terminó (39 min) | AUC 0,9323 · cortes 90,5–96,0 M (prom. 93,1) · máx. 98,0 M en 2639 | 77,8–86,5 (prom. 81,8) |
| 9002 | 9001 | `JR` + `VAL` + `HP-INESP` | jr (spot) | 04/11 21:25 | terminó (8 min) | AUC 0,9307 · cortes 92,5–95,0 M (prom. 94,0) · máx. 96,2 M en 1354 | 77,2–83,7 (prom. 81,0) |
| 9003 | 9002 | `JR` + `VAL` + `HP-INESP` + `TS-SINUS` · no sube a Kaggle (modelo final = 9002) | jr2 | 07/11 19:40 | terminó | AUC 0,9296 · prom. 93,6 · máx. 97,3 M en 3029 | — |
| 9004 | 9002 | `JR` + `VAL` + `HP-INESP` + `SEM30` | jr | 07/11 19:35 | terminó | AUC 0,9323 · cortes 91,5–97,0 M (prom. 94,3) · máx. 97,6 M en 1978 | 81,2–89,0 (prom. 85,7) |
| 9005 | 9001 | `JR` + `VAL` + Bayesian de 9001 (se reutiliza `HT.RDATA`) + `SEM30`: la línea Bayesian con 30 semillas, pareja de 9004 | jr2 | 07/11 20:08 | terminó (47 min) | AUC 0,9323 · cortes 90,0–96,0 M (prom. 92,9) · máx. 98,9 M en 2565 | 77,7–84,9 (prom. 81,7) |
| 9006 | 9004 | `JR` + `VAL` + `HP-INESP` + `SEM30` + `MDL355` | jr | 07/11 20:33 | terminó (10 min) | AUC 0,9327 · cortes 89,0–98,0 M (prom. 94,9) · máx. 100,7 M en 2532 | 88,3–96,0 (prom. 92,0) |
| 9007 | 9004 | `JR` + `VAL` + `HP-INESP` + `SEM30` + `MDL1422` | jr | 07/11 20:42 | terminó (10 min) | AUC 0,9322 · cortes 90,0–97,5 M (prom. 94,0) · máx. 98,2 M en 2071 | 80,5–91,3 (prom. 84,5) |
| 9008 | 9004 | 9004 + `E05-A` · los 23 cortes con `enviar_cortes.sh` (CF) | jr2 | 08/11 18:55 | terminó (4 min + envíos) | AUC 0,9303 · prom. 1300–2200: 95,5 · máx. suav. 98,7 M en 2500 (meseta 2000–2700) | 64,5–91,2 (prom. 79,6) |
| 9009 | 9004 | 9004 + `E05-A` + `E05-TEND` · 23 cortes (CF) | jr2 | 08/11 19:12 | terminó | AUC 0,9320 · prom. 94,9 · máx. suav. 97,0 M en 2000 (meseta 1800–2800) | 71,4–83,5 (prom. 78,6) |
| 9010 | 9004 | 9004 + `TS-2021` · 23 cortes (MCD) | jr2 | 08/11 19:27 | terminó | AUC 0,9256 · prom. 81,2 · máx. suav. 86,2 M en 2200 | 66,6–85,9 (prom. 77,1) |
| 9011 | 9008 | 9004 + `E05-R` · 23 cortes (MCD) | jr | 08/11 18:57 | terminó | AUC 0,9331 · prom. 93,0 · máx. suav. 97,8 M en 2800 (meseta 2600–2900) | 72,9–96,8 (prom. 84,9) |
| 9012 | 9010 | 9004 + `TS-2103` · 23 cortes (MCD) | jr | 08/11 19:13 | terminó | AUC 0,9221 · prom. 78,4 · máx. suav. 83,8 M en 3000 | 73,1–87,6 (prom. 79,0) |
| 9013 | 9004 | 9004 + `TS-SINUS` + `MDL-US` · validación y modelo final con todos los CONTINUA, `min_data_in_leaf` 3555 · 23 cortes (MCD) | jr | 08/11 19:28 | terminó (5 min + envíos) | AUC 0,9329 · prom. 95,1 · máx. suav. 96,6 M en 2000 (meseta 1800–2200) | 72,3–92,1 (prom. 84,4) |
| 9014 | 9008 | 9004 + `E05-A` + `TS-SINUS` + `MDL-US` · cuarta celda del 2 × 2 pandemia × undersampling (con 9004, 9008 y 9013) · 23 cortes (1300 a 3500) | jr2 | 09/11 | terminó (22:42) | AUC 0,9314 · prom. 1300–3500: 97,0 · máx. suav. 99,3 M en 2300 (meseta 2100–2700) | 63,0–96,3 (prom. 81,2) |
| 9015 | 9004 | 9004 + `CA-INT` · 8 cortes (CF) | jr2 | 09/11 21:45 | terminó | AUC 0,9331 · prom. 1300–3500: 93,8 · máx. suav. 97,7 M en 2300 (meseta 2100–2400) | prom. 8 cortes 85,5 |
| 9016 | 9004 | 9004 + `CA-TEND` · 8 cortes (CF) | jr2 | 09/11 | terminó | AUC 0,9341 · prom. 1300–3500: 94,9 · máx. suav. 99,0 M en 2200 (meseta 2000–2300) | prom. 8 cortes 83,2 |
| 9017 | 9014 | 9014 + `CA-INT` · 8 cortes (CF; el 1900 se resubió el 11/11, había fallado) | jr2 | 09/11 | terminó | AUC 0,9310 · prom. 1300–3500: 94,9 · máx. suav. 97,5 M en 2900 (meseta 2100–3000) | 76,2–92,5 (prom. 8 cortes 85,0) |
| 9018 | 9014 | 9014 + `CA-TEND` · 8 cortes (CF) | jr2 | 09/11 | terminó | AUC 0,9307 · prom. 1300–3500: 95,0 · máx. suav. 98,2 M en 2200 (meseta 2000–2400) | 76,4–93,5 (prom. 8 cortes 85,8) |
| 9019 | 9004 | 9004 + `CA-PMM` | jr | 09/11 | falló en el CA: `system is computationally singular` (predictores colineales en la regresión de PMM) | — | — |
| 9020 | 9004 | 9004 + `CA-CART` | jr2 | 09/11 | cortada el 10/11 a las 9 h 47 min: 56 GB de memoria, procesador casi quieto | — | — |
| 9021 | 9004 | 9004 + `CA-CART-L` · versión corregida de 9020 · 8 cortes (1500 a 2900, los sube la notebook; CF) | jr2 | 11/11 | terminó | AUC 0,9321 · prom. 1300–3500: 94,5 · máx. suav. 97,9 M en 2100 (meseta 1800–2700) | 77,1–89,7 (prom. 8 cortes 81,6) |
| 9022 | 9004 | 9004 + `CA-PMM-L` · versión corregida de 9019 · 8 cortes (1500 a 2900, los sube la notebook; CF) | jr | 11/11 | terminó | AUC 0,9329 · prom. 1300–3500: 94,0 · máx. suav. 98,5 M en 2100 (meseta 2000–2300) | 72,4–86,3 (prom. 8 cortes 80,6) |
| 9023 | 9013 | 9013 + `CA-TEND` · pandemia adentro, rotas con tendencia, sin undersampling, `min_data_in_leaf` 3555 · 8 cortes (1500 a 2900, `enviar_cortes.sh` encadenado; CF) | jr2 | 12/11 20:11 | terminó | AUC 0,9350 · prom. 1300–3500: 94,7 · máx. suav. 97,2 M en 2600 (meseta 2300–2700) | 79,0–90,8 (prom. 8 cortes 85,2) |
| 9024 | 9014 | 9014 con `min_data_in_leaf` 1777 (la mitad) · 8 cortes (1500 a 2900) | jr | 12/11 | terminó | AUC 0,9290 · prom. 1300–3500: 97,6 · máx. suav. 101,2 M en 2200 (meseta 2000–2400) | 76,5–90,6 (prom. 8 cortes 84,7) |
| 9029 | 9014 | 9014 con 100 semillas · corre en las dos VM (WF9029_jr y WF9029_jr2) para comparar md5 · 8 cortes con CF desde WF9029_jr2 (`CARPETA=WF9029_jr2 enviar_cortes.sh`) | jr y jr2 | 13/11 03:24 (jr2) y 03:28 (jr) | terminó (13 min) | 202107: prom. 1300–3500: 96,4 · máx. suav. 99,2 M en 2000 (meseta 1800–2700) | — |
| 9104 | 9004 | 9004 validando en 202105 (entrena hasta 202103) · 100 semillas · sin modelo final ni Kaggle | jr2 | 13/11 03:37 | terminó | 202105: prom. 1300–3500: 52,2 · escalada 1000–2600: 54,0 · máx. suav. 55,3 M en 1700 (meseta 1500–2500) | — |
| 9114 | 9014 | 9014 validando en 202105 · 100 semillas · sin modelo final ni Kaggle | jr2 | 13/11 03:41 | terminó | 202105: prom. 47,8 · escalada 50,2 · máx. suav. 54,4 M en 1600 (meseta 1500–1700) | — |
| 9123 | 9023 | 9023 validando en 202105 · 100 semillas · sin modelo final ni Kaggle | jr2 | 13/11 03:44 | terminó | 202105: prom. 53,1 · escalada 55,2 · máx. suav. 57,8 M en 2400 (meseta 2200–2500) | — |
| 9204 | 9004 | 9004 validando en 202103 (entrena hasta 202101) · 100 semillas · sin modelo final ni Kaggle | jr | 13/11 | terminó | 202103: prom. 40,4 · escalada 900–2500: 44,4 · máx. suav. 48,8 M en 1200 (meseta en el borde: 1200–1300) | — |
| 9214 | 9014 | 9014 validando en 202103 · 100 semillas · sin modelo final ni Kaggle | jr | 13/11 | terminó | 202103: prom. 39,0 · escalada 43,6 · máx. suav. 47,8 M en 1400 (meseta 1200–1600) | — |
| 9223 | 9023 | 9023 validando en 202103 · 100 semillas · sin modelo final ni Kaggle | jr | 13/11 | terminó | 202103: prom. 40,7 · escalada 43,5 · máx. suav. 46,6 M en 1200 (meseta en el borde: 1200–1400) | — |
| 9025 | 9014 | 9014 sin `internet` · 30 semillas · 8 cortes (1500 a 2900, `enviar_cortes.sh`; CF) | jr2 | 13/11 03:50 | terminó | 202107: prom. 98,9 · máx. suav. 101,5 M en 1900 (meseta 1800–2900) | ver `envios_kaggle.txt` |
| 9026 | 9023 | 9023 sin `internet` · 30 semillas · 8 cortes (1500 a 2900, `enviar_cortes.sh`; CF) | jr | 13/11 | terminó | 202107: prom. 97,1 · máx. suav. 101,7 M en 2300 (meseta 2200–2600) | ver `envios_kaggle.txt` |
| 9027 | 9014 | 9014 con peso 3 en 201908–201911 (análogo electoral, exploración) · 100 semillas (las de 9029) · 8 cortes con MCD (`lanzar_9027.sh`) | jr | 13/11 | terminó | 202107: AUC 0,9303 · prom. 1300–3500: 97,0 · máx. suav. 100,8 M en 2400 (meseta 2300–2600) | 84,4–90,8 (prom. 8 cortes 87,5) |
| 9030 | 9004 | 9004 con 100 semillas (referencia) · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9331 · prom. 1300–3500: 93,8 · máx. suav. 97,0 M en 2400 (meseta 2200–2500; 9,0–10,2 envíos por BAJA+2) | 76,8–95,2 (prom. 8 cortes 87,3) |
| 9031 | 9023 | 9023 con 100 semillas (candidata 2) · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9353 · prom. 1300–3500: 95,0 · máx. suav. 97,4 M en 2800 (meseta 2600–2800; 10,7–11,5 envíos por BAJA+2) | 76,0–92,6 (prom. 8 cortes 85,1) |
| 9032 | 9031 | 9031 sin drifting (contraria) · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9314 · prom. 1300–3500: 94,0 · máx. suav. 97,5 M en 2500 (meseta 2300–2700; 9,4–11,1 envíos por BAJA+2) | 75,5–95,5 (prom. 8 cortes 87,5) |
| 9033 | 9031 | 9031 con dólar blue en lugar de IPC · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9346 · prom. 1300–3500: 97,5 · máx. suav. 101,8 M en 2200 (meseta 2100–2800; 8,6–11,5 envíos por BAJA+2) | 78,7–87,1 (prom. 8 cortes 84,1) |
| 9034 | 9031 | 9031 + rank de monetarias (`rank_cero_fijo`, empates average) · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9359 · prom. 1300–3500: 95,9 · máx. suav. 100,1 M en 1900 (meseta 1800–2500; 7,4–10,2 envíos por BAJA+2) | 78,3–94,5 (prom. 8 cortes 86,2) |
| 9035 | 9031 | 9031 + rank de monetarias y 8 cantidades transaccionales (average) · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9336 · prom. 1300–3500: 94,3 · máx. suav. 97,1 M en 2100 (meseta 1800–2500; 7,4–10,2 envíos por BAJA+2) | 76,1–86,0 (prom. 8 cortes 80,9) |
| 9036 | 9029 | 9029 sin drifting (contraria) · 8 cortes (MCD) | jr | 13/11 | terminó | 202107: AUC 0,9317 · prom. 1300–3500: 95,2 · máx. suav. 98,7 M en 2300 (meseta 2100–2500; 8,6–10,2 envíos por BAJA+2) | 75,3–95,5 (prom. 8 cortes 85,7) |
| 9037 | 9029 | 9029 con dólar blue en lugar de IPC · 8 cortes (MCD) | jr | 13/11 | terminó | 202107: AUC 0,9326 · prom. 1300–3500: 93,5 · máx. suav. 96,5 M en 2300 (meseta 2200–2500; 9,0–10,2 envíos por BAJA+2) | 75,9–90,5 (prom. 8 cortes 83,7) |
| 9038 | 9029 | 9029 + rank de monetarias (average) · 8 cortes (MCD) | jr | 13/11 | terminó | 202107: AUC 0,9353 · prom. 1300–3500: 98,4 · máx. suav. 100,8 M en 2600 (meseta 2000–2700; 8,2–11,1 envíos por BAJA+2) | 79,7–94,1 (prom. 8 cortes 86,6) |
| 9039 | 9029 | 9029 + rank de monetarias y 8 cantidades transaccionales (average) · 8 cortes (MCD) | jr | 13/11 | terminó | 202107: AUC 0,9335 · prom. 1300–3500: 94,3 · máx. suav. 98,7 M en 2500 (meseta 2300–2600; 9,4–10,7 envíos por BAJA+2) | 78,6–88,9 (prom. 8 cortes 84,7) |
| 9040 | 9039 | 9039 con empates del rank al azar, `set.seed` fijo (semilla 1) · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9339 · prom. 1300–3500: 96,0 · máx. suav. 100,4 M en 2400 (meseta 2200–2600; 9,0–10,7 envíos por BAJA+2) | 75,4–91,0 (prom. 8 cortes 85,9) |
| 9041 | 9039 | 9039 con empates al azar, `set.seed` fijo (semilla 2) · 8 cortes (MCD) | jr | 13/11 | terminó | 202107: AUC 0,9347 · prom. 1300–3500: 96,8 · máx. suav. 101,6 M en 2600 (meseta 2500–2800; 10,2–11,5 envíos por BAJA+2) | 76,5–95,3 (prom. 8 cortes 87,3) |
| 9042 | 9039 | 9039 con empates al azar distintos en cada semilla, RF recalculado en cada una (D3a) · 8 cortes (MCD) | jr | 13/11 | terminó | 202107: AUC 0,9348 · prom. 1300–3500: 96,5 · máx. suav. 99,8 M en 2600 (meseta 2200–2800; 9,0–11,5 envíos por BAJA+2) | 75,3–91,2 (prom. 8 cortes 84,7) |
| 9043 | 9039 | 9039 con empates al azar en cada semilla, RF una vez sin las columnas de rank (D3b) · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9344 · prom. 1300–3500: 97,5 · máx. suav. 101,2 M en 2400 (meseta 2200–2800; 9,0–11,5 envíos por BAJA+2) | 76,0–90,6 (prom. 8 cortes 84,7) |
| 9044 | 9123 | 9123 con dólar blue · sin modelo final ni Kaggle | jr2 | 13/11 | terminó | 202105: AUC 0,9300 · prom. 1300–3500: 50,5 · escalada 51,9 · máx. suav. 53,7 M en 1900 (meseta 1800–2400; 10,0–13,3 envíos por BAJA+2) | — |
| 9045 | 9223 | 9223 con dólar blue · sin modelo final ni Kaggle | jr | 13/11 | terminó | 202103: AUC 0,9169 · prom. 1300–3500: 36,3 · escalada 42,4 · máx. suav. 44,8 M en 1000 (meseta 800–1600; 4,5–9,1 envíos por BAJA+2) | — |
| 9046 | 9123 | 9123 + rank de monetarias (average, como 9034) · sin modelo final ni Kaggle | jr2 | 13/11 | terminó | 202105: AUC 0,9313 · prom. 1300–3500: 52,4 · escalada 54,3 · máx. suav. 56,1 M en 2100 (meseta 1800–2300; 10,0–12,8 envíos por BAJA+2) | — |
| 9047 | 9223 | 9223 + rank de monetarias (average, como 9034) · sin modelo final ni Kaggle | jr | 13/11 | terminó | 202103: AUC 0,9242 · prom. 1300–3500: 40,0 · escalada 43,9 · máx. suav. 49,8 M en 1000 (meseta 800–1100; 4,5–6,2 envíos por BAJA+2) | — |
| 9048 | 9031 | 9031 sin `internet` · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9353 · prom. 1300–3500: 97,1 · máx. suav. 100,5 M en 2300 (meseta 1900–2600; 7,8–10,7 envíos por BAJA+2) | 75,8–90,5 (prom. 8 cortes 84,4) |
| 9049 | 9123 | 9123 sin `internet` · sin modelo final ni Kaggle | jr2 | 13/11 | terminó | 202105: AUC 0,9304 · prom. 1300–3500: 49,5 · escalada 50,9 · máx. suav. 52,1 M en 2100 (meseta 1800–2700; 10,0–15,0 envíos por BAJA+2) | — |
| 9050 | 9223 | 9223 sin `internet` · sin modelo final ni Kaggle | jr | 13/11 | terminó | 202103: AUC 0,9236 · prom. 1300–3500: 40,0 · escalada 44,5 · máx. suav. 48,8 M en 1000 (meseta 800–1200; 4,5–6,8 envíos por BAJA+2) | — |
| 9051 | 9031 | 9031 con peso 3 en 201908 a 201911 (electoral, exploración) · 8 cortes (MCD) | jr | 13/11 | terminó | 202107: AUC 0,9348 · prom. 1300–3500: 97,0 · máx. suav. 100,2 M en 2400 (meseta 2100–2600; 8,6–10,7 envíos por BAJA+2) | 79,2–87,0 (prom. 8 cortes 84,4) |
| 9052 | 9031 | H0: 9031 sin lags, deltas ni tendencias (contraria) · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9274 · prom. 1300–3500: 93,4 · máx. suav. 97,3 M en 2100 (meseta 1800–2200; 7,4–9,0 envíos por BAJA+2) | 67,1–82,7 (prom. 8 cortes 75,0) |
| 9053 | 9031 | H1: 9031 + valor / promedio de los 6 meses anteriores y máximo / promedio · 8 cortes (MCD) | jr | 13/11 | terminó | 202107: AUC 0,9363 · prom. 1300–3500: 97,6 · máx. suav. 101,8 M en 2200 (meseta 2000–2400; 8,2–9,8 envíos por BAJA+2) | 75,3–89,7 (prom. 8 cortes 83,4) |
| 9054 | 9031 | H2: 9031 + lags y deltas de 3, 6 y 12 · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9329 · prom. 1300–3500: 94,6 · máx. suav. 98,1 M en 2100 (meseta 1600–2400; 6,6–9,8 envíos por BAJA+2) | 69,5–83,0 (prom. 8 cortes 76,4) |
| 9055 | 9031 | H3: 9031 + tendencia, mínimo y máximo en ventanas de 3, 6 y 12 · 8 cortes (MCD) | jr | 13/11 | terminó | 202107: AUC 0,9339 · prom. 1300–3500: 95,4 · máx. suav. 100,8 M en 1800 (meseta 1700–2000; 7,0–8,2 envíos por BAJA+2) | sin dato |
| 9056 | 9031 | I0: 9031 sin las intra-mes de la cátedra (contraria) · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9353 · prom. 1300–3500: 96,1 · máx. suav. 98,2 M en 2200 (meseta 1700–2500; 7,0–10,2 envíos por BAJA+2) | 77,1–87,9 (prom. 8 cortes 82,8) |
| 9057 | 9031 | I1: 9031 + 15 variables de negocio · 8 cortes (MCD) | jr | 13/11 | terminó | 202107: AUC 0,9335 · prom. 1300–3500: 94,8 · máx. suav. 97,0 M en 2600 (meseta 1700–2800; 7,0–11,5 envíos por BAJA+2) | 75,7–87,6 (prom. 8 cortes 82,5) |
| 9058 | 9031 | I3: 9031 + ratios entre pares de las 25 monetarias · 8 cortes (MCD) | jr | 13/11 | terminó | 202107: AUC 0,9353 · prom. 1300–3500: 97,4 · máx. suav. 100,0 M en 2400 (meseta 1800–2700; 7,4–11,1 envíos por BAJA+2) | 73,7–84,4 (prom. 8 cortes 80,0) |
| 9059 | 9031 | I2: 9031 + COVID del AMBA y nacional · 8 cortes (CF) | jr2 | 13/11 | terminó | 202107: AUC 0,9348 · prom. 1300–3500: 96,9 · máx. suav. 98,0 M en 2600 (meseta 1600–2900; 6,6–11,9 envíos por BAJA+2) | 75,9–87,4 (prom. 8 cortes 84,2) |
| 9060 | 9123 | H1 en 202105 · sin Kaggle | jr2 | 14/11 | terminó | 202105: AUC 0,9296 · prom. 1300–3500: 50,2 · escalada 52,8 · máx. suav. 54,0 M en 1800 (meseta 1600–2000; 8,9–11,1 envíos por BAJA+2) | — |
| 9061 | 9223 | H1 en 202103 · sin Kaggle | jr | 14/11 | terminó | 202103: AUC 0,9222 · prom. 1300–3500: 40,2 · escalada 44,3 · máx. suav. 47,0 M en 800 (meseta 800–1000; 4,5–5,7 envíos por BAJA+2) | — |
| 9062 | 9123 | I2 en 202105 · sin Kaggle | jr2 | 14/11 | terminó | 202105: AUC 0,9304 · prom. 1300–3500: 49,3 · escalada 51,2 · máx. suav. 52,5 M en 2100 (meseta 1500–2200; 8,3–12,2 envíos por BAJA+2) | — |
| 9063 | 9223 | I2 en 202103 · sin Kaggle | jr | 14/11 | terminó | 202103: AUC 0,9226 · prom. 1300–3500: 39,7 · escalada 44,6 · máx. suav. 49,6 M en 1000 (meseta 900–1100; 5,1–6,2 envíos por BAJA+2) | — |
| 9064 | 9123 | I3 en 202105 · sin Kaggle | jr2 | 14/11 | terminó | 202105: AUC 0,9293 · prom. 1300–3500: 53,4 · escalada 55,5 · máx. suav. 59,6 M en 2400 (meseta 2300–2500; 12,8–13,9 envíos por BAJA+2) | — |
| 9065 | 9223 | I3 en 202103 · sin Kaggle | jr | 14/11 | terminó | 202103: AUC 0,9217 · prom. 1300–3500: 40,6 · escalada 44,6 · máx. suav. 47,3 M en 900 (meseta 800–1300; 4,5–7,4 envíos por BAJA+2) | — |
| 9066 | 9123 | Electoral (peso 3 en 201908 a 201911) en 202105 · sin Kaggle | jr2 | 14/11 | terminó | 202105: AUC 0,9287 · prom. 1300–3500: 49,8 · escalada 51,6 · máx. suav. 53,8 M en 1800 (meseta 1500–2000; 8,3–11,1 envíos por BAJA+2) | — |
| 9067 | 9223 | Electoral en 202103 · sin Kaggle | jr | 14/11 | terminó | 202103: AUC 0,9221 · prom. 1300–3500: 40,7 · escalada 43,5 · máx. suav. 47,2 M en 1000 (meseta 800–1100; 4,5–6,2 envíos por BAJA+2) | — |
| 9068 | z728 | z728_final_junior_power de la cátedra, tal cual (20 semillas, grid por AUC) · 7 cortes, 1700 a 2300 (MCD) · no guarda la validación por semilla | jr | 14/11 | terminó | — (no guarda la validación por semilla) | ver Kaggle (MCD) |
| 9069 | 9031 | V1: 9031 sin `numero_de_cliente` ni `foto_mes` · 8 cortes (CF) | jr2 | 14/11 | terminó | 202107: AUC 0,9350 · prom. 1300–3500: 94,8 · máx. suav. 98,5 M en 1900 (meseta 1800–2700; 7,4–11,1 envíos por BAJA+2) | 73,1–89,6 (prom. 8 cortes 83,1) |
| 9070 | 9123 | V1 en 202105 · sin Kaggle | jr2 | 14/11 | terminó | 202105: AUC 0,9249 · prom. 1300–3500: 46,9 · escalada 49,4 · máx. suav. 50,8 M en 1400 (meseta 1200–2400; 6,7–13,3 envíos por BAJA+2) | — |
| 9071 | 9223 | V1 en 202103 · sin Kaggle | jr2 | 14/11 | terminó | 202103: AUC 0,9175 · prom. 1300–3500: 39,4 · escalada 44,5 · máx. suav. 46,2 M en 1000 (meseta 800–2000; 4,5–11,4 envíos por BAJA+2) | — |
| 9072 | 9031 | V2: 9031 sin canaritos · 8 cortes (CF) | jr2 | 14/11 | terminó | 202107: AUC 0,9351 · prom. 1300–3500: 95,3 · máx. suav. 98,9 M en 2100 (meseta 1900–2100; 7,8–8,6 envíos por BAJA+2) | 80,2–88,6 (prom. 8 cortes 84,3) |
| 9073 | 9123 | V2 en 202105 · sin Kaggle | jr2 | 14/11 | terminó | 202105: AUC 0,9323 · prom. 1300–3500: 52,4 · escalada 54,8 · máx. suav. 56,4 M en 1800 (meseta 1600–2000; 8,9–11,1 envíos por BAJA+2) | — |
| 9074 | 9223 | V2 en 202103 · sin Kaggle | jr2 | 14/11 | terminó | 202103: AUC 0,9226 · prom. 1300–3500: 38,0 · escalada 42,3 · máx. suav. 46,6 M en 1400 (meseta 700–1500; 4,0–8,5 envíos por BAJA+2) | — |
| 9075 | 9031 | V3: 9031 con los hiperparámetros de Maylén (ExpCol 10 B) · 8 cortes (CF) | jr2 | 14/11 | terminó | 202107: AUC 0,9326 · prom. 1300–3500: 90,4 · máx. suav. 95,3 M en 2100 (meseta 1900–2300; 7,8–9,4 envíos por BAJA+2) | 74,1–85,5 (prom. 8 cortes 79,5) |
| 9076 | 9123 | V3 en 202105 · sin Kaggle | jr2 | 15/11 | terminó | 202105: AUC 0,9319 · prom. 1300–3500: 54,8 · escalada 57,3 · máx. suav. 60,0 M en 1600 (meseta 1400–1800; 7,8–10,0 envíos por BAJA+2) | — |
| 9077 | 9223 | V3 en 202103 · sin Kaggle | jr2 | 15/11 | terminó | 202103: AUC 0,9233 · prom. 1300–3500: 39,2 · escalada 43,7 · máx. suav. 47,4 M en 1200 (meseta 900–1300; 5,1–7,4 envíos por BAJA+2) | — |
| 9078 | 9031 | V4: 9031 con clase ingenua (positivos solo BAJA+2) · 8 cortes (CF, por error) | jr2 | 15/11 | terminó | 202107: AUC 0,9329 · prom. 1300–3500: 97,2 · máx. suav. 100,9 M en 2500 (meseta 2300–2700; 9,4–11,1 envíos por BAJA+2) | 73,4–82,1 (prom. 8 cortes 77,2) |
| 9079 | 9123 | V4 en 202105 · sin Kaggle | jr2 | 15/11 | terminó | 202105: AUC 0,9257 · prom. 1300–3500: 48,1 · escalada 49,6 · máx. suav. 50,8 M en 2200 (meseta 1800–2400; 10,0–13,3 envíos por BAJA+2) | — |
| 9080 | 9223 | V4 en 202103 · sin Kaggle | jr2 | 15/11 | terminó | 202103: AUC 0,9171 · prom. 1300–3500: 35,5 · escalada 42,2 · máx. suav. 45,8 M en 1200 (meseta 1000–1300; 5,7–7,4 envíos por BAJA+2) | — |
| 9081 | 9031 | V5: 9031 con clase intermedia (BAJA+1 positivo con peso 0,5) · 8 cortes (CF, por error) | jr2 | 15/11 | terminó | 202107: AUC 0,9352 · prom. 1300–3500: 96,0 · máx. suav. 98,2 M en 2800 (meseta 1700–2900; 7,0–11,9 envíos por BAJA+2) | 76,0–87,9 (prom. 8 cortes 83,1) |
| 9082 | 9123 | V5 en 202105 · sin Kaggle | jr2 | 15/11 | terminó | 202105: AUC 0,9294 · prom. 1300–3500: 51,9 · escalada 53,0 · máx. suav. 54,1 M en 1500 (meseta 1400–2700; 7,8–15,0 envíos por BAJA+2) | — |
| 9083 | 9223 | V5 en 202103 · sin Kaggle | jr2 | 15/11 | terminó | 202103: AUC 0,9235 · prom. 1300–3500: 40,6 · escalada 43,8 · máx. suav. 48,6 M en 1000 (meseta 900–1100; 5,1–6,2 envíos por BAJA+2) | — |
| 9084 | 9031 | Verificación de la versión con tendencia: la notebook de la entrega de ese momento, desde cero · 9 CSV (1900 a 2700) sin subir | jr | 15/11 | terminó | 202107: AUC 0,9353 · prom. 1300–3500: 95,0 · máx. suav. 97,4 M en 2800 (meseta 2600–2800; 10,7–11,5 envíos por BAJA+2) | — |
| 9085 | 9031 | 9031 con las rotas en NA (`PARAM$CA$metodo <- "MachineLearning"`): **candidata final** · 8 cortes (MCD) y 7 (CF), entre ellos el envío final (1800) | jr2 | 15/11 | terminó | 202107: AUC 0,9345 · prom. 1300–3500: 95,6 · máx. suav. 97,6 M en 1800 (meseta 1600–2000; 6,6–8,2 envíos por BAJA+2) | MCD: 77,3–97,1 (prom. 8 cortes 88,3) · CF: 85,5–95,1 (7 cortes; 1800: 92,6) |
| 9086 | 9123 | 9123 con las rotas en NA · sin Kaggle | jr2 | 15/11 | terminó | 202105: AUC 0,9318 · prom. 1300–3500: 51,3 · escalada 53,5 · máx. suav. 54,5 M en 1500 (meseta 1400–2400; 7,8–13,3 envíos por BAJA+2) | — |
| 9087 | 9223 | 9223 con las rotas en NA · sin Kaggle | jr2 | 15/11 | terminó | 202103: AUC 0,9240 · prom. 1300–3500: 40,6 · escalada 45,6 · máx. suav. 48,6 M en 1000 (meseta 800–1200; 4,5–6,8 envíos por BAJA+2) | — |
| 9088 | 9085 | Verificación de la entrega: `cpf_final_analista_jr.ipynb` desde cero · 13 CSV (1500 a 2700) sin subir | jr2 | 15/11 | terminó | 202107: AUC 0,9345 · prom. 1300–3500: 95,6 · máx. suav. 97,6 M en 1800 (meseta 1600–2000; 6,6–8,2 envíos por BAJA+2) | — |

9001 y 9002 se vuelven a correr el 07/11 solo para la validación por semilla (misma carpeta, sin envíos). Los resultados de la tabla son los de la primera corrida.

Validación: ganancia del semillerío en los cortes 1300 a 2200 de a 100, en millones (desde 9008, "prom." es el promedio de esa ventana y "máx. suav." el máximo de la curva suavizada de 1000 a 5000, con su meseta). Public: desde 9008, los 23 cortes de 1300 a 3500. Public: los 10 envíos de 1300 a 2200. El 07/11 se subieron además los cortes 2300 a 3500 de 9004 a 9007 con `enviar_cortes.sh` (sin volver a entrenar).

Desde 9030 (filas armadas el 15/11 desde la `prediccion_validacion.txt` de cada carpeta): AUC del semillerío, promedio de la ventana general 1300 a 3500, ventana escalada en 202105 (1000 a 2600) y 202103 (900 a 2500), máximo de la curva suavizada de 500 a 5000 y meseta en envíos y en envíos por BAJA+2 (244, 180 y 176). Public: mínimo, máximo y promedio de los cortes de `comparaciones/envios_kaggle.txt`. VM y cuenta de Kaggle según el script de cada cola.

Las corridas 9001 y 9002 se lanzaron desde `PredFinal` del fork, antes de crear este repositorio; el código es el mismo que el de los notebooks de acá.

### Lectura de 9001 y 9002 (04/11)

- **No se distinguen.** En 202107 un BAJA+2 vale 975 mil: las diferencias entre las dos son de uno o dos clientes. En el Public un BAJA+2 vale 3,25 M y la diferencia promedio entre ellas (0,8 M) es menor; dentro de un mismo modelo, el Public salta casi 9 M entre cortes vecinos.
- **9002 rinde igual en 8 minutos contra 39,** y su ganancia en 202107 es más pareja entre cortes (meseta más plana).
- **La Bayesian Optimization de 9001 terminó en el borde:** `num_iterations` 1019 (máximo del rango, 1024) y `learning_rate` 0,012 (cerca del mínimo, 0,008). Si se vuelve a usar, ampliar el rango. Además, eligió mirando 202107: su validación sale algo optimista.
- **El máximo de 9001 en 202107 cayó en 2639 envíos,** fuera del rango de cortes. Tenerlo en cuenta al fijar los cortes.
- **Las variables de hojas de Random Forest (`rf_…`) aparecen arriba en la importancia de las dos:** la etapa propia del Senior parece aportar.
- Para comparar con un test hacen falta resultados por semilla en validación; hoy la celda `VAL` guarda solo el promedio del semillerío.

### Lectura de 9001 a 9007 (07/11)

- **Bayesian contra inesperados, con 30 semillas cada una (9005 contra 9004):** el modelo suelto de la Bayesian es mucho mejor (gana en 29 de 30 semillas), pero el semillerío de los inesperados gana: 94,3 M contra 92,9 M. De acá sale el cambio de regla.
- **En la Bayesian, pasar de 10 a 30 semillas no suma (9001 contra 9005):** 93,1 M contra 92,9 M. Cada modelo ya rinde casi como el semillerío (desvío entre semillas 0,9 M).
- **Sin undersampling en la validación (9003):** cada semilla suelta se derrumba (AUC entre 0,78 y 0,90), pero el semillerío casi no cambia (93,6 M contra 94,0 M de 9002). Como el modelo final entrena sin undersampling, lo que se sube se parece más a 9003 que a 9002. Ideas que salen de acá, en pendientes.
- **`min_data_in_leaf` (9006 y 9007 contra 9004):** las tres quedan dentro de 1 M en validación, que es más o menos un BAJA+2. Con un solo número no se puede decir cuál es mejor: falta el remuestreo. El Public de 9006 (prom. 92,0, 96,0 en 1800) es el más alto hasta ahora, pero no decide.
- **Cortes:** los máximos en validación caen en 1978 a 3029 envíos, varios fuera del rango 1300 a 2200. La curva de cortes de 1000 a 5000 dice dónde está la meseta.
- **Tiempos:** inesperados con 30 semillas, unos 10 minutos; Bayesian con 30 semillas reutilizando la optimización, 47 minutos.

### Lectura de 9008 a 9013 (08/11)

Comparación contra 9004 con `comparar_corridas.sh` (remuestreo de semillas y clientes, 1000 repeticiones). P = probabilidad de que la corrida gane a 9004, remuestreando semillas y clientes.

| Corrida | Ventana 1300–2200: diferencia (P) | Ventana 1800–2800: diferencia (P) | Lectura |
|---|---|---|---|
| 9008 `E05-A` | +1,8 M (0,76) | +2,9 M (0,88; solo semillas 0,99) | La mejor hasta ahora; cerca del umbral propuesto. Corre la meseta hacia arriba (2000–2700) |
| 9009 `E05-A` + `E05-TEND` | +0,7 M (0,58) | +1,6 M (0,69) | Anular la tendencia no suma sobre 9008; si algo, resta |
| 9011 `E05-R` | −0,7 M (0,37) | +0,3 M (0,57) | La pandemia restringida no mueve nada: coincide con el ExpCol 05, donde la tendencia estaba en la amplia |
| 9010 `TS-2021` | −13,6 M (0,002) | −10,5 M (0,002) | Mucho peor: con el dataset Jr, sacar la historia anterior a 2021 pierde mucho |
| 9012 `TS-2103` | −15,9 M (0,000) | −12,9 M (0,004) | Igual que 9010, y peor. La receta del #07 A (dataset gerencial) no se traslada al Jr. Ojo: los hiperparámetros inesperados (`min_data_in_leaf` 711) no se reajustaron a un training más chico |
| 9013 `TS-SINUS` + `MDL-US` | +0,2 M (0,54) | +0,7 M (0,63) | Empata con 9004 en el semillerío, pero contra 9003 (también sin undersampling, con 711) gana en las 10 semillas en común (+4,3 M, P solo semillas 0,94): escalar `min_data_in_leaf` arregla el derrumbe de cada semilla sin undersampling. Responde la pregunta de Silvina: sí, hay que transformarlo |

Controles: en las seis, las notebooks corrieron completas (todas las celdas ejecutadas), 30 modelos y 23 envíos cada una, y el AUC recalculado coincide con el guardado. `E05-A` dejó en NA el lag 1 de 245.266 filas y el lag 2 de 244.472 (pandemia amplia, 8 meses); `E05-R`, 150.803 y 150.303 (5 meses). Cada corrida tardó de 3 a 5 minutos sin contar los envíos.

Lo que queda para decidir: la ventana de cortes (con 1800–2800 las diferencias crecen y 9008 queda cerca de 0,90), el umbral de la regla, y si 9008 pasa como candidata al bloque siguiente. Las mesetas de las mejores corridas caen entre 1800 y 2900.

### Lectura de 9014 (09/11)

Cuarta celda del 2 × 2 pandemia × undersampling. Remuestreo de semillas y clientes (P = probabilidad de que 9014 gane):

| Comparación | Ventana | Diferencia | P (semillas y clientes) | P solo semillas / solo clientes |
|---|---|---|---|---|
| 9014 contra 9004 | 1300–3500 | +3,4 M | 0,93 | 0,999 / 0,984 |
| 9014 contra 9008 (`E05-A` solo) | 1300–3500 | +1,1 M | 0,74 | 0,87 / 0,91 |
| 9014 contra 9013 (`TS-SINUS` + `MDL-US` solo) | 1300–2200 | +2,4 M | 0,80 | 0,94 / 0,82 |

- **Es la primera corrida que pasa el umbral propuesto contra 9004** (P 0,93). Es candidata, no confirmada: falta evidencia que no se usó para encontrarla (otras semillas, otro mes).
- **Los dos cambios no se pisan.** Promedio de la ventana 1300–3500, sin remuestreo: 9004 93,2 M; 9008 95,3 (+2,1); 9013 94,3 (+1,0); 9014 97,0 (+3,8). La suma de los dos efectos sueltos da +3,1 M, y juntos dan +3,8: si algo, se potencian, pero la diferencia (0,7 M, menos de un BAJA+2) está dentro del ruido. (La columna "Diferencia" de la tabla es la media del remuestreo, por eso no coincide exacto.)
- **El semillerío aporta más que en 9004 y 9008.** El modelo suelto rinde igual o peor (87,3 M contra 87,9 de 9004 y 89,6 de 9008; 9008 gana en 20 de 30 semillas), pero el semillerío de 30 llega a 97,0 M y la curva de semillas sigue subiendo de 20 a 30 (96,6 a 97,0). Es el patrón de 9004 contra 9005: modelos más distintos entre sí. Sumar semillas todavía puede aportar.
- **La meseta se corre hacia arriba:** 2100 a 2700 (9004: 1700 a 2600), y la caída después de 3000 es más lenta.
- **El Public va al revés** (prom. 81,2, igual que 9004; máximo 96,3 en 1400 y cae desde 2000, justo donde la validación tiene la meseta). Se registra; no decide.
- Falta la comparación contra 9013 con la ventana 1300–3500. El resumen de 9014 se armó antes de los controles automáticos: no tiene la sección 0.

### Lectura del bloque Catastrophe Analysis sobre 9004 (10/11)

Ventana 1300 a 3500, remuestreo de semillas y clientes (P = probabilidad de que la corrida gane):

| Comparación | Diferencia | P (semillas y clientes) | P solo semillas / solo clientes |
|---|---|---|---|
| 9015 interpolar contra 9004 (NA) | +0,6 M | 0,63 | 0,77 / 0,64 |
| 9016 tendencia contra 9004 (NA) | +1,7 M | 0,80 | 0,96 / 0,87 |
| 9016 tendencia contra 9015 interpolar | +1,1 M | 0,84 | 0,94 / 0,97 |

Ninguna llega a 0,90, pero las tres van en la misma dirección: reconstruir los valores rotos con la historia del cliente rinde algo más que dejarlos en NA, y la tendencia (6 meses vecinos) más que interpolar (2). Coincide con el #01 B (interpolar +1,0 M, no significativo). Falta ver el efecto sobre 9014 (9017 y 9018), donde el CA pesa en menos meses.

MICE (9019 PMM y 9020 CART) no corrió: la versión con todas las filas y todos los predictores completos es demasiado pesada (CART llegó a 56 GB) y la regresión de PMM encontró predictores colineales. Queda en pausa: para que sea viable habría que entrenar la imputación solo con los meses vecinos y con menos predictores.

### Lectura del bloque Catastrophe Analysis sobre 9014 (11/11)

Ventana 1300 a 3500, remuestreo de semillas y clientes (P = probabilidad de que la segunda corrida gane a la primera):

| Comparación | Promedio de la ventana | Diferencia (media del remuestreo, 5 % a 95 %) | P (semillas y clientes) | P solo semillas / solo clientes |
|---|---|---|---|---|
| 9017 interpolar contra 9014 (NA) | 94,9 contra 97,0 | −1,5 M (−4,8 a +1,7) | 0,213 | 0,061 / 0,051 |
| 9018 tendencia contra 9014 (NA) | 95,0 contra 97,0 | −1,8 M (−5,2 a +1,6) | 0,186 | 0,053 / 0,057 |
| 9018 tendencia contra 9017 interpolar | 95,0 contra 94,9 | −0,2 M (−2,4 a +1,9) | 0,428 | 0,402 / 0,418 |

- **Sobre 9014, reconstruir no suma.** Interpolar y tendencia quedan unos 2 M abajo de dejar los NA. Ninguna cruza la regla en contra (9014 gana con P 0,787 y 0,814); cada eje por separado da P 0,061 y 0,053, pero con semillas y clientes juntos el rango cruza el cero.
- **Con la pandemia afuera el CA casi no tiene dónde actuar.** Con la pandemia amplia afuera, el CA toca solo 14 pares variable-mes, todos de 2019 (201904, 201905 y 201910): la diferencia contra 9014 es más probablemente ruido que un efecto. Sobre 9004 el CA sumaba (9015 +0,6 M, P 0,63; 9016 +1,7 M, P 0,80). La interacción CA × pandemia queda como hipótesis: el mes que pesa es 202006 (15 variables), que solo entra con la pandemia adentro.
- **Qué rompe el CA en el dataset Jr (verificado el 11/11 contando ceros por mes):** de las 47 variables de `Corregir_Rotas` solo existen 16 en el Jr (`internet`, `mrentabilidad`, `mrentabilidad_annual`, `mcomisiones`, `mactivos_margen`, `mpasivos_margen`, `mcuentas_saldo`, `ctarjeta_visa_transacciones`, `mtarjeta_visa_consumo`, `ctarjeta_master_transacciones`, `mtarjeta_master_consumo`, `mttarjeta_visa_debitos_automaticos`, `ccomisiones_otras`, `ccallcenter_transacciones`, `thomebanking`, `chomebanking_transacciones`); `Corregir_atributo` saltea las otras sin avisar. Los meses rotos son solo cuatro: 201904 (1 variable), 201905 (6), 201910 (7) y 202006 (15). En los 29 pares variable-mes, el mes roto tiene 100 % de ceros. 202002, 202009, 202010, 202102 y 202105 figuran en la lista de la cátedra solo por variables que el Jr no tiene.
- **Interpolar y tendencia empatan entre sí** (P 0,428); la ventaja de la tendencia sobre 9004 (P 0,84) no se repite.
- AUC recalculado igual al guardado en las tres. Semilla por semilla (diagnóstico): 9014 gana en 17 y 18 de 30.

### Pandemia arreglada adentro contra sacarla, con undersampling como 9004 (11/11)

Pregunta de Carla: ¿se está comparando meter los meses arreglados contra sacarlos (amplia y restringida)? Con las corridas que ya había, con undersampling y `min_data_in_leaf` 711, como 9004, donde lo único que cambia es qué se hace con la pandemia. Ventana 1300 a 3500, remuestreo de semillas y clientes (P = probabilidad de que 9016 gane):

| Comparación | Promedio de la ventana | Diferencia (media del remuestreo, 5 % a 95 %) | P (semillas y clientes) | P solo semillas / solo clientes |
|---|---|---|---|---|
| 9016 (tendencia, adentro) contra 9008 (amplia afuera) | 94,9 contra 95,3 | −0,6 M (−3,6 a +2,2) | 0,372 | 0,234 / 0,320 |
| 9016 (tendencia, adentro) contra 9011 (restringida afuera) | 94,9 contra 94,1 | +0,7 M (−2,7 a +4,0) | 0,647 | 0,777 / 0,642 |

- **Arreglar con tendencia y meter la pandemia empata con sacarla.** Las tres quedan dentro de 1,2 M, con rangos que cruzan el cero; ninguna P se acerca a 0,90 en ninguna dirección.
- **La hipótesis del 11/11 (si se la corrige bien, quizás convenga incluirla) no se sostiene con tendencia, pero tampoco se descarta.** Falta MICE (9021 y 9022), que entra en esta misma comparación.
- La restringida saca también 202006 (cae en 202003 a 202007): con amplia o restringida afuera, el CA casi no tiene dónde actuar.
- **Para la decisión final falta la celda sin undersampling** (`min_data_in_leaf` 3555, como 9013) con la pandemia adentro y el mejor arreglo, contra 9014: 9014 cambia la pandemia y el undersampling a la vez, así que no se compara directo con 9016.

### Prueba de enmascarado del CA (11/11)

Para elegir el método de imputación antes de gastar corridas: `prueba_enmascarado.R` borra a propósito, en meses sanos, las 16 variables que se rompen en el Jr, las reconstruye con cada método y compara contra el valor real. Meses: tres normales (201912, 202102, 202104) y uno de pandemia (202007, el de vecinos más parecidos a los de 202006: distancia 2,09 contra 2,77 de 202005), reportados por separado. Métodos: cero y mediana de los vecinos (referencias), interpolar, tendencia, y MICE con PMM y con CART (`cartliviano`) en tres versiones: liviana (±2 meses, historia del cliente y hasta 12 predictores de la fila, `maxit` 1), ±6 meses y todos los predictores. Control al principio de la salida: en los 29 pares rotos reales, 0 ceros y todo NA (si no, los ceros falsos de 202006 entrarían como vecinos de 202007).

Imputar mejor no garantiza ganar más: la prueba elige qué métodos vale la pena correr; la decisión sigue saliendo de `comparar_corridas.sh`.

**Verificación de `cartliviano` contra `mice.impute.cart`** (modo rápido, commit `5865e70`, mes 201912, mismos datos y predictores; salida en `~/buckets/b1/exp/CA_enmascarado/enmascarado_rapido.txt`):

| Variable | Método | Media | p10 | p50 | p90 | Ceros | Segundos | Memoria máx. |
|---|---|---|---|---|---|---|---|---|
| `ctarjeta_visa_transacciones` | `cartliviano` | 14,1 | 0 | 9 | 33 | 0,148479108 | 4,6 | 2036 MB |
| | `mice.impute.cart` | 14,1 | 0 | 9 | 34 | 0,149265468 | 12,9 | 2498 MB |
| | valor real | 13,8 | 0 | 9 | 33 | 0,150159059 | | |
| `mrentabilidad` | `cartliviano` | 2588,9 | −639,0 | 1229,7 | 6772,7 | 0,003288415 | 1,7 | 1234 MB |
| | `mice.impute.cart` | 2616,1 | −633,8 | 1245,5 | 6676,1 | 0,002823748 | 8,3 | 2114 MB |
| | valor real | 2267,7 | −629,0 | 1271,4 | 5790,7 | 0,002966723 | | |

Las dos versiones dan la misma distribución: sus diferencias son menores que las de cada una contra el valor real y van en las dos direcciones, como dos sorteos del mismo método. `internet` no se comparó con el original porque es justo donde se queda sin memoria; con `cartliviano` usó 2,0 a 2,4 GB (antes 15,6 a 39,4 GB). Ningún fit de PMM tuvo que subir `ridge` (no apareció la matriz singular de 9019).

**Resultados de la prueba completa** (11/11, jr2, 31 minutos, memoria máxima 1,8 GB, los cuatro controles `[OK]`, ninguna falla; salida en `verificaciones/enmascarado_resumen.txt`). CART es siempre `cartliviano`. Mediana de `error_rel` (error contra el de imputar la mediana del mes; menos es mejor) y diferencia media en la proporción de ceros:

| Método | `error_rel` normales | `error_rel` 202007 | Dif. ceros normales | Dif. ceros 202007 |
|---|---|---|---|---|
| cero | 1,144 | 1,180 | 0,749 | 0,781 |
| mediana de los vecinos | 1,000 | 1,000 | 0,132 | 0,131 |
| interpolar | 0,410 | 0,466 | 0,017 | 0,006 |
| tendencia | 0,416 | 0,481 | 0,029 | 0,030 |
| PMM liviano | 0,707 | 0,719 | 0,008 | 0,006 |
| CART liviano | 0,685 | 0,677 | 0,003 | 0,003 |
| PMM ±6 meses | 0,687 | 0,661 | 0,009 | 0,007 |
| CART ±6 meses | 0,690 | 0,714 | 0,003 | 0,003 |
| PMM todos los predictores | 0,720 | 0,751 | 0,004 | 0,003 |
| CART todos los predictores | 0,690 | 0,661 | 0,003 | 0,003 |

Lectura:
- En error por cliente ganan interpolar y tendencia (0,41 a 0,48), lejos de MICE (0,66 a 0,75). Variable por variable, tendencia le gana a PMM y a CART en las 16 en los meses normales y en 14 en 202007. Allí pierde `ccallcenter_transacciones` contra PMM (1,278 contra 1,303) y `internet`, donde MICE queda en 0,69 a 0,71 y tendencia en 0,99: el salto de `internet` no se adivina mirando al mismo cliente.
- En la distribución (proporción de ceros) gana MICE, sobre todo CART: 0,003 contra 0,017 a 0,030. Como un cero de más parece un cliente que se va, la diferencia puede importar aunque sea chica.
- Las versiones livianas no pierden contra ±6 meses ni contra todos los predictores, y son las más rápidas. Por eso 9021 y 9022 usan la liviana.
- La pandemia (202007) no cambia el orden entre familias: interpolar y tendencia siguen arriba de MICE en error, y MICE sigue arriba en ceros. Dentro de MICE las versiones se reacomodan (0,66 a 0,75), sin una que se despegue.
- Lo que no dice: cuál gana plata. Interpolar o tendencia aciertan más cliente por cliente; MICE respeta mejor la forma de la distribución. Lo decide `comparar_corridas.sh` (9016 contra 9021 y 9022).

### Lectura de 9021 y 9022: MICE liviano sobre 9004 (12/11)

Las dos corridas completaron el CA sin huecos (`[OK]`, 827918 de 827918 valores reconstruidos; detalle por par en `WF9021/CA_control.txt` y `WF9022/CA_control.txt`) y no tuvieron problemas de memoria ni de matriz singular. Comparaciones con la ventana 1300–3500 (P = probabilidad de que gane B, en "semillas y clientes"; diferencia en millones):

| A | B | P(B gana) | Diferencia media | Intervalo 5–95 % | Pregunta |
|---|---|---|---|---|---|
| 9016 (tendencia) | 9021 (CART) | 0,436 | −0,3 | −3,6 a 3,0 | ¿MICE le gana al CA simple? |
| 9016 (tendencia) | 9022 (PMM) | 0,220 | −0,9 | −3,1 a 1,0 | |
| 9004 (sin CA) | 9021 (CART) | 0,794 | 1,4 | −1,6 a 4,3 | ¿MICE le gana a no tocar nada? |
| 9004 (sin CA) | 9022 (PMM) | 0,646 | 0,8 | −2,2 a 3,8 | |
| 9021 (CART) | 9022 (PMM) | 0,362 | −0,6 | −3,8 a 2,5 | ¿CART o PMM? |
| 9008 (pandemia fuera) | 9021 (CART) | 0,323 | −0,9 | −4,1 a 2,1 | ¿arreglar la pandemia con MICE le gana a sacarla? |
| 9008 (pandemia fuera) | 9022 (PMM) | 0,180 | −1,6 | −4,4 a 1,4 | |
| 9011 (pandemia fuera) | 9021 (CART) | 0,599 | 0,4 | −2,7 a 3,5 | |
| 9011 (pandemia fuera) | 9022 (PMM) | 0,459 | −0,2 | −3,6 a 3,2 | |

Resultados (sin decisión todavía):
- Ninguna comparación llega a 0,90: no hay reemplazo en ninguna dirección.
- MICE no le gana a tendencia: con CART es un empate (0,436) y con PMM la balanza se inclina hacia tendencia (0,220).
- Contra 9004 sin CA, MICE se inclina a favor (0,794 y 0,646), como tendencia (9016: 0,803, +1,7 M), sin llegar a la regla.
- CART contra PMM: empate (0,362).
- Contra sacar la pandemia (9008, 9011) sigue el empate que ya se vio con tendencia (9016: 0,372 y 0,647).
- Coincide con la prueba de enmascarado: la mejor proporción de ceros de MICE no se traduce en ganancia; tendencia, que acierta más cliente por cliente, gana igual o un poco más y es mucho más simple.
- Public (no decide): 9021 prom. 81,6 y 9022 prom. 80,6, debajo de 9016 (83,2) y de 9004 (85,7).

### Lectura de 9023 y 9024 (12/11)

9023 es la celda que faltaba: pandemia adentro con las rotas corregidas por tendencia, sin undersampling, contra 9014 (pandemia afuera, sin undersampling). 9024 prueba hojas más chicas en 9014. Ventana 1300 a 3500, remuestreo de semillas y clientes (P = probabilidad de que la corrida nueva gane):

| Comparación | Promedio de la ventana | Diferencia (media del remuestreo, 5 % a 95 %) | P (semillas y clientes) | P solo semillas / solo clientes |
|---|---|---|---|---|
| 9023 contra 9014 (pandemia afuera, NA, sin undersampling) | 94,7 contra 97,0 | −2,0 M (−5,9 a +1,9) | 0,196 | 0,051 / 0,097 |
| 9023 contra 9016 (pandemia adentro, tendencia, con undersampling) | 94,7 contra 94,9 | −0,3 M (−3,4 a +3,0) | 0,442 | 0,438 / 0,471 |
| 9023 contra 9004 (referencia) | 94,7 contra 93,2 | +1,4 M (−2,1 a +5,2) | 0,718 | 0,914 / 0,831 |
| 9024 (`min_data_in_leaf` 1777) contra 9014 (3555) | 97,6 contra 97,0 | +0,8 M (−2,4 a +3,8) | 0,655 | 0,806 / 0,662 |

- **Ninguna llega a la regla.** Lo más marcado es 9014 sobre 9023 (P 0,804 a favor de 9014; por eje, 0,051 y 0,097). Semilla por semilla, 9014 gana en 24 de 30.
- **Con la pandemia adentro, sacar el undersampling no cambia nada** (9023 empata con 9016). Con la pandemia afuera sí sumaba (9014 contra 9008, +1,1 M, P 0,74).
- **9023 tiene el AUC más alto (0,9350) y la ganancia más baja de las candidatas:** el AUC no ordena igual que la ganancia.
- **9024: cada modelo suelto empeora (9014 gana en 26 de 30 semillas) y el semillerío mejora apenas,** como 9004 contra 9005. El máximo sube a 101,2 M, pero la meseta se angosta (2000–2400 contra 2100–2700).
- Curva de semillas de 20 a 30: 9014 de 96,6 a 97,0; 9024 de 97,3 a 97,6 (siguen subiendo); 9023 de 94,6 a 94,7 (casi plana).
- Controles: todo [OK] en las dos (celdas sin error, 30 de 30 modelos, AUC guardado igual al recalculado, 8 archivos para Kaggle). En 9023 el CA reconstruyó las 16 variables.
- Public (no decide), promedio de los 8 cortes: 9023 85,2; 9024 84,7; 9014 85,4; 9016 83,2.

### Comparaciones que no estaban en la bitácora (12/11)

Salieron en el resumen de estado del 12/11; las comparaciones son anteriores. Ventana 1300 a 3500, remuestreo de semillas y clientes (P = probabilidad de que B gane):

| Comparación (A contra B) | Promedio de la ventana | Diferencia (media del remuestreo, 5 % a 95 %) | P (semillas y clientes) | P solo semillas / solo clientes |
|---|---|---|---|---|
| 9004 contra 9006 (`MDL355`, `min_data_in_leaf` a la mitad) | 93,2 contra 95,4 | +2,1 M (−0,4 a +4,8) | 0,912 | 0,994 / 0,989 |
| 9013 (sin undersampling, pandemia adentro) contra 9014 (sin undersampling, pandemia afuera) | 94,3 contra 97,0 | +2,5 M (−1,1 a +6,1) | 0,876 | 0,990 / 0,947 |

- **9006 pasa la regla contra 9004** con la ventana 1300 a 3500. Es candidata a confirmar, como 9014: con unas 30 comparaciones, por azar pasarían unas 3. Semilla por semilla empatan (9006 gana en 14 de 30).
- **Sin undersampling, sacar la pandemia amplia se acerca a la regla** (P 0,876): coincide con 9023 contra 9014 (P 0,196, a favor de 9014).

### Reproducibilidad: 9029 en las dos VM (13/11)

**Veredicto: la solución es reproducible.** 9029 (9014 con 100 semillas) corrió en la jr y en la jr2, cada una en su carpeta (WF9029_jr y WF9029_jr2), con el mismo procesador (AMD EPYC 7B12) y los mismos 8 hilos en las dos.

| Archivo | Filas y columnas | Columnas idénticas | Diferencia máxima en una probabilidad | Orden de clientes del semillerío | Elegidos | Ganancia | md5 |
|---|---|---|---|---|---|---|---|
| `prediccion_validacion.txt` (202107) | 32.938 × 102, mismos clientes en el mismo orden | 91 de 101 (10 con diferencias) | 1,5e-14 | el mismo | los mismos en 1300, 2300 y 3500 | 96,4 M en la ventana 1300–3500, en las dos | distinto (los archivos difieren en 78 bytes, por dígitos del último decimal) |
| `prediccion.txt` (202109, lo que se sube) | 33.080 × 102, mismos clientes en el mismo orden | 93 de 101 | 2,0e-15 | el mismo | — | — | distinto |
| Archivo de Kaggle (solo 0 y 1) | — | — | — | — | — | — | **igual** en 1300, 2100, 2300, 2400 y 3500 |

**Causa.** No es el hardware: las dos VM tienen el mismo procesador y los mismos hilos. Es el cálculo en paralelo de LightGBM: con varios hilos, las sumas parciales se juntan en un orden que puede variar entre corridas, y la suma en punto flotante no es exactamente asociativa. Por eso la diferencia aparece en el decimal 14 y podría aparecer incluso repitiendo en la misma VM.

**Criterio adoptado:** mismo orden de clientes, mismos elegidos y misma ganancia. El archivo de Kaggle del corte elegido tiene que dar el mismo md5 en las dos VM, y ese md5 va en la entrega. Fijar `num_threads` daría md5 idénticos de las probabilidades, pero cambia los tiempos y no la decisión.

**Hardware confirmado (13/11, 03:36 hora argentina, al lanzar la cola del drifting):** la jr y la jr2 tienen el mismo hardware (AMD EPYC 7B12, 8 hilos, 60 GB). La diferencia en el decimal 14 viene, entonces, de la suma en paralelo de LightGBM.

### Análogo electoral (13/11)

**Contexto.** La clase de 202109 (BAJA+2 = se va en noviembre de 2021) cae en contexto electoral y cambiario. Desde 1983, las legislativas de medio término en contextos conflictivos (2001, 2009, 2013, 2021) vinieron con presión sobre el dólar, y las de contextos calmos (2017) no. 2021 comparte con 2019 el conflicto, pero no el tipo de elección (2019 fue presidencial) ni la magnitud: en 2019 los bancos perdieron el 42 % de los depósitos en dólares desde las PASO; en 2021 cayeron unos US$ 69 M en septiembre, 230 M en octubre y 765 M en noviembre, sobre unos 16.500 M. Limitaciones: el dataset tiene un solo período electoral (2019); sacar plata no es lo mismo que cerrar la cuenta; y el Jr no tiene saldos en dólares, plazos fijos ni inversiones, así que el canal cambiario no se puede mirar directo.

**Lo que mostró la tabla** (documento del 13/11, con el mismo promedio previo en los dos años: los 4 meses que terminan 4 meses antes de las PASO, 201901–201904 y 202102–202105): en 2019 la tasa de BAJA+2 bajó en las PASO (201908, −28 %; 201909, −19 %) y subió en 201910–201911. En 2021 sube hasta 202107 (+22 %). 202109 tiene más actividad que su análogo en variables de cantidad (Master +22,5 %, transacciones del trimestre +12,1 %, Visa +11,9 %). No es "algo muy claro": queda como exploración.

**Por qué se sostiene igual como exploración:** no depende de que la cátedra haya elegido 202109 a propósito; el contexto de ese mes existe igual y la clase la determina noviembre de 2021.

**9027: qué prueba y por qué peso 3.**
- 9027 = 9014 con peso 3 en las filas de 201908 (PASO), 201909 (cepo), 201910 (generales) y 201911, en el entrenamiento de la validación y en el del modelo final. Cada cliente de esos meses cuenta el triple al calcular los errores, como si apareciera tres veces. `min_data_in_leaf` cuenta filas, no pesos, así que no cambia.
- Cuánto pesan esos 4 meses (filas reales): en el entrenamiento de la validación de 202107 (201901 a 202105 sin la pandemia amplia, 21 meses, 599.017 filas, 108.062 de esos meses) pasan del 18,0 % al 39,8 % (28,6 meses equivalentes). En el modelo final (23 meses, 664.846 filas) pasan del 16,3 % al 36,8 %. Con peso 2 serían 30,6 % y 28,0 %.
- El 3 no se puede calibrar, porque ningún mes de validación tiene contexto electoral: es una dosis alta elegida a propósito para buscar una señal. Si con 3 no aparece, con 2 tampoco; si aparece, se prueba 2.
- Antecedente en contra: el ExpCol 7 B encontró que dar más peso a meses viejos empeora (p 0,003).
- Se compara contra 9029 (9014 con las mismas 100 semillas). Juez real: el Public (no hay mes de validación electoral); 202107 queda como control de que no empeora un mes normal. Va con MCD y no entra en el candidato.

### Cómo se elige el envío final (13/11)

Criterios definidos el 13/11, antes de ver los resultados finales. Una fila por candidata; se completa el domingo.

| Candidata | Reproducibilidad: md5 del archivo de Kaggle en las dos VM (excluyente) | P del mes contra la referencia: 202107 / 202105 / 202103 (principal) | P de los tres meses contra la referencia (principal) | Ganancia en la ventana de cada mes (principal) | Meseta: ancho y posición, en envíos y en envíos por BAJA+2 (alto) | Corte de 202109: las dos estimaciones (para el corte) | Curva de semillas (medio) | Desvío entre semillas, C1 (desempate) | Coincidencia de clientes con la referencia, C2 (desempate) | Public, 30 % del future (solo desempate final) |
|---|---|---|---|---|---|---|---|---|---|---|
| 9029 (pandemia afuera, 100 semillas) | | | | | | | | | | |
| 9031 (pandemia adentro, tendencia, 100 semillas) | | | | | | | | | | |
| 9030 (referencia, 100 semillas) | | — | — | | | | | | — | |

- El AUC no elige.
- Plan del domingo: a las 18:00 se elige con la tabla. Si el corte cae entre dos cortes subidos, se genera el corte exacto con `enviar_cortes.sh` desde la predicción guardada, y se sube y marca en CF a las 20:00 (antes de las 23:59).

### Referencia y candidatas por etapa (13/11)

De acá en adelante, todo se compara con 100 semillas.

| Etapa | Mes de validación | Referencia (9004) | Candidata pandemia afuera (9014) | Candidata pandemia adentro, tendencia (9023) |
|---|---|---|---|---|
| 30 semillas | 202107 | 9004 | 9014 | 9023 |
| 100 semillas | 202107 | 9030 | 9029 | 9031 |
| 100 semillas | 202105 | 9104 | 9114 | 9123 |
| 100 semillas | 202103 | 9204 | 9214 | 9223 |

### Lectura preliminar de la cola del 13/11, sin remuestreo

Mirada rápida (ganancia del semillerío sin remuestreo); las P del mes y la P de los tres meses salen con `comparar_corridas.sh` adaptado a otros meses (pendiente de aprobar).

| Mes | 9004 / 9104 / 9204 (referencia) | 9014 / 9114 / 9214 (pandemia afuera) | 9023 / 9123 / 9223 (pandemia adentro, tendencia) |
|---|---|---|---|
| 202107 (30 semillas), ventana 1300–3500 | 93,2 | 97,0 | 94,7 |
| 202105 (100), ventana 1300–3500 (escalada 1000–2600) | 52,2 (54,0) | 47,8 (50,2) | 53,1 (55,2) |
| 202103 (100), ventana 1300–3500 (escalada 900–2500) | 40,4 (44,4) | 39,0 (43,6) | 40,7 (43,5) |

- En 202105 el orden se da vuelta: 9014 queda última y 9023 primera. En 202103, 9023 y 9004 quedan sobre 9014.
- A tener en cuenta: con la pandemia afuera y un entrenamiento que termina antes, a 9014 le quedan pocos meses recientes (en 202103 entrena con 2019, 202001, 202002, 202011, 202012 y 202101).
- En 202103 la meseta cae en 1200 envíos o menos: la curva tiene que empezar antes de 1000 para verla entera.
- 9029 da 96,4 con 100 semillas contra 97,0 de 9014 con 30.
- El archivo de Kaggle de 9029 tiene el mismo md5 en las dos VM: reproducibilidad confirmada (ver "Reproducibilidad: 9029 en las dos VM").
- `internet`: 9025 (9014 sin internet) da 98,9 contra 97,0 y 9026 (9023 sin internet) 97,1 contra 94,7, con 30 semillas. Quedan como exploración; si su P lo confirma, se rehacen con 100.

### Confirmación del drifting en 202105 y 202103 (13/11)

Sobre la candidata 2 (P-adentro, rotas con tendencia, sin undersampling), 100 semillas (las mismas de 9031), ventana 1300 a 3500. A es IPC (lo que tiene la candidata): 9031, 9123 y 9223. Cada par cambia solo el drifting.

| Mes | IPC (M) | Dólar blue (M) | P del mes (gana el dólar blue) | IPC + rank de monetarias, average (M) | P del mes (gana el rank) |
|---|---|---|---|---|---|
| 202107 | 95,0 | 97,5 (9033) | 0,921 | 95,9 (9034) | 0,752 |
| 202105 | 53,1 | 50,5 (9044) | 0,058 | 52,4 (9046) | 0,371 |
| 202103 | 40,7 | 36,3 (9045) | 0,042 | 40,0 (9047) | 0,440 |
| P de los tres meses | | | 0,115 | | 0,545 |

- Las P del mes de 202107 salen de `comparar_tres_meses.sh` (otro sorteo): 0,921 y 0,752, contra 0,913 y 0,739 de `comparar_corridas.sh`.
- Ventana escalada (lectura fina): dólar blue 0,923 / 0,068 / 0,206, tres meses 0,275; rank 0,738 / 0,328 / 0,565, tres meses 0,596.
- Dólar blue: gana solo en 202107 y pierde en los otros dos meses. Rank: empata en los tres.
- Archivos: `comparaciones/tres_meses_9031_vs_9033.txt` y `tres_meses_9031_vs_9034.txt`, y los `comparar_corridas.sh` de 9123 contra 9044 y 9046 (`MES=202105`) y de 9223 contra 9045 y 9047 (`MES=202103`).

### Sin `internet` y peso electoral sobre la candidata 2 (13/11)

Sobre la candidata 2 (P-adentro, rotas con tendencia, sin undersampling, IPC), 100 semillas (las mismas de 9031), ventana 1300 a 3500. Cada par cambia una sola cosa.

| Cambio | Mes | A | B | P del mes (gana B) |
|---|---|---|---|---|
| Sin `internet` | 202107 | 9031: 95,0 | 9048: 97,1 | 0,936 |
| Sin `internet` | 202105 | 9123: 53,1 | 9049: 49,5 | 0,021 |
| Sin `internet` | 202103 | 9223: 40,7 | 9050: 40,0 | 0,394 |
| Sin `internet` | Tres meses | 188,8 | 186,6 | 0,25 |
| Peso electoral 3 en 201908 a 201911 | 202107 | 9031: 95,0 | 9051: 97,0 | 0,940 |

- Sin `internet`, ventana escalada (lectura fina): 202105 0,013, 202103 0,650, tres meses 0,324. Public (CF, no decide): 85,1 con `internet` contra 84,4 sin, promedio de los 8 cortes.
- Sin `internet` gana solo en 202107 y pierde en 202105.
- Electoral: los dos semillerios comparten del 94,5 al 95,6 % de los elegidos; el electoral tiene de 2 a 5 BAJA+2 más entre los que elige uno solo. Sobre la candidata 1 había dado 0,638 (9029 contra 9027). No se corrió en 202105 ni en 202103. El Public de 9051 (MCD) se ve desde la jr.
- Archivos: `comparaciones/9031_vs_9048_1300_3500.txt`, `tres_meses_9031_vs_9048.txt`, `9031_vs_9051_1300_3500.txt` y los de 9123 contra 9049 (`MES=202105`) y 9223 contra 9050 (`MES=202103`).

### Bloque de FE en 202107 (14/11)

Sobre la candidata 2 con IPC (9031), 100 semillas (las mismas), ventana 1300 a 3500. A es 9031 (95,0); B, la variante. Todos los pares mezclan el cambio con otras hojas de RF y otros canaritos (su cantidad depende del número de columnas).

| B | Qué cambia | Ganancia de B (M) | P del mes 202107 (gana B) | Meseta | Public de B |
|---|---|---|---|---|---|
| 9053 H1 | + valor / promedio de los 6 meses anteriores y máximo / promedio (154 columnas) | 97,6 | 0,932 | 2000 a 2400 | 83,4 (MCD) |
| 9059 I2 | + COVID del AMBA y nacional, del mes y del anterior (8) | 96,9 | 0,897 | 1600 a 2900 | sin subir |
| 9058 I3 | + ratios entre pares de las 25 monetarias, sin lags (300) | 97,4 | 0,888 | 1800 a 2700 | 80,0 (MCD) |
| 9056 I0 | − intra-mes de la cátedra (contraria, −150) | 96,1 | 0,707 | 1700 a 2500 | sin subir |
| 9055 H3 | + tendencia, mínimo y máximo en 3, 6 y 12 (616) | 95,4 | 0,505 | 1700 a 2000 | sin dato |
| 9057 I1 | + 15 variables de negocio, con lags y tendencia (90) | 94,8 | 0,423 | 1700 a 2800 | 82,5 (MCD) |
| 9054 H2 | + lags y deltas de 3, 6 y 12 (462) | 94,6 | 0,384 | 1600 a 2400 | sin subir |
| 9052 H0 | − lags, deltas y tendencias (contraria, −385) | 93,4 | 0,214 | 1800 a 2200 | 78,4 (CF, 4 cortes) |

- 9031: meseta 2600 a 2800, Public 85,1 (8 cortes). Ninguna variante supera su Public.
- H1 pasa la regla solo en 202107; I2 e I3 quedan cerca. Por el patrón de 202107, se confirman en 202105 y 202103 antes de entrar.
- Contrarias: sacar las históricas cuesta 1,5 M; sacar las intra-mes de la cátedra no cuesta nada (+1,2 M), pero la regla es agregar, nunca borrar.
- Archivos: `comparaciones/9031_vs_90XX_1300_3500.txt` (90XX de 9052 a 9059).

### Confirmación de H1, I2, I3 y el electoral en tres meses (14/11)

Cada variante contra la candidata 2 (P-adentro, rotas con tendencia, sin undersampling, IPC) en cada mes, con las mismas 100 semillas de la referencia: 9031 (202107), 9123 (202105) y 9223 (202103). Ventana general 1300 a 3500. P del mes: `comparar_corridas.sh` (semillas y clientes); P de los tres meses: `comparar_tres_meses.sh`.

| Variante | 202107: variante / 9031 (M) | 202105: variante / 9123 (M) | 202103: variante / 9223 (M) | P del mes 202107 | P del mes 202105 | P del mes 202103 | P de los tres meses | Pierde con P < 0,30 | Meseta en envíos por BAJA+2 (202107 / 202105 / 202103) |
|---|---|---|---|---|---|---|---|---|---|
| H1, caída contra el promedio propio (9053, 9060, 9061) | 97,6 / 95,0 | 50,2 / 53,1 | 40,2 / 40,7 | 0,932 | 0,048 | 0,415 | 0,38 | sí (202105) | 8,2–9,8 / 8,9–11,1 / 4,5–5,7 |
| I2, COVID del AMBA y nacional (9059, 9062, 9063) | 96,9 / 95,0 | 49,3 / 53,1 | 39,7 / 40,7 | 0,897 | 0,011 | 0,301 | 0,178 | sí (202105) | 6,6–11,9 / 8,3–12,2 / 5,1–6,2 |
| I3, ratios entre monetarias (9058, 9064, 9065) | 97,4 / 95,0 | 53,4 / 53,1 | 40,6 / 40,7 | 0,888 | 0,546 | 0,472 | 0,784 | no | 7,4–11,1 / 12,8–13,9 / 4,5–7,4 |
| Electoral, peso 3 en 201908 a 201911 (9051, 9066, 9067) | 97,0 / 95,0 | 49,8 / 53,1 | 40,7 / 40,7 | 0,940 | 0,001 | 0,522 | 0,296 | sí (202105) | 8,6–10,7 / 8,3–11,1 / 4,5–6,2 |

- Mesetas de las referencias: 9031 10,7–11,5; 9123 12,2–13,9; 9223 4,5–6,8 envíos por BAJA+2 (BAJA+2: 244, 180 y 176). Meseta: cortes cada 100 cuyo promedio móvil de 5 queda a 1 M o menos del máximo (como `mirar.sh`).
- Las P del mes de 202107 en `comparar_tres_meses.sh` (otro sorteo): H1 0,944, I2 0,900, I3 0,899, electoral 0,926.
- **Ninguna pasa:** ninguna llega a 0,90 en la P de los tres meses. H1, I2 y el electoral repiten el patrón de 202107 (ganan ahí y pierden en 202105 con P < 0,05). I3 no pierde en ningún mes pero solo gana en 202107: empata en 202105 (0,546) y 202103 (0,472); tres meses 0,784.
- Lectura fina (ventana escalada, no decide): 202105 / 202103 / tres meses: H1 0,088 / 0,626 / 0,608; I2 0,016 / 0,683 / 0,343; I3 0,577 / 0,634 / 0,826; electoral 0,004 / 0,458 / 0,24. En 202103 todas mejoran con la escalada (la meseta de 202103 está en 800 a 1300 envíos, debajo de la ventana general), pero 202105 no cambia: H1, I2 y el electoral siguen perdiendo.
- Coincidencia entre ganadoras: no corresponde, ninguna pasa.
- Public (CF o MCD, no decide; promedio de 8 cortes 1500 a 2900): 9031 85,1; 9053 83,4; 9059 84,2; 9058 80,0; 9051 84,4.
- H1 (0,932) y el electoral (0,940) pasaron la regla en 202107 y no se sostuvieron; I2 quedó en el borde (0,897). Con ellos, cinco cambios pasaron la regla en 202107 y perdieron en 202105 (PA-afuera, dólar blue, sin `internet`, H1 y electoral); con el promedio de las candidatas (0,819 en 202107), son seis los que ganaron solo en 202107.

**Columnas de entrenamiento de 9031 (14/11, por el ExpCol 16 B).** `foto_mes` y `numero_de_cliente` entran al modelo final:
- Hojas de RF (celda 58): `campos_buenos <- setdiff(colnames(dataset), c("clase_ternaria", "clase01"))`: entran las dos.
- Canaritos (celda 66): `campitos <- c("numero_de_cliente", "foto_mes", "clase_ternaria")` y `campos_buenos <- setdiff(colnames(dataset), c(campitos, "clase01"))`: el modelo de los canaritos no las usa, y después las conserva (`col_utiles <- unique(c(col_utiles, c(campitos, "mes")))`).
- Modelo de validación y modelo final (celda 76): `campos_buenos <- copy(setdiff(colnames(dataset), c("clase_ternaria","clase01","azar")))`: entran las dos. La predicción (celdas 99 y 105) usa el mismo `campos_buenos`.
- En `impo.txt` de 9031 (modelo final), `foto_mes` está séptima por ganancia (gain 0,034) y `numero_de_cliente`, en el puesto 172 de 202. En 202109, `foto_mes` cae fuera del rango de entrenamiento: el modelo lo trata como el último mes visto.
- El ExpCol 16 B (Carvallo) encontró en 202107 que sacar las dos da +3,35 M (10 de 10 semillas, p 0,0059). No se probó en este pipeline.

**Interpolar contra NA (de las lecturas del 10/11 y 11/11):**
- 9015 (interpolar) contra 9004 (rotas en NA), P-adentro, con undersampling: +0,6 M, P 0,63 (prom. 93,8; ventana 1300 a 3500).
- 9017 (interpolar) contra 9014 (rotas en NA), PA-afuera, sin undersampling: 94,9 contra 97,0, −1,5 M, P 0,213 (es decir, 0,787 de que gane NA).

### V1, V2 y V3 sobre la candidata 2 en tres meses (15/11)

Cada variante contra la candidata 2 (P-adentro, rotas con tendencia, sin undersampling, IPC) en cada mes, con las mismas 100 semillas de la referencia: 9031 (202107), 9123 (202105) y 9223 (202103). Ventana general 1300 a 3500. P del mes: `comparar_corridas.sh`; P de los tres meses: `comparar_tres_meses.sh`.

| Variante | 202107: variante / 9031 (M) | 202105: variante / 9123 (M) | 202103: variante / 9223 (M) | P del mes 202107 | P del mes 202105 | P del mes 202103 | P de los tres meses | Pierde con P < 0,30 | Meseta en envíos por BAJA+2 (202107 / 202105 / 202103) | Public 202107 (CF, 8 cortes) |
|---|---|---|---|---|---|---|---|---|---|---|
| V1, sin `numero_de_cliente` ni `foto_mes` (9069, 9070, 9071) | 94,8 / 95,0 | 46,9 / 53,1 | 39,4 / 40,7 | 0,432 | 0 | 0,296 | 0,009 | sí (202105 y 202103) | 7,4–11,1 / 6,7–13,3 / 4,5–11,4 | 83,1 |
| V2, sin canaritos (9072, 9073, 9074) | 95,3 / 95,0 | 52,4 / 53,1 | 38,0 / 40,7 | 0,514 | 0,349 | 0,112 | 0,216 | sí (202103) | 7,8–8,6 / 8,9–11,1 / 4,0–8,5 | 84,3 |
| V3, hiperparámetros de Maylén (9075, 9076, 9077) | 90,4 / 95,0 | 54,8 / 53,1 | 39,2 / 40,7 | 0,012 | 0,873 | 0,258 | 0,111 | sí (202107 y 202103) | 7,8–9,4 / 7,8–10,0 / 5,1–7,4 | 79,5 |

- Referencias: meseta 9031 10,7–11,5; 9123 12,2–13,9; 9223 4,5–6,8 envíos por BAJA+2; Public de 9031 85,1.
- P del mes en `comparar_tres_meses.sh` (otro sorteo): V1 0,475 / 0,000 / 0,314; V2 0,572 / 0,322 / 0,127; V3 0,018 / 0,893 / 0,260.
- Lectura fina (ventana escalada, no decide): 202105 / 202103 / tres meses: V1 0,001 / 0,637 / 0,052; V2 0,476 / 0,242 / 0,367; V3 0,897 / 0,504 / 0,289.
- **Ninguna pasa.** V1 pierde fuerte en 202105 (−6,3 M, P 0): sacar `foto_mes` y `numero_de_cliente` empeora la candidata 2; en 202107 empata, lo contrario del +3,35 M del ExpCol 16 B (otro pipeline: Junior, sin RF ni canaritos). V2 empata en 202107 y 202105 y pierde en 202103 (−2,7 M). V3 pierde en 202107 (−4,5 M) y gana en 202105 sin llegar (0,873): es el único caso del bloque que va al revés del patrón de 202107.
- 9068 (z728 de la cátedra, tal cual) terminó y subió 7 cortes con MCD; no se compara con la regla (no guarda la validación por semilla). Su Public se ve desde la jr.
- Kaggle: 9069 subió con el cupo de CF del sábado; 9072 y 9075 (16 cortes) subieron después de las 21:00, con el cupo reservado para el armado final. Con los 16 cortes de 9078 y 9081 que salieron por CF el 15/11 a la mañana y los 7 de 9085 a la tarde, quedaban 61 hasta el domingo a las 21:00.

### V4 y V5: la clase binaria sobre la candidata 2 en tres meses (15/11)

Mismo diseño que V1 a V3: cada variante contra la candidata 2 (P-adentro, rotas con tendencia, sin undersampling, IPC) en cada mes, con las mismas 100 semillas: 9031 (202107), 9123 (202105) y 9223 (202103). Ventana general 1300 a 3500. P del mes: `comparar_corridas.sh`; P de los tres meses: `comparar_tres_meses.sh`. Las hojas de Random Forest y los canaritos no cambian.

| Variante | 202107: variante / 9031 (M) | 202105: variante / 9123 (M) | 202103: variante / 9223 (M) | P del mes 202107 | P del mes 202105 | P del mes 202103 | P de los tres meses | Pierde con P < 0,30 | Meseta en envíos por BAJA+2 (202107 / 202105 / 202103) | Public 202107 (CF, 8 cortes) |
|---|---|---|---|---|---|---|---|---|---|---|
| V4, clase ingenua: positivos solo BAJA+2, BAJA+1 negativo (9078, 9079, 9080) | 97,2 / 95,0 | 48,1 / 53,1 | 35,5 / 40,7 | 0,884 | 0,002 | 0,002 | 0,007 | sí (202105 y 202103) | 9,4–11,1 / 10,0–13,3 / 5,7–7,4 | 77,2 |
| V5, clase intermedia: BAJA+1 y BAJA+2 positivos, BAJA+1 con peso 0,5 (9081, 9082, 9083) | 96,0 / 95,0 | 51,9 / 53,1 | 40,6 / 40,7 | 0,832 | 0,075 | 0,510 | 0,432 | sí (202105) | 7,0–11,9 / 7,8–15,0 / 5,1–6,2 | 83,1 |

- Referencias: meseta 9031 10,7–11,5; 9123 12,2–13,9; 9223 4,5–6,8 envíos por BAJA+2; Public de 9031 85,1.
- P del mes en `comparar_tres_meses.sh` (otro sorteo): V4 0,893 / 0,001 / 0,004; V5 0,849 / 0,071 / 0,528.
- Lectura fina (ventana escalada, no decide): 202107 / 202105 / 202103 / tres meses: V4 0,870 / 0,001 / 0,186 / 0,068; V5 0,831 / 0,048 / 0,684 / 0,385.
- **Ninguna pasa.** V4 repite el patrón de 202107: gana ahí sin llegar (0,884) y pierde unos 5 M en cada uno de los otros dos meses. V5 queda más cerca de la candidata 2: gana poco en 202107, pierde en 202105 (−1,3 M) y empata en 202103. La clase de la candidata (BAJA+1 y BAJA+2 positivos, mismo peso) se queda.
- Los 16 cortes de 202107 salieron por CF por error (ver Decisiones del 15/11).
- Archivos: `comparaciones/9031_vs_9078_1300_3500.txt`, `9031_vs_9081_1300_3500.txt`, `tres_meses_9031_vs_9078.txt`, `tres_meses_9031_vs_9081.txt` y los de 9123 contra 9079 y 9082 (`MES=202105`) y 9223 contra 9080 y 9083 (`MES=202103`).

### Candidata 2 contra la referencia, con la P de los tres meses (15/11)

Regla fijada a las 11:52, antes de calcular (ver Decisiones): la candidata 2 es A y la referencia, B; la referencia la reemplaza solo si gana con P de los tres meses ≥ 0,90. Mismas 100 semillas, en el mismo orden, en los tres pares. Entre las dos cambian las rotas (tendencia en la candidata, NA en la referencia), el undersampling (sin / con 20 % de CONTINUA) y `min_data_in_leaf` (3555 / 711).

| Mes | A: candidata 2 (M) | B: referencia (M) | B − A | P del mes (gana la referencia) | Pierde con P < 0,30 |
|---|---|---|---|---|---|
| 202107 | 95,0 (9031) | 93,8 (9030) | −1,1 | 0,244 | sí (la referencia) |
| 202105 | 53,1 (9123) | 52,2 (9104) | −1,0 | 0,270 | sí (la referencia) |
| 202103 | 40,7 (9223) | 40,4 (9204) | −0,3 | 0,525 | no |
| Tres meses | 188,8 | 186,4 | −2,0 | **0,255** | |

- Ventana escalada (lectura fina): 0,252 / 0,281 / 0,756; tres meses 0,33.
- La referencia no reemplaza a la candidata 2. Con la referencia como base, la candidata 2 tampoco habría llegado a 0,90 (P 0,745): unos 2 M en la suma, unos dos BAJA+2.
- Archivo: `comparaciones/tres_meses_9031_vs_9030.txt` (calculado a las 12:05).

### Rotas: NA contra tendencia sobre la candidata 2 (15/11)

Regla del 13/11, ratificada a las 11:52 antes de correr: la tendencia se queda solo si le gana a NA con P de los tres meses ≥ 0,90; si no, NA. 9085, 9086 y 9087 son 9031, 9123 y 9223 con una sola línea cambiada (`PARAM$CA$metodo` de `"tendencia"` a `"MachineLearning"`), con las mismas 100 semillas (cola 8, jr2, de 12:33 a 13:01). Entre las dos versiones cambian solo las 29 combinaciones variable-mes rotas (15 de 202006 y 14 de 2019: 7 de 201910, 6 de 201905 y 1 de 201904).

| Mes | A: tendencia (M) | B: NA (M) | B − A | P del mes (gana NA) | P del mes (gana la tendencia) |
|---|---|---|---|---|---|
| 202107 | 95,0 (9031) | 95,6 (9085) | +0,6 | 0,574 | 0,426 |
| 202105 | 53,1 (9123) | 51,3 (9086) | −1,8 | 0,104 | 0,896 |
| 202103 | 40,7 (9223) | 40,6 (9087) | −0,1 | 0,551 | 0,449 |
| Tres meses | 188,8 | 187,4 | −1,2 | 0,322 | **0,678** |

- P del mes de `comparar_corridas.sh`; la de `comparar_tres_meses.sh` (otro sorteo) da 0,575 / 0,072 / 0,572 para NA.
- Ventana escalada (lectura fina): 0,556 / 0,186 / 0,875 para NA; tres meses 0,588.
- La tendencia no llega a 0,90: queda NA (decisión de las 14:17).
- Mesetas: con NA, la de 202107 cae mucho antes (1600 a 2000 envíos, 6,6 a 8,2 por BAJA+2, contra 2600 a 2800, 10,7 a 11,5, con tendencia); en 202105, 1400 a 2400 (7,8 a 13,3) contra 2200 a 2500 (12,2 a 13,9); en 202103, igual (800 a 1200, 4,5 a 6,8).
- Archivos: `comparaciones/tres_meses_9031_vs_9085.txt`, `9031_vs_9085_1300_3500.txt` y los de 9123 contra 9086 (`MES=202105`) y 9223 contra 9087 (`MES=202103`).

### NA contra la referencia (15/11, registro)

Solo para registro: no decide nada. A es la versión NA (9085, 9086 y 9087); B, la referencia (9030, 9104 y 9204). Mismas 100 semillas, en el mismo orden. Ahora el método de las rotas es el mismo en las dos (NA): solo cambian el undersampling y `min_data_in_leaf`.

| Mes | A: NA (M) | B: referencia (M) | B − A | P del mes (gana la referencia) | Pierde con P < 0,30 |
|---|---|---|---|---|---|
| 202107 | 95,6 (9085) | 93,8 (9030) | −1,7 | 0,154 | sí (la referencia) |
| 202105 | 51,3 (9086) | 52,2 (9104) | +0,9 | 0,832 | no |
| 202103 | 40,6 (9087) | 40,4 (9204) | −0,1 | 0,401 | no |
| Tres meses | 187,4 | 186,4 | −1,0 | 0,394 | |

- Ventana escalada: 0,150 / 0,666 / 0,308; tres meses 0,251.
- Archivo: `comparaciones/tres_meses_9085_vs_9030.txt`.

### Cómo se eligió la candidata final (15/11)

Texto de Carla, tal cual (`texto_candidata_final.md`).

El 13/11, después de validar en tres meses, la candidata 2 (9031: pandemia adentro, rotas corregidas con tendencia, sin undersampling) pasó a ser la principal: le ganó a la candidata 1 (9029, pandemia amplia afuera) en la suma de los tres meses con P 0,951, aunque en 202107 perdía con ella (0,166). Desde entonces, todas las variantes (drifting, feature engineering, campos clave, canaritos, hiperparámetros y clase) se probaron contra ella, y ninguna la superó.

Hasta ese momento, la bitácora decía que decidía la P de cada mes. Desde la elección entre las dos candidatas se decidió con la P de los tres meses, y ese cambio no quedó registrado como decisión. Además, faltaba comparar la candidata 2 con la referencia (9030) usando la P de los tres meses: solo estaban las P de cada mes (0,756, 0,730 y 0,475, a favor de la candidata 2).

Las dos faltas se detectaron al revisar la bitácora el 15/11. Antes de calcular la comparación, a las 11:52, se fijó la regla: como la candidata 2 era la principal desde el 13/11 y todo se había probado contra ella, la referencia la reemplazaría solo si le ganaba con P de los tres meses ≥ 0,90. Resultado: P 0,255 de que gane la referencia. La candidata 2 queda arriba en los tres meses (+1,1, +1,0 y +0,3 M).

Si se hubiera tomado la referencia como base, la candidata 2 no habría llegado a 0,90 (P 0,745) y quedaría la referencia. La diferencia entre las dos, unos 2 M en la suma de los tres meses, equivale a unos dos BAJA+2: con estos datos no se distinguen.

Rotas: NA en lugar de tendencia. El 13/11 quedó escrito que, si la tendencia y NA seguían empatadas al final, ganaba la más simple (NA). El empate venía de una sola comparación con 30 semillas y solo en 202107 (P 0,566). Esa regla se nos pasó por alto: la candidata 2 siguió con tendencia sin haber resuelto el empate. Lo detectamos al revisar la bitácora el 15/11. Antes de correr la comparación, a las 11:52, se ratificó la regla: la tendencia se queda solo si le gana a NA con P de los tres meses >= 0,90. Se corrió la candidata 2 con las rotas en NA (9085, 9086 y 9087: copias de 9031, 9123 y 9223 con una sola línea cambiada, las mismas 100 semillas). Resultado: P 0,678 de que gane la tendencia en los tres meses (0,426 / 0,896 / 0,449); no llega a 0,90, así que queda NA. Con la lógica general de la regla (la que está se queda salvo que el retador gane con 0,90) habría quedado la tendencia; se aplicó la regla específica de las rotas porque estaba escrita antes.

Limitación: todas las variantes probadas desde el 13/11 (drifting, feature engineering, campos clave, canaritos, hiperparámetros y clase) se compararon contra la candidata 2 con tendencia, no con NA. Entre las dos versiones solo cambian las 29 combinaciones variable-mes (15 de 202006 y 14 de 2019), y no hay un mecanismo para esperar que eso cambie esos resultados, pero no se volvió a probar. La notebook de la entrega se corrió de nuevo desde cero con todos estos cambios juntos (rotas en NA, selector del dólar corregido, cortes) y su resultado se verificó con md5 contra 9085.

### Corte de 202109 con la versión NA (15/11)

Material con el que se decidió el corte a las 15:58 (ver Decisiones). Pérdida = cuánto se pierde contra el máximo de cada mes, en M.

**Mesetas de la versión NA** (cortes cada 100 cuyo promedio móvil de 5 queda a 1 M o menos del máximo):

| Mes | Corrida | BAJA+2 | Meseta en envíos | En envíos por BAJA+2 |
|---|---|---|---|---|
| 202107 | 9085 | 244 | 1600 a 2000 | 6,6 a 8,2 |
| 202105 | 9086 | 180 | 1400 a 2400 | 7,8 a 13,3 |
| 202103 | 9087 | 176 | 800 a 1200 | 4,5 a 6,8 |

**Estimaciones de BAJA+2 en 202109:**
- 204: tasa de BAJA+2 de 2021 (1.411 / 228.624 = 0,617 %) por los 33.080 clientes de 202109.
- 216: tasa de los últimos tres meses con clase (644 / 98.616 = 0,653 %).
- 238: suma de las probabilidades de 9085 en 202109 (417,5), calibrada con 202107. Con 9031 daba 242; las columnas de la tabla se calcularon con 242.

**Pérdida en cada mes según los envíos por BAJA+2** (M):

| Envíos por BAJA+2 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 14 | 16 | 20 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 202107 (9085) | −10,4 | −6,2 | −2,0 | −0,2 | −0,5 | −1,9 | −2,4 | −2,3 | −2,3 | −4,8 | −11,2 | −20,6 |
| 202105 (9086) | −12,1 | −7,4 | −4,3 | −2,0 | −0,6 | −0,4 | −0,8 | −0,7 | −0,7 | −1,6 | −3,7 | −14,4 |
| 202103 (9087) | −1,3 | −0,1 | −0,1 | −1,4 | −2,2 | −1,5 | −1,8 | −3,5 | −5,2 | −8,8 | −13,9 | −13,2 |

**Pérdida por corte** (M; "3 m" = promedio de los tres meses; "07 + 05" = promedio de 202107 y 202105; cada corte se lleva a envíos por BAJA+2 con cada estimación):

| Corte | 204: 3 m | 204: 07 + 05 | 216: 3 m | 216: 07 + 05 | 242: 3 m | 242: 07 + 05 | Suma de las seis | Peor caso |
|---|---|---|---|---|---|---|---|---|
| 1500 | −1,1 | −0,8 | −1,2 | −1,2 | −1,9 | −2,7 | −8,9 | −2,7 |
| 1600 | −1,0 | −0,5 | −1,1 | −0,8 | −1,5 | −1,7 | −6,6 | −1,7 |
| 1700 | −1,0 | −0,6 | −1,0 | −0,5 | −1,2 | −1,1 | −5,5 | −1,2 |
| 1800 | −1,1 | −0,9 | −1,0 | −0,6 | −1,1 | −0,8 | −5,6 | −1,1 |
| 1900 | −1,5 | −1,5 | −1,1 | −0,9 | −1,0 | −0,5 | −6,5 | −1,5 |
| 2000 | −1,6 | −1,6 | −1,5 | −1,5 | −1,1 | −0,6 | −7,9 | −1,6 |
| 2100 | −1,7 | −1,6 | −1,6 | −1,6 | −1,0 | −0,7 | −8,3 | −1,7 |
| 2200 | −2,1 | −1,6 | −1,7 | −1,6 | −1,4 | −1,3 | −9,6 | −2,1 |
| 2300 | −2,2 | −1,3 | −1,9 | −1,6 | −1,6 | −1,6 | −10,2 | −2,2 |
| 2400 | −2,5 | −1,3 | −2,2 | −1,4 | −1,6 | −1,6 | −10,7 | −2,5 |
| 2500 | −3,0 | −1,7 | −2,4 | −1,3 | −1,7 | −1,6 | −11,6 | −3,0 |
| 2600 | −3,6 | −2,2 | −2,8 | −1,5 | −2,0 | −1,6 | −13,8 | −3,6 |
| 2700 | −4,2 | −2,8 | −3,3 | −1,9 | −2,2 | −1,4 | −15,7 | −4,2 |

- Corte de menor pérdida según la estimación: 1600 (204), 1700 (216) y 1900 (242).
- Con NA, las pérdidas son más chicas que con tendencia: el peor caso más bajo es −1,1 M (1800), contra −2,6 M con tendencia.
- 1800 tiene el peor caso más bajo y la segunda suma más baja (1700: −5,5 M).

### Public de 9085 (15/11, registro)

Solo registro: el Public no decide, y el corte se fijó antes de conocer el de 1800.

| Corte | 1500 | 1700 | 1900 | 2100 | 2300 | 2500 | 2700 | 2900 | Promedio |
|---|---|---|---|---|---|---|---|---|---|
| Public (MCD) | 90,9 | 92,0 | 97,1 | 92,5 | 87,6 | 86,8 | 81,8 | 77,3 | 88,3 |

- Promedio de los mismos 8 cortes con tendencia (9031): 85,1.
- Por CF, entre las 16:00 y las 16:03: 1600 91,713; 1750 94,039; 1800 92,627; 1850 95,119; 2000 94,953; 2200 90,218; 2400 85,482. El de 1800 es el envío final, marcado a las 16:14.
- Cupo de CF: con esos 7 envíos, se usaron 39 desde el sábado a las 21:00 (9072, 9075, 9078 y 9081, 8 cada una, y los 7 de 9085); quedan 61 hasta el domingo a las 21:00.

### Reproducibilidad de la entrega (15/11)

Criterio del 13/11: mismo orden de clientes, mismos elegidos, misma ganancia y mismo md5 de los archivos de Kaggle (excluyente). La notebook de la entrega se corre desde cero, desde el dataset original, con otro número de experimento, y sus CSV se comparan corte por corte con los generados desde la predicción guardada de la corrida original (`verificar_repro.sh`).

**Versión con tendencia: 9084 contra 9031** (jr, 15 minutos). Los 9 archivos de Kaggle de 1900 a 2700 tienen el mismo md5. Las probabilidades difieren hasta 3,1e-13 (`prediccion.txt`) y 1,6e-13 (`prediccion_validacion.txt`), por la suma en paralelo de LightGBM; mismo orden de clientes y misma ganancia (95,2 M en `verificar_repro.sh`). Archivo: `comparaciones/repro_9031_vs_9084.txt`.

| Corte | md5 (9031 = 9084) |
|---|---|
| 1900 | `f538810f65a5f66d35cfa0806d2f4b4c` |
| 2000 | `3ae2f85ecdb78e05e3672eff65de77d4` |
| 2100 | `d30a8d08b65494866cc42fc2f589296e` |
| 2200 | `61e05d9c8daa9ebc7e48db978f8d3cf5` |
| 2300 | `eb8846a5f380a1aed258a30cd9fecde5` |
| 2400 | `a4e55beb37d49154210bafe964f2320d` |
| 2500 | `a793956f46c2baabf9755627094d1535` |
| 2600 | `ced2da782ce8a0787f35044a9c352123` |
| 2700 | `48c2666058b6e8628bfa6cf0337125fe` |

**Versión NA, la de la entrega: 9088 contra 9085** (jr2, 15:28 a 15:41, `lanzar_repro.sh`). Los 13 archivos de Kaggle de 1500 a 2700 tienen el mismo md5, incluido el del envío final (1800). Las probabilidades difieren hasta 1,4e-14 (`prediccion.txt`) y 1,1e-12 (`prediccion_validacion.txt`); mismo orden de clientes y misma ganancia (95,5 M en `verificar_repro.sh`). Archivo: `comparaciones/repro_9085_vs_9088.txt`.

| Corte | md5 (9085 = 9088) |
|---|---|
| 1500 | `804ac586a03eb2ada2b5cf500a3d5e0d` |
| 1600 | `8643015d8560ca68e4aadf088db1f49f` |
| 1700 | `bc300bd24078365a61797316a0985693` |
| 1800 | `dbfa78781de150967de93c6abc5daae7` |
| 1900 | `699744c75c625ff22cf38050030044ca` |
| 2000 | `3644fa2ac980e37d34201036b26e7223` |
| 2100 | `137c6ef24692ec5a1a60f595b6f5adc7` |
| 2200 | `786fdbb38a12e3b81fefbe4988df7341` |
| 2300 | `5e2f098009280fdeff252418f2dbc489` |
| 2400 | `6b223d9a0f510cc7862830568fcf448a` |
| 2500 | `278cebce6307e0969ddce44acf3fa1d2` |
| 2600 | `2e85d5e0aed9c21741e82e93cf92ee9d` |
| 2700 | `b8d1639072a10ec469f90208d43c2042` |

**Notebook de la entrega** (`cpf_entrega_final_analista_jr/cpf_final_analista_jr.ipynb`, en el fork). Contra 9085 cambian solo cuatro cosas:
- `PARAM$experimento <- 9088`, para no pisar `WF9085`.
- El selector del dólar corregido: el `switch` de la cátedra llamaba a `drift_dolarblue` y `drift_dolaroficial`, que no existen; ahora llama a `drift_dolar_blue` y `drift_dolar_oficial`. La candidata usa IPC, así que no cambia el resultado; evita el error si alguien elige el dólar.
- `PARAM$kaggle$cortes <- seq(1500, 2700, by = 100)`, porque la meseta de NA cae antes.
- `PARAM$kaggle$subir <- FALSE`, con la subida dentro de un `tryCatch`: genera los CSV sin subir nada.

El `PARAM.yml` de la carpeta de entrega es el de la re-corrida 9088.

**Respaldo de la versión con tendencia** (en este repositorio, fuera de la carpeta de entrega):

| Archivo | Qué es | md5 |
|---|---|---|
| `cpf_final_analista_jr_tendencia_9084.ipynb` | La notebook verificada como 9084 | `51867ccc69e780e68b8a3ca59f34710f` |
| `cpf_final_analista_jr_tendencia_9084_PARAM.yml` | Su `PARAM.yml` | `a27669e65e81090d7a15d9b810c4f27a` |
| `cpf_final_analista_jr_tendencia_9084_md5.txt` | El resultado de su verificación (los 9 md5) | — |

### Cuánto podemos detectar (10/11)

Con 30 semillas y un solo mes de validación, el rango de la diferencia (5 % a 95 %) es de unos ±3 M: diferencias menores a 1 o 2 M quedan dentro del ruido, como vio la clase 08 (con pocas pruebas, nada da significativo). Sumar semillas achica solo la parte de semillas; la parte de clientes (un mes) no baja con más semillas: para eso hace falta otro mes de validación (pendiente: 202105). Por eso las mejoras chicas y consistentes (como la tendencia en el CA) se acumulan con cuidado y se confirman con evidencia nueva.

## Cómo se combinan los bloques (criterio del 08/11)

Ir de a un bloque y quedarse con el ganador supone que los efectos se suman. Si el mejor de un bloque cambia según lo que se haga en otro (interacción), ese camino puede dejar afuera la mejor combinación. Ejemplo ya visible: la receta del #01 B (interpolar las variables rotas de 202006) deja de importar si la pandemia se saca del entrenamiento.

- Si dos opciones de un bloque quedan dentro del ruido, pasan las dos al bloque siguiente: se siguen dos caminos, no uno.
- Se cruzan (2 × 2) solo los bloques donde hay un mecanismo para esperar interacción. Primer candidato: pandemia × undersampling, porque los dos tocan qué filas entran al entrenamiento. Con 9004, 9008 y 9013 ya hay tres de las cuatro celdas; falta 9008 + 9013.
- Las interacciones son más difíciles de ver que los efectos simples: con el ruido actual (±3 a 4 M) solo se ven si son grandes. Por eso no se cruza todo contra todo.

## Ideas y pendientes

**Pendientes hasta el domingo, en orden (13/11; ninguno corre sin el OK de Carla)**
1. Viernes, después de leer el drifting: elegir ganador y confirmarlo en 202105 y 202103. Después, el bloque de FE: histórico H0, H1, H2; intra-mes I0, I1; contexto COVID I2.
2. Corte: la asimetría (perder un BAJA+2 cuesta 0,975 M y enviar uno de más, 0,025 M), mirada con las curvas de los tres meses; las dos estimaciones del corte de 202109 (por tasa y por suma de probabilidades).
3. Sábado a la mañana, si entran: `neg_bagging_fraction` 0,25 (ExpCol 13 A), canaritos sí o no, hojas de RF sí o no, 9024 (`min_data_in_leaf` 1777) con 100 semillas, `internet` con 100 semillas si se confirma, promedio de las dos candidatas.
4. Sábado a las 12:00: no se abren bloques nuevos. Sábado a la tarde: combinar ganadores y confirmar en los tres meses.
5. Domingo: completar la tabla de decisión con los criterios definidos; 18:00 elegir; 20:00 subido y marcado en CF; copia al fork con README y md5; 23:58 link en Zulip.

**Hiperparámetros y semillerío**
- `min_data_in_leaf`: en el ExpCol 05 quedó en el borde superior (2048) en 12 de 80 corridas. En el Senior no se optimiza (está fijo en 0 y la regularización pasa por `min_sum_hessian_in_leaf`), pero en los parámetros inesperados de la clase 08 aparece en 711.
- En la clase 08, los hiperparámetros del 100-semillerío salieron de una bayesiana que tenía el semillerío adentro (unos 15 días de cómputo). No hay código para eso y no entra en el tiempo; la alternativa es comparar pocas configuraciones, cada una con semillerío.
- Pasar de 10 a 30 o más semillas en la configuración elegida. En la clase 08, la ganancia se estabiliza desde unas 60. 9004 lo prueba con `HP-INESP`.
- Canaritos: ya está en el workflow del Senior, así que todas las corridas 9001 a 9007 lo tienen (igual que las hojas de Random Forest y la tendencia de 6 meses). Explorarlo como bloque es correr sin canaritos (o con otros parámetros) y comparar con la regla.
- La Bayesian Optimization del Senior entrena con el 20 % de los CONTINUA (undersampling) y terminó en el borde del rango. Rehacerla sin undersampling cuesta unas 5 veces más; no es prioridad mientras 9001 y 9002 no se distingan.
- Ensemble diverso (no solo semillas): combinar configuraciones distintas, por ejemplo distintos hiperparámetros o distintas ventanas de meses.

**Validación**
- Evolución de la clase (pendiente del 12/11): hasta ahora no se tiene en cuenta. La tabla por mes, de 201901 a 202107 (clientes, CONTINUA, BAJA+1, BAJA+2 y % BAJA+2), está en el documento [Resultados 9023 y 9024 y evolución de la clase](https://claude.ai/artifact/9uHHZCV89yqh1DxBuyojgZ). 202107 tiene el % de BAJA+2 más alto de la serie (0,741 %; en 2019, entre 0,39 y 0,59 %). Con esa tabla se decide: los meses de validación nuevos, cómo escalar su ventana y si el corte conviene expresarlo como proporción y no como número fijo de envíos.
- `VAL` guarda cada semilla desde 9003. Desde el 08/11 se compara semillerío contra semillerío con remuestreo; el Wilcoxon por semilla queda como diagnóstico.
- Validar en más de un mes, para que la elección sea más estable.
- Undersampling: la validación del semillerío se entrena con el 20 % de los CONTINUA (como la optimización del Senior), mientras que el modelo final usa todos. La 9003 lo probó: sin undersampling cada semilla rinde mucho peor, aunque el semillerío compense. Dos ideas para el bloque de training:
  - Entrenar también el modelo final con undersampling, como la validación.
  - Undersampling distinto en cada semilla (otro 20 % de CONTINUA por semilla): más diversidad entre los modelos, que es lo que aprovecha el semillerío.
- Revisar si conviene elegir por ganancia en lugar de AUC.

**Catastrophe Analysis**
- `internet` (va en el CA desde el 12/11): desde 202010 pasa de un 0/1 con 6 a 10 % de ceros a valores de 0 a 4 con 95,6 a 97,5 % de ceros, todos los meses hasta 202109. 202006 ya lo corrige el CA (100 % de ceros). Opciones: sacarla, o NA desde 202010; se prueban sobre las dos candidatas.

**Drifting**
- Idea del 13/11: 202109 tiene más actividad que el promedio previo en variables de cantidad (transacciones Master +22,5 %, del trimestre +12,1 %, Visa +11,9 %, con la base 202102–202105), y 202108 ya venía subiendo: parece una suba gradual de 2021, o sea drifting en variables no monetarias. Experimento: aplicar `rank_cero_fijo` por mes también a las variables de cantidad transaccionales, sobre las dos candidatas, validando en 202107, 202105 y 202103. Primero, un inventario de qué variables de cantidad tienen tendencia en 2021. Ojo: hoy el drifting de las monetarias es `deflacion` (`PARAM$DR$metodo`), no `rank_cero_fijo`; las variables de cantidad no tienen corrección.
- Corrección por dólar blue (para el bloque de drifting del 14/11): `drift_dolar_blue` existe en la notebook, pero el `switch` de la cátedra llama a `drift_dolarblue` (y a `drift_dolaroficial`), que no existen: elegir "dolar_blue" o "dolar_oficial" hoy da error. Hay que corregir el nombre antes de probarla.
- Revisar con el mismo conteo si hay otras variables con saltos así: no solo meses con 100 % de ceros, también cortes bruscos de nivel (proporción de ceros, mediana, cuantiles) que se mantienen. Sin cambiar nada todavía: primero el inventario, después se decide en el bloque de drifting.

**Contexto electoral como análogo (idea del 12/11; el 13/11 queda como idea y se explora con 9027, ver "Análogo electoral (13/11)")**
- La clase de 202109 (BAJA+2 = se va en noviembre de 2021) cae en contexto electoral y cambiario: PASO el 12/9, generales en noviembre, presión sobre el dólar. En 2019 pasó algo parecido y está en el dataset: PASO el 11/8, caída del mercado, cepo en septiembre, generales en octubre (201908 a 201911).
  1. Con la tabla de la evolución de la clase, mirar si la tasa de BAJA+2 cambió alrededor de las elecciones de 2019.
  2. Ver qué variables del Jr se movieron en esos meses (saldos en dólares, plazos fijos, etc.).
  3. Si hay efecto, probar a darles más peso a esos meses al entrenar (bloque meses), con corrección por dólar (bloque drifting) o con variables históricas de cambio (bloque FE histórico).
- Pendiente del 13/11: proponer opciones para correr algo como exploración con MCD (la primera, 9027, se lanzó el 13/11).
- Limitación: ningún mes de validación cercano tiene ese contexto, así que solo lo juzga el Public. Es exploración: se sube con la cuenta MCD y no entra en el candidato salvo que la tabla de 2019 muestre algo muy claro.

**Feature Engineering: variables de contexto (idea del 13/11)**
- COVID: dos variables por mes, casos y muertes por 100 mil habitantes, idealmente del AMBA (CABA más provincia de Buenos Aires) o, si no, nacionales. Van en el bloque FE como "variables de contexto", separadas del FE intra-mes. La segunda ola tuvo su pico en mayo de 2021, así que la validación en 202105 es la prueba justa. Riesgo: al ser el mismo valor para todos los clientes del mes, el modelo puede usarlo como reloj del período. Fuentes (13/11, solo se miró si responden, no se bajó nada): Our World in Data responde desde la VM (archivo nacional de 98 MB, sin desagregar por provincia); la descarga del Ministerio de Salud (SISA) da 404 y datos.gob.ar no responde. Con datos nacionales es una tarde de trabajo (bajar, agregar por mes, unir por `foto_mes`); con AMBA falta encontrar una fuente que funcione.

**Ensembles (idea del 13/11)**
- Promediar las probabilidades de 9014 y 9023 (las predicciones que ya existen) y compararlo contra 9014 con `comparar_corridas.sh`. Comparten alrededor del 90 % de los clientes elegidos, así que diría si combinar pandemia adentro y afuera suma algo.

**Corte**
- Asimetría (pendiente del 13/11): perder un BAJA+2 cuesta 0,975 M y enviar uno de más cuesta 0,025 M, así que ante la duda conviene equivocarse enviando de más. Mirar con las curvas de los tres meses cuánto se pierde de cada lado de la meseta. Tener en cuenta que el modelo estima BAJA+1 + BAJA+2 y la ganancia paga solo BAJA+2 (en 202107, suma de probabilidades 424 contra 466 positivos reales).
- Elegir el corte en la meseta de la ganancia en validación, no en el pico del Public. `prediccion.txt` guarda la probabilidad de cada semilla, así que se pueden armar otros cortes sin volver a entrenar.

**ExpCol 05 (lags y pandemia)**
- Llevar la configuración que recomiende el experimento. En el Senior, la tendencia de 6 meses también mira los meses de pandemia: si se anulan los lags que apuntan a la pandemia (C3), hay que decidir qué hacer con la tendencia.

**Comparación con el pipeline Junior**
- Comparar contra el 5100 del ExpCol 05 (pipeline Junior base, 10 semillas, Public por semilla). Como las semillas no son las mismas, el test es Mann-Whitney y no Wilcoxon pareado.

**Otros experimentos colaborativos**
- Leer la Recomendación Concreta de cada experimento (grupos A y B) a medida que se publiquen las slides, y decidir qué entra al catálogo.
