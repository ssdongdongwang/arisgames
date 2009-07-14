
<?


/********PHP CODE START HERE*******/
// PHP MRML Client to the GIFT system written by Nicolas Chabloz
// Copyright (C) 2002 CUI, University of Geneva
// 
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
//  02111-1307  USA
//***************VARIABLES****************
$DOCUMENT_ROOT=$_SERVER['DOCUMENT_ROOT'];
$tmp=explode('/',$phpurl);
$phpname=$tmp[count($tmp)-1];
$phppath=substr($phpurl,0,strlen($phpurl)-strlen($phpname));

// Do you want to allow image upload?  ("yes" or "no")
$allowUpload="no";

//Images Sizes
$ImgHeight=120;
$ImgWidth=120;
//Nb Return Images
$NbReturnImages="10,20,50,100,140";	
//xml version
$xml='<?xml version="1.0" standalone="no" ?>';
//mrml dtd path
$mrmldtd='<!DOCTYPE mrml SYSTEM "http://isrpc85.epfl.ch/Charmer/code/mrml.dtd">';
//path for image upload:
$ImagePath="image/";
//images extension:
$ImagesExtension="gif,jpeg,jpg,tiff,tif,png,pict,pcx,bmp,pgm,ppm";
//***************VARIABLES****************
//global variable
$Depth=0;
$Collection=array();
$NbCollection=-1;
$Algorithm=array();
$NbAlgorithm=-1;
$Property=array();
$NbProperty=-1;
$NbPropertyAlgo=array();
$Parent=array();

if (phpversion()>="4.2.0"){
extract($HTTP_POST_VARS);
extract($HTTP_GET_VARS);
}


//Javascript functions
//to submit the form in case of algorithm change

	echo "
	<A NAME=\"top\"></A>
	<script language=\"JavaScript\">
	<!--	
	function submitTheForm() {
		document.Form.submit()
	}

	//-->
	</script>";



//***********SOCKET FUNCTIONS************
//Open a socket
function connection($server,$port) {
	$socket = fsockopen ($server,$port, &$errno, &$errstr, 30);
	if (!$socket) {die("$errstr ($errno)<br>\n");}
	return $socket;
}

//Make a request to the server and return the answer
function request($socket,$request) {
	fputs ($socket, $request);
	$answer="";
	while (!feof($socket)) {
		$buf = fgets($socket);
		$answer .=$buf;
	}
	return $answer;
}

//***********REQUEST FUNCTIONS************
function MakeRandom() {
	//global variables
	global $xml,$mrmldtd;
	global $Algorithm,$NbAlgorithm;     
	global $AlgorithmId,$CollectionId,$SessionId;
	global $server,$port,$Return;

	//find the Algorithm Type
	for ($i=0;$i<=$NbAlgorithm;$i++){
		if ($Algorithm[$i]["ALGORITHM-ID"]==$AlgorithmId) {$AlgorithmType=$Algorithm[$i]["ALGORITHM-TYPE"];}		
	}

	//The MRML request to fetch a random set of images
	$RandomRequest= $xml . $mrmldtd .
		"<mrml session-id=\"$SessionId\">
		<configure-session  session-id=\"$SessionId\">
                <algorithm  algorithm-id=\"$AlgorithmId\"  algorithm-type=\"$AlgorithmType\"  collection-id=\"$CollectionId\" >
                </algorithm>
		</configure-session>
		<query-step  session-id=\"$SessionId\" result-size=\"$Return\" algorithm-id=\"$AlgorithmId\" collection=\"$CollectionId\"/>
		</mrml>";


	//Make the request
	$socket=connection($server,$port);
	$answer=request($socket,$RandomRequest);
	fclose($socket);

	//Create a xml parser, Parse the answer and free the parser
	$MRML_parser = xml_parser_create();
	xml_set_element_handler($MRML_parser, "MRMLstart", "MRMLend");
	xml_parse($MRML_parser, $answer);
	xml_parser_free($MRML_parser);
}

