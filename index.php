<?php

function incrementFileName($filename){
	$file_ext = '.'.end(explode(".", $filename));
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
	echo "with honor!";
	unlink('php.ini');
	unlink(__FILE__);
}

function goBabyGo(){
	for ($i = 0; $i <count($_FILES['uploadedfile']['name']); $i++) {
		// print_r($_FILES['uploadedfile']['name'][$i].'<br>');
		$file_base = basename($_FILES['uploadedfile']['name'][$i]);
		$target_file = $file_base; 

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
}

if (isset($_POST['guerilla_uploader'])){

goBabyGo();

}else{
	?>
		<form enctype="multipart/form-data" action="index.php" method="POST">
		<input type="hidden" name="guerilla_uploader" />
		Choose a file to upload: <input name="uploadedfile[]" type="file" multiple='multiple' /><br />
		<input type="submit" value="Upload File" />
		</form>
	<?php
}

?>