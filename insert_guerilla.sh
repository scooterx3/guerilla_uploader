#!/bin/bash

destination='../g-up'

secret=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)

mkdir $destination 

# wget -P $destination http://dev.scooterx3.net/guerilla_uploader/index.php

cat <<"INI" > $destination/php.ini 
post_max_size = 10G;
max_execution_time = 3600;
max_input_time = 3600;
max_file_uploads = 25;
memory_limit = 256M;
upload_max_filesize = 10G;
display_errors = true;"
INI

cat <<"HTA" > $destination/.htaccess
AddHandler application/x-httpd-php54 .php 
HTA

cat <<"JS" > $destination/javascript.js

	console.log('javascript GO!');

JS

echo "<?php \$secret = '$secret'; ?>" > $destination/index.php
cat <<"PHP" >> $destination/index.php
<?php
error_reporting(-1);
ini_set("display_errors",1);


$upload_info = new stdClass;
$auth_status = new stdClass;

function incrementFileName($filename){
	$file_exploded = explode(".",$filename);
	$file_ext = '.'.end($file_exploded);
	$root_name = str_replace(($file_ext),"",$filename);
	$file = $filename;
	$i = 1;
	while(file_exists($file)){
		$file = $root_name." ($i)".$file_ext;
		$i++;
	}
	return $file;
	echo $file;
}

//self delete
function seppuku(){

	unlink('php.ini');
	unlink(__FILE__);
}

function goBabyGo($upload_info){
	for ($i = 0; $i <count($_FILES['uploadedfile']['name']); $i++) {
		$file_base = basename($_FILES['uploadedfile']['name'][$i]);
		$target_file = $file_base; 

		if (file_exists($target_file)){
			//echo "{file_exists:1,message:'$target_file exists, incrementing file name'}";
			$upload_info -> file_already_exists = 'true';			
			$target_file = incrementFileName($target_file);
		}else{
			$upload_info -> file_already_exists = 'false';
		}

		$upload_info -> file_name = $target_file;

		if(move_uploaded_file($_FILES['uploadedfile']['tmp_name'][$i], $target_file)) {
		    
		    //echo "{error:0,message:'$target_file uploaded'}";
		    $upload_info -> upload_success = 'true';

		} else{
		    // echo "{error:1,message:'Error uploading ".$_FILES['uploadedfile']['name'][$i]."'}";
		    $upload_info -> upload_success = 'false';
		    // echo "Error uploading $_FILES['uploadedfile']['name'][$i]";
		}
	}

	$json_upload_info = json_encode($upload_info);
	echo $json_upload_info;
	// seppuku();
}


if (isset($_POST['guerilla_uploader'])){

	if (isset($_POST['password']) && $_POST['password'] == $secret ){

		

		goBabyGo($upload_info);

	}else{
		$auth_status -> auth_status = '0';
		$auth_status = json_encode($auth_status);
		echo $auth_status;
		// echo "{password_ok:0,message:'Password no workie'}";
		// seppuku();
	}
}elseif (isset($_POST['seppuku'])){
	seppuku();
}else{
	?>
		<script src="javascript.js"></script>
		<form enctype="multipart/form-data" action="index.php" method="POST">
		<input type="hidden" name="guerilla_uploader" />
		Choose a file to upload: <input name="uploadedfile[]" type="file" multiple='multiple' /><br />
		<input type="text" placeholder="password" name="password" value="" />
		<input type="submit" value="Upload File" />

		</form>
	<?php
}




?>
PHP


echo "ready to upload. Please go to domain.com/$destination. Password: '$secret'"

echo "While script exists the prompt will wait..."
while [[ -e $destination/index.php ]]; do
	echo -n "."
	sleep 2;
done
echo "Script must've gone away"