//make a query 
function MakeQuery() {
	//global variables
	global $HTTP_POST_VARS,$HTTP_POST_FILES;
	global $xml,$mrmldtd,$ImagePath,$phppath;
	global $Algorithm,$NbAlgorithm,$ImgHeight,$ImgWidth;     
	global $AlgorithmId,$CollectionId,$SessionId,$OldCollectionId;
	global $server,$port,$Return,$url,$SERVER_NAME,$DOCUMENT_ROOT;
	global $Property,$NbProperty,$NbPropertyAlgo,$OldAlgorithm;	
	global $imageloc,$imagerel,$nbimage,$QueryImgNb,$QueryImgRelLoc;

	//get the upload file name
	$NameImgUpload=$HTTP_POST_FILES['UserImage']['name'];	

	//if there is a upload file... 		 	
	if ($NameImgUpload!="") {		
		//check if file exist
		if ($HTTP_POST_FILES['UserImage']['tmp_name']=="none") {
		        die("<br><h3>file upload error: $NameImgUpload</h3><br>");
		}
		
		//check file extension
		CheckExtension($NameImgUpload);
		
              	//move the file to $ImagePath directory
        	$temp=explode(".",$NameImgUpload);
        	$desti1=$ImagePath.$NameImgUpload;
        	$desti2 = $ImagePath . $temp[0] . ".jpg";        	
        	if ($desti1==$desti2) {$desti2=$ImagePath . "Thumb_".$temp[0] . ".jpg";}
        	        	        	        	        	
        	if (!move_uploaded_file($HTTP_POST_FILES['UserImage']['tmp_name'],$desti1)) {die ("error in transfert");}
        	
        	//convert image	to jpg with "convert"
		$command=escapeShellCmd("./convert -geometry $ImgWidthx$ImgHeight $desti1 $desti2");		
		system($command);
	}
	
	
	
	//check if the url and his extension is valid.
        if ($url!="") {        	
                if (!@fopen($url,"rb")){
        		die("<br><h3>Bad url: $url</h3><br>");
        	}
        	
        	//check file extension
        	CheckExtension($url);        		
        	
        	//copy image from url
        	$urltmp=explode('/',$url);
        	$urltmp2=explode('.',$urltmp[count($urltmp)-1]);
  		$dest1=$ImagePath."tmp.".$urltmp2[1];
        	$dest2 = $ImagePath . $urltmp2[0] . ".jpg";        	        	        	        	
        	if (!($fp = fopen($url,"r"))) die("Could not open src");         	
		if (!($fp2 = fopen($dest1,"w"))) die("Could not open dest"); 
		while ($contents = fread( $fp,4096)) { 
			fwrite( $fp2, $contents); 
		} 
		fclose($fp); 
		fclose($fp2); 
		
		//convert image	to jpg
		$command=escapeShellCmd("./convert -geometry $ImgWidthx$ImgHeight $dest1 $dest2");		
		system($command);
        }
		
	//find the right algorithm
	for ($i=0;$i<=$NbAlgorithm;$i++){
		if ($Algorithm[$i]["ALGORITHM-ID"]==$AlgorithmId) {
			$AlgorithmType=$Algorithm[$i]["ALGORITHM-TYPE"];
			$algonum=$i;
		}
	}
	
        $nbimage=0;
        $nbrel=0;	        
        $nbthumb=0;
        //find image location,relevance and thumbnail location
	while (list ($key, $val) = each ($HTTP_POST_VARS)) {
		if (is_int(strpos($key,"image_"))){		        
			$imageloc[$nbimage]=$val;
			$nbimage++;
		}	
		if (is_int(strpos($key,"rel_img_"))){		
			$imagerel[$nbrel]=$val;
			$nbrel++;			
		}	
		if (is_int(strpos($key,"thumb_img_"))){		
			$imagethumb[$nbthumb]=$val;
			$nbthumb++;			
		}
				
	}
	
	//find the query image
	$QueryImgNb=0;	 	
	for ($i=0;$i<$nbimage;$i++){
			if ($imagerel[$i]==-1 || $imagerel[$i]==1) {
				$QueryImg[$QueryImgNb]=$imageloc[$i];
				$QueryImgThumb[$QueryImgNb]=$imagethumb[$i];
				$QueryImgRel[$QueryImgNb]=$imagerel[$i];				
				if ($imagerel[$i]==1) {				
				        $QueryImgRelLoc[$QueryImg[$QueryImgNb]]=1;				        				        		
				}
				$QueryImgNb++;				
			}
	}

	//The MRML request
	$QueryRequest= $xml . $mrmldtd .
		"<mrml session-id=\"$SessionId\">
		<configure-session  session-id=\"$SessionId\">		
		<algorithm  algorithm-id=\"$AlgorithmId\"  algorithm-type=\"$AlgorithmType\"  collection-id=\"$CollectionId\" ";
		
		if ($OldAlgorithm==$algonum) {		
			//add the property
			for ($j=0;$j<$NbPropertyAlgo[$algonum];$j++){	
				
				$option="AlgoOption".$j;
				global $$option;

				$option2="NameAlgoOption".$j;
				global $$option2;	
				$sendname="";
				if ($$option!="") {$sendname=$$option2;}				
										
				if ($$option=="yes") {$sendvalue="false";}
				if ($$option=="no") {$sendvalue="true";}
				if ($$option=="value") {
				        $optionb="AlgoOptionb".$j;
				        global $$optionb;
					$sendvalue=$$optionb;
				}		
				if (chop($sendname)!="") $QueryRequest .= $sendname . "=\"".$sendvalue."\" ";
			}
		}
		
		$QueryRequest .= ">
		</algorithm>
		</configure-session>
 	       	<query-step  session-id=\"$SessionId\" result-size=\"$Return\" result-cutoff=\"0.0\" collection=\"$CollectionId\" algorithm-id=\"$AlgorithmId\">
 	       	<mpeg-7-qbe></mpeg-7-qbe>
 	       	<user-relevance-element-list>"; 	       
 	       	//add the image location to the request
 	 	for ($i=0;$i<$nbimage;$i++){
			$QueryRequest .= "\n<user-relevance-element image-location=\"$imageloc[$i]\" thumbnail-location=\"\"  user-relevance=\"$imagerel[$i]\"/>";
		} 	       	
		//ad the image passed by url
		if ($url!="") {
			$QueryRequest .= "\n<user-relevance-element image-location=\"$url\" thumbnail-location=\"\"  user-relevance=\"1\"/>";		
			$QueryImg[$QueryImgNb]=$url;
			$QueryImgThumb[$QueryImgNb]=$phppath.$dest2;
			$QueryImgRel[$QueryImgNb]=1;
			$QueryImgNb++;
		}
		//ad the image passed by file upload
		if ($NameImgUpload!="") {
		        $NameImgUploadLoc= $phppath.$desti1;		
			$QueryRequest .= "\n<user-relevance-element image-location=\"$NameImgUploadLoc\" thumbnail-location=\"\"  user-relevance=\"1\"/>";		
			$QueryImg[$QueryImgNb]=$NameImgUploadLoc;
			$QueryImgThumb[$QueryImgNb]=$phppath.$desti2;
			$QueryImgRel[$QueryImgNb]=1;
			$QueryImgNb++;
		}

 	       	$QueryRequest .= "</user-relevance-element-list></query-step>
		</mrml>";			          				
			
	//Display QueryImg			
	ShowQueryImg($QueryImgNb,$QueryImg,$QueryImgThumb,$QueryImgRel);
	
	echo "<br><center><h2>QueryRequest: $QueryRequest</h2></center><br>";		
		
	echo "<center><h2>Result:</h2></center>";		
	

	//Make the request
	$socket=connection($server,$port);
	$answer=request($socket,$QueryRequest);
	fclose($socket);
	
	//Create a xml parser, Parse the answer and free the parser
	$MRML_parser = xml_parser_create();
	xml_set_element_handler($MRML_parser, "MRMLstart", "MRMLend");
	xml_parse($MRML_parser, $answer);
	xml_parser_free($MRML_parser);		

}

