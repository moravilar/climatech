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

test_that("da error si datos no es un data frame", {
  expect_error(graf_prom_mensual(1:10), "data frame")
  expect_error(graf_prom_mensual(NULL), "data frame")
})

test_that("da error si falta la columna fecha", {
  sin_fecha <- datos_estaciones[, c("id", "temperatura_abrigo_150cm")]
  expect_error(graf_prom_mensual(sin_fecha), "fecha")
})

test_that("da error si variable no es un solo texto", {
  expect_error(graf_prom_mensual(datos_estaciones, variable = 3), "solo texto")
  expect_error(
    graf_prom_mensual(datos_estaciones, variable = c("a", "b")),
    "solo texto"
  )
})

test_that("da error si la variable no existe o no es numerica", {
  expect_error(
    graf_prom_mensual(datos_estaciones, variable = "lluvia"),
    "no existe"
  )
  expect_error(
    graf_prom_mensual(datos_estaciones, variable = "id"),
    "numerica"
  )
})

test_that("da error si la variable es toda NA", {
  datos <- datos_estaciones
  datos$temperatura_abrigo_150cm <- NA_real_
  expect_error(graf_prom_mensual(datos), "todos sus valores son NA")
})

test_that("da error si por_estacion no es TRUE o FALSE", {
  expect_error(graf_prom_mensual(datos_estaciones, por_estacion = "si"), "TRUE")
  expect_error(graf_prom_mensual(datos_estaciones, por_estacion = NA), "TRUE")
})

test_that("da error si se pide por estacion y no hay columna id", {
  sin_id <- datos_estaciones[, c("fecha", "temperatura_abrigo_150cm")]
  expect_error(graf_prom_mensual(sin_id, por_estacion = TRUE), "id")
})

test_that("da error si el titulo no es un solo texto", {
  expect_error(graf_prom_mensual(datos_estaciones, titulo = 2024), "titulo")
  expect_error(
    graf_prom_mensual(datos_estaciones, titulo = c("a", "b")),
    "titulo"
  )
})

test_that("da error si las fechas de texto no estan en orden anio-mes-dia", {
  datos <- data.frame(fecha = c("05/01/2010", "06/01/2010"), x = c(1, 2))
  expect_error(graf_prom_mensual(datos, variable = "x"), "no se pudieron leer")
})

test_that("da error si colores no es texto", {
  expect_error(graf_prom_mensual(datos_estaciones, colores = 1), "texto")
})

test_that("da error si hay mas de un color para una sola linea", {
  expect_error(
    graf_prom_mensual(datos_estaciones, colores = c("red", "blue")),
    "un solo color"
  )
})

test_that("da error si hay menos colores que estaciones", {
  expect_error(
    graf_prom_mensual(datos_estaciones, por_estacion = TRUE, colores = "red"),
    "estaciones"
  )
})

test_that("usa el color elegido para una sola linea", {
  p <- suppressMessages(graf_prom_mensual(datos_estaciones, colores = "orchid3"))

  expect_equal(unique(ggplot2::layer_data(p)$colour), "orchid3")
})

test_that("usa un color elegido para cada estacion", {
  p <- suppressMessages(
    graf_prom_mensual(
      datos_estaciones,
      por_estacion = TRUE,
      colores = c("orchid3", "darkorange")
    )
  )

  expect_setequal(unique(ggplot2::layer_data(p)$colour), c("orchid3", "darkorange"))
})

test_that("las fechas como texto funcionan igual que como fecha", {
  como_texto <- datos_estaciones
  como_texto$fecha <- as.character(como_texto$fecha)

  p_texto <- suppressMessages(graf_prom_mensual(como_texto))
  p_fecha <- suppressMessages(graf_prom_mensual(datos_estaciones))

  expect_equal(p_texto$data, p_fecha$data)
})


test_that("da error si la fecha no es texto ni fecha", {
  datos <- data.frame(fecha = c(20200115, 20200215), temp = c(20, 22))
  expect_error(graf_prom_mensual(datos, variable = "temp"), "tipo fecha")
})
test_that("ignora las filas sin fecha y avisa cuantas son", {
  datos <- data.frame(fecha = as.Date(c("2020-01-15", NA)), temp = c(20, 22))

  expect_message(graf_prom_mensual(datos, variable = "temp"), "Se ignoraron 1 fila")

  p <- suppressMessages(graf_prom_mensual(datos, variable = "temp"))
  expect_false(any(is.na(p$data$mes)))
})
