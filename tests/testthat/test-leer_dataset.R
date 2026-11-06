test_that("da error si dataset no es un unico texto", {
  ruta <- tempfile(fileext = ".csv")
  expect_error(leer_dataset(123, ruta), "unico texto")
  expect_error(leer_dataset(c("NH0437", "NH0472"), ruta), "unico texto")
  expect_error(leer_dataset(NA_character_, ruta), "unico texto")
  expect_error(leer_dataset("", ruta), "unico texto")
})

test_that("da error si ruta no es un unico texto", {
  expect_error(leer_dataset("NH0437", 1), "unico texto")
  expect_error(leer_dataset("NH0437", ""), "unico texto")
  expect_error(leer_dataset("NH0437", c("a.csv", "b.csv")), "unico texto")
})

test_that("da error si url_base no es una direccion web", {
  ruta <- tempfile(fileext = ".csv")
  expect_error(leer_dataset("NH0437", ruta, url_base = 1), "direccion web")
  expect_error(leer_dataset("NH0437", ruta, url_base = "mi_carpeta/"), "http")
})

# Archivos que ya existen

test_that("si el archivo ya existe lo lee sin descargar", {
  ruta <- tempfile(fileext = ".csv")
  writeLines(c("fecha,x", "2010-01-01,5", "2010-01-02,7"), ruta)

  expect_message(leer_dataset("NH0437", ruta), "ya existe")

  datos <- suppressMessages(leer_dataset("NH0437", ruta))
  expect_equal(nrow(datos), 2)
  expect_equal(datos$x, c(5, 7))
})

test_that("da error si el archivo parece una pagina web y no lo borra", {
  ruta <- tempfile(fileext = ".csv")
  writeLines(c("<!DOCTYPE html>", "<html></html>"), ruta)

  expect_error(
    suppressMessages(leer_dataset("NH0437", ruta)),
    "pagina web"
  )
  # el archivo era del usuario, asi que no se tiene que borrar
  expect_true(file.exists(ruta))
})

test_that("avisa si la tabla tiene una sola columna", {
  ruta <- tempfile(fileext = ".csv")
  writeLines(c("fecha;x", "2010-01-01;5"), ruta)

  expect_warning(
    suppressMessages(leer_dataset("NH0437", ruta)),
    "una sola columna"
  )
})

test_that("avisa si el archivo solo tiene los nombres de las columnas", {
  ruta <- tempfile(fileext = ".csv")
  writeLines("fecha,x", ruta)

  expect_warning(
    suppressMessages(leer_dataset("NH0437", ruta)),
    "no tiene filas"
  )
})

test_that("no convierte en NA una columna que empieza con muchos vacios", {
  # el problema que encontramos con humedad: si las primeras 1000 filas
  # estan vacias, read_csv por defecto toma la columna como logica
  ruta <- tempfile(fileext = ".csv")
  filas <- c(rep("2010-01-01,", 1500), "2010-01-02,85.5")
  writeLines(c("fecha,humedad", filas), ruta)

  datos <- suppressMessages(leer_dataset("NH0437", ruta))

  expect_true(is.numeric(datos$humedad))
  expect_equal(datos$humedad[1501], 85.5) })
# test con internet, se saltean si no hay conexion o si corren en cran

test_that("descarga el archivo si no existe y crea la carpeta", {
  skip_on_cran()
  skip_if_offline()

  carpeta <- tempfile("carpeta_nueva")
  ruta <- file.path(carpeta, "NH0437.csv")

  expect_message(datos <- leer_dataset("NH0437", ruta), "Descargando")
  expect_true(file.exists(ruta))
  expect_true(nrow(datos) > 0)
  expect_true("fecha" %in% names(datos)) })

test_that("si el archivo existe pero esta vacio lo vuelve a descargar", {
  skip_on_cran()
  skip_if_offline()

  ruta <- tempfile(fileext = ".csv")
  file.create(ruta)

  expect_message(datos <- leer_dataset("NH0437", ruta), "Descargando")
  expect_true(nrow(datos) > 0) })


test_that("da error si url_base no termina con /", {
  ruta <- tempfile(fileext = ".csv")
  url_sin_barra <- "https://raw.githubusercontent.com/rse-r/intro-programacion/main/datos"

  expect_error(leer_dataset("NH0437", ruta, url_base = url_sin_barra), "terminar con")
  # no se tiene que haber intentado la descarga
  expect_false(file.exists(ruta))
})

