# Serie mensual de COVID para el FE de contexto (I2, 13/11): AMBA y nacional
#
# FUENTES (bajadas el 13/11/2026 a ~/buckets/b1/datasets/externos/)
#
# 1. Sistemas Mapache, Covid19arData (licencia CC BY 4.0): partes diarios oficiales del Ministerio de Salud
#    de la Nacion, cargados por provincia y por dia (fecha del parte), del 02/03/2020 al 09/11/2021.
#    Repo:  https://github.com/SistemasMapache/Covid19arData
#    Datos: el repo enlaza la planilla (la serie no esta en archivos del repo, salvo un espejo de mayo de 2020)
#      https://docs.google.com/spreadsheets/d/16-bnsDdmmgtSxdWbVMboIHo5FRuz76DBxsz_BbsEVWA/export?format=csv&id=16-bnsDdmmgtSxdWbVMboIHo5FRuz76DBxsz_BbsEVWA&gid=0
#    Archivo: mapache/mapache_historico.csv (927.804 bytes, md5 399d559d20d530a60aca627a2c222027)
#    Columnas usadas: fecha, osm_admin_level_4 (provincia), nue_casosconf_diff, nue_fallecidos_diff.
#    Los nue_fallecidos_diff vacios se toman como 0: con eso la suma por provincia coincide con la
#    diferencia del acumulado nacional (tot_fallecidos) en todos los meses (diferencia de 0 a 2 muertes).
#
# 2. Our World in Data, owid-covid-data.csv (solo para comparar; el notebook no lo usa por defecto)
#    https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv
#    (98.391.483 bytes, md5 435c09b9ba2bb962b13c1d936a2be13b; el dominio covid.ourworldindata.org ya no resuelve)
#    Desde 2023 OWID toma la serie de la OMS: para Argentina, un dato por semana (los domingos) y las muertes
#    reasignadas por el Ministerio. El total coincide con Mapache (al 30/09/2021: 5.318.508 contra 5.256.902 casos,
#    116.434 contra 115.179 muertes), pero mes a mes los casos difieren entre 0,73 y 1,19 veces (la semana
#    cae en un mes o en el otro) y las muertes entre 0,35 y 3,20 veces.
#
# POBLACION: proyecciones 2020 del INDEC (proyecciones de poblacion 2010-2040).
#    CABA 3.075.646; provincia de Buenos Aires 17.541.141; total del pais 45.376.763.
#    AMBA, aca, es CABA + provincia de Buenos Aires completa (decision de Carla del 13/11), no solo los 40 partidos.
#
# SALIDA: ~/buckets/b1/datasets/externos/covid_mensual.csv, una fila por foto_mes (201901 a 202109):
#   covid_amba_casos_100k, covid_amba_muertes_100k   casos y muertes del mes cada 100.000 habitantes (Mapache)
#   covid_nac_casos_100k,  covid_nac_muertes_100k    lo mismo, todo el pais (Mapache)
#   covid_owid_casos_100k, covid_owid_muertes_100k   todo el pais segun OWID (comparacion)
#   y cada una con _mesant: el valor del mes anterior. Antes de 202003: 0.
#
# Uso: Rscript covid_mensual.R

library(data.table)

dir_ext <- file.path(Sys.getenv("HOME"), "buckets/b1/datasets/externos")
POB <- c(caba = 3075646, pba = 17541141, pais = 45376763)

meses <- data.table(foto_mes = as.integer(format(seq(as.Date("2019-01-01"), as.Date("2021-09-01"), by = "month"), "%Y%m")))

# 1. Mapache: suma de los partes diarios por mes
m <- fread(file.path(dir_ext, "mapache/mapache_historico.csv"),
           select = c("fecha", "osm_admin_level_4", "nue_casosconf_diff", "nue_fallecidos_diff"))
