# Como contribuir a climatech

Esta guia explica como proponer cambios a climatech. ¡Cualquier ayuda es bienvenida!

## Corregir errores de tipeo

Podes corregir errores de tipeo u ortografia en la documentacion directamente desde GitHub, siempre que el cambio se haga en el archivo *fuente*.
Eso significa editar los comentarios de [roxygen2](https://roxygen2.r-lib.org/articles/roxygen2.html) en los archivos `.R` de la carpeta `R/`, y no los archivos `.Rd` de la carpeta `man/`, que se generan automaticamente.

## Cambios mas grandes

Si queres hacer un cambio mas grande, primero abri un [issue](https://github.com/moravilar/climatech/issues) para charlarlo con nosotras.
Si encontraste un error, contanos en el issue como reproducirlo con un ejemplo minimo (lo ideal es un [reprex](https://www.tidyverse.org/help/#reprex)): asi tambien es mas facil escribir un test para el caso.

### Como trabajamos con las ramas

* La rama `master` tiene la version estable del paquete, y desde ahi se publica la pagina web.
* Los cambios se hacen en la rama `dev`, y cuando estan listos pasan a `master` con un pull request.
* Por eso, **los pull requests tienen que apuntar a la rama `dev`**, no a `master`.

### Pasos para mandar un pull request

* Hace un fork del repositorio y clonalo en tu computadora, por ejemplo con `usethis::create_from_github("moravilar/climatech", fork = TRUE)`.
* Pasate a la rama `dev` y crea una rama nueva para tu cambio, por ejemplo con `usethis::pr_init("descripcion-corta-del-cambio")`.
* Hace tus cambios y revisa que el paquete siga funcionando con `devtools::test()` y `devtools::check()`.
* Hace commit de los cambios y crea el pull request (por ejemplo con `usethis::pr_push()`).
  El titulo tiene que describir el cambio, y en la descripcion poné `Closes #` con el numero del issue que resuelve.

### Estilo del codigo

* Seguimos la [guia de estilo del tidyverse](https://style.tidyverse.org).
* Para documentar usamos [roxygen2](https://roxygen2.r-lib.org) con formato Markdown.
* Para los tests usamos [testthat](https://testthat.r-lib.org). Los cambios que incluyen tests son mas faciles de aceptar.
* Los mensajes de error y avisos los escribimos con [cli](https://cli.r-lib.org), y sin tildes ni enies para que el paquete pase `R CMD check`.

## Codigo de conducta

Este proyecto tiene un [codigo de conducta](https://github.com/moravilar/climatech/blob/master/CODE_OF_CONDUCT.md). Al participar, aceptas respetarlo.
