#' Graficar el promedio mensual de una variable
#'
#' Calcula el promedio de una variable numerica para cada mes del anio
#' y lo representa en un grafico de lineas, lo que permite observar
#' su variacion a lo largo del anio. El grafico se puede hacer con todos
#' los datos juntos o con una linea para cada estacion.
#'
#' @param datos Un data frame con una columna `fecha` y al menos una
#'   columna numerica. La columna `fecha` puede ser de tipo fecha (`Date`)
#'   o texto en el orden anio-mes-dia, por ejemplo `"1961-07-01"`. Si
#'   `por_estacion = TRUE`, tambien tiene que tener la columna `id`, que
#'   identifica a cada estacion.
#' @param variable Nombre de la columna numerica a promediar, como
#'   cadena de caracteres. Por defecto, `"temperatura_abrigo_150cm"`.
#' @param por_estacion `TRUE` o `FALSE`. Si es `TRUE`, se dibuja una linea
#'   para cada estacion. Si es `FALSE` (por defecto), se dibuja una sola
#'   linea con todos los datos juntos, aunque haya mas de una estacion.
#' @param colores Colores de las lineas, como cadena de caracteres. Si
#'   `por_estacion = FALSE`, un solo color. Si `por_estacion = TRUE`, un
#'   color por estacion, en el orden alfabetico de los `id`. Por defecto
#'   (`NULL`), se usa `"steelblue"` para una sola linea y los colores
#'   automaticos de ggplot2 para varias.
#' @param titulo Titulo del grafico, como cadena de caracteres. Por
#'   defecto, `"Temperatura"`. Si se grafica otra variable, conviene
#'   cambiarlo.
#'
#' @details
#' El promedio se calcula agrupando las observaciones por mes (1 a 12).
#' Si los datos abarcan varios anios, el promedio de cada mes combina
#' todos los anios: por ejemplo, el valor de enero es el promedio de
#' todos los eneros disponibles.
#'
#' Si `por_estacion = FALSE`, la funcion no distingue entre estaciones
#' meteorologicas: si `datos` contiene observaciones de mas de una
#' estacion, se promedian todas juntas.
#'
#' Si la columna `fecha` es texto, se convierte a fecha dentro de la
#' funcion (el data frame original no se modifica).
#'
#' Los valores faltantes (`NA`) de `variable` se ignoran al calcular
#' los promedios. Si hay alguno, la funcion informa en la consola
#' cuantos se ignoraron.
#'
#' @return Un objeto `ggplot` con el promedio mensual de `variable`.
#'   Se le pueden agregar capas de ggplot2 con `+`.
#'
#' @examples
#' # temperatura de abrigo a 150 cm (variable por defecto), todos los datos juntos
#' graf_prom_mensual(datos_estaciones)
#'
#' # una linea para cada estacion
#' graf_prom_mensual(datos_estaciones, por_estacion = TRUE)
#'
#' # eligiendo un color para cada estacion
#' graf_prom_mensual(datos_estaciones, por_estacion = TRUE,
#'                   colores = c("orchid3", "steelblue"))
#'
#' # otra variable, con su propio titulo
#' graf_prom_mensual(datos_estaciones, variable = "humedad_media_8_14_20",
#'                   titulo = "Humedad")
#' @export

# debido a que en la funcion leer_dataset, quitamos la variable id para que sea
# una funcion mas "universal", aqui tambien hicimos cambios


graf_prom_mensual <- function(datos, variable = "temperatura_abrigo_150cm", por_estacion = FALSE,
                              colores = NULL, titulo = "Temperatura") {
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

  if (!is.logical(por_estacion) || length(por_estacion) != 1 || is.na(por_estacion)) {
    cli::cli_abort("{.arg por_estacion} tiene que ser {.val TRUE} o {.val FALSE}.")
  }

  # id solo hace falta si se pide una linea por estacion
  if (por_estacion && !("id" %in% names(datos))) {
    cli::cli_abort("Para graficar por estacion, {.arg datos} tiene que tener la columna {.field id}.")
  }

  if (!is.character(titulo) || length(titulo) != 1) {
    cli::cli_abort("{.arg titulo} tiene que ser un solo texto, por ejemplo {.val Temperatura}.")
  }

  # colores es opcional: solo lo revisamos si el usuario lo indico
  if (!is.null(colores)) {
    if (!is.character(colores)) {
      cli::cli_abort("{.arg colores} tiene que ser texto, por ejemplo {.code steelblue}.")
    }
    if (!por_estacion && length(colores) != 1) {
      cli::cli_abort("{.arg colores} tiene que ser un solo color, por ejemplo {.code steelblue}.")
    }
    if (por_estacion) {
      cantidad_estaciones <- length(unique(datos$id))
      if (length(colores) < cantidad_estaciones) {
        cli::cli_abort(c(
          "Hay {cantidad_estaciones} estacion{?es} pero {.arg colores} tiene {length(colores)} color{?es}.",
          "i" = "Indica un color por estacion, o no indiques {.arg colores} para usar los automaticos."
        ))
      }
    }
  }

  # si fecha viene como texto, la convertimos con lubridate (solo adentro
  # de la funcion, el dataset del usuario no se modifica)
  if (is.character(datos$fecha)) {
    fechas <- lubridate::ymd(datos$fecha, quiet = TRUE)
    # si algun texto no se pudo convertir, ymd devuelve NA en ese lugar
    if (any(is.na(fechas) & !is.na(datos$fecha))) {
      cli::cli_abort(c(
        "Algunas fechas de la columna {.field fecha} no se pudieron leer.",
        "i" = "Tienen que estar en el orden anio-mes-dia, por ejemplo {.val 1961-07-01}."
      ))
    }
    datos$fecha <- fechas
  }

  # como en este caso, la variable es un character, pero necesitamos buscar
  # la columna, usamos esta notacion datos[[variable]]
  promedios <- datos |>
    dplyr::mutate(mes = lubridate::month(datos$fecha),
                  valor = datos[[variable]])

  # agrupamos por estacion y mes, o solo por mes
  if (por_estacion) {
    promedios <- dplyr::group_by(promedios, id, mes)
  } else {
    promedios <- dplyr::group_by(promedios, mes)
  }

  promedios <- dplyr::summarise(promedios,
                                promedio = mean(valor, na.rm = TRUE),
                                .groups = "drop")

  # una linea por estacion (cada una de un color) o una sola linea
  # una linea por estacion (cada una de un color) o una sola linea
  if (por_estacion) {
    grafico <- ggplot2::ggplot(promedios,
                               ggplot2::aes(x = mes,
                                            y = promedio,
                                            color = id)) +
      ggplot2::geom_line(linewidth = 1, linejoin = "round") +
      # la leyenda de colores solo existe cuando hay una linea por estacion
      ggplot2::labs(color = "Estacion")
    # si no hay colores, quedan los automaticos de ggplot2
    if (!is.null(colores)) {
      grafico <- grafico + ggplot2::scale_color_manual(values = colores)
    }
  } else {
    if (is.null(colores)) {
      colores <- "steelblue"
    }
    grafico <- ggplot2::ggplot(promedios,
                               ggplot2::aes(x = mes,
                                            y = promedio)) +
      ggplot2::geom_line(color = colores, linewidth = 1, linejoin = "round")
  }

  grafico <- grafico +
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
