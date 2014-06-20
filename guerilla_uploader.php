<?php
ini_set('upload_max_filesize','10737418240'); //full byte length
ini_set('memory_limit','10737418240');
ini_set('max_file_uploads','25');
ini_set('post_max_size','10737418240');
ini_set('max_execution_time','3600');



function incrementFileName($filename){
	$file_ext = '.'.end(explode(".", $filename));
	$root_name = str_replace(($file_ext),"",$filename);
	$file = $target_path.$filename;
	$i = 1;
	while(file_exists($file)){
		$file = $target_path.$root_name." ($i)".$file_ext;
		$i++;
	}
	return $file;
	echo $file;
}

//self delete
function seppuku(){
	echo "with honor!";
	unlink(__FILE__);
}

$target_path = "files/";

for ($i = 0; $i <count($_FILES['uploadedfile']['name']); $i++) {
	// print_r($_FILES['uploadedfile']['name'][$i].'<br>');
	$file_base = basename($_FILES['uploadedfile']['name'][$i]);
	$target_file = $target_path . $file_base; 

	if (file_exists($target_file)){
		echo $target_file." exists!";
		$target_file = incrementFileName($target_file);
	}

	if(move_uploaded_file($_FILES['uploadedfile']['tmp_name'][$i], $target_file)) {
	    echo "The file ".  $target_file.   " has been uploaded<br>";
	} else{
		echo $i;
		echo $_FILES['uploadedfile']['name'][$i];
	    echo "There was an error uploading the file, please try again!";
	}


}

seppuku();
?>