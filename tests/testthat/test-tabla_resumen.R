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
