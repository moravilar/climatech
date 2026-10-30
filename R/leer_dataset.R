#' Descargar y leer un dataset
#'
#' Descarga un archivo CSV desde una URL y lo lee como tabla. Si el archivo
#' ya existe en `ruta` y no esta vacio, no se vuelve a descargar y se lee
#' directamente.
#'
#' La URL completa se arma como `url_base` + `dataset` + `".csv"`. Por defecto
#' apunta a datos de estaciones meteorologicas del Instituto Nacional de
#' Tecnologia Agropecuaria (INTA), pero se puede indicar cualquier otra
#' direccion que cumpla ese formato.
#'
#' Antes de leer el archivo, la funcion revisa su contenido. Si esta vacio o
#' es una pagina web en lugar de un CSV, se detiene con un error. Si el
#' archivo se acaba de descargar, ademas lo borra; si ya estaba en `ruta`,
#' no lo borra. Si la tabla leida tiene una sola columna o no tiene filas de
#' datos, devuelve la tabla igual pero muestra una advertencia, porque puede
#' tratarse de un archivo con otro formato.
#'
#' Si la descarga falla (por ejemplo, sin conexion a internet o con una
#' direccion que no existe), se muestra el error de R correspondiente. El
#' mensaje previo de descarga indica que URL se intento usar.
#'
#' @param dataset Texto con el nombre del archivo a descargar, sin la
#'   extension `.csv`. Por ejemplo, el id de una estacion: `"NH0437"`.
#' @param ruta Texto con la ruta donde se guardara el archivo, incluyendo su
#'   nombre y extension. Por ejemplo: `"datos/NH0437.csv"`. Es obligatorio:
#'   la funcion no guarda archivos en ningun lugar que el usuario no indique.
#'   Si las carpetas no existen, se crean. Si ya existe un archivo en esa ruta,
#'   se lee ese archivo sin descargar nada, aunque corresponda a otro dataset;
#'   si existe pero esta vacio, se vuelve a descargar.
#' @param url_base Texto con la direccion de la carpeta donde esta el archivo.
#'   Debe empezar con `http` y terminar con `/`, y tiene que apuntar al
#'   contenido crudo del archivo (en GitHub, la direccion del boton "Raw").
#'   Por defecto apunta a los datos de estaciones del INTA:
#'   `"https://raw.githubusercontent.com/rse-r/intro-programacion/main/datos/"`.
#'
#' @return Una tabla con los datos del archivo.
#'
#' @examples
#' # necesita conexion a internet para descargar los datos
#' # tempdir() devuelve la carpeta temporal de tu sesion de R
#' ruta <- file.path(tempdir(), "NH0437.csv")
#' datos <- leer_dataset("NH0437", ruta = ruta)
#' head(datos)
#'
#' # si se vuelve a llamar con la misma ruta, se lee el archivo
#' # guardado y no se descarga de nuevo
#' datos <- leer_dataset("NH0437", ruta = ruta)
#'
#' @export

leer_dataset <- function(dataset, ruta, url_base = "https://raw.githubusercontent.com/rse-r/intro-programacion/main/datos/"
) {
  #ponemos que la ruta tenga q especificar si o si el usuario, y el nombre del dataset tambien.
  # si el archivo no existe lo descargamos asi no lo bajamos cada vez q corremos el codigo
  if (!is.character(dataset) || length(dataset) != 1 || is.na(dataset) || dataset == "") {
    cli::cli_abort("{.arg dataset} tiene que ser un unico texto, por ejemplo {.val NH0437}.")
  }
  #estos trucos de .arg y .val  ayudan a referenciar para que el usuario entienda mejor
  # de lo que le estamos hablando cuando le salta este mensaje
  # si utilizan otro tipo de dato, o pasan un vector o algo raro, lo manejamos para q no rompa todo
  if (!is.character(ruta) || length(ruta) != 1 || is.na(ruta) || ruta == "") {
    cli::cli_abort("{.arg ruta} tiene que ser un unico texto, por ejemplo {.val datos/NH0437.csv}.")
  }
  if (!is.character(url_base) || length(url_base) != 1) {
    cli::cli_abort("{.arg url_base} debe ser un texto con una direccion web.")
  }
  #startsWith es una funcion que nos ayuda a verificar que la url comience con la estructura necesaria
  if (!startsWith(url_base, "http")) {
    cli::cli_abort(
      "{.arg url_base} debe empezar con {.val http}.")
  }

  # guardamos si el archivo se descargo en esta llamada, para borrarlo
  # solo en ese caso (nunca un archivo que ya tenia el usuario)
  descargado <- FALSE
  url <- paste0(url_base, dataset, ".csv")

  if (!file.exists(ruta) || length(readLines(ruta, n = 1)) == 0) {
    cli::cli_inform("Descargando {.val {dataset}} desde {.url {url}}...")
    dir.create(dirname(ruta), showWarnings = FALSE, recursive = TRUE)
    utils::download.file(url = url, destfile = ruta, mode = "wb", quiet = TRUE)
    descargado <- TRUE
  } else {
    cli::cli_inform("El archivo {.file {ruta}} ya existe, se lee sin descargar.")
  }

  # revisamos que lo descargado sea un csv y no otra cosa
  primera_linea <- readLines(ruta, n = 1)
  if (length(primera_linea) == 0) {
    if (descargado) {
      file.remove(ruta)
    }
    cli::cli_abort(c(
      "Lo descargado desde {.url {url}} esta vacio.",
      "i" = "Revisa que {.arg dataset} y {.arg url_base} sean correctos."
    ))
  }
  # ponemos < por <!DOCTYPE>
  if (startsWith(primera_linea, "<")) {
    if (descargado) {
      file.remove(ruta)
    }
    cli::cli_abort(c(
      "El archivo {.file {ruta}} no es un CSV, parece una pagina web.",
      "i" = "Revisa que {.arg url_base} sea la direccion del boton Raw."
    ))
  }

  # read_csv decide el tipo de cada columna mirando solo las primeras 1000
  # filas; si en esas filas una variable esta vacia, la toma como logica y
  # despues convierte en NA los numeros que aparecen. Con guess_max = Inf
  # mira todas las filas antes de decidir.
  datos <- readr::read_csv(ruta, guess_max = Inf, show_col_types = FALSE)

  # si la tabla tiene una sola columna, puede que el archivo use otro
  # separador (por ejemplo ";") o que no sea un CSV
  if (ncol(datos) == 1) {
    cli::cli_warn(c(
      "La tabla leida tiene una sola columna.",
      "i" = "Puede que el archivo no use comas para separar columnas (por ejemplo, que use {.val ;})."
    ))
  }
  # si no tiene filas, el archivo solo tiene los nombres de las columnas
  if (nrow(datos) == 0) {
    cli::cli_warn(c(
      "La tabla leida no tiene filas de datos, solo los nombres de las columnas.",
      "i" = "Revisa el contenido de {.file {ruta}}."
    ))
  }

  return(datos)
}