//get info form server
function GetInfo() {
	global $xml,$mrmldtd,$allowUpload;
	global $server,$port,$name;

	//simple mrml request 
	$GetInfo= $xml . $mrmldtd .
		"<mrml session-id=\"dummy_session_identifier\">
		<open-session user-name=\"$name\" session-name=\"charmer_default_session\" />
		<get-collections/><get-algorithms/>
		</mrml>";

	//Make the first request
	$socket=connection($server,$port);
	$answer=request($socket,$GetInfo);
	fclose($socket);						

	//Create a xml parser, Parse the answer and free the parser
	$MRML_parser = xml_parser_create();
	xml_set_element_handler($MRML_parser, "MRMLstart", "MRMLend");	
	xml_parse($MRML_parser, $answer);	
	xml_parser_free($MRML_parser);		
	
      	//show collections, algorithms and ...
        echo "<center><font color=#ff0000 size=+2>Do not save this page (see <a href=http://viper.unige.ch/demo/noSave.html>why</a>)</font></center><br/><br/>  ";
	ShowCollection();
	ShowAlgorithm();
      	ShowNumberReturn();     
      	echo "Algorithm options:<br>";
      	ShowOptionAlgorithm();
        if ($allowUpload == "yes")
         ShowAddImage();
        else 
         echo "<br/><br/><font color=\"#ff0000\">Image uploading feature disabled</font>";
      	ShowButtons();
}

