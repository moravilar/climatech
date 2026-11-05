# casos base: la funcion se usa como esta pensada

test_that("devuelve un tibble con las columnas esperadas", {
  resultado <- suppressMessages(tabla_resumen(datos_estaciones))

  expect_s3_class(resultado, "tbl_df")
  expect_named(resultado, c("mes", "estadistico", "valor"))
})

test_that("con todos los datos juntos hay 5 estadisticos para cada uno de los 12 meses", {
  resultado <- suppressMessages(tabla_resumen(datos_estaciones))

  expect_equal(nrow(resultado), 12 * 5)
  expect_setequal(unique(resultado$mes), 1:12)
  expect_setequal( unique(resultado$estadistico), c("media", "desvio", "q1", "mediana", "q3"))
})

test_that("por estacion agrega la columna id y separa cada estacion", {
  resultado <- suppressMessages(
    tabla_resumen(datos_estaciones, por_estacion = TRUE)
  )

  expect_named(resultado, c("id", "mes", "estadistico", "valor"))
  expect_setequal(unique(resultado$id), unique(datos_estaciones$id))
  expect_equal(nrow(resultado), 2 * 12 * 5)
})

test_that("la media de enero coincide con la calculada a mano", {
  resultado <- suppressMessages(tabla_resumen(datos_estaciones))
  enero <- datos_estaciones[lubridate::month(datos_estaciones$fecha) == 1, ]
  media_a_mano <- mean(enero$temperatura_abrigo_150cm, na.rm = TRUE)

  media_funcion <- resultado$valor[resultado$mes == 1 &resultado$estadistico == "media"]
  expect_equal(media_funcion, media_a_mano)
})

test_that("funciona con otra variable numerica", {
  resultado <- suppressMessages(
    tabla_resumen(datos_estaciones, variable = "humedad_media_8_14_20")
  )

  expect_equal(nrow(resultado), 12 * 5)
  expect_true(all(resultado$valor[resultado$estadistico == "media"] > 0))
})

test_that("avisa cuantos valores faltantes hay en la variable", {
  expect_message(
    tabla_resumen(datos_estaciones),
    "faltante")
})




#------------------------------------
# argumentos mal pasados (c/u prueba un cli_abort)

test_that("da error si datos no es un data frame", {
  expect_error(tabla_resumen(1:10), "data frame")
  expect_error(tabla_resumen(NULL), "data frame")
  expect_error(tabla_resumen(list(a = 1)), "data frame")
})

test_that("da error si variable no es un unico texto", {
  expect_error(tabla_resumen(datos_estaciones, variable = 3), "unico texto")
  expect_error(tabla_resumen(datos_estaciones, variable = c("a", "b")), "unico texto")
  expect_error(tabla_resumen(datos_estaciones, variable = NA_character_), "unico texto")
  expect_error(tabla_resumen(datos_estaciones, variable = ""), "unico texto")
})

test_that("da error si por_estacion no es TRUE o FALSE", {
  expect_error(tabla_resumen(datos_estaciones, por_estacion = "si"), "TRUE")
  expect_error(tabla_resumen(datos_estaciones, por_estacion = NA), "TRUE")
  expect_error(tabla_resumen(datos_estaciones, por_estacion = c(TRUE, FALSE)), "TRUE")
})

test_that("da error si falta la columna fecha", {
  sin_fecha <- datos_estaciones[, c("id", "temperatura_abrigo_150cm")]
  expect_error(tabla_resumen(sin_fecha), "fecha")
})

test_that("da error si se pide por estacion y no hay columna id", {
  sin_id <- datos_estaciones[, c("fecha", "temperatura_abrigo_150cm")]
  expect_error(tabla_resumen(sin_id, por_estacion = TRUE), "id")
})

test_that("da error si la variable no existe en los datos", {
  expect_error(
    tabla_resumen(datos_estaciones, variable = "lluvia"),
    "no esta en"
  )
})

test_that("da error si la variable no es numerica", {
  expect_error(
    tabla_resumen(datos_estaciones, variable = "id"),
    "numerica"
  )
})

test_that("da error si las fechas de texto no estan en orden anio-mes-dia", {
  datos <- data.frame(fecha = c("05/01/2010", "06/01/2010"), x = c(1, 2))
  expect_error(tabla_resumen(datos, variable = "x"), "no se pudieron leer")
})

test_that("da error si la fecha no es texto ni fecha", {
  datos <- data.frame(fecha = c(20100105, 20100106), x = c(1, 2))
  expect_error(tabla_resumen(datos, variable = "x"), "tipo fecha")
})

# casos 'límite'; datos raros qe la funcion tiene que aguantar

test_that("las fechas como texto dan el mismo resultado que como fecha", {
  como_texto <- datos_estaciones
  como_texto$fecha <- as.character(como_texto$fecha)

  expect_equal(
    suppressMessages(tabla_resumen(como_texto)),
    suppressMessages(tabla_resumen(datos_estaciones))
  )
})

test_that("con un data frame sin filas devuelve una tabla vacia", {
  vacio <- datos_estaciones[0, ]

  resultado <- tabla_resumen(vacio)

  expect_equal(nrow(resultado), 0)
})

test_that("si la variable es toda NA la media da NaN y el resto NA", {
  datos <- data.frame(
    fecha = as.Date(c("2010-01-01", "2010-01-02")),
    x = c(NA_real_, NA_real_)
  )

  resultado <- suppressMessages(tabla_resumen(datos, variable = "x"))

  expect_true(is.nan(resultado$valor[resultado$estadistico == "media"]))
  expect_true(is.na(resultado$valor[resultado$estadistico == "desvio"]))
})

test_that("con un solo dato en el mes el desvio da NA", {
  datos <- data.frame(fecha = as.Date("2010-03-15"), x = 20)

  resultado <- tabla_resumen(datos, variable = "x")

  expect_equal(resultado$valor[resultado$estadistico == "media"], 20)
  expect_true(is.na(resultado$valor[resultado$estadistico == "desvio"]))
})

test_that("solo aparecen los meses que tienen datos", {
  datos <- data.frame(
    fecha = as.Date(c("2010-01-10", "2010-07-10")),
    x = c(30, 10)
  )

  resultado <- tabla_resumen(datos, variable = "x")

  expect_setequal(unique(resultado$mes), c(1, 7))
})

test_that("las filas con id NA se resumen como un grupo aparte", {
  datos <- data.frame(
    id = c("A", "A", NA),
    fecha = as.Date(c("2010-01-01", "2010-01-02", "2010-01-03")),
    x = c(10, 20, 100)
  )

  resultado <- tabla_resumen(datos, variable = "x", por_estacion = TRUE)
  medias <- resultado[resultado$estadistico == "media", ]

  expect_equal(nrow(medias), 2)
  expect_equal(medias$valor[medias$id %in% "A"], 15)
  expect_equal(medias$valor[is.na(medias$id)], 100)
})

test_that("con valores negativos y decimales calcula bien la media", {
  datos <- data.frame(
    fecha = as.Date(c("2010-07-01", "2010-07-02", "2010-07-03")),
    x = c(-2.5, 0, 1.5)
  )

  resultado <- tabla_resumen(datos, variable = "x")

  expect_equal(resultado$valor[resultado$estadistico == "media"], -1 / 3)
})


