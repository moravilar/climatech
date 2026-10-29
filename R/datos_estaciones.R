#' Datos meteorologicos de dos estaciones del INTA
#'
#' Mediciones diarias de dos estaciones meteorologicas del INTA (NH0437 y
#' NH0472) entre 2004 y 2013. Es un recorte pensado para explorar y probar
#' las funciones del paquete.
#'
#' @format Un data frame con 7306 filas y 4 variables:
#' \describe{
#'   \item{id}{Identificador de la estacion.}
#'   \item{fecha}{Fecha de la medicion.}
#'   \item{temperatura_abrigo_150cm}{Temperatura de abrigo a 150 cm, en grados Celsius.}
#'   \item{humedad_media_8_14_20}{Humedad relativa media del dia, calculada
#'     con las mediciones de las 8, 14 y 20 horas, en porcentaje.}
#' }
#' @source Datos originales del Sistema de Informacion y Gestion
#'   Agrometeorologica (SIGA) del INTA: <https://siga.inta.gob.ar/>.
#'   Descargados de la recopilacion publica disponible en
#'   <https://github.com/rse-r/intro-programacion>.
"datos_estaciones"