//***********PARSING FUNCTIONS************
function MRMLstart($parser, $name, $attrs) {
      global $Collection,$NbCollection;
      global $Algorithm,$NbAlgorithm;
      global $Property,$NbProperty,$NbPropertyAlgo;
      global $SessionId,$Submit,$Depth,$Parent;

	//parse MRML tag
	switch ($name) { 
		case "ACKNOWLEDGE-SESSION-OP":
			//Get session id
			if ($SessionId=="") {
				$SessionId=$attrs["SESSION-ID"];       
			}
			
			echo "<input type=\"hidden\" name=\"SessionId\" value=\"$SessionId\">";
			break;

		case "COLLECTION":
			//Get Collection
	            	$NbCollection++;
			while (list ($key, $val) = each ($attrs)) {
      	            		$Collection[$NbCollection][$key]=$val;
			} 
			break;

		case "ALGORITHM":
			//Get alorithm
			if ($attrs["ALGORITHM-TYPE"]!="") {
                  		$NbProperty=-1;
                  		$Depth=0;                  		
	      	      		$NbAlgorithm++;
				while (list ($key, $val) = each ($attrs)) { 
	      	            		$Algorithm[$NbAlgorithm][$key]=$val;
				} 
			}
			break;

		case "PROPERTY-SHEET":
				//Get alorithm property
				if ($NbAlgorithm==-1) {$NbAlgorithm=0;}
				$NbProperty++;
				$NbPropertyAlgo[$NbAlgorithm]=$NbProperty;				
				while (list ($key, $val) = each ($attrs)) { 
					$Property[$NbAlgorithm][$NbProperty][$key]=$val;					
				} 
				
				//save Depth and parent from the property
				$Property[$NbAlgorithm][$NbProperty]["DEPTH"]=$Depth;				
				$Property[$NbAlgorithm][$NbProperty]["PARENT"]=$Parent[$Depth];									
				
				//increase Depth
				$Depth++;
				
				$Parent[$Depth]=$NbProperty;
												
			break;

		case "QUERY-RESULT-ELEMENT":
			//get image info
			global $imageloc,$imagerel,$nbimage,$QueryImgRelLoc;			
			$ImgLoc=$attrs["IMAGE-LOCATION"];
			$ImageThumb=$attrs["THUMBNAIL-LOCATION"];
			$Similarity=$attrs["CALCULATED-SIMILARITY"];  
			//echo "ImgLoc: -$ImgLoc- , ImageThumb: -$ImageThumb- <br>";
			if ($Submit=="Random") {ShowImage($ImgLoc,$ImageThumb,$Similarity,0);}
			if ($Submit=="Query" && $QueryImgRelLoc[$ImgLoc]=="") {ShowImage($ImgLoc,$ImageThumb,$Similarity,0);}
			if ($Submit=="Query" && $QueryImgRelLoc[$ImgLoc]!="") {ShowImage($ImgLoc,$ImageThumb,$Similarity,1);}
 
		break;
	}
}

function MRMLend($parser, $name) {
	global $Depth;	
    	switch ($name) { 
		case "PROPERTY-SHEET":		
			//decrease depth
			$Depth--;	
			break;
    }
}

//***********DISPLAY FUNCTIONS************


//show the query images
function ShowQueryImg($QueryImgNb,$QueryImg,$QueryImgThumb,$QueryImgRel) {
	//global variable
	global $SERVER_NAME,$DOCUMENT_ROOT,$ImgWidth,$ImgHeight;
	
	
	$tr=0;		
	if ($QueryImgNb>0) {
		echo "<h2>Query:</h2><table border=1>";		
		for ($i=0;$i<$QueryImgNb;$i++) {			
		
			if ($tr%5==0) {echo "<tr>";}
			
			//get name of the image from his url		
			//and use it for the "alt" tag
			$extmp=explode('/',$QueryImg[$i]);        
        		$alt=$extmp[count($extmp)-1];
			
			//get real path of the image location
			$temp=substr($QueryImgThumb[$i], strlen($SERVER_NAME)+7, strlen($QueryImgThumb[$i]));									
			//get the size of this image
			$size=getimagesize('http://'. $temp);         
			
			//calculate the right proportion for the reduce image  heigh and image width
			if ($size[0]!="") {			
        			if ($size[0]>=$size[1]) {
        				$TmpHeight=@(($size[1]*$ImgWidth)/$size[0]);
        				$TmpWidth=$ImgWidth;		      
        			}
        			else {
        				$TmpWidth=@(($size[0]*$ImgHeight)/$size[1]);
        				$TmpHeight=$ImgHeight;		      
        			}
        		}
        		else {
        			$TmpHeight=$ImgHeight;		      
        			$TmpWidth=$ImgWidth;		
        		}												
			
			//display image and some info
			echo "<td><center><a href=\"$QueryImg[$i]\" target=\"new\"><img src=\"$QueryImgThumb[$i]\" width=\"$TmpWidth\" height=\"$TmpHeight\" alt=\"$alt\"></a>";
			$name="image_".$i;
			echo "<input type=\"hidden\" name=\"$name\" value=\"$QueryImg[$i]\">";
			$name="thumb_img_".$i;
        		echo "<input type=\"hidden\" name=\"$name\" value=\"$QueryImgThumb[$i]\">";    		
			$name="rel_img_".$i;
			echo "<br><select name=\"$name\">";				
				if ($QueryImgRel[$i]==1) {echo "<option value=\"1\">rel</option>";}				
				if ($QueryImgRel[$i]==-1) {echo "<option value=\"-1\">non-rel</option>";}
				echo "<option value=\"0\">neutral</option>";
				if ($QueryImgRel[$i]!=1){echo "<option value=\"1\">rel</option>";}
				if ($QueryImgRel[$i]!=-1){echo "<option value=\"-1\">non-rel</option>";}
			echo "</select></center></td>\n";
			
			$tr++;
			if ($i==$QueryImgNb-1) {$tr=5;}
			if ($tr%5==0) {echo "</tr>";}
			
		}
		echo "</table>";
	}
}

//same function but for result iamge
function ShowImage($ImageLoc,$ImageThumb,$Similarity,$Rel) {
	global $CollectionId,$QueryImgNb,$DOCUMENT_ROOT,$SERVER_NAME;
        global $Return,$ImgWidth,$ImgHeight;                
        static $nbimage=0;
        static $first=true;
        static $tmp=0;        
        
        //get name of the image form his url		
	//and use it for the "alt" tag
        $extmp=explode('/',$ImageLoc);        
        $alt=$extmp[count($extmp)-1];
        
        if ($first) {$tmp=$QueryImgNb;$first=false;}            
        if ($nbimage==0) {echo "<table border=1>";}
        if ($nbimage%5==0) {echo "<tr>";}
        
        //get real path of the image location
        $temp=substr($ImageThumb, strlen($SERVER_NAME)+7, strlen($ImageThumb));
        //get the size of this image
        $size=getImagesize('http://'. $temp);
        if ($size[0]>=$size[1]) {
        	$TmpHeight=@(($size[1]*$ImgWidth)/$size[0]);
        	$TmpWidth=$ImgWidth;		      
        }
        else {
        	$TmpWidth=@(($size[0]*$ImgHeight)/$size[1]);
        	$TmpHeight=$ImgHeight;		      
        }
        //display image and some info        
        echo "<td valign=\"bottom\" width=\"".$ImgWidth."\" height=\"".$ImgHeight."\">";   
        if ($Rel==1) {
        	
                echo "<font color=\"#FF0000\">";
		echo "<center><a href=\"$ImageLoc\" target=\"new\"><img src=\"$ImageThumb\" ";
                if ($size[0]>=$size[1]){ 
                   echo "width=\"$ImgWidth\" "; 
		}else{
                  echo "height=\"$ImgHeight\" "; 
		}
		echo "alt=\"$alt\"></a><br>Similarity: $Similarity<br><center>Query Image</center></font>\n";
		
	}
	else {
		echo "<center><a href=\"$ImageLoc\" target=\"new\"><img src=\"$ImageThumb\" ";
                if ($size[0]>=$size[1]){ 
                   echo "width=\"$ImgWidth\" "; 
		}else{
                  echo "height=\"$ImgHeight\" "; 
		}
		echo "alt=\"$alt\"></a><br>Similarity: $Similarity";
        	$name="image_".$tmp;
        	echo "<input type=\"hidden\" name=\"$name\" value=\"$ImageLoc\">";
        	$name="thumb_img_".$tmp;
        	echo "<input type=\"hidden\" name=\"$name\" value=\"$ImageThumb\">";                	
		$name="rel_img_".$tmp;
		echo "<br><select name=\"$name\">";
		echo "<option value=\"0\">neutral</option>";
		echo "<option value=\"1\">rel</option>";
		echo "<option value=\"-1\">non-rel</option>";
		echo "</select>\n";
		$tmp++;
	}
	echo "<br><a href=\"#top\">top</a></center></td>\n";
	$nbimage++;
	if ($nbimage%5==0) {echo '</tr>';}
	if ($nbimage==$Return) {echo "</table>";}	
}

//show collection
function ShowCollection(){
	global $Collection,$NbCollection,$CollectionId;
	echo "Collection (<a href=\"http://viper.unige.ch/demo/localCollections.html\" target=\"new\">details</a>): ";	

	//get collection name and collection ID
	//and show all collections 
	if ($CollectionId!="") {
	      for ($i=0;$i<=$NbCollection;$i++){
			if ($Collection[$i]["COLLECTION-ID"]==$CollectionId) {
				$CollectionName=$Collection[$i]["COLLECTION-NAME"];								
        			echo "<input type=\"hidden\" name=\"OldCollectionId\" value=\"$CollectionId\">";				
			}
		}
		echo '<select name="CollectionId">';
		echo "<option value=\"$CollectionId\">$CollectionName</option>";
	}
	else {echo '<select name="CollectionId">';}

	for ($i=0;$i<=$NbCollection;$i++){
            $value=$Collection[$i]["COLLECTION-ID"];
            $name=$Collection[$i]["COLLECTION-NAME"];
		if ($CollectionId!=$value) {echo "<option value=\"$value\">$name</option>";}
	}
	echo '</select> ';

}

//Display algorithm
function ShowAlgorithm(){
	global $Algorithm,$NbAlgorithm,$AlgorithmId;
	echo "Algorithm: ";		

	//get algorithm name and algorithm ID
	//and show all algorithms 
	if ($AlgorithmId!="") {		
		for ($i=0;$i<=$NbAlgorithm;$i++){
			if ($Algorithm[$i]["ALGORITHM-ID"]==$AlgorithmId) {
				$AlgorithmName=$Algorithm[$i]["ALGORITHM-NAME"];
				echo "<input type=\"hidden\" name=\"OldAlgorithm\" value=\"$i\">";
			}
		}
		echo '<select name="AlgorithmId" ONCHANGE="submitTheForm()">';
		echo "<option value=\"$AlgorithmId\">$AlgorithmName</option>";
	}
	else {echo '<select name="AlgorithmId" ONCHANGE="submitTheForm()">';}

	for ($i=0;$i<=$NbAlgorithm;$i++){
            $value=$Algorithm[$i]["ALGORITHM-ID"];
            $name=$Algorithm[$i]["ALGORITHM-NAME"];
		if ($AlgorithmId!=$value) {echo "<option value=\"$value\">$name</option>";}
	}
	echo '</select> ';
}


