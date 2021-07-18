*Fijamos el directorio
global DATA = "C:\Udesa\Herramientas\Clase_4\videos 2 y 3\data" 
cd "$DATA"

*Instalamos los paquetes
*ssc install spmap
*ssc install shp2dta
*net install spwmatrix, from(http://fmwww.bc.edu/RePEc/bocode/s)

* Leemos la información shape en Stata
shp2dta using london_sport.shp, database(ls) coord(coord_ls) genc(c) genid(id) replace

/* Importamos y transformamos los datos de Excel a formato Stata */
import delimited "$DATA/mps-recordedcrime-borough.csv", clear 

*Nos quedamos con el tipo de crimen solicitado
keep if crimetype=="Theft & Handling"

* Renombramos la variable de interes
rename borough name
* Sumamos la cantidad de crimenes por municipio y guardamos la base
collapse (sum) crimecount, by(name)
save "crime.dta", replace

*Cargamos la base y la margeamos
use ls, clear
merge 1:1 name using crime.dta

*Corregimos la variable mal nombrada y dropeamos _m
drop _m
replace crimecount = 3735 in 7
drop in 34
* Guardamos
save london_crime_shp.dta, replace

*Con esta base haremos los graficos
* Generamos la variable de interes a graficas
gen Theft_pop1000=crimecount/Pop_2001*1000

* El mapa:
spmap Theft_pop1000 using coord_ls, id(id) clmethod(q) cln(5) title("Cantidad de asaltos reportados cada 1000 habitantes") legend(size(medium) position(5) xoffset(15.05)) fcolor(Reds) plotregion(margin(b+15)) ndfcolor(gray) name(g2,replace)  

*Exportamos
graph export "C:\Udesa\Herramientas\Clase_4\spmap1.png", as(png) replace
