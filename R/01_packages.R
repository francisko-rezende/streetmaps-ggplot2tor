# checking for and installing needed packages -----------------------------

# code from Shane's reply to this stack overflow answer:
# https://stackoverflow.com/questions/4090169/elegant-way-to-check-for-missing-packages-and-install-them

packages <- c("osmdata", "tidyverse", "here", "sf", "sp", "maptools", "extrafont")

new.packages <- packages[!(packages %in% installed.packages()[, "Package"])]
if (length(new.packages)) install.packages(new.packages)


# loading packages --------------------------------------------------------

library(osmdata)
library(tidyverse)
library(here)
library(sf)
library(sp)
library(maptools)
library(extrafont)