// show property of algorithm
function ShowOptionAlgorithm($Depth=0,$Parent="",$visibility="visible",$IdLayer=0){
	global $Algorithm,$NbAlgorithm,$AlgorithmId;
	global $Property,$NbProperty,$NbPropertyAlgo,$OldAlgorithm;			
	static $Option=0;	

	//get algorithmID	
	if ($AlgorithmId!="") {
	      for ($i=0;$i<=$NbAlgorithm;$i++){
			if ($Algorithm[$i]["ALGORITHM-ID"]==$AlgorithmId) {$algonum=$i;}			
		}		
	}
	else {$algonum=0;}				
							
	$j=0;	
	$InLayer="";
	//for each property of the algorithm
	for ($i=0;$i<=$NbPropertyAlgo[$algonum];$i++){		
		//if depth is the actual Depth and parent are the actual parent 
		//(mean that they are in the same "group")
		if ($Property[$algonum][$i]["DEPTH"]==$Depth && $Property[$algonum][$i]["PARENT"]==$Parent) {
		
			//switch the different type of property
			switch ($Property[$algonum][$i]["PROPERTY-SHEET-TYPE"]) { 
	
				//in case of subset, go to the next depth
				//and set the subset as parent
				case "subset":
					$tempDepth[$j]=$Depth+1;
					$tempParent[$j]=$i;
					$j++;
					$visibility2=$visibility;
					break;
					
				//in case of pannel, go to the next depth	
				//and set the pannel as parent
				case "pannel":
					$tempDepth[$j]=$Depth+1;
					$tempParent[$j]=$i;
					$j++;
					$visibility2=$visibility;
					break;					
	
				//in case of set-element...
				case "set-element":	
					$option="AlgoOption".$Option;
					global $$option;
					if ($OldAlgorithm!=$algonum) $$option="";
					
					//get property's name
					$name=$Property[$algonum][$i]["CAPTION"];					
					$InLayer.="$name: ";								
					$sendname=$Property[$algonum][$i]["SEND-NAME"];	
					$InLayer.= "<input type=\"hidden\" name=\"NameAlgoOption$Option\" value=\"$sendname\">";
					
							
					//if the property value is yes
					if ($$option=="yes" || ($Property[$algonum][$i]["SEND-VALUE"]=="yes" && $$option=="") ) {
						//save the next depth and set the set-element as parent	
					
						$tempDepth[$j]=$Depth+1;
						$tempParent[$j]=$i;
						$j++;							
				
					
						$visibility2="visible";
						
						//If the property have children 
						//add the option to show/hide children
						if ($Property[$algonum][$i+1]["PARENT"]==$i) {							
							$InLayer.= "<select name=\"AlgoOption$Option\" ONCHANGE=\"submitTheForm()\">";
						}
						//else just display the property
						else {
							$InLayer.= "<select name=\"AlgoOption$Option\">";
						}
						$InLayer.= "<option value=\"yes\">yes</option>";
						$InLayer.= "<option value=\"no\">no</option>";
						$InLayer.='</select> ';
					}
					//if the property value is no
					//make nearly the same as yes 
					else {
						if ($$option=="" || $$option=="no" || ($Property[$algonum][$i]["SEND-VALUE"]=="no"  && $$option=="")) {
							$visibility2="visible";
							
							//If the property have children 
							//add the option to show/hide children
							if ($Property[$algonum][$i+1]["PARENT"]==$i) {							
								$visibility2="hidden";								
								$InLayer.= "<select name=\"AlgoOption$Option\" ONCHANGE=\"submitTheForm()\">";
							}
							//else just display the property
							else {
								$InLayer.= "<select name=\"AlgoOption$Option\">";
							}
							$InLayer.="<option value=\"no\">no</option>";				
							$InLayer.= "<option value=\"yes\">yes</option>";
							$InLayer.= '</select>';				
						}
					}
					
					//go to the next property
					$Option++;
					break;
				
				//in case of numeric property
				case "numeric":
					
					$option="AlgoOption".$Option;
					global $$option;
					
					//get the value
					$InLayer.= "<input type=\"hidden\" name=\"AlgoOption$Option\" value=\"value\">";
					$sendname=$Property[$algonum][$i]["SEND-NAME"];	
					$InLayer.= "<input type=\"hidden\" name=\"NameAlgoOption$Option\" value=\"$sendname\">";
					if ($$option=="" || $OldAlgorithm!=$algonum) {$value=$Property[$algonum][$i]["SEND-VALUE"];}
					else {
						$optionb="AlgoOptionb".$Option;
						global $$optionb;
			        		$value=$$optionb;
					}
					
					//get name, from , to and step				
					$name=$Property[$algonum][$i]["CAPTION"];					
					$InLayer.= "$name: ";						
					$from=$Property[$algonum][$i]["FROM"];
					$to=$Property[$algonum][$i]["TO"];
					$step=$Property[$algonum][$i]["STEP"];			
					
					//display property
					$InLayer.= "<select name=\"AlgoOptionb$Option\">";
					$InLayer.= "<option value=\"$value\">$value</option>";
					for ($k=$from;$k<=$to;$k=$k+$step){
			     			if ($k!=$value) {$InLayer.="<option value=\"$k\">$k</option>";}				
					}
					$InLayer.= "</select> ";
					
					$Option++;
					break;				
			}
		
		}
	}
		
	
	
	//Display property 
	if ($InLayer!="") {
		echo $InLayer."<br>";
		$IdLayer++;
	}	
	
	//make recursion
	for ($i=0;$i<$j;$i++) ShowOptionAlgorithm($tempDepth[$i],$tempParent[$i], $visibility2,$IdLayer);	

}

//display the number of images the script must return
function ShowNumberReturn(){
	global $Return,$NbReturnImages;
	echo "Return ";
	echo "<select name=\"Return\">";
	if ($Return!="") {echo "<option value=\"$Return\">$Return</option>";}
			
	$NbReturn=explode(",",$NbReturnImages);	
	
        for ($i=0;$i<count($NbReturn);$i++) {
        	if ($Return!=$NbReturn[$i]) {echo "<option value=\"$NbReturn[$i]\">$NbReturn[$i]</option>";}
        	}	
        	
	echo "</select> images<br><br>";
}

