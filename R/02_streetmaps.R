# sourcing packages -------------------------------------------------------

source(here::here("R", "01_packages.R"))

# actual tutorial ---------------------------------------------------------

## creating sf objs

streets <- osmdata::getbb("Jyväskylä Finland") %>% # getting jyväskylä's bounding box
  osmdata::opq() %>% # this one is kind of a mistery!
  osmdata::add_osm_feature(
    key = "highway", # this function gets features, key gets feature key
    value = c(
      "motorway", "primary",
      "secondary", "tertiary"
    )
  ) %>% # value specifies feature tag
  osmdata::osmdata_sf() # creates an sf object that we'll plot later

# streets # just checking if it worked

small_streets <- getbb("Jyväskylä Finland") %>%
  opq() %>%
  add_osm_feature(
    key = "highway",
    value = c(
      "residential",
      "living_street",
      "unclassified",
      "service",
      "footway"
    )
  ) %>%
  osmdata_sf()

## getting lakes/water bodies

# checking for possible featues that have water
# osmdata::available_features()

# hopefully natural will work since waterway/water no longer works unfortunately since they
# are no longer available
# available_tags("natural")

lake <- getbb("Jyväskylä Finland") %>%
  opq() %>%
  add_osm_feature(
    key = "natural",
    value = "water"
  ) %>%
  osmdata_sf()

## sf didn't work because multipolygons have too large names, trying sp
## workaround found from:
## https://stackoverflow.com/questions/59144491/r-unusual-error-plotting-multipolygons-with-ggplot-geom-sf-and-openstreetmap

lake_sp <- getbb("Jyväskylä Finland") %>%
  opq() %>%
  add_osm_feature(
    key = "natural",
    value = "water"
  ) %>%
  osmdata_sp()

gpclibPermit()

lake_sp$osm_multipolygons@data$id <- rownames(lake_sp$osm_multipolygons@data)
df_lake_sp <-
  fortify(lake_sp$osm_multipolygons, region = "id") %>%
  merge(lake_sp$osm_multipolygons@data, by = "id")

# plotting ----------------------------------------------------------------

# Linux newbie here, ran into issues installing sf and worked around said issues
# following this tutorial:
# https://philmikejones.me/tutorials/2018-08-29-install-sf-ubuntu/

ggplot2::ggplot() +
  geom_polygon(
    data = df_lake_sp,
    aes(x = long, y = lat, group = group),
    fill = "lightblue4"
  ) +
  geom_sf(
    data = streets$osm_lines,
    inherit.aes = FALSE,
    # color = "#7fc0ff",
    color = "#edb271",
    size = .8,
    alpha = .8
  ) +
  geom_sf(
    data = small_streets$osm_lines,
    inherit.aes = FALSE,
    color = "#ff9d49",
    size = .4,
    alpha = .6
  ) +
  # geom_sf(data = lake$osm_polygons,
  #         inherit.aes = FALSE,
  #         fill = "lightblue",
  #         alpha = .4) +
  coord_sf(
    xlim = c(25.67, 25.82),
    ylim = c(62.21, 62.27),
    expand = FALSE
  ) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "#282828")
  )


## black and white

ggplot2::ggplot() +
  geom_sf(
    data = streets$osm_lines,
    inherit.aes = FALSE,
    color = "black",
    size = .4,
    alpha = .8
  ) +
  geom_sf(
    data = small_streets$osm_lines,
    inherit.aes = FALSE,
    color = "black",
    size = .15,
    alpha = .6
  ) +
  # geom_sf(data = lake$osm_polygons,
  #         inherit.aes = FALSE,
  #         fill = "lightblue",
  #         alpha = .4) +
  # geom_polygon(data = df_lake_sp,
  #              aes(x = long, y = lat, group = group),
  #              fill = "lightblue",
  #              alpha = .4) +
  coord_sf(
    xlim = c(25.67, 25.82),
    ylim = c(62.21, 62.27),
    expand = FALSE
  ) +
  theme_minimal()+
  ggtitle("J Y V Ä S K Y L Ä") +
  theme(plot.title = element_text(size = 29, hjust = .5),
        axis.text = element_blank(),
        panel.grid = element_blank(),
        text = element_text(family = "Palatino"))

ggsave(here("figures", "jyv-streetmap.png"), dpi = 800)
