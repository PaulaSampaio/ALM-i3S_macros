//Macro to analise FRET ration on Cassilda Pereira images
//Paula Sampaio
//ALM i3S
//v.6
//2020

run("Misc...", "divive=NaN");
run("Clear Results");

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.


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
	// Leave the print statements until things work, then remove them.
run("Bio-Formats Macro Extensions"); 
run("Bio-Formats Importer", "open=" + input + File.separator + file +" color_mode=Composite view=Hyperstack stack_order=XYCZT");
//Macro to calculate the cleavage eficiency of CCF2-AM

title = getTitle;
run("Duplicate...", "duplicate");
run("Subtract Background...", "rolling=50 sliding stack");
rename("Image");
run("Mean...", "radius=2 stack");
//run("Gaussian Blur...", "sigma=2");
Stack.setChannel(1);
setMinAndMax(0, 1400);
Stack.setChannel(2);
setMinAndMax(0, 1400);
waitForUser("Draw backgroud area by selecting several bkg areas (use Shift key)");
setBatchMode(true);
Stack.setChannel(1);
run("Measure");
List.setMeasurements;
BkgCh1 = List.getValue("Mean");
Stack.setChannel(2);
run("Measure");
List.setMeasurements;
BkgCh2 = List.getValue("Mean");
run("Select None");
run("Split Channels");
Ch1 = "C1-Image";
Ch2 = "C2-Image";
run("Ratio Plus", "image1=" +Ch1+" image2="+Ch2+" background1="+BkgCh1+" clipping_value1=0 background2="+BkgCh2+" clipping_value2=0 multiplication=2");
rename("Ratio");
//Create Mask to remove backgrund
imageCalculator("Average create", Ch1, Ch2);
setAutoThreshold("Mean dark");
run("Create Mask");
run("Options...", "interactions=1 count=2 black do=Erode");
run("Divide...", "value=255.000");
imageCalculator("Divide create 32-bit", "Ratio","mask");
rename(title+"_ratio");
run("Measure"); //Get Mean value of ratio
setBatchMode(false);
//Add Ratio LUT to final image
run("Ratio"); 
setMinAndMax(0, 10);
rimg = getTitle();
saveAs(".tif", output + File.separator + rimg);
close();
close();
	print("Processing: " + input + File.separator + file);
	print("Saving to: " + output + File.separator + rimg);
}
	saveAs("Results", output + File.separator + "results.csv");
waitForUser("End of Job");
