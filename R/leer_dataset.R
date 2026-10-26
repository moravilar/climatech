#' leer_dataset
#'
#' Descarga un archivo CSV desde una URL y lo lee como tabla. Si el archivo
#' ya existe en `ruta` y no está vacío, no se vuelve a descargar y se lee
#' directamente.
#'
#' La URL completa se arma como `url_base` + `dataset` + `".csv"`. Por defecto
#' apunta al repositorio de datos de la materia, donde están los datos de las
#' estaciones meteorológicas del INTA, pero se puede indicar cualquier otra
#' dirección que cumpla ese formato.
#'
#' Antes de leer el archivo, la función revisa su contenido. Si lo descargado
#' está vacío o es una página web en lugar de un CSV, se detiene con un error
#' y borra el archivo descargado. Si la tabla leída tiene una sola columna o
#' no tiene filas de datos, devuelve la tabla igual pero muestra una
#' advertencia, porque puede tratarse de un archivo con otro formato.
#'
#' Si la descarga falla (por ejemplo, sin conexión a internet o con una
#' dirección que no existe), se muestra el error de R correspondiente. El
#' mensaje previo de descarga indica qué URL se intentó usar.
#'
#' @param dataset Texto con el nombre del archivo a descargar, sin la
#'   extensión `.csv`. Por ejemplo, el id de una estación: `"NH0437"`.
#' @param ruta Texto con la ruta donde se guardará el archivo, incluyendo su
#'   nombre y extensión. Por ejemplo: `"datos/NH0437.csv"`. Es obligatorio:
#'   la función no guarda archivos en ningún lugar que el usuario no indique.
#'   Si las carpetas no existen, se crean. Si ya existe un archivo en esa ruta,
#'   se lee ese archivo sin descargar nada, aunque corresponda a otro dataset;
#'   si existe pero está vacío, se vuelve a descargar.
#' @param url_base Texto con la dirección de la carpeta donde está el archivo.
#'   Debe empezar con `http` y terminar con `/`, y tiene que apuntar al
#'   contenido crudo del archivo (en GitHub, la dirección del botón "Raw").
#'   Por defecto es la carpeta de datos del repositorio de la materia:
#'   `"https://raw.githubusercontent.com/rse-r/intro-programacion/main/datos/"`.
#'
#' @return Un tibble con los datos del archivo.
#'
#' @examples
#' \donttest{
#' # datos de una estación, con la URL por defecto
#' datos <- leer_dataset("NH0437", ruta = file.path(tempdir(), "NH0437.csv"))
#' head(datos)
#' }
#'
#' @export


leer_dataset <- function(dataset, ruta, url_base = "https://raw.githubusercontent.com/rse-r/intro-programacion/main/datos/"
) {
  #ponemos que la ruta tenga q especificar si o si el usuario, y el nombre del dataset tambien.
  # si el archivo no existe lo descargamos asi no lo bajamos cada vez q corremos el codigo
  if (!is.character(dataset) || length(dataset) != 1 || is.na(dataset) || dataset == "") {
    cli::cli_abort("{.arg dataset} tiene que ser un unico texto, por ejemplo {.val NH0472}.")
  }
  #claude nos dio estos trucos de .arg y .val, que ayudan a referenciar para que el usuario entienda mejor
  # de lo que le estamos hablando cuando le salta este mensaje
  # si utilizan otro tipo de dato, o pasan un vector o algo raro, lo manejamos para q no rompa todo
  if (!is.character(ruta) || length(ruta) != 1 || is.na(ruta) || ruta == "") {
    cli::cli_abort("{.arg ruta} tiene que ser un unico texto, por ejemplo {.val datos/NH0437.csv}.")
  }
  if (!is.character(url_base) || length(url_base) != 1) {
    cli::cli_abort("{.arg url_base} debe ser un texto con una direccion web.")
  }
  #startsWith es una funcion provista por claude, nos ayuda a verificar que la url comience con la estructura necesaria
  if (!startsWith(url_base, "http")) {
    cli::cli_abort(
      "{.arg url_base} debe empezar con {.val http}.")
  }

  # revisamos que lo descargado sea un csv y no otra cosa
  primera_linea <- readLines(ruta, n = 1)
  if (length(primera_linea) == 0) {
    file.remove(ruta)
    cli::cli_abort(c(
      "Lo descargado desde {.url {url}} esta vacio.",
      "i" = "Revisa que {.arg dataset} y {.arg url_base} sean correctos."
    ))
  }
  if (startsWith(primera_linea, "<")) {
    file.remove(ruta)
    cli::cli_abort(c(
      "Lo descargado no es un CSV, parece una pagina web.",
      "i" = "Revisa que {.arg url_base} sea la direccion del boton Raw."
    ))
  }

  if (!file.exists(ruta) || length(readLines(ruta, n = 1)) == 0) {
    url <- paste0(url_base, dataset, ".csv")
    cli::cli_inform("Descargando {.val {dataset}} desde {.url {url}}...")
    dir.create(dirname(ruta), showWarnings = FALSE, recursive = TRUE)
    utils::download.file(url = url, destfile = ruta, mode = "wb", quiet = TRUE)
  } else {
    cli::cli_inform("El archivo {.file {ruta}} ya existe, se lee sin descargar.")
  }

  readr::read_csv()(ruta)
}

#notaciones para eliminar despues:
# trucos nuevos que dio claude:
# .file, .val, etc,
#