m[, f := as.IDate(fecha, format = "%d/%m/%Y")]
stopifnot(!anyNA(m$f))
m[, foto_mes := year(f) * 100L + month(f)]
m[is.na(nue_casosconf_diff), nue_casosconf_diff := 0L]
m[is.na(nue_fallecidos_diff), nue_fallecidos_diff := 0L]

amba <- m[osm_admin_level_4 %in% c("CABA", "Buenos Aires"),
          .(casos = sum(nue_casosconf_diff), muertes = sum(nue_fallecidos_diff)), by = foto_mes]
nac <- m[, .(casos = sum(nue_casosconf_diff), muertes = sum(nue_fallecidos_diff)), by = foto_mes]

# 2. OWID: diferencia del acumulado al ultimo dato de cada mes
o <- fread(file.path(dir_ext, "owid-covid-data.csv"),
           select = c("iso_code", "date", "total_cases", "total_deaths", "population"))[iso_code == "ARG"]
o[, date := as.IDate(date)]
setorder(o, date)
pob_owid <- as.numeric(o[!is.na(population), last(population)])  # fread la lee como integer64
o[, foto_mes := year(date) * 100L + month(date)]
om <- o[, .(tc = last(na.omit(total_cases)), tf = last(na.omit(total_deaths))), by = foto_mes]
om <- merge(data.table(foto_mes = c(201912L, meses$foto_mes)), om, by = "foto_mes", all.x = TRUE)
om[is.na(tc) & foto_mes < 202003, `:=`(tc = 0, tf = 0)]
om[, `:=`(casos = tc - shift(tc), muertes = tf - shift(tf))]

serie <- copy(meses)
serie[amba, on = "foto_mes", `:=`(covid_amba_casos_100k = i.casos / (POB[["caba"]] + POB[["pba"]]) * 1e5,
                                  covid_amba_muertes_100k = i.muertes / (POB[["caba"]] + POB[["pba"]]) * 1e5)]
serie[nac, on = "foto_mes", `:=`(covid_nac_casos_100k = i.casos / POB[["pais"]] * 1e5,
                                 covid_nac_muertes_100k = i.muertes / POB[["pais"]] * 1e5)]
serie[om, on = "foto_mes", `:=`(covid_owid_casos_100k = i.casos / pob_owid * 1e5,
                                covid_owid_muertes_100k = i.muertes / pob_owid * 1e5)]
base <- setdiff(names(serie), "foto_mes")
for (v in base) serie[is.na(get(v)) & foto_mes < 202003, (v) := 0]
setorder(serie, foto_mes)
for (v in base) serie[, paste0(v, "_mesant") := shift(get(v), fill = 0)]
stopifnot(nrow(serie) == 33, !anyNA(serie))

fwrite(serie, file.path(dir_ext, "covid_mensual.csv"))

# control: AMBA y nacional de Mapache contra OWID, meses con casos
ctl <- serie[foto_mes >= 202003, .(foto_mes,
  amba_casos = round(covid_amba_casos_100k, 1), nac_casos = round(covid_nac_casos_100k, 1), owid_casos = round(covid_owid_casos_100k, 1),
  amba_muertes = round(covid_amba_muertes_100k, 2), nac_muertes = round(covid_nac_muertes_100k, 2), owid_muertes = round(covid_owid_muertes_100k, 2))]
ctl[, `:=`(nac_sobre_owid_casos = round(nac_casos / owid_casos, 2), nac_sobre_owid_muertes = round(nac_muertes / owid_muertes, 2))]
print(ctl)
cat("correlacion mensual Mapache nacional contra OWID: casos",
    round(ctl[, cor(nac_casos, owid_casos)], 3), " muertes", round(ctl[, cor(nac_muertes, owid_muertes)], 3), "\n")
cat("correlacion mensual AMBA contra nacional (Mapache): casos",
    round(ctl[, cor(amba_casos, nac_casos)], 3), " muertes", round(ctl[, cor(amba_muertes, nac_muertes)], 3), "\n")
