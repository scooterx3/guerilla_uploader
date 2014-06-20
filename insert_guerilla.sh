#!/bin/bash

destination='g-up'

mkdir $destination 

wget -P $destination https://raw.githubusercontent.com/scooterx3/guerilla_uploader/master/index.php

echo "
post_max_size = 10G;
max_execution_time = 3600;
max_file_uploads = 25;
memory_limit = 256M;
upload_max_filesize = 10G;" > $destination/php.ini

