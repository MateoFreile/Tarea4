#Prior to use, install the following packages:

install.packages("ggplot2")
install.packages("tibble")
install.packages("dplyr")
install.packages("gridExtra")
install.packages("Lock5Data")
install.packages("ggthemes")

install.packages("maps")
install.packages("mapproj")
install.packages("corrplot")
install.packages("fun")
install.packages("zoo")
install.packages("tidyr")

#Load Libraries

library("ggplot2")
library("tibble")
library("gridExtra")
library("dplyr")
library("Lock5Data")
library("ggthemes")
library("fun")
library("zoo")
library("corrplot")
library("maps")
library("mapproj")

#Set pathname for the directory where you have data
setwd("C:/Udesa/Herramientas/Clase_4/Applied-Data-Visualization-with-R-and-ggplot2-master")
#Check working directory
getwd()

#Load the data files
df <- read.csv("data/gapminder-data.csv")

####### GRAFICO 1 #######

p1 <- ggplot(df,aes(x=Electricity_consumption_per_capita))
a1 <- p1 + 
  geom_histogram(fill="white",
                 color="black",
                 bins = 15,
                 position = 'identity', 
                 alpha = 0.9) + 
  labs(title = 'Histograma del consumo per capita de electricidad',
       x = 'KWh',
       y =  NULL,
       subtitle = NULL,
       caption. = NULL) +
  scale_x_continuous(breaks=seq(0,15000,2500))
a1

####### GRAFICO 2 #######

dfs <- subset(df,Country %in% c("Germany","India","China","United States"))
var1<-"Electricity_consumption_per_capita"
var2<-"gdp_per_capita"

a2 <- ggplot(dfs,aes_string(x=var1,y=var2)) +
  geom_point(aes(color=Country)) +
  labs(title = "PBI y Electricidad (per cápitas)",
       x = 'KWh',
       y =  NULL,
       subtitle = "USD",
       caption. = NULL) +
  scale_color_brewer(name = NULL, 
                     labels = c("China", "Alemania", "India" , "Estados Unidos"),
                     palette="Spectral") +
  scale_x_continuous(breaks=seq(0,15000,2500)) +
  scale_y_continuous(breaks=seq(0,55000,10000))+
  theme(legend.justification=c(1,0), 
        legend.position=c(0.3,0.6), 
        legend.background = element_rect(fill="lightblue",
                                         size=0.5, linetype="solid", 
                                         colour ="darkblue"),
        legend.box.background = element_rect())+
  theme(plot.title = element_text(hjust = 0.5))+
  theme (plot.subtitle = element_text(hjust = -.06))
a2  

####### GRAFICO 3 #######

#Tiramos los NA que estan en las 2 variables de 
#interes para que no queden espacios en blanco
#dentro de los graficos

library(tidyr)
dfinal <- dfs %>% drop_na(gdp_per_capita,
                          Electricity_consumption_per_capita)

#Añadimos una columna con los nombres de los paises en español
dfinal$pais <- factor(dfinal$Country, 
                      labels = c("China", "Alemania", "India", "Estados Unidos"))

a3 <- ggplot(dfinal, aes(gdp_per_capita,
                Electricity_consumption_per_capita,
                color=pais)) + 
  geom_point() + stat_smooth(method=lm) +
  scale_color_brewer(palette="Spectral") + 
  ylab("Electricidad per cápita en KWh") +
  xlab("PBI per capita en USD") +
  facet_wrap(~pais, scales="free") + 
  theme_bw() +
  theme(legend.position= "none")
a3