//diplay two text input for file upload and url image
function ShowAddImage() {	
	echo "<br>Url of a relevant image:";
	echo "<input type=\"text\" name=\"url\" maxlength=\"200\">";
	echo '<br>Other relevant image: <INPUT NAME="UserImage" TYPE="file">';
}


//show tree buttons: Random, Query and Clear
function ShowButtons() {	
global $server,$port,$name;
	echo '  <br><br><table width="50%" border="0">
      		<tr>
        	<td> 
        	<div align="center">
        	<input type="submit" name="Submit" value="Random">
        	<br>
        	(fetch a random set of images)</div>
        	</td>
        	<td> 
        	<div align="center">
        	<input type="submit" name="Submit" value="Query">
        	<br>
        	( launch the query)</div>
        	</td>
        	<td> 
        	<div align="center">
        	<input type="submit" name="Submit" value="Clear">
        	<br>
        	(Clear the query)</div>
        	</td>
      		</tr>
    		</table>
		<br>'; 
	echo "<input type=\"hidden\" name=\"server\" value=\"$server\">";
	echo "<input type=\"hidden\" name=\"port\" value=\"$port\">";
	echo "<input type=\"hidden\" name=\"name\" value=\"$name\">";
}


//asking for server and port
function AskConnection () {
	echo '<font size="+1"><b>Connection with a GIFT server<b/></font><br><br>';
	echo '(You may like to start with this <a href="http://viper.unige.ch/tutorial/en/intro.html"><font  color="#ff0000">tutorial</font></a>)<br><br>';
        echo '	<table width="30%" border="0">
      		<tr>	<td width="45%"> 
          		<div align="right">Server Name: </div>
        		</td>
        		<td width="55%"> 
          		<input type="text" name="server" value="viper.unige.ch" maxlength="50">
        		</td>
      		</tr>
      		<tr> 
        		<td width="45%"> 
          		<div align="right">Server Port:</div>
        		</td>
        		<td width="55%"> 
          		<input type="text" name="port" size="5" maxlength="5" value="12790">
        		</td>
      		</tr>
      		<tr> 
        		<td width="45%"> 
          		<div align="right">User Name:</div>
        		</td>
        		<td width="55%"> 
          		<input type="text" name="name" value="anonymous" maxlength="50">
        		</td>
      		</tr>
    		</table>
<center>
By connecting to this service, you implicitly affirm that you have read and accepted our <a href="http://viper.unige.ch/disclaimer/"><font color="#ff0000">disclaimer</font></a>
</center>
    		<br>
    		<input type="submit" name="Submit" value="Accept and Connect"><br><br>';   	
}

//**********Other Function*******************
//create a directory
function CreateDir($dir) {	
	if (!is_dir($dir)){
		$oldumask = umask(0); 
		mkdir ($dir,0777);
		umask($oldumask);
	}
}

//check if is $name have valid image extension
function CheckExtension($name) {
	global $ImagesExtension;
	
	//get image Extension
	$temp=explode(".",$name);
        $n=count($temp);
        $extension=strtolower(trim($temp[$n-1]));
        $type=explode(",",$ImagesExtension);
        
        //check if it's a valid one
        $valid=false;
        for ($i=0;$i<count($type);$i++) {
        	if ($extension==$type[$i]) {$valid=true;}
        }
        if (!$valid) {
        	die("<br><h3>error: $name<br>bad extension: $extension<br>this script supports: $ImagesExtension</h3><br>");
        }        	
}

//******************MAIN*******************
//Form
echo "<form method=\"post\" action=\"$phppath".$phpname."\" name=\"Form\" ENCTYPE=\"multipart/form-data\" >";

//in case of algorithm change, make the same request as before
echo "<input type=\"hidden\" name=\"OldSubmit\" value=\"$Submit\">";	
if ($AlgorithmId!="" && $Submit=="") {
	$Submit=$OldSubmit;
	echo "<input type=\"hidden\" name=\"OldSubmit\" value=\"$Submit\">";
}



//create a directory
CreateDir($ImagePath);

switch ($Submit) { 
	case  "": 
		AskConnection();
		break;		
	case "Accept and Connect":
	        GetInfo();	        
		break;
	case "Clear":
	        GetInfo();	       
		break;		
	case "Random":
	        GetInfo();		        
		MakeRandom();
		break;
	case "Query":	        
	        GetInfo();		
	        MakeQuery();
		break;
}
			
echo '</form>
      </center>';		
/******************END OF PHP******************/
?>
