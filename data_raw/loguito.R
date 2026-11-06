# code  para generar el logo del paquete (man/figures/logo.png);
# laas dos lineas son la temperatura promedio de cada mes de las dos
# estaciones de datos_estaciones, el diseño nos ayudó la IA (tema formas y colores
#mas q nada)

library(ggplot2)
devtools::load_all()

# promedio mensual de temperatura de cada estacion
promedios <- datos_estaciones
promedios$mes <- lubridate::month(promedios$fecha)
promedios <- aggregate(temperatura_abrigo_150cm ~ id + mes,
                       data = promedios, FUN = mean)

# llevamos los meses (1 a 12) y las temperaturas a una caja chica
# dentro del hexagono, para que el grafico entre en el logo
promedios$x <- -0.55 + (promedios$mes - 1) / 11 * 1.1
rango <- range(promedios$temperatura_abrigo_150cm)
promedios$y <- -0.05 + (promedios$temperatura_abrigo_150cm - rango[1]) / diff(rango) * 0.55

# vertices de un hexagono con una punta arriba
angulos <- seq(90, 450, by = 60) * pi / 180
hexagono <- data.frame(x = cos(angulos), y = sin(angulos))

logo <- ggplot() +
  geom_polygon(data = hexagono, aes(x, y),
               fill = "#2E1A47", color = "#D63384", linewidth = 2.5) +
  geom_line(data = promedios, aes(x, y, color = id),
            linewidth = 1.6, lineend = "round", linejoin = "round") +
  geom_point(data = promedios, aes(x, y, color = id), size = 1.2) +
  annotate("text", x = 0, y = -0.42, label = "climatech",
           color = "white", size = 9, fontface = "bold") +
  scale_color_manual(values = c("#F48FB1", "#8AB4F8")) +
  coord_fixed() +
  theme_void() +
  theme(legend.position = "none")

ggsave("man/figures/logo.png", logo,
       width = 2.4, height = 2.78, dpi = 300, bg = "transparent")
