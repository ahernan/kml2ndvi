
#------------------- METADATA -------------------
# Descripcion del Script: Retorna un recorte y un reporte de un raster 
#                         a partir de un poligono vectorial
# Raster: Se considera del producto MOD13Q1 de MODIS la banda NDVI y EVI. 
#         En este caso recortes proporcionados por Patricio Oricchio en formato .img
#         Valores en raster almacenado como entero. Si quiero valor real entonces (value=value/1000)
# Vector: Inicialmente se considera un archivo KML con un poligono dentro

# Sistema de referencia de cordenadas (CRS) de Raster y Vector = WGS84 !!!

# Fecha de ultima modificacion: 4-nov-2016

# Participantes
# angelini.hernan@inta.gob.ar
# oricchio.patricio@inta.gob.ar
# bienvenidos otros interesados
#------------------- /METADATA -------------------

#---- Librerias ----
library(rgdal)
library(rgeos)
library(sp)


#---- Construccion de la Pila de RASTER ----
# Almacenadas dentro del directorio NDVI. 23 img por anio.
# de 001-2015 a 353-2015. con xxx-2015@1=NDVI y xxx-2015@2=EVI

# Seteo el wd de IMAGEN
setwd("/home/hernan/Curso_R/git/kml2ndvi/NDVI")

# Lista de nombres de los archivos .img 
(lista_img <- list.files(getwd(), pattern = glob2rx("*.img"), full.names = F))

# Se crea en memoria el RasterStack o pila de bandas 
# (2 bandas por archivo, solo se trae la 1ra=NDVI)
(RasterStack <- raster::stack(lista_img, bands=1))
#---- /Construccion de la Pila de RASTER ----


#---- Construccion del poligono - VECTOR ----
# Almacenado dentro de la carpeta data, un KML con poligonos dentro
# Se selecciona uno y se procesa

# Seteo el wd para el VECTOR
setwd("/home/hernan/Curso_R/git/kml2ndvi/")

# dsnv = Data Source Name Vector
dsnv <- file.path("data","Lotes.kml") #carga directorio y archivo
ogrListLayers(dsnv) # Funcion para leer objetos espaciales. Para ver que hay dentro del KML 

# Selecciono la capa dentro del KML que contiene los poligonos
lotes_layer <- rgdal::readOGR(dsnv, layer = "Lotes")

# Puedo graficar los poligonos con la siguiente instruccion
# raster::plot(lotes_layer)


# Creo un objeto espacial con uno de los poligonos de la capa
prj_string_WGS <- CRS("+proj=longlat +datum=WGS84")
lotev <- SpatialPolygons(lotes_layer@polygons[1])
# raster::plot(Lote)
#---- /Construccion del poligono - VECTOR ----



#---- Construccion del REPORTE - VECTOR y RASTER ----
# Se corta RasterStack con Lote
# Se procesa media de valores y desvio estandar para cada pixel del lote
# Se genera salida en jpg. Hay multiples lecturas de este resultado. Mas o menos validas

# Corto del Stack
lote_raster <- raster::crop(RasterStack, lotev)
#raster::plotRGB(lote_raster) #grafico si hace falta

# Si no quiero el aspecto cuadrado del raster Enmascaro
# loteymascara <- raster::mask(lote_raster, lotev) 
# raster::plotRGB(loteymascara)

# Reporta la Media de las fechas para cada pixel
loter_media <- raster::calc(lote_raster, fun=mean)
# Reporta las desviaciones estandar de esas medias
loter_sd <- raster::calc(lote_raster, fun=sd)

# Si quiero ver valores dentro del lote
# raster::values(loter_media)
# raster::values(loter_sd)
#---- /Construccion del REPORTE - VECTOR y RASTER ----


#---- Construccion de la salida grafica - VECTOR y RASTER ----
# Configura espacios de salida
opar <- par(mfrow=c(1,2))

# Grafica la media de NDVI del lote 
raster::plot(loter_media, main = "Media")
plot(lotev, add=T, border="green", lwd=3)

# Grafica la media de NDVI del lote 
raster::plot(loter_sd, main = "SD", col=c("blue", "yellow", "orange", "red"))
plot(lotev, add=T, border="green", lwd=3)

par(opar)
#---- /Construccion de la salida grafica - VECTOR y RASTER ----
