#!/bin/bash

rsync -av --delete-after build/html/ www.lasteamlab.com:/var/www/html/documentation/game-design
