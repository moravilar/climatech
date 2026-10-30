# Este script arma el dataset de ejemplo del paquete, datos_estaciones.
# Se corre una sola vez (o de nuevo si hay que cambiar los datos).
# Usa dos de las estaciones que trabajamos en el proyecto transversal.

devtools::load_all()   # para poder usar leer_dataset()

nh0437 <- leer_dataset("NH0437", ruta = "data_raw/NH0437.csv")
nh0472 <- leer_dataset("NH0472", ruta = "data_raw/NH0472.csv")

# primero nos quedamos con las mismas columnas en las dos estaciones
# (usamos humedad_media_8_14_20 porque humedad_media esta vacia en estas
# dos estaciones: no tiene ningun dato en toda la serie)
nh0437 <- dplyr::select(nh0437, id, fecha, temperatura_abrigo_150cm, humedad_media_8_14_20)
nh0472 <- dplyr::select(nh0472, id, fecha, temperatura_abrigo_150cm, humedad_media_8_14_20)

# unimos con full_join por todas las columnas: como el id de cada estacion
# es distinto, ninguna fila coincide y full_join conserva todas, asi que
# las dos tablas quedan una debajo de la otra
datos_estaciones <- dplyr::full_join(nh0437, nh0472)

# nos quedamos con 9 anios, para que el paquete no pese mucho
datos_estaciones <- dplyr::filter(datos_estaciones,
                                  lubridate::year(fecha) >= 2004,
                                  lubridate::year(fecha) <= 2013)

# guarda los datos en data/datos_estaciones.rda
usethis::use_data(datos_estaciones, overwrite = TRUE)
