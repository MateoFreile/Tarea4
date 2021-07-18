##### Mapa con tmap #####
x <- c("ggmap", "rgdal", "rgeos", "maptools", "dplyr", "tidyr", "tmap")
# install.packages(x) 
lapply(x, library, character.only = TRUE) # load the required packages

setwd("C:/Udesa/Herramientas/Clase_4/videos 2 y 3")

# Cargamos la base y la miramos
lnd <- readOGR(dsn = "data/london_sport.shp")
View(lnd)

# Chequeamos la clase de cada variable
sapply(lnd@data, class)
#La convertimos a numero a poblacion y chequeamos
lnd$Pop_2001 <- as.numeric(as.character(lnd$Pop_2001))
sapply(lnd@data, class)

# Configuramos la proyeccion de los datos (CRS)
lnd@proj4string

# Cargamos la base de crimenes
crime_data <- read.csv("data/mps-recordedcrime-borough.csv",
                       stringsAsFactors = FALSE)
View(crime_data)
head(crime_data$CrimeType) # information about crime type

# Extract "Theft & Handling" crimes and save
crime_theft <- crime_data[crime_data$CrimeType == "Theft & Handling", ]
View(crime_theft)

# Calculate the sum of the crime count for each district, save result
crime_ag <- aggregate(CrimeCount ~ Borough, FUN = sum, data = crime_theft)
View(crime_ag)

#Le cambiamos el nombre a la variable mal nombrada
crime_ag[crime_ag=="NULL"]<-"City of London"

#Hacemos el marge
lnd@data <- left_join(lnd@data, crime_ag, by = c('name' = 'Borough'))

#Creamos la nueva variable , importante que operemos numeros y no caracteres
lnd$thefts_pop <- lnd$CrimeCount/lnd$Pop_2001*1000

qtm(shp = lnd, fill = "thefts_pop", 
    fill.palette = "Reds", 
    fill.title = "Robos cada\n1000 habitantes",
    fill.n = 7, 
    style = "natural") + tm_scale_bar(position = c(0,0))

##### Mapa con ggplot #####
library(broom)
lnd_f <- broom::tidy(lnd)

# This step has lost the attribute information associated with the lnd object. We can add it back using the left_join function from the dplyr package (see ?left_join).
lnd$id <- row.names(lnd) # allocate an id variable to the sp data
head(lnd@data, n = 2) # final check before join (requires shared variable name)
lnd_f <- left_join(lnd_f, lnd@data)

map <- ggplot(lnd_f, aes(long, lat, group = group, fill = thefts_pop)) +
  geom_polygon(colour = "black") + coord_equal() +
  labs(x = NULL, y = NULL, 
       fill = "Robos cada\n1000 habitantes") +
  scale_fill_gradient(low = "yellow", mid ="orange", high = "red") + 
  scale_x_discrete(breaks = c("")) + 
  scale_y_discrete(breaks = c("")) +
  theme(legend.justification=c(1,0), 
        legend.position=c(0.95,0.05), 
        legend.background = element_rect(fill="white",
                                         size=0.5, linetype="solid", 
                                         colour ="black"),
        legend.box.background = element_rect())
map