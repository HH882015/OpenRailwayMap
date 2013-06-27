#!/bin/bash

# OpenRailwayMap Copyright (C) 2012 Alexander Matheisen
# This program comes with ABSOLUTELY NO WARRANTY.
# This is free software, and you are welcome to redistribute it under certain conditions.
# See http://wiki.openstreetmap.org/wiki/OpenRailwayMap for details.

# some commands are marked as comments because on the server they are merged with OpenLinkMap

# working directory, please change
cd /home/www/sites/194.245.35.149/site/olm/import
PATH="$PATH:/home/www/sites/194.245.35.149/site/olm/import/bin"
PATH="$PATH:/home/www/sites/194.245.35.149/site/orm/import/bin/osm2pgsql"
export JAVACMD_OPTIONS=-Xmx2800M


# download planet file
# echo "Downloading planet file"
# echo ""
# wget http://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
# mv planet-latest.osm.pbf old.pbf
# echo ""


# update planet file
# echo "Updating planet file"
# echo ""
# date -u +%s > timestamp
# osmupdate old.pbf new.pbf --max-merge=2 --hourly --drop-author -v
# rm old.pbf
# mv new.pbf old.pbf
# echo ""


# convert planet file
echo "Converting planet file"
echo ""
osmconvert old.pbf --drop-author --out-o5m >temp.o5m
echo ""


# pre-filter planet file
echo "Filtering planet file"
echo ""
osmfilter temp.o5m --keep="railway= route=tracks route=railway route=train route=light_rail route=tram route=subway route_master=train route_master=light_rail route_master=tram route_master=subway shop=ticket vending=public_transport_tickets" --out-osm >old-railways.osm
rm temp.o5m
echo ""


# load data into database
echo "Loading data into database"
echo ""
osm2pgsql --create --database railmap --username olm --prefix railmap --slim --style railmap.style --hstore --cache 512 old-railways.osm
osmconvert old-railways.osm --out-o5m >old-railways.o5m
rm old-railways.osm
echo ""


# run mapcss converter
echo "Create MapCSS style"
echo ""
cd /home/www/sites/194.245.35.149/site/orm/styles
python mapcss_converter.py --mapcss style.mapcss --icons-path .
echo ""

# prerender lowzoom tiles
echo "Prerendering tiles"
echo ""
cd /home/www/sites/194.245.35.149/site/orm/renderer
php prerender-lowlevel.php
echo ""
echo "Finished."
