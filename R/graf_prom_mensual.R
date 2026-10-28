#' Graficar el promedio mensual de una variable
#'
#' Calcula el promedio de una variable numerica para cada mes del anio
#' y lo representa en un grafico de lineas, lo que permite observar
#' su variacion a lo largo del anio.
#'
#' @param datos Un data frame con una columna `fecha` y al menos una
#'   columna numerica.
#' @param variable Nombre de la columna numerica a promediar, como
#'   cadena de caracteres. Por defecto, `"temperatura_abrigo_150cm"`.
#' @param colores Un solo color para la linea del grafico, como cadena
#'   de caracteres. Por defecto, `"steelblue"`.
#'
#' @details
#' El promedio se calcula agrupando las observaciones por mes (1 a 12).
#' Si los datos abarcan varios anios, el promedio de cada mes combina
#' todos los anios: por ejemplo, el valor de enero es el promedio de
#' todos los eneros disponibles.
#'
#' La funcion no distingue entre estaciones meteorologicas. Si `datos`
#' contiene observaciones de mas de una estacion, se promedian todas
#' juntas; para graficar una sola estacion, filtrar los datos antes de
#' usar la funcion.
#'
#' Los valores faltantes (`NA`) de `variable` se ignoran al calcular
#' los promedios. Si hay alguno, la funcion informa en la consola
#' cuantos se ignoraron.
#'
#' @return Un objeto `ggplot` con el promedio mensual de `variable`.
#'   Se le pueden agregar capas de ggplot2 con `+`.
#'
#' @examples
#' # Temperatura de abrigo a 150 cm (variable por defecto)
#' graf_prom_mensual(NOMBRE_DATASET)
#'
#' # Cambiando el color de la linea
#' graf_prom_mensual(NOMBRE_DATASET, colores = "firebrick")
#'
#' @export

# debido a que en la funcion leer_dataset, quitamos la variable id para que sea
# una funcion mas "universal", aqui tambien hicimos cambios


graf_prom_mensual <- function(datos, variable = "temperatura_abrigo_150cm", colores = "steelblue") {
#nota: datos[[variable]] devuelve la columna como un vector
  if (!is.data.frame(datos)) {
    cli::cli_abort("{.arg datos} tiene que ser un data frame.")
  }

  if (!"fecha" %in% names(datos)) {
    cli::cli_abort("{.arg datos} tiene que tener una columna {.field fecha}.")
  }

  if (!is.character(variable) || length(variable) != 1) {
    cli::cli_abort(
      "{.arg variable} tiene que ser un solo texto con el nombre de una columna."
    )
  }

  if (!variable %in% names(datos)) {
    cli::cli_abort(c(
      "La columna {.field {variable}} no existe en {.arg datos}.",
      "i" = "Si no indicas {.arg variable}, se usa {.val temperatura_abrigo_150cm}, la temperatura de los datos del paquete.",
      "i" = "Si usas otros datos, indica la columna en {.arg variable}. Podes ver las columnas con {.code names(datos)}."
    ))
  }

  if (!is.numeric(datos[[variable]])) {
    cli::cli_abort(
      "La columna {.field {variable}} tiene que ser numerica para calcular el promedio."
    )
  }

  if (all(is.na(datos[[variable]]))) {
    cli::cli_abort("La columna {.field {variable}} no tiene datos: todos sus valores son NA.")
  }

  if (!is.character(colores) || length(colores) != 1) {
    cli::cli_abort("{.arg colores} tiene que ser un solo color, por ejemplo {.code steelblue}.")
  }

  titulo <- paste("Promedio mensual de", variable)

  # como en este caso, la variable es un character, pero necesitamos buscar
  # la columna, usamos esta notacion datos[[variable]]
  promedios <- datos |>
    dplyr::mutate(mes = lubridate::month(datos$fecha),
                  valor = datos[[variable]]) |>
    dplyr::group_by(mes) |>
    dplyr::summarise(promedio = mean(valor, na.rm = TRUE))

  grafico <- ggplot2::ggplot(promedios,
                  ggplot2::aes(x = mes,
                               y = promedio)) +
    ggplot2::geom_line(color = colores) +
# con la siguiente linea le indicas que ponga una marca en cada numero
#entero del 1 al 12, o sea, una por mes:
    ggplot2::scale_x_continuous(breaks = 1:12) +
    ggplot2::labs(title = titulo,
                  x = "Mes", y = paste("Promedio de", variable)) +
    ggplot2::theme_minimal()

  cantidad_na <- sum(is.na(datos[[variable]]))
  if (cantidad_na > 0) {
    cli::cli_inform(
      "Valores faltantes (NA) ignorados en {.field {variable}}: {cantidad_na}."
    )
  }
  return(grafico)
}


#para eliminar despues:
# trucos que dio claude:
# datos[[variable]]: toma el valor de variable, que es un character con el
#nombre de una columna, y devuelve el vector de esa columna dentro de los datos
#con los que esta trabajando la funcion de dplyr o de ggplot2.
#
