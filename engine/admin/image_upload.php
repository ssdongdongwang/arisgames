<?php 

require_once('../common.php');
page_header();

$path = $IMAGE_DIR;

if (isset($HTTP_POST_FILES['userfile'])) {
	if (is_uploaded_file($HTTP_POST_FILES['userfile']['tmp_name'])) { 
		

		if (file_exists($path . $HTTP_POST_FILES['userfile']['name'])) { echo "The file already exists<br>"; exit; } 

		$res = copy($HTTP_POST_FILES['userfile']['tmp_name'], $path . $HTTP_POST_FILES['userfile']['name']); 

		if (!$res) { echo "upload failed!<br>n"; exit; } else { echo "upload sucessful<br>"; } 

		echo "File Directory: ".$path."<br>";
		echo "File Name: ".$HTTP_POST_FILES['userfile']['name']."<br>"; 
		echo "File Size: ".$HTTP_POST_FILES['userfile']['size']." bytes<br>";
		echo "File Type: ".$HTTP_POST_FILES['userfile']['type']."<br>"; 

	} 
	 

	 

$new_file = $HTTP_POST_FILES['userfile']['name']; 
}


echo'<h1>ARIS Media List</h1>';
//using the opendir function
$dir_handle = @opendir($path) or die("Unable to open $path");
echo "Directory Listing of $path<br/>";
//running the while loop

while ($file = readdir($dir_handle)) 
{
   if($file!="." && $file!="..")
      echo "<a href='$WWW_ROOT/media/$file'>$file</a><br/>";
}
//closing the directory
closedir($dir_handle);


echo('<h1>Upload New Media</h1>
	<p>Once uploaded, this file can be used in any area that requires and image or other media</p> 
<FORM ENCTYPE="multipart/form-data" ACTION="' . $PHP_SELF . '" METHOD="POST"> 
<INPUT TYPE="file" NAME="userfile"> 
<INPUT TYPE="submit" VALUE="Upload"> 
</FORM>'); 



?>