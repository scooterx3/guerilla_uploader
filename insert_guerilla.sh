#!/bin/bash

# destination='../g-up/'
secret=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)
working_dir='g-up'
cwd=`pwd`
upload_dir_name='g-up/'
upload_dir_full_path='';
php_script='guerilla.php';
javascript='javascript.js';
css='css.css';
mkdir -p $working_dir 
# mkdir -p $upload_dir_full_path

cat <<"INI" > $working_dir/php.ini 
	post_max_size = 10G;
	max_execution_time = 3600;
	max_input_time = 3600;
	max_file_uploads = 25;
	memory_limit = 256M;
	upload_max_filesize = 10G;
	display_errors = true;"
INI

cat <<HTA > $working_dir/.htaccess
	AddHandler application/x-httpd-php54 .php 
	DirectoryIndex $php_script
HTA

cat <<"JS" > $working_dir/$javascript

	console.log('javascript GO!');

JS

# declare php vars using bash vars
cat <<DECLARE > $working_dir/$php_script 
	<?php 

	\$secret = '$secret'; 
	\$working_dir = '$working_dir';
	// \$cwd = '$cwd';
	\$upload_dir_name = '$upload_dir_name';
	\$upload_dir_full_path = 'upload_dir_full_path';
	\$php_script = '$php_script';
	\$javascript = '$javascript';
	\$css = '$css';

	?>
DECLARE

cat <<"PHP" >> $working_dir/$php_script
	<?php
	error_reporting(-1);
	ini_set("display_errors",1);

	$cwd = getcwd(); //
	// $upload_dir_name = 'g-up/'; //
	$upload_dir_full_path = ''; // Initializing variable to avoid a notice. 

	$delete_whitelist = [$php_script,$javascript,$css,'.htaccess','php.ini','error_log'];
			
	$myvar = strpos($cwd,'public_html');
	// echo substr($cwd,0,$myvar)."g-up/";
	if ($myvar){
		
		$upload_dir_full_path = substr($cwd,0,$myvar).$upload_dir_name;
		
		if (!file_exists($upload_dir_full_path)){
			mkdir($upload_dir_full_path,0755);
		}


	}else{
		$upload_dir_full_path = $cwd.'/../../';
	}


	// echo "<br>Destination: $upload_dir_full_path";

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
		// echo $file;
	}

	//self delete
	function seppuku($working_dir,$delete_whitelist){

		//print_r($delete_whitelist);

		$handle = opendir('.');

		for ($i = 0; $i < count($delete_whitelist); $i++){
			if (file_exists($delete_whitelist[$i])){
				// echo "removing $delete_whitelist[$i]<br>";
				unlink($delete_whitelist[$i]);	
			}
		}
		
		rmdir('../'.$working_dir);
	}

	function goBabyGo($upload_info, $upload_dir_full_path, $working_dir, $delete_whitelist){
		

		for ($i = 0; $i <count($_FILES['uploadedfile']['name']); $i++) {
			$file_name = basename($_FILES['uploadedfile']['name'][$i]);
			// echo "base:".$file_name."<br>"; //testing
			//$target_file = '../'.$upload_dir_full_path.$file_name; 

			$target_file = $upload_dir_full_path.$file_name;

			if (file_exists($target_file)){
				//echo "{file_exists:1,message:'$target_file exists, incrementing file name'}";
				$upload_info -> file_already_exists = 'true';			
				$target_file = incrementFileName($target_file);
			}else{
				$upload_info -> file_already_exists = 'false';
			}

			$upload_info -> file_name = $target_file;

			// echo "target file: ".$target_file;
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
		seppuku($working_dir,$delete_whitelist);
	}


	if (isset($_POST['guerilla_uploader'])){

		if (isset($_POST['password']) && $_POST['password'] == $secret ){

			

			goBabyGo($upload_info,$upload_dir_full_path, $working_dir, $delete_whitelist);

		}else{
			$auth_status -> auth_status = '0';
			$auth_status = json_encode($auth_status);
			echo $auth_status;
			// echo "{password_ok:0,message:'Password no workie'}";
			// seppuku();
		}
	}elseif (isset($_POST['seppuku'])){
		seppuku($working_dir,$delete_whitelist);
	}else{
		?>
			<script src="javascript.js"></script> 
			<form enctype="multipart/form-data" action="<?php echo $php_script; ?>" method="POST">
			<input type="hidden" name="guerilla_uploader" />
			Choose a file to upload: <input name="uploadedfile[]" type="file" multiple='multiple' /><br />
			<input type="text" placeholder="password" name="password" value="" />
			<input type="submit" value="Upload File" />

			</form>
		<?php
	}

	//seppuku($working_dir,$delete_whitelist); //testing


	?>
PHP


echo "ready to upload. Please go to domain.com/$working_dir. Password: '$secret'"

echo "While script exists the prompt will wait..."
while [[ -e $working_dir/$php_script ]]; do
	echo -n "."
	sleep 2;
done
echo "Script must've gone away"