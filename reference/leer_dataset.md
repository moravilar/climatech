# Descargar y leer un dataset

Descarga un archivo CSV desde una URL y lo lee como tabla. Si el archivo
ya existe en `ruta` y no esta vacio, no se vuelve a descargar y se lee
directamente.

## Usage

``` r
leer_dataset(
  dataset,
  ruta,
  url_base = "https://raw.githubusercontent.com/rse-r/intro-programacion/main/datos/"
)
```

## Arguments

- dataset:

  Texto con el nombre del archivo a descargar, sin la extension `.csv`.
  Por ejemplo, el id de una estacion: `"NH0437"`.

- ruta:

  Texto con la ruta donde se guardara el archivo, incluyendo su nombre y
  extension. Por ejemplo: `"datos/NH0437.csv"`. Es obligatorio: la
  funcion no guarda archivos en ningun lugar que el usuario no indique.
  Si las carpetas no existen, se crean. Si ya existe un archivo en esa
  ruta, se lee ese archivo sin descargar nada, aunque corresponda a otro
  dataset; si existe pero esta vacio, se vuelve a descargar.

- url_base:

  Texto con la direccion de la carpeta donde esta el archivo. Debe
  empezar con `http` y terminar con `/`, y tiene que apuntar al
  contenido crudo del archivo (en GitHub, la direccion del boton "Raw").
  Por defecto apunta a los datos de estaciones del INTA:
  `"https://raw.githubusercontent.com/rse-r/intro-programacion/main/datos/"`.

## Value

Una tabla con los datos del archivo.

## Details

La URL completa se arma como `url_base` + `dataset` + `".csv"`. Por
defecto apunta a datos de estaciones meteorologicas del Instituto
Nacional de Tecnologia Agropecuaria (INTA), pero se puede indicar
cualquier otra direccion que cumpla ese formato.

Antes de leer el archivo, la funcion revisa su contenido. Si esta vacio
o es una pagina web en lugar de un CSV, se detiene con un error. Si el
archivo se acaba de descargar, ademas lo borra; si ya estaba en `ruta`,
no lo borra. Si la tabla leida tiene una sola columna o no tiene filas
de datos, devuelve la tabla igual pero muestra una advertencia, porque
puede tratarse de un archivo con otro formato.

Si la descarga falla (por ejemplo, sin conexion a internet o con una
direccion que no existe), se muestra el error de R correspondiente. El
mensaje previo de descarga indica que URL se intento usar.

## Examples

``` r
# necesita conexion a internet para descargar los datos
# tempdir() devuelve la carpeta temporal de tu sesion de R
ruta <- file.path(tempdir(), "NH0437.csv")
datos <- leer_dataset("NH0437", ruta = ruta)
#> Descargando "NH0437" desde
#> <https://raw.githubusercontent.com/rse-r/intro-programacion/main/datos/NH0437.csv>...
head(datos)
#> # A tibble: 6 × 35
#>   id     fecha      temperatura_abrigo_150cm temperatura_abrigo_150cm_maxima
#>   <chr>  <date>                        <dbl>                           <dbl>
#> 1 NH0437 1970-08-01                     23.3                            31.2
#> 2 NH0437 1970-08-02                     26.6                            32.1
#> 3 NH0437 1970-08-03                     17.4                            22.9
#> 4 NH0437 1970-08-04                     11.0                            11.9
#> 5 NH0437 1970-08-05                     11.1                            12.6
#> 6 NH0437 1970-08-06                     13.6                            15.1
#> # ℹ 31 more variables: temperatura_abrigo_150cm_minima <dbl>,
#> #   temperatura_intemperie_5cm_minima <dbl>,
#> #   temperatura_intemperie_50cm_minima <dbl>,
#> #   temperatura_suelo_5cm_media <dbl>, temperatura_suelo_10cm_media <dbl>,
#> #   temperatura_inte_5cm <lgl>, temperatura_intemperie_150cm_minima <lgl>,
#> #   humedad_suelo <lgl>, precipitacion_pluviometrica <dbl>, granizo <dbl>,
#> #   nieve <dbl>, heliofania_efectiva <dbl>, heliofania_relativa <dbl>, …

# si se vuelve a llamar con la misma ruta, se lee el archivo
# guardado y no se descarga de nuevo
datos <- leer_dataset("NH0437", ruta = ruta)
#> El archivo /tmp/RtmpoGQvjU/NH0437.csv ya existe, se lee sin descargar.
```
