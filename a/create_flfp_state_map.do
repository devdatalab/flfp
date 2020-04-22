*********************************************/
/*GENERATE MAPS FOR FLFP BY STATE			 */
/*********************************************/


/*  NOTE: In this current version, the produced graphs will be saved in the flfp folder. 
I'm trying to find a way to put them into the $tmp folder while keeping the code reproducible and will update 
it once I figure that out.  */

/* Install rsource package which allows you to access R from within Stata */
ssc install rsource, replace 

/* Change directory to flfp. This means that in the following R code block, the working directory will be $flfp */
cd $flfp

/* Open up R through Stata. Everything between this line and END_OF_R will be coded in R */ 
rsource, terminator(END_OF_R) rpath("/usr/local/bin/R") roptions(`"--vanilla"')

	## Load necessary packages. The require function should install and load them.
	
	require("rgdal") # rgdal, rgeos and maptools are necessary to load in the shapefiles
	require("rgeos")
	require("maptools")
	require("ggplot2") # ggplot2 is necessary for graphing
	require("haven") #haven is necessary for importing .dta files
	require("tidyverse") #used for data manipulation and merges
	require("dplyr") #used for renaming and merges
	require("magrittr") 
	require("magick") #magick and magrittr are necessary to turn the PNGs into a GIF

	## Create local containing all EC years

	year_set <- c(1990,1998,2005,2013) 
	
	## Loop over all EC years, creating a png for each year 
	
	for (val in year_set) {
  
	## Read in pc11 state shapefiles
	shapefile = readOGR(dsn = "./pc11", layer = "pc11-state")
	
	## Read in EC State Level Data
	ec_flfp_state <- read_dta("./ec_flfp_state_level.dta")
  
	## Filter for year and rename variable for future merge
	ec_flfp_state <- data %>%
		filter(year == val) %>%
		dplyr::rename(pc11_s_id = pc11_state_id)
  
	## Merge shapefile and dataset into a combined shapefile
	combined <- merge(india,data, by = "pc11_s_id")
  
	## Prep new combined shapefile for graphing 
	combined@data$id = rownames(combined@data)
	combined.points = fortify(combined,region = "id")
	combined.df = left_join(combined.points, combined@data, by = "id")
  
	## Graph shapefiles creating state-by-state chloropleth of emp_f_share
	ggplot(combined.df, aes(x = long, y = lat)) + geom_polygon(aes(group = group, fill = emp_f_share)) + 
		coord_map() + labs(title = "Female Employment Share by State", fill = "Female Employment Share", subtitle = val) + 
		xlab("") + ylab("") + scale_fill_gradient(low = "#c70000", high = "#239600", limits = c(0,0.45)) +
		theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.background = element_blank(), panel.grid = element_blank())
  
	## Save map to PNG
	ggsave(paste("ec_flfp_state_map_",val,".png"))
	
}
	
	## Combine PNGs to create a GIF 
	list.files(path = '.', pattern = '*.png', full.names = TRUE) %>%
		image_read() %>%
		image_join() %>%
		image_animate(fps = 1) %>%
		image_write("ec_flfp_state_cloropleth.gif")
  
END_OF_R

