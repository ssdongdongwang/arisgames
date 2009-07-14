<?php


function display_media($media_path,$width='100%',$height='100%'){
	//find the extension
	$type = substr($media_path, strlen($media_path)-3);

	if ($type == 'jpg' or $type == 'png') echo "<img src = '$GLOBALS[WWW_ROOT]/media/$media_path'/>";
	
	if ($type == 'swf' ) echo "<object classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000'
							codebase'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=4,0,2,0'
							width='100%' height='100%'>
							<param name='movie' value='$GLOBALS[WWW_ROOT]/media/$media_path' />
							<param name='quality' value='high' />
							<embed src='$GLOBALS[WWW_ROOT]/media/$media_path' quality='high'
							type='application/x-shockwave-flash' width='100%' height='100%'></embed>
							</object>";
	


	if ($type=='mp4' or $type== 'mpg' or $type == 'mov') echo "<embed src='$GLOBALS[WWW_ROOT]/media/$media_path' type='video/x-m4v' />";
	if ($type=='m4a') echo "<embed src = '$GLOBALS[WWW_ROOT]/media/$media_path' 
									
									type='audio/x-m4a' />";

}



?>
