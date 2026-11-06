# nmbres de columnas que usamos dentro de funciones de dplyr y ggplot2
#(por ej, mes, id o valor). El R CMD check no sabe que son columnas
# de un data frame y las marca como variables sin definir, por eso las declarams

utils::globalVariables(c("fecha", "id", "mes", "promedio", "valor"))
