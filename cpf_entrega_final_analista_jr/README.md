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
> **Envío final:** `KA9085_100_1800.csv` · 1800 estímulos · cuenta principal de Kaggle ([carlaperezfernandez][perfil])
>
> Lo genera la notebook [`cpf_final_analista_jr.ipynb`][notebook], incluida en esta carpeta. Verificamos que su ejecución completa desde cero reproduce exactamente el archivo enviado: md5 `dbfa78781de150967de93c6abc5daae7` ([Verificación](#verificación)).

*Escribimos en primera persona del plural. Compartimos el porqué en [Autoría y uso de IA](#autoría-y-uso-de-ia).*

---

## Contenido

1. [Resumen ejecutivo](#resumen-ejecutivo)
2. [Punto de partida](#punto-de-partida)
3. [Criterio de decisión](#criterio-de-decisión)
4. [Qué modificamos y por qué](#qué-modificamos-y-por-qué)
   - [Aportes de los experimentos colaborativos](#1-aportes-de-los-experimentos-colaborativos)
   - [Pruebas adicionales en los mismos bloques](#2-pruebas-adicionales-en-los-mismos-bloques)
   - [Aspectos no abordados en los experimentos colaborativos](#3-aspectos-no-abordados-en-los-experimentos-colaborativos)
5. [Configuración final y limitaciones](#configuración-final-y-limitaciones)
6. [Método para definir el corte](#método-para-definir-el-corte)
7. [Cómo reproducir](#cómo-reproducir)
8. [Verificación](#verificación)
9. [Autoría y uso de IA](#autoría-y-uso-de-ia)
10. [Archivos y bitácora](#archivos-y-bitácora)
11. Anexos
    - [Anexo A: origen de cada cambio probado](#anexo-a-origen-de-cada-cambio-probado)
    - [Anexo B: registro de envíos a Kaggle](#anexo-b-registro-de-envíos-a-kaggle)
    - [Anexo C: verificación de los archivos de Kaggle](#anexo-c-verificación-de-los-archivos-de-kaggle)

---

## Resumen ejecutivo

Adaptamos el workflow Senior de la cátedra ([z739][z739]) al dataset Junior para generar las predicciones de 202109 y definir la cantidad de estímulos del envío final. Construimos una configuración de referencia con los [hiperparámetros inesperados](#punto-de-partida) y el entrenamiento sin undersampling. Estas decisiones iniciales precedieron a la aplicación del criterio de decisión en tres meses.

Retomamos resultados de los [experimentos colaborativos](#1-aportes-de-los-experimentos-colaborativos) y [evaluamos variantes adicionales](#2-pruebas-adicionales-en-los-mismos-bloques) sobre los mismos bloques del workflow. Desde el 13 de noviembre, comparamos las nuevas variantes mediante la ganancia de semilleríos de 100 semillas en 202107, 202105 y 202103. El [criterio de decisión](#criterio-de-decisión), fijado antes de ejecutar esas comparaciones, exigía una P conjunta de al menos 0,90, estimada mediante remuestreo pareado de semillas y clientes. Decidimos por ganancia y no por AUC.

[Ampliar la validación de uno a tres meses](#3-aspectos-no-abordados-en-los-experimentos-colaborativos) fue la decisión que más cambió el resultado. Varias propuestas que alcanzaban el umbral en 202107 no sostuvieron la mejora en los otros períodos y quedaron fuera del modelo final (ver [el patrón de 202107](#el-patrón-de-202107)).

Conservamos el tratamiento de los datos, las variables y la definición de clase del z739. El modelo final utiliza los hiperparámetros inesperados, entrena sin undersampling con `min_data_in_leaf = 3555` y promedia las predicciones de 100 semillas. Las comparaciones realizadas sobre la candidata que estimaba los faltantes por tendencia no se repitieron después de volver a NA; esta limitación queda documentada en [Configuración final y limitaciones](#configuración-final-y-limitaciones).

Para elegir el corte, desarrollamos un [método](#método-para-definir-el-corte) que expresa la meseta de ganancia en envíos por BAJA+2 y compara las pérdidas bajo tres estimaciones de la cantidad de bajas de 202109. Seleccionamos 1800 estímulos por presentar la menor pérdida en el peor de los escenarios considerados, antes de conocer el puntaje público del envío. La tabla de pérdidas utiliza la estimación anterior de 242 BAJA+2 y no fue recalculada con las 238 del modelo final.

La ejecución completa de la notebook de la entrega reprodujo los 13 CSV de la corrida de origen, incluido el envío final, con los mismos md5 (ver [Verificación](#verificación)). El detalle de las decisiones, las corridas y los resultados está disponible en la [bitácora][bitacora].

---

## Punto de partida

Tomamos como base el workflow Senior de la cátedra, [z739][z739], y lo adaptamos al dataset Junior. La adaptación incluyó el cambio de dataset, la competencia de Kaggle, la semilla primigenia (`384841`) y los nombres de los archivos. También redefinimos los cortes de envío, ya que el rango de 8000 a 12000 estímulos del workflow original correspondía al dataset Senior.

El z739 incluye variables intrames, lags y deltas de uno y dos meses, tendencias de seis meses y variables generadas a partir de las hojas de un Random Forest. Utiliza canaritos (random probes): variables de puro azar que permiten descartar las que aportan menos que el azar. Entrena con undersampling del 20 % de los CONTINUA, optimiza los hiperparámetros con optimización bayesiana y promedia un semillerío (modelos entrenados con distintas semillas) de 10 semillas. La clase de entrenamiento es binaria y considera positivos tanto a BAJA+1 como a BAJA+2.

En la [clase 08][libro], del 3 de noviembre de 2026, la cátedra compartió una configuración de LightGBM que denominó *hiperparámetros inesperados*, porque va en contra de lo habitual: combina pocas iteraciones con una tasa de aprendizaje alta, un mínimo elevado de registros por hoja y una fracción reducida de variables por árbol.

| Hiperparámetro | Valor |
|---|---:|
| Iteraciones | 23 |
| `learning_rate` | 0,34 |
| `num_leaves` | 32 |
| `min_data_in_leaf` | 711 |
| `feature_fraction` | 0,20 |

Utilizamos estos valores tal como fueron compartidos. Posteriormente, al retirar el undersampling, ajustamos `min_data_in_leaf` de manera proporcional. La comparación con la optimización bayesiana y el ajuste de este parámetro se presentan en el bloque de [Hyperparameter tuning](#2-pruebas-adicionales-en-los-mismos-bloques) y en el de [Training strategy](#2-pruebas-adicionales-en-los-mismos-bloques).

A partir de lo trabajado en la clase 08, el 7 de noviembre ampliamos el semillerío original de 10 semillas a un mínimo de 30. Desde el 13 de noviembre utilizamos las mismas 100 semillas en todas las nuevas corridas, para comparar las configuraciones de manera pareada. Los resultados que fundamentaron esta ampliación se presentan en el bloque de [Hyperparameter tuning](#2-pruebas-adicionales-en-los-mismos-bloques).

---

## Criterio de decisión

### Configuración de referencia y alcance del criterio

Antes de adoptar el criterio de decisión en tres meses, habíamos definido una configuración de referencia con los hiperparámetros inesperados y el entrenamiento sin undersampling. Los primeros se eligieron por presentar ganancias similares a las de la optimización bayesiana con aproximadamente un quinto del tiempo de ejecución, 8 minutos contra 39. El entrenamiento sin undersampling formaba parte de la candidata del 12 de noviembre. Estas decisiones no estuvieron sujetas al umbral de 0,90.

Desde el 13 de noviembre, aplicamos ese umbral a la comparación conjunta de los tres meses para evaluar la incorporación de nuevas variantes. Comparamos la ganancia de los semilleríos, porque el envío a Kaggle se construye a partir del promedio de sus predicciones.

### Validación temporal

Inicialmente utilizamos un único mes de validación, 202107. Luego incorporamos 202105 y 202103 para evaluar si las mejoras observadas se sostenían en otros períodos.

Los tres meses pertenecen a 2021 y mantienen la misma separación temporal entre entrenamiento y predicción que la utilizada para predecir 202109: en cada caso, el entrenamiento termina dos meses antes del mes que se predice. Los meses adicionales también presentan menos BAJA+2 que 202107, lo que permite evaluar las variantes bajo distintas frecuencias del evento.

Descartamos 202106 por su proximidad a 202107. La validación en 202103 tiene una limitación adicional, ya que dispone de menos meses previos para entrenar.

### Comparación mediante remuestreo

Para cada mes de validación, calculamos la ganancia del semillerío y la promediamos sobre los cortes de 1300 a 3500 estímulos, en intervalos de 100.

Evaluamos las diferencias entre configuraciones mediante 1000 repeticiones de un procedimiento de remuestreo. En cada repetición reconstruimos ambos semilleríos seleccionando semillas con reposición y remuestreamos, también con reposición, los clientes de cada mes. Utilizamos las mismas semillas y los mismos clientes para las dos configuraciones, de modo que la comparación fuera pareada.

Luego sumamos las diferencias de ganancia de los tres meses. Denominamos **P** a la proporción de repeticiones en las que esa suma favorece a la variante evaluada. Esta medida describe el resultado del procedimiento de remuestreo; no es un p-valor.

Una variante reemplaza a la opción vigente si alcanza una P de al menos 0,90. Si dos opciones no se distinguen, queda la más simple, aunque la más compleja sea la vigente. También señalamos los meses en los que una variante obtiene una P inferior a 0,30, para identificar resultados desfavorables que podrían quedar ocultos en la comparación conjunta.

### Evolución del procedimiento

Propusimos el umbral de 0,90 el 8 de noviembre y lo confirmamos el 12, junto con la ventana de cortes. Hasta entonces lo aplicábamos solo en 202107. El 13 de noviembre definimos los tres meses de validación antes de ejecutar las comparaciones correspondientes. Desde entonces utilizamos la P conjunta para decidir, aunque su registro explícito en la bitácora se realizó el 15 de noviembre a las 11:52, antes de las últimas comparaciones.

En las primeras evaluaciones habíamos utilizado la prueba de Wilcoxon para comparar las ganancias obtenidas con cada semilla. Reemplazamos ese procedimiento porque una configuración podía superar a otra en los modelos individuales sin producir un mejor semillerío. Por ejemplo, la optimización bayesiana ganó en 29 de 30 semillas, pero su semillerío no superó al de los inesperados. Por ese motivo, centramos la comparación en el conjunto de predicciones utilizado para generar el envío.

### Fuentes de variabilidad

El semillerío reduce la variabilidad asociada a las semillas, pero no resuelve la sensibilidad del resultado a los clientes y al período evaluado. La validación en tres meses y el remuestreo de clientes permiten examinar esa sensibilidad.

La cantidad de variantes exploradas también exige cautela al interpretar resultados favorables ([Ioannidis, 2005][ioannidis]). Por eso evaluamos si las mejoras observadas en 202107 se sostenían en otros meses, en lugar de incorporar una modificación únicamente por su desempeño en julio (ver [el patrón de 202107](#el-patrón-de-202107)).

La partición entre Public y Private de Kaggle introduce otra fuente de variabilidad. En la clase 08, la cátedra mostró que el desempeño en el Public no anticipaba el del Private. Además, el Public contiene unas 70 BAJA+2 de 202109, y entre cortes vecinos su puntaje varía 2 o 3 M, lo que equivale a una sola BAJA+2. Registramos los puntajes públicos, pero no los utilizamos para seleccionar el modelo ni el corte final.

---

## Qué modificamos y por qué

Presentamos el trabajo en tres apartados: los aportes de los experimentos colaborativos, las pruebas adicionales que realizamos en esos mismos bloques y los aspectos no abordados en los experimentos colaborativos. El origen y la decisión sobre cada cambio probado se resumen en el [Anexo A](#anexo-a-origen-de-cada-cambio-probado).

### 1. Aportes de los experimentos colaborativos

Nuestra configuración difería de las utilizadas en los experimentos colaborativos. Retomamos sus resultados de tres maneras: reprodujimos algunas propuestas sobre nuestras propias candidatas antes de decidir su incorporación; adoptamos otras recomendaciones sin repetir las pruebas; y consideramos algunos resultados como antecedentes para formular pruebas propias.

Presentamos las propuestas en orden de problema, con los títulos utilizados en el [documento de los experimentos colaborativos][expcol].

**Catastrophe analysis: variables rotas (problema #01)**

El grupo B propuso reemplazar cada faltante sistemático por el promedio de los valores del mes anterior y del siguiente para el mismo cliente.

Al evaluar esta propuesta sobre nuestra configuración, obtuvimos una P de 0,63 con los meses de pandemia incluidos en el entrenamiento y de 0,213 al excluirlos. No incorporamos la interpolación. La decisión final sobre estos faltantes se presenta en el bloque de catastrophe analysis del punto 2.

**Data drifting: variables monetarias (problema #02)**

El grupo A comparó nueve métodos de corrección y encontró el mejor resultado con un ranking con cero fijo, aunque utilizó AUC como métrica y no ganancia. El grupo B encontró que la corrección por IPC reduce el drift de las variables monetarias sin mejorar la ganancia.

Con estos antecedentes, evaluamos sobre nuestra configuración las correcciones por IPC, dólar blue y ranking. Conservamos el IPC. Las comparaciones se presentan en el bloque de data drifting del punto 2.

**Feature engineering histórico: variables históricas (problema #04)**

Los grupos obtuvieron resultados diferentes. Para el grupo A, agregar historia reducía la ganancia o no producía cambios. Para el grupo B, incorporar más lags, tendencias y variables de comportamiento la mejoraba.

Como los resultados podían depender de la configuración y del mes evaluado, probamos nuestras propias variantes históricas. Ninguna superó el umbral de incorporación. El detalle se presenta en el bloque de feature engineering histórico del punto 2.

**Feature engineering histórico: lags y pandemia (problema #05)**

Participamos en este experimento como integrantes del grupo A. Nuestra propuesta excluye del entrenamiento los meses de 202003 a 202010 y asigna NA a los lags que utilizan información de ese período.

El resultado en 202107 llevó a seleccionar esta configuración como candidata. Sin embargo, la mejora no se sostuvo al incorporar los otros meses de validación.

| Validación | P a favor de excluir la pandemia |
|---|---:|
| 202107 | 0,933 |
| 202105 | 0,017 |
| 202103 | 0,196 |
| Tres meses, frente a la candidata principal | 0,049 |

La exclusión de ese período reduce la cantidad de meses recientes disponibles para entrenar. También evaluamos una exclusión más restringida, de 202003 a 202007, sin obtener una mejora suficiente para incorporarla. Conservamos los meses de pandemia en el entrenamiento.

En el mismo experimento habíamos encontrado resultados desfavorables para los lags de 3, 6 y 12 meses frente a los de uno y dos meses. El grupo B, en cambio, recomendó lags de 1, 3 y 6 meses. Volvimos a evaluar la variante de 3, 6 y 12 meses sobre nuestra configuración: en 202107 obtuvo una P de 0,384 y no se incorporó.

**Feature engineering: canaritos (problema #06)**

Ambos grupos encontraron que modificar los parámetros de los canaritos no producía cambios en la ganancia. Su reemplazo por Boruta tampoco mostró una mejora: empató en el grupo B y, en el grupo A, redujo la ganancia un 12 % en 202109.

Ninguno de los grupos evaluó entrenar sin canaritos. Realizamos esa prueba sobre nuestra configuración y no encontramos una mejora suficiente para retirarlos. La comparación se presenta en el bloque de canaritos del punto 2.

**Training strategy: meses de pandemia (problema #07)**

El grupo A propuso entrenar únicamente con meses recientes. Evaluamos dos fechas de inicio del entrenamiento y ambas redujeron la ganancia en la validación de 202107.

| Inicio del entrenamiento | Diferencia de ganancia |
|---|---:|
| 202101 | −10,2 M |
| 202103 | −12,4 M |

Con el dataset Junior, estas restricciones dejan pocos meses disponibles para entrenar. Conservamos el período de entrenamiento de la configuración de referencia.

El grupo B no encontró mejoras al ponderar los meses y observó resultados desfavorables al dar más peso a los más antiguos. No repetimos esta prueba, pero la consideramos como antecedente al formular la hipótesis electoral.

**Training strategy: testing en varios meses (problema #08)**

Ambos grupos evaluaron el uso de uno o varios meses de testing en la optimización bayesiana. Ninguna de las ventanas evaluadas mejoró el resultado obtenido con un único mes.

Esta comparación no se aplica directamente a nuestra configuración, que utiliza hiperparámetros fijos. Nuestra validación en tres meses evalúa el workflow completo y tiene un propósito diferente del testing utilizado durante la optimización bayesiana.

**Training strategy: undersampling (problema #09)**

El grupo A encontró que entrenar sin undersampling producía mejores resultados en la mayoría de las semillas, aunque la diferencia no fue significativa con 10 semillas.

El grupo B no observó una pérdida de ganancia al reducir la proporción de CONTINUA del 75 % al 10 %. Concluyó que el undersampling ahorra tiempo de ejecución, pero no mejora la ganancia.

Estos resultados aportaron respaldo a la decisión de retirar el undersampling. Nuestra comparación se presenta en el bloque de training strategy del punto 2.

**Training strategy: esquemas de validación (problema #10)**

El grupo B comparó hold-out, validación cruzada y walk-forward sin encontrar diferencias entre los esquemas. Sus resultados también incluyeron valores altos de `min_data_in_leaf`, entre 4096 y 8192.

La configuración de ese grupo que evaluamos sobre nuestro workflow utilizaba 256 iteraciones, 64 hojas y `min_data_in_leaf = 2048`.

| Validación | Resultado |
|---|---|
| 202107 | Diferencia de ganancia de −4,5 M |
| 202105 | Mejora sin alcanzar el umbral; P = 0,873 |
| Tres meses | P = 0,111 |

No incorporamos esta configuración.

**Hyperparameter tuning: más hiperparámetros en la bayesiana (problema #12)**

Ambos grupos encontraron que ampliar la cantidad de hiperparámetros incluidos en la optimización bayesiana no aumentaba la ganancia.

Consideramos este resultado como antecedente para reemplazar la optimización bayesiana por los hiperparámetros inesperados. Nuestra comparación se presenta en el bloque de hyperparameter tuning del punto 2.

**Hyperparameter tuning: desbalanceo (problema #13)**

El grupo A encontró una señal débil a favor del tratamiento del desbalanceo con `neg_bagging_fraction = 0,25`. El grupo B no observó diferencias entre las estrategias de balanceo.

Registramos esta propuesta como pendiente de baja prioridad y no llegamos a evaluarla.

**Hyperparameter tuning: gbdt, Random Forest y DART (problema #14)**

Ambos grupos encontraron que `gbdt` superaba en ganancia a Random Forest y a DART, y que DART requería más del doble de tiempo de ejecución.

Adoptamos la recomendación sin repetir la prueba y conservamos `gbdt`, como en el z739. Esta comparación se refiere al modelo predictivo. El uso de las hojas de Random Forest como variables constituye otra etapa del workflow, cuya exclusión no evaluamos.

**Training strategy: campos clave (problema #16)**

Ambos grupos evaluaron la exclusión de `numero_de_cliente` y `foto_mes` del modelo. El grupo A no observó cambios en la ganancia en 202109, mientras que el grupo B obtuvo una mejora de 3,35 M en 202107.

En nuestra configuración, que incluye hojas de Random Forest y canaritos, la exclusión redujo la ganancia en 6,3 M en 202105. La comparación conjunta de los tres meses obtuvo una P de 0,009. Conservamos ambos campos.

No se presentaron entregas para los problemas #03, #11, #15, #17 y #18, ni para los grupos A de los problemas #01 y #10.

### 2. Pruebas adicionales en los mismos bloques

En los bloques de los experimentos colaborativos también evaluamos variantes que no habían sido propuestas o exploradas por los otros grupos.

Salvo que se indique otra cosa, comparamos cada variante con la candidata principal en los tres meses de validación, utilizando las mismas 100 semillas.

**Catastrophe analysis (problema #01)**

Identificamos 29 combinaciones de variable y mes sin valores para ningún cliente, a las que llamamos faltantes sistemáticos. Además de la interpolación presentada en el punto anterior, evaluamos estimarlos por tendencia o conservarlos en NA, como en el z739. También intentamos aplicar MICE, pero las pruebas no pudieron completarse por problemas de memoria y de singularidad de la matriz.

La estimación por tendencia obtuvo una P de 0,678 y no alcanzó el umbral de incorporación. El criterio establecido el 13 de noviembre indicaba conservar la opción más simple ante una mejora insuficiente. Teníamos esa regla y se nos pasó por alto: mantuvimos un tiempo la tendencia en la candidata. Lo corregimos el 15 de noviembre y volvimos a NA.

También evaluamos la exclusión de la variable `internet`, que no se incorporó (P = 0,250).

**Data drifting (problema #02)**

El z739 ajusta las variables monetarias por IPC. Evaluamos dos alternativas:

| Variante | P |
|---|---:|
| Agregar un ranking al ajuste por IPC | 0,545 |
| Reemplazar el IPC por el dólar blue | 0,115 |

Ninguna alcanzó el umbral, por lo que conservamos el ajuste por IPC.

También corregimos un error de código en el selector: utilizaba los nombres `drift_dolarblue` y `drift_dolaroficial`, mientras que las funciones se llaman `drift_dolar_blue` y `drift_dolar_oficial`. El error no afectaba las corridas con IPC, porque esas ramas no se ejecutaban.

**Feature engineering intra mes (problema #03, sin entrega)**

Evaluamos nuevas variables intrames y de contexto. Incluimos además un control negativo (ablation): entrenar sin las variables intrames que ya trae el workflow, para medir su aporte. Esta corrida no buscaba incorporarse; la regla de este bloque era evaluar agregados, sin eliminar las variables existentes.

| Variante | Validación | Resultado |
|---|---|---|
| Ratios entre variables monetarias (9058) | Tres meses | P = 0,784 |
| 15 variables de negocio (9057) | Solo 202107 | P = 0,423 |
| Variables de COVID (9059) | Tres meses | P = 0,178 |
| Sin las variables intrames de la cátedra: ablation (9056) | Solo 202107 | 96,1 M frente a 95,0 M de la referencia; P = 0,707 |

Ninguna de las propuestas de nuevas variables alcanzó el umbral de incorporación. En el control, retirar las variables intrames no redujo la ganancia observada, pero tampoco produjo una mejora que superara el umbral. Conservamos las variables de la configuración de referencia.

**Feature engineering histórico (problemas #04 y #05)**

Además de las pruebas sobre lags mencionadas en el punto anterior, evaluamos otras variantes históricas. Incluimos un control negativo (ablation): entrenar sin las variables históricas existentes para medir su aporte. Al igual que en el bloque intra mes, esta corrida no buscaba incorporarse.

| Variante | Validación | Resultado |
|---|---|---|
| Valor respecto de su propio promedio (9053) | Tres meses | P = 0,380 |
| Ventanas de 3, 6 y 12 meses (9055) | Solo 202107 | P = 0,505 |
| Sin las variables históricas: ablation (9052) | Solo 202107 | 93,4 M frente a 95,0 M de la referencia; P = 0,214 |

Las propuestas de nuevas variables no alcanzaron el umbral. El control mostró una reducción de la ganancia al retirar las variables históricas existentes. Conservamos las variables de la configuración de referencia.

**Feature engineering: canaritos (problema #06)**

Evaluamos entrenar sin canaritos, una alternativa que no habían probado los grupos del problema #06. La exclusión obtuvo una P de 0,216, por lo que conservamos esta etapa del workflow.

**Training strategy**

*Undersampling y `min_data_in_leaf` (problema #09)*

Los hiperparámetros inesperados se habían seleccionado utilizando el 20 % de los CONTINUA. Al retirar el undersampling, la cantidad de registros de esa clase se multiplica por cinco. Tomamos esa proporción para ajustar `min_data_in_leaf`, de 711 a 3555.

La pregunta sobre este ajuste fue planteada por Silvina Muzio [en Zulip][zulip-undersampling] y propuesta como experimento por Gustavo.

En línea con lo encontrado por ambos grupos del problema #09, evaluamos retirar el undersampling. Esto permite utilizar todos los CONTINUA tanto en el entrenamiento para validación como en el entrenamiento final, que ya los incluía.

En 202107, la comparación frente a la versión con undersampling obtuvo una P de 0,442. También evaluamos un valor intermedio de `min_data_in_leaf`, 1777, que obtuvo una P de 0,655.

El entrenamiento sin undersampling, con `min_data_in_leaf = 3555`, quedó incorporado en la candidata del 12 de noviembre. Fue una decisión previa a la aplicación del criterio en tres meses y no estuvo respaldada por una mejora que superara el umbral. Desde el 13 de noviembre, esta configuración formó parte de la referencia utilizada para evaluar las nuevas variantes.

*Hipótesis electoral (problema #07)*

El mes que debíamos predecir, 202109, corresponde al período de las elecciones legislativas de 2021, con las PASO el 12 de septiembre y las generales en noviembre. Considerando el horizonte de BAJA+2, nos preguntamos si la información de meses electorales anteriores podía mejorar la predicción.

El dataset contiene un único período electoral previo, el de las elecciones presidenciales de 2019: PASO el 11 de agosto, restricciones cambiarias en septiembre y elecciones generales en octubre. La señal observada no era uniforme: la tasa de BAJA+2 se redujo un 28 % en 201908 y aumentó en 201910 y 201911.

Evaluamos asignar un peso de 3 a las filas de 201908 a 201911. Elegimos ese valor para acentuar una posible señal, aunque no contábamos con meses de validación en contexto electoral para calibrarlo.

| Validación | P a favor de la ponderación electoral |
|---|---:|
| 202107 | 0,940 |
| 202105 | 0,001 |
| 202103 | 0,522 |
| Tres meses | 0,296 |

La mejora observada en 202107 no se sostuvo en los otros meses y no incorporamos la ponderación.

La hipótesis tiene limitaciones adicionales: solo contamos con un período electoral previo, el retiro de fondos no equivale al cierre de una cuenta y el dataset Junior no incluye saldos en dólares ni plazos fijos.

**Definición de la clase**

El z739 considera positivos tanto a BAJA+1 como a BAJA+2. Evaluamos dos alternativas:

| Variante | Tratamiento de BAJA+1 | P |
|---|---|---:|
| Clase ingenua | Se considera negativo; solo BAJA+2 es positivo | 0,007 |
| Clase intermedia | Se considera positivo con peso 0,5 | 0,432 |

Ninguna alcanzó el umbral de incorporación. Conservamos la definición de clase del z739.

**Hyperparameter tuning**

*Optimización bayesiana e hiperparámetros inesperados (problemas #12 y #15)*

Comparamos la optimización bayesiana del z739 (9001) con los hiperparámetros inesperados (9002), inicialmente con 10 semillas por configuración. Las ganancias observadas fueron similares, mientras que los tiempos de ejecución fueron de 39 y 8 minutos, respectivamente.

Luego ampliamos la comparación a 30 semillas. La configuración bayesiana obtuvo mayor ganancia en 29 de las 30 comparaciones individuales. Sin embargo, esa ventaja no se trasladó de la misma manera al promedio de las predicciones del semillerío.

El resultado también dependió de la ventana de cortes utilizada:

| Ventana de cortes | Inesperados: ganancia (M) | Optimización bayesiana: ganancia (M) |
|---|---:|---:|
| 1300 a 2200 | 94,3 | 92,9 |
| 1300 a 3500 | 93,2 | 93,9 |

Estas comparaciones corresponden a 202107, con undersampling. En la ventana definitiva, la P a favor de la configuración bayesiana fue de 0,659.

Mantuvimos los hiperparámetros inesperados porque la optimización bayesiana no alcanzó el umbral y requirió aproximadamente cinco veces más tiempo de ejecución.

La pregunta del problema #15, si es posible prescindir de la optimización de hiperparámetros, no tuvo entrega. Es la que responde esta comparación.

*Cantidad de semillas*

El 7 de noviembre ampliamos el semillerío de 10 semillas a un mínimo de 30. El 12 de noviembre establecimos que, si la ganancia continuaba aumentando entre 20 y 30 semillas, consideraríamos que el semillerío todavía no había alcanzado una meseta.

Eso ocurrió en la corrida 9014: su ganancia pasó de 96,6 M con las primeras 20 semillas a 97,0 M con las 30. La repetimos con 100 semillas (9029) y obtuvimos 96,4 M.

En el ejemplo presentado por la cátedra en la clase 08, la ganancia se estabilizaba alrededor de las 30 semillas. Elegimos trabajar con 100 para disponer de un margen adicional, aunque esa cantidad tuvo un componente arbitrario.

Desde el 13 de noviembre utilizamos las mismas 100 semillas en todas las nuevas corridas, de modo que las comparaciones fueran pareadas. La reducción de ganancia al pasar de 30 a 100 muestra la sensibilidad del resultado a las semillas utilizadas.

Las limitaciones de estas comparaciones se reúnen en [Configuración final y limitaciones](#configuración-final-y-limitaciones).

### 3. Aspectos no abordados en los experimentos colaborativos

Además de las pruebas sobre los bloques anteriores, trabajamos sobre la validación del workflow completo, el criterio para incorporar modificaciones, la elección del corte y la verificación de la reproducibilidad.

**Validación del workflow completo**

Hasta el 12 de noviembre utilizábamos únicamente 202107 para evaluar las variantes. Más semillas reducen el azar asociado a la semilla, pero no el de los clientes del mes de validación. Para evaluar ese componente hace falta otro mes, con otros clientes. Por eso incorporamos 202105 y 202103, según el diseño presentado en [Criterio de decisión](#criterio-de-decisión).

Fue la decisión que más cambió el resultado.

Los tres meses de validación tenían las siguientes frecuencias:

| Mes | BAJA+2 | Tasa de BAJA+2 |
|---|---:|---:|
| 202107 | 244 | 0,741 % |
| 202105 | 180 | 0,549 % |
| 202103 | 176 | 0,540 % |

#### El patrón de 202107

202107 tiene la tasa de BAJA+2 más alta de la serie (0,741 %). Cinco cambios alcanzaron el umbral en 202107 y perdieron en 202105: excluir los meses de pandemia, usar el dólar blue, retirar `internet`, agregar el valor respecto de su propio promedio y aplicar la ponderación electoral. Un sexto, el promedio de las dos candidatas, también ganó solo en 202107. Con un único mes de validación, alguno de esos cambios habría entrado.

La pregunta del problema #18, sobre la estabilidad del modelo en el tiempo, no tuvo entrega. La validación en tres meses la aborda al evaluar si los resultados se sostienen en otros períodos.

Esta evaluación corresponde al workflow completo y se diferencia de las pruebas del problema #08, centradas en los meses de testing utilizados durante la optimización bayesiana.

**Criterio para incorporar modificaciones**

Fijamos el criterio antes de ver los resultados de las comparaciones a las que se aplicaría. Desde el 13 de noviembre, una variante reemplaza a la opción vigente solo si alcanza una P conjunta de al menos 0,90 en los tres meses, estimada mediante remuestreo pareado de semillas y clientes.

Decidimos siempre por ganancia y no por AUC, porque en nuestras corridas las dos medidas no ordenaban igual a las variantes. Esta era la pregunta del problema #11, que no tuvo entrega.

El procedimiento, su evolución y su alcance se describen en [Criterio de decisión](#criterio-de-decisión).

**Elección del corte**

El corte era un aspecto fijo en los experimentos colaborativos: ninguna de las consignas proponía modificarlo. Desarrollamos un método propio para elegirlo a partir de las curvas de ganancia en validación y de distintas estimaciones de las BAJA+2 de 202109.

La idea central fue expresar los cortes de la meseta de ganancia en **envíos por BAJA+2**, para comparar meses con distinta cantidad de bajas. Luego evaluamos cuánto se perdería con cada corte bajo las distintas estimaciones y seleccionamos 1800 estímulos antes de conocer el puntaje público de ese envío.

El desarrollo se presenta en [Método para definir el corte](#método-para-definir-el-corte).

**Reproducibilidad**

Ejecutamos la notebook de la entrega desde cero, a partir del dataset original, como corrida 9088. Los 13 archivos de Kaggle generados tuvieron los mismos md5 que los de la corrida de origen, 9085, incluido el correspondiente al envío final de 1800 estímulos.

Las instrucciones de ejecución y los resultados de esta comprobación se presentan en [Cómo reproducir](#cómo-reproducir) y [Verificación](#verificación).

---

## Configuración final y limitaciones

El modelo final corresponde a la corrida 9085. Conserva la mayor parte del procesamiento del z739, utiliza los hiperparámetros inesperados, entrena sin undersampling y promedia las predicciones de 100 semillas.

| Componente | z739 | Configuración final |
|---|---|---|
| Catastrophe analysis | Faltantes sistemáticos en NA | Se conservan en NA |
| Data drifting | Ajuste por IPC | Se conserva |
| Feature engineering intra mes | Variables de la cátedra | Se conservan |
| Feature engineering histórico | Lags y deltas de uno y dos meses; tendencia de seis meses | Se conservan |
| Feature engineering: canaritos | Canaritos (random probes) | Se conservan |
| Training strategy | Undersampling del 20 % de los CONTINUA | Sin undersampling |
| Definición de la clase | BAJA+1 y BAJA+2 como positivos | Se conserva |
| Hyperparameter tuning | Optimización bayesiana | Hiperparámetros inesperados |
| Hyperparameter tuning: semillerío | 10 semillas | 100 semillas |
| Corte | 8000 a 12000 estímulos | 1800 estímulos |

También conservamos las hojas de Random Forest como variables, los campos `numero_de_cliente` y `foto_mes`, y los meses de pandemia en el entrenamiento.

La configuración final de hiperparámetros es la siguiente:

| Hiperparámetro | Valor |
|---|---:|
| Iteraciones | 23 |
| `learning_rate` | 0,34 |
| `num_leaves` | 32 |
| `min_data_in_leaf` | 3555 |
| `feature_fraction` | 0,20 |

El valor de `min_data_in_leaf` corresponde al ajuste proporcional realizado al retirar el undersampling. El envío final utiliza un corte de 1800 estímulos, cuya elección se desarrolla en el apartado siguiente.

### Alcance de las decisiones y limitaciones

La adopción inicial de los hiperparámetros inesperados y del entrenamiento sin undersampling precedió a la aplicación del criterio en tres meses. Por lo tanto, su presencia en el modelo final no implica que ambas decisiones hayan superado ese umbral. Los inesperados se eligieron inicialmente por las ganancias observadas y el menor tiempo de ejecución; el entrenamiento sin undersampling quedó como parte de la configuración de referencia del 12 de noviembre.

Las primeras comparaciones utilizaron un único mes de validación y semilleríos de 10 o 30 semillas. Desde el 13 de noviembre ampliamos la evaluación a tres meses y utilizamos las mismas 100 semillas en las nuevas corridas. Las excepciones se indican en los resultados de cada bloque.

Las comparaciones con la candidata principal se realizaron cuando todavía estimábamos los faltantes sistemáticos por tendencia. El modelo final volvió a NA, pero no repetimos esas comparaciones después del cambio. Aunque la diferencia se concentra en 29 combinaciones de variable y mes, los resultados informados corresponden a la configuración utilizada en cada prueba.

De los tres meses de validación, 202103 es el más débil: entrena con menos meses, y las hojas de Random Forest y los canaritos, que se entrenan dos meses antes, caen en meses de pandemia.

---

## Método para definir el corte

Dejar afuera a un BAJA+2 implica perder una ganancia de 0,975 M, mientras que enviar un estímulo a un cliente que no es BAJA+2 cuesta 0,025 M. Por esa asimetría, buscamos un corte dentro de la meseta de ganancia, donde aumentar ligeramente los envíos tenga un costo reducido.

El método combina las curvas de ganancia de los meses de validación con distintas estimaciones de la cantidad de BAJA+2 de 202109.

### 1. Expresar la meseta en envíos por BAJA+2

Definimos la meseta como el conjunto de cortes cuya ganancia, suavizada mediante la media de cinco cortes vecinos, queda a 1 M o menos del máximo.

Como cada mes tiene una cantidad diferente de BAJA+2, expresamos esos cortes en envíos por BAJA+2. Esta escala permite comparar cuántos estímulos se necesitan, en relación con la cantidad total de bajas del mes, para alcanzar la meseta.

| Mes | BAJA+2 | Meseta en envíos | Envíos por BAJA+2 |
|---|---:|---|---|
| 202107 | 244 | 1600 a 2000 | 6,6 a 8,2 |
| 202105 | 180 | 1400 a 2400 | 7,8 a 13,3 |
| 202103 | 176 | 800 a 1200 | 4,5 a 6,8 |

Los resultados corresponden a las corridas 9085, 9086 y 9087, que evalúan la configuración final en cada mes.

202107 y 202105 comparten el intervalo de 7,8 a 8,2 envíos por BAJA+2. La meseta de 202103 se encuentra en un rango inferior. No existe una intersección común a los tres meses, por lo que definimos el corte comparando las pérdidas de ganancia bajo distintos escenarios, como se explica en el paso 3.

### 2. Estimar las BAJA+2 de 202109

Estimamos la cantidad de BAJA+2 entre los 33.080 clientes de 202109 mediante tres procedimientos:

| Estimación | Cómo se calcula | BAJA+2 estimadas |
|---|---|---:|
| Tasa de 2021 | Tasa de BAJA+2 de 2021, de 0,617 %, aplicada a los 33.080 clientes | 204 |
| Tasa de los últimos tres meses | Tasa de BAJA+2 de los últimos tres meses con clase, de 0,653 %, aplicada a los 33.080 clientes | 216 |
| Probabilidades del modelo | Suma de las probabilidades individuales de 202109, calibrada con lo observado en 202107 | 242 con tendencia; 238 en el modelo final |

La tasa de 2021 se calculó con 1.411 BAJA+2 sobre 228.624 registros de clientes; la de los últimos tres meses, con 644 sobre 98.616. En el modelo final, la suma de probabilidades de 202109 fue de 417,5 antes de la calibración.

La tabla de pérdidas del paso 3 se construyó con las estimaciones de 204, 216 y 242 BAJA+2. Esta última correspondía a la versión que estimaba los faltantes por tendencia, vigente cuando elaboramos el método. Al volver a NA, la estimación del modelo final pasó a 238. No recalculamos la tabla de pérdidas.

Con 238 BAJA+2, el corte de 1800 equivale a 7,6 envíos por BAJA+2, frente a 7,4 con la estimación anterior. Ambos valores están dentro de la meseta de 202107; esta comprobación no reemplaza el recálculo de los seis escenarios.

Las estimaciones utilizadas para decidir abarcan de 204 a 242 BAJA+2. La tasa había aumentado durante 2021: de 0,540 % en 202103 a 0,549 % en 202105, 0,669 % en 202106 y 0,741 % en 202107. Si esa evolución continuaba, 202109 podía superar las 216 bajas estimadas con los últimos tres meses.

La estimación del modelo utiliza información individual de los clientes de 202109; las otras dos trasladan tasas observadas en meses anteriores. Como desconocemos la cantidad real, comparamos los cortes bajo las tres estimaciones.

### 3. Comparar la pérdida de ganancia de cada corte

Para cada corte y cada estimación, calculamos los envíos por BAJA+2 y utilizamos las curvas de validación para medir la pérdida respecto del máximo de cada mes.

Resumimos esas pérdidas de dos maneras: con el promedio de los tres meses y con el promedio de 202107 y 202105. El segundo resumen permite examinar el resultado sin 202103, que dispone de menos meses para entrenar.

Las tres estimaciones y los dos resúmenes generan seis escenarios por corte. La tabla muestra la suma de sus diferencias respecto del máximo y la diferencia en el peor escenario. Los valores negativos representan pérdida de ganancia.

| Corte | Suma de las seis diferencias (M) | Peor escenario (M) |
|---|---:|---:|
| 1500 | −8,9 | −2,7 |
| 1600 | −6,6 | −1,7 |
| 1700 | −5,5 | −1,2 |
| **1800** | **−5,6** | **−1,1** |
| 1900 | −6,5 | −1,5 |
| 2000 | −7,9 | −1,6 |
| 2100 | −8,3 | −1,7 |
| 2200 | −9,6 | −2,1 |
| 2300 | −10,2 | −2,2 |
| 2400 | −10,7 | −2,5 |
| 2500 | −11,6 | −3,0 |
| 2600 | −13,8 | −3,6 |
| 2700 | −15,7 | −4,2 |

El mejor corte cambia según la estimación: 1600 con 204 BAJA+2, 1700 con 216 y 1900 con 242.

El corte de 1800 presenta la menor pérdida en el peor escenario considerado, de 1,1 M, y la segunda menor pérdida acumulada. Su diferencia acumulada respecto de 1700 es de 0,1 M. Entre opciones con resultados cercanos, priorizamos un corte ligeramente mayor por la asimetría entre omitir un BAJA+2 y enviar un estímulo adicional.

Con las estimaciones utilizadas, 1800 representa entre 7,4 y 8,8 envíos por BAJA+2.

### 4. Fijar el envío final

Elegimos el corte de 1800 el 15 de noviembre a las 15:58, antes de conocer su puntaje público. Lo subimos desde la cuenta principal y lo marcamos como envío final a las 16:14.

Registramos los puntajes del Public, pero no los utilizamos para elegir el corte. El detalle de los envíos y las cuentas utilizadas se presenta en el [Anexo B](#anexo-b-registro-de-envíos-a-kaggle).

---

## Cómo reproducir

### Entorno y archivos necesarios

La notebook se ejecutó en una máquina virtual de la materia en Google Cloud, con el siguiente entorno:

| Componente | Configuración |
|---|---|
| Procesador | 8 vCPU AMD EPYC 7B12 |
| Memoria | 60 GB |
| Kernel | `ir` |
| R | 4.6.1 |
| lightgbm | 4.7.0.99 |
| data.table | 1.18.6.1 |
| Tiempo de ejecución | Aproximadamente 13 minutos |

La notebook instala los paquetes auxiliares que falten: `R.utils`, `mice`, `lubridate`, `Rcpp`, `DiceKriging`, `mlrMBO`, `primes` y `yaml`.

Utiliza el dataset original, sin modificaciones, ubicado en:

```text
/content/datasets/analistajr_competencia_2026.csv.gz
```

El archivo tiene 90.547.491 bytes y md5 `10dd4969dd7d7cf746ce1331bfd22276`.

### Ejecución

1. Colocar el dataset en la ruta indicada.
2. Copiar `cpf_final_analista_jr.ipynb` a la máquina virtual.
3. Desde la carpeta que contiene la notebook, ejecutar:

```bash
jupyter nbconvert --to notebook --execute \
  --ExecutePreprocessor.kernel_name=ir \
  --ExecutePreprocessor.timeout=-1 \
  --output-dir=/content/buckets/b1/exp/WF9088 \
  --output=corrida_9088.ipynb \
  cpf_final_analista_jr.ipynb
```

La notebook crea la carpeta `/content/buckets/b1/exp/WF9088/` y genera, dentro de `kaggle/`, un CSV por corte de 1500 a 2700 estímulos, en intervalos de 100.

El archivo correspondiente al envío final es `KA9088_100_1800.csv`. Para comprobarlo:

```bash
md5sum \
  /content/buckets/b1/exp/WF9088/kaggle/KA9088_100_1800.csv
```

El resultado esperado es:

```text
dbfa78781de150967de93c6abc5daae7
```

El número de experimento es 9088 para evitar sobrescribir la carpeta de 9085. Cambia el nombre de los archivos, pero reproduce su contenido.

La subida automática a Kaggle está desactivada mediante `PARAM$kaggle$subir <- FALSE`. La notebook también guarda las probabilidades por semilla en `prediccion.txt`, la validación en 202107, los parámetros en `PARAM.yml` y los archivos `canaritos.txt` e `impo.txt`.

---

## Verificación

El 15 de noviembre ejecutamos la notebook de la entrega desde cero, a partir del dataset original, como experimento 9088.

Comparamos sus CSV con los generados a partir de la predicción guardada de 9085, la corrida de origen del envío final. Los 13 archivos, correspondientes a los cortes de 1500 a 2700, dieron los mismos md5. Esto incluye el corte de 1800, cuyo md5 es `dbfa78781de150967de93c6abc5daae7`.

La comprobación incluyó el orden de los clientes, los clientes seleccionados, la ganancia y el md5 de cada CSV. El detalle se presenta en el [Anexo C](#anexo-c-verificación-de-los-archivos-de-kaggle).

Las probabilidades presentaron diferencias de hasta 1,1 × 10⁻¹², asociadas a las sumas en paralelo de LightGBM y a la aritmética de punto flotante. Estas diferencias no modificaron los clientes seleccionados ni los CSV generados.

Como antecedentes, el 13 de noviembre habíamos ejecutado la configuración 9029 en dos máquinas virtuales con el mismo procesador, obteniendo los mismos clientes seleccionados y los mismos md5. El 15 de noviembre también verificamos la versión anterior, con los faltantes estimados por tendencia: la comparación entre 9084 y 9031 produjo nueve md5 idénticos, correspondientes a los cortes de 1900 a 2700.

---

## Autoría y uso de IA

Escribimos en primera persona del plural porque ningún saber es estrictamente propio: el trabajo recoge el workflow y las enseñanzas de la cátedra, los experimentos de compañeras y compañeros, y las decisiones y los desarrollos de quienes han trabajado antes. A todas esas personas, gracias.

Utilizamos asistentes de IA para distintas tareas:

| Herramienta | Uso |
|---|---|
| Claude, de Anthropic | Discusión del diseño experimental, revisión crítica de la lectura de resultados, búsqueda de literatura y revisión de la redacción |
| Claude Code, de Anthropic | Escritura y ejecución de código y scripts en las máquinas virtuales, control de versiones y registro en la bitácora |
| ChatGPT, de OpenAI | Revisión de la estructura y la redacción del informe, y lectura crítica de la coherencia entre métodos, resultados y decisiones |

Las decisiones finales y la responsabilidad por la entrega son mías. Los criterios utilizados, sus modificaciones y las decisiones quedaron registrados con fecha en la bitácora. El entorno de trabajo con Claude Code está documentado en [`CLAUDE.md`][claudemd].

---

## Archivos y bitácora

| Archivo o carpeta | Contenido |
|---|---|
| [`cpf_final_analista_jr.ipynb`][notebook] | Notebook que reproduce la configuración final y genera los CSV |
| `PARAM.yml` | Parámetros registrados durante la corrida de verificación 9088 |
| `README.md` | Este documento |
| [`trabajo/`][trabajo] | Carpeta con el recorrido experimental y sus registros |

La notebook de la entrega corresponde a la configuración de 9085 con cuatro cambios:

- El número de experimento pasa a 9088 para evitar sobrescribir la carpeta de origen.
- Se corrigen los nombres de las funciones en el selector de data drifting.
- Se generan cortes de 1500 a 2700 estímulos, en intervalos de 100.
- Se desactiva la subida automática a Kaggle.

`PARAM.yml` es el archivo generado durante la verificación y tiene md5 `aeed581972db389bed3dcf9f12b2aa68`.

La carpeta [`trabajo/`][trabajo] reúne la [bitácora][bitacora], las notebooks de las corridas, los scripts de comparación y la documentación del entorno de trabajo en [`CLAUDE.md`][claudemd].

La bitácora registra las decisiones con fecha, hora y fundamento. Incluye además el catálogo de cambios, la tabla de corridas y la lectura de resultados por bloque, para vincular las pruebas realizadas con las decisiones presentadas en este informe.

---

## Anexo A: origen de cada cambio probado

La tabla reúne las propuestas consideradas, las pruebas realizadas y las decisiones adoptadas. Los controles por ablation se utilizaron para medir el aporte de variables existentes y no se evaluaron como candidatas para su incorporación.

| Bloque | Propuesta o prueba | Origen o antecedente | Uso o decisión |
|---|---|---|---|
| Catastrophe analysis | Interpolar faltantes | #01 B | No incorporada |
| Catastrophe analysis | Estimar faltantes por tendencia | Propio | No incorporada en el modelo final |
| Catastrophe analysis | Estimar faltantes con MICE | Propio | Prueba no completada |
| Catastrophe analysis | Retirar `internet` | Propio | No incorporada |
| Data drifting | Ranking y dólar blue | Propio, con antecedente del #02 | No incorporados |
| Feature engineering intra mes | Ratios y variables de negocio | Propio | No incorporados |
| Feature engineering intra mes | Variables de COVID | Propio | No incorporadas |
| Feature engineering intra mes | Retirar las variables intrames: ablation | Propio | Control |
| Feature engineering histórico | Lags de 3, 6 y 12 meses | #05 | No incorporados |
| Feature engineering histórico | Valor respecto del promedio y ventanas | Propio, con antecedente del #04 | No incorporados |
| Feature engineering histórico | Retirar las variables históricas: ablation | Propio | Control |
| Feature engineering histórico | Excluir los meses de pandemia | #05 A | No incorporada |
| Feature engineering: canaritos | Conservar canaritos frente a su reemplazo por Boruta | #06 | Recomendación adoptada sin prueba propia |
| Feature engineering: canaritos | Entrenar sin canaritos | Propio, pregunta no evaluada en el #06 | No incorporada |
| Feature engineering | Retirar las hojas de Random Forest como variables | Propio | Sin probar |
| Training strategy | Entrenar solo con meses recientes | #07 A | No incorporada |
| Training strategy | Dar más peso a los meses antiguos | #07 B | Antecedente |
| Training strategy | Ponderar los meses electorales | Propio | No incorporada |
| Training strategy | Más meses de testing en la optimización bayesiana | #08 | No aplica: el workflow no usa optimización bayesiana |
| Training strategy | Retirar el undersampling y usar `min_data_in_leaf = 3555` | Zulip: S. Muzio; respaldo del #09 | Incorporada |
| Training strategy | Usar `min_data_in_leaf = 1777` | Propio | No incorporada |
| Training strategy | Utilizar los hiperparámetros del #10 B | #10 B | No incorporada |
| Training strategy | Retirar los campos clave | #16 | No incorporada |
| Definición de la clase | Clase ingenua e intermedia | Propio | No incorporadas |
| Hyperparameter tuning | Utilizar los hiperparámetros inesperados | Cátedra, clase 08; comparación vinculada al #15 | Incorporada |
| Hyperparameter tuning | Ampliar los hiperparámetros de la optimización bayesiana | #12 | Antecedente |
| Hyperparameter tuning | Utilizar `neg_bagging_fraction` | #13 A | Sin probar |
| Hyperparameter tuning | Conservar `gbdt` frente a Random Forest y DART | #14 | Recomendación adoptada sin prueba propia |
| Hyperparameter tuning | Ampliar el semillerío a 30 semillas | Cátedra, clase 08 | Incorporada |
| Hyperparameter tuning | Ampliar el semillerío a 100 semillas | Propio | Incorporada |
| Aspectos no abordados en los experimentos colaborativos | Validación del workflow en tres meses | Propio; pregunta del #18, sin entrega | Incorporada |
| Aspectos no abordados en los experimentos colaborativos | Criterio de decisión mediante remuestreo | Propio; decide por ganancia, pregunta del #11, sin entrega | Incorporado |
| Aspectos no abordados en los experimentos colaborativos | Método para definir el corte | Propio | Incorporado |
| Aspectos no abordados en los experimentos colaborativos | Verificación de reproducibilidad | Propio | Realizada |

---

## Anexo B: registro de envíos a Kaggle

Registramos los siguientes puntajes públicos para distintos cortes de la corrida 9085. Utilizamos la cuenta principal, `carlaperezfernandez`, y la secundaria, `carlapf`, cuando el cupo diario de la principal no alcanzaba para completar las exploraciones.

| Corte | Public (M) | Cuenta |
|---|---:|---|
| 1500 | 90,9 | Secundaria |
| 1600 | 91,7 | Principal |
| 1700 | 92,0 | Secundaria |
| 1750 | 94,0 | Principal |
| **1800** | **92,6** | **Principal** |
| 1850 | 95,1 | Principal |
| 1900 | 97,1 | Secundaria |
| 2000 | 95,0 | Principal |
| 2100 | 92,5 | Secundaria |
| 2200 | 90,2 | Principal |
| 2300 | 87,6 | Secundaria |
| 2400 | 85,5 | Principal |
| 2500 | 86,8 | Secundaria |
| 2700 | 81,8 | Secundaria |
| 2900 | 77,3 | Secundaria |

Los puntajes muestran oscilaciones entre cortes cercanos, sensibles a la distribución de las BAJA+2 en el 30 % que integra el Public. Conservamos este registro como parte del recorrido experimental. La decisión final se basó en el método de validación descrito en el cuerpo del documento.

---

## Anexo C: verificación de los archivos de Kaggle

Los archivos generados por la ejecución completa de la notebook de la entrega, como corrida 9088, coinciden con los generados a partir de la predicción de 9085.

| Corte | md5 idéntico en 9085 y 9088 |
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

[kaggle]: https://www.kaggle.com/competitions/labo-1-virtual-2026-analista-jr
[perfil]: https://www.kaggle.com/carlaperezfernandez
[notebook]: cpf_final_analista_jr.ipynb
[libro]: https://storage.googleapis.com/open-courses/austral2026-5da5/labo1-virtual/Austral_labo2026-VIRTUAL.pdf
[expcol]: https://docs.google.com/presentation/d/13GXCXtlAEPEpR4z4gyxc06exZnh06w_IEbt8dPjA2sY/edit?usp=sharing
[ioannidis]: https://doi.org/10.1371/journal.pmed.0020124
[z739]: https://github.com/labo-imp/labo2026v/blob/main/PredFinal/z739_final_senior.ipynb
[trabajo]: trabajo/
[bitacora]: trabajo/BITACORA.md
[claudemd]: trabajo/CLAUDE.md
[zulip-undersampling]: https://austral2026.zulip.rebelare.com/#narrow/channel/1093-L1V-Experimentos-Colaborativos/topic/Undersampling.20de.20clase.20CONTINUA/with/207232
