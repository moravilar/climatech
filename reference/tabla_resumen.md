# Tabla de resumen mensual de una variable

Calcula medidas de resumen de una variable numerica para cada mes del
anio: media, desvio estandar, primer cuartil, mediana y tercer cuartil.
Los meses se agrupan sin importar el anio, es decir, el resumen de julio
usa todos los julios de la serie. El resumen se puede hacer con todos
los datos juntos o por separado para cada estacion.

## Usage

``` r
tabla_resumen(
  datos,
  variable = "temperatura_abrigo_150cm",
  por_estacion = FALSE
)
```

## Arguments

- datos:

  Data frame con una fila por medicion. Tiene que tener la columna
  `fecha` (dia de la medicion) y la columna indicada en `variable`. Si
  `por_estacion = TRUE`, tambien tiene que tener la columna `id`, que
  identifica a cada estacion (por ejemplo, `"NH0472"`). Las filas con
  `id` vacio (`NA`) se resumen juntas como un grupo aparte.

- variable:

  Texto con el nombre de la columna numerica a resumir, entre comillas.
  Por defecto, `"temperatura_abrigo_150cm"`, la temperatura de los datos
  del paquete.

- por_estacion:

  `TRUE` o `FALSE`. Si es `TRUE`, el resumen se calcula por separado
  para cada estacion. Si es `FALSE` (por defecto), se calcula con todos
  los datos juntos, aunque haya mas de una estacion.

## Value

Un tibble en formato largo, con cinco filas por cada mes (o por cada
combinacion de estacion y mes, si `por_estacion = TRUE`) y las columnas:

- id:

  Identificador de la estacion. Solo aparece si `por_estacion = TRUE`.

- mes:

  Numero del mes, de 1 a 12.

- estadistico:

  Nombre de la medida: `"media"`, `"desvio"`, `"q1"`, `"mediana"` o
  `"q3"`.

- valor:

  Valor de la medida.

## Details

Los valores faltantes (`NA`) se ignoran en los calculos. Si en un mes no
hay ningun dato de la variable, la media da `NaN` y el resto de los
estadisticos da `NA`. Si hay un solo dato, el desvio da `NA`.

La columna `fecha` puede ser de tipo fecha (`Date`) o texto. Si es
texto, se convierte a fecha dentro de la funcion (el data frame original
no se modifica). Tiene que estar en el orden anio-mes-dia, por ejemplo
`"1961-07-01"`.

## Examples

``` r
# resumen de la temperatura con todos los datos juntos (valor por defecto)
tabla_resumen(datos_estaciones)
#> Hay 1 valor(es) faltante(s) (`NA`) en "temperatura_abrigo_150cm", que no se
#> usa(n) en los calculos.
#> # A tibble: 60 × 3
#>      mes estadistico valor
#>    <dbl> <chr>       <dbl>
#>  1     1 media       26.1 
#>  2     1 desvio       2.86
#>  3     1 q1          24.4 
#>  4     1 mediana     26.2 
#>  5     1 q3          28.0 
#>  6     2 media       24.9 
#>  7     2 desvio       3.13
#>  8     2 q1          22.9 
#>  9     2 mediana     24.9 
#> 10     2 q3          27.0 
#> # ℹ 50 more rows

# resumen de la temperatura para cada estacion
tabla_resumen(datos_estaciones, por_estacion = TRUE)
#> Hay 1 valor(es) faltante(s) (`NA`) en "temperatura_abrigo_150cm", que no se
#> usa(n) en los calculos.
#> # A tibble: 120 × 4
#>    id       mes estadistico valor
#>    <chr>  <dbl> <chr>       <dbl>
#>  1 NH0437     1 media       26.7 
#>  2 NH0437     1 desvio       2.79
#>  3 NH0437     1 q1          25.0 
#>  4 NH0437     1 mediana     26.8 
#>  5 NH0437     1 q3          28.5 
#>  6 NH0437     2 media       25.8 
#>  7 NH0437     2 desvio       3.07
#>  8 NH0437     2 q1          23.8 
#>  9 NH0437     2 mediana     25.6 
#> 10 NH0437     2 q3          27.6 
#> # ℹ 110 more rows

# resumen de otra variable
tabla_resumen(datos_estaciones, variable = "humedad_media_8_14_20")
#> Hay 4 valor(es) faltante(s) (`NA`) en "humedad_media_8_14_20", que no se usa(n)
#> en los calculos.
#> # A tibble: 60 × 3
#>      mes estadistico valor
#>    <dbl> <chr>       <dbl>
#>  1     1 media        70.2
#>  2     1 desvio       13.5
#>  3     1 q1           61  
#>  4     1 mediana      70.5
#>  5     1 q3           80  
#>  6     2 media        75.9
#>  7     2 desvio       12.0
#>  8     2 q1           68  
#>  9     2 mediana      76  
#> 10     2 q3           85  
#> # ℹ 50 more rows
```
