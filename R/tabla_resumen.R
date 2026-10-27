#' Tabla de resumen mensual de una variable
#'
#' Calcula medidas de resumen de una variable numerica para cada mes del
#' anio: media, desvio estandar, primer cuartil, mediana y tercer cuartil.
#' Los meses se agrupan sin importar el anio, es decir, el resumen de julio
#' usa todos los julios de la serie. El resumen se puede hacer con todos los
#' datos juntos o por separado para cada estacion.
#'
#' Los valores faltantes (`NA`) se ignoran en los calculos. Si en un mes no
#' hay ningun dato de la variable, la media da `NaN` y el resto de los
#' estadisticos da `NA`. Si hay un solo dato, el desvio da `NA`.
#'
#' Si la columna `fecha` es texto, se convierte a fecha dentro de la funcion
#' (el data frame original no se modifica). Tiene que estar en el orden
#' anio-mes-dia, por ejemplo `"1961-07-01"`.
#'
#' @param datos Data frame con una fila por medicion. Tiene que tener la
#'   columna `fecha` (dia de la medicion) y la columna indicada en
#'   `variable`. Si `estaciones = TRUE`, tambien tiene que tener la columna
#'   `id`, que identifica a cada estacion (por ejemplo, `"NH0472"`). Las
#'   filas con `id` vacio (`NA`) se resumen juntas como un grupo aparte.
#' @param variable Texto con el nombre de la columna numerica a resumir,
#'   entre comillas. Por defecto, `"temperatura_abrigo_150cm"`, la
#'   temperatura de los datos del paquete.
#'   .
#' @param estaciones `TRUE` o `FALSE`. Si es `TRUE`, el resumen se calcula
#'   por separado para cada estacion. Si es `FALSE` (por defecto), se
#'   calcula con todos los datos juntos, aunque haya mas de una estacion.
#'
#' @return Una tabla en formato largo, con cinco filas por cada mes (o por
#'   cada combinacion de estacion y mes, si `estaciones = TRUE`) y las
#'   columnas: id (identificador de la estacion, solo si estaciones = TRUE),
#'   mes (del 1 al 12), estadistico ya sea media, desvio estandar, q1, mediana
#'   o q3, y valor (valor de tal medida).
#'
#' @examples
#' # datos inventados de dos estaciones
#' datos <- data.frame(
#'   id = c("NH0001", "NH0001", "NH0002", "NH0002"),
#'   fecha = c("2020-01-01", "2020-01-02", "2020-01-01", "2020-01-02"),
#'   temperatura_abrigo_150cm = c(25.1, 27.3, 22.0, NA),
#'   humedad_media = c(70, 65, 80, 75)
#' )
#'
#' # resumen de la temperatura con todos los datos juntos (valor por defecto)
#' tabla_resumen(datos)
#'
#' # resumen de la temperatura para cada estacion
#' tabla_resumen(datos, por_estacion = TRUE)
#'
#' # resumen de otra variable
#' tabla_resumen(datos, variable = "humedad_media")
#'
#' \donttest{
#' # con datos reales de la materia
#' datos <- leer_dataset("NH0437", ruta = file.path(tempdir(), "NH0437.csv"))
#' tabla_resumen(datos, por_estacion = TRUE)
#' }
#'
#' @export
tabla_resumen <- function(datos, variable = "temperatura_abrigo_150cm", estaciones = FALSE) {

  if (!is.data.frame(datos)) {
    cli::cli_abort("{.arg datos} tiene que ser un data frame.")
  }
  if (!is.character(variable) || length(variable) != 1 || is.na(variable) || variable == "") {
    cli::cli_abort("{.arg variable} tiene que ser un unico texto, por ejemplo {.val temperatura_abrigo_150cm}.")
  }
  if (!is.logical(estaciones) || length(estaciones) != 1 || is.na(estaciones)) {
    cli::cli_abort("{.arg por_estacion} tiene que ser {.val TRUE} o {.val FALSE}.")
  }
  if (!("fecha" %in% names(datos))) {
    cli::cli_abort("{.arg datos} tiene que tener la columna {.val fecha}.")
  }
  # id solo hace falta si se pide el resumen por estacion
  if (estaciones && !("id" %in% names(datos))) {
    cli::cli_abort("Para resumir por estacion, {.arg datos} tiene que tener la columna {.val id}.")
  }
  # nos fijamos que variable exista, pero que tambien no le aparezca un mensaje
  # como que "temperatura_abrigo_150cm" cuando este usando otro dataset cistinto
  # de el del paquete, porque no va a entender nada
  if (!(variable %in% names(datos))) {
    cli::cli_abort(c(
      "La columna {.val {variable}} no esta en {.arg datos}.",
      "i" = "Si no indicas {.arg variable}, se usa {.val temperatura_abrigo_150cm}, la temperatura de los datos del paquete.",
      "i" = "Si usas otros datos, indica la columna en {.arg variable}. Podes ver las columnas con {.code names(datos)}."
    ))
  }
  if (!is.numeric(datos[[variable]])) {
    cli::cli_abort("La columna {.val {variable}} tiene que ser numerica.")
  }

  # si fecha viene como texto, la convertimos con lubridate (solo adentro
  # de la funcion, el dataset del usuario no se modifica)
  if (is.character(datos$fecha)) {
    fechas <- lubridate::ymd(datos$fecha, quiet = TRUE)
    # si algun texto no se pudo convertir, ymd devuelve NA en ese lugar
    if (any(is.na(fechas) & !is.na(datos$fecha))) {
      cli::cli_abort(c(
        "Algunas fechas de la columna {.val fecha} no se pudieron leer.",
        "i" = "Tienen que estar en el orden anio-mes-dia, por ejemplo {.val 1961-07-01}."
      ))
    }
    datos$fecha <- fechas
  }

  # copiamos la variable elegida a una columna con nombre fijo,
  # asi summarise la calcula por grupo (y no sobre la columna entera)
  datos$valor <- datos[[variable]]
  datos <- dplyr::mutate(datos, mes = lubridate::month(fecha))

  # agrupamos por estacion y mes, o solo por mes
  if (estaciones) {
    datos <- dplyr::group_by(datos, id, mes)
  } else {
    datos <- dplyr::group_by(datos, mes)
  }

  resumen <- dplyr::summarise(
    datos,
    media   = mean(valor, na.rm = TRUE),
    desvio  = stats::sd(valor, na.rm = TRUE),
    # quantile() devuelve el numero con una etiqueta que dice que
    # percentil es; con names = FALSE devuelve solo el numero
    q1      = stats::quantile(valor, 0.25, na.rm = TRUE, names = FALSE),
    mediana = stats::median(valor, na.rm = TRUE),
    q3      = stats::quantile(valor, 0.75, na.rm = TRUE, names = FALSE),
    .groups = "drop"
  )

  tidyr::pivot_longer(resumen,
                      cols = c("media", "desvio", "q1", "mediana", "q3"),
                      names_to = "estadistico",
                      values_to = "valor")
}
