/*
 * Macro to measure Drosophila wings 
 * V1.1
 * Paula Sampaio, ALM, i3S
 * 07 August 2023
 */


/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".jpg") suffix
#@ String (label = "Experiment", value = "") name

//print(input);
// See also Process_Folder.py for a version of this code
// in the Python scripting language.
run("Set Measurements...", "area mean perimeter fit shape feret's display redirect=None decimal=2");

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
roiManager("reset");	
	open(input+"/"+file);
	
	ori=getTitle();
//print(ori);

run("Duplicate...", " ");
run("8-bit");


setTool("rectangle");
waitForUser("Draw a ROI in background");
getRawStatistics(nPixels, mean, min, max, std, histogram);
setBackgroundColor(mean, mean, mean);
run("Select None");


//setBackgroundColor(220, 220, 220);

setTool("polygon");
waitForUser("Trace the areas to remove and click (T) to add to ROI Manager ");

/*
count = roiManager("count");
array = newArray(count);
  for (i=0; i<array.length; i++) {
      array[i] = i;
  }

roiManager("select", array);
roiManager("Combine");
*/

n = roiManager("count");
  for (i=0; i<n; i++) {
	roiManager("Select", i);
	run("Clear", "slice");
  }

run("Select None");
roiManager("reset");
//setTool("rectangle");
setTool("freehand");

//run("Median...", "radius=4");
run("Mean...", "radius=4");
setAutoThreshold("Triangle");
run("Convert to Mask");
run("Options...", "iterations=1 count=4 black do=[Fill Holes]");
run("Options...", "iterations=7 count=1 black do=Erode");

run("Analyze Particles...", "size=40000-Infinity display include add");

selectWindow(ori);
run("Select None");
roiManager("select", 0);


waitForUser; //just to check the quality of ROI
run("Measure");


}

resultsname = name +".csv";

saveAs("Results", output+"/"+resultsname);
close("Results");	
run("Close All");


