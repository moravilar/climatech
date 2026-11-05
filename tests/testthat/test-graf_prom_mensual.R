# casostipicos; la funcion se usa como esta pensada

test_that("devuelve un grafico de ggplot", {
  p <- suppressMessages(graf_prom_mensual(datos_estaciones))

  expect_true(inherits(p, "ggplot"))
})

test_that("usa el titulo por defecto o el que se le pasa", {
  p_defecto <- suppressMessages(graf_prom_mensual(datos_estaciones))
  p_propio <- suppressMessages(
    graf_prom_mensual(datos_estaciones, titulo = "Humedad")
  )

  expect_equal(p_defecto$labels$title, "Temperatura")
  expect_equal(p_propio$labels$title, "Humedad")
})

test_that("con todos los datos juntos hay un promedio por mes", {
  p <- suppressMessages(graf_prom_mensual(datos_estaciones))

  expect_equal(nrow(p$data), 12)
  expect_named(p$data, c("mes", "promedio"))
})

test_that("por estacion hay un promedio por mes para cada estacion", {
  p <- suppressMessages(
    graf_prom_mensual(datos_estaciones, por_estacion = TRUE)
  )

# 2 estacions x 12 meses
  expect_equal(nrow(p$data), 2 * 12)
  expect_true("id" %in% names(p$data))
})

test_that("el promedio de enero coincide con el calculado a mano", {
  p <- suppressMessages(graf_prom_mensual(datos_estaciones))

  enero <- datos_estaciones[lubridate::month(datos_estaciones$fecha) == 1, ]
  media_a_mano <- mean(enero$temperatura_abrigo_150cm, na.rm = TRUE)

  expect_equal(p$data$promedio[p$data$mes == 1], media_a_mano)
})

test_that("con otra variable el eje y muestra su nombre", {
  p <- suppressMessages(
    graf_prom_mensual(datos_estaciones, variable = "humedad_media_8_14_20")
  )

  expect_equal(p$labels$y, "Promedio de humedad_media_8_14_20")
})



test_that("avisa cuantos valores faltantes se ignoraron", {
  expect_message(
    graf_prom_mensual(datos_estaciones),
    "faltantes"
  )
})
