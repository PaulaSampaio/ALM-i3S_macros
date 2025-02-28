/* Measure Gfp
 * v0.3
*
* Read tiff files and measure the intensity in 2 regions 
* 
* This macro should NOT be redistributed without author's permission. 
* Explicit acknowledgement to the ALM facility should be done in case of published articles (approved in C.E. 7/17/2017):     
* 
* "The authors acknowledge the support of i3S Scientific Platform Advanced Light Microscopy, 
* member of the national infrastructure PPBI-Portuguese Platform of BioImaging (supported by POCI-01-0145-FEDER-022122)."
* 
* Date: December/2019
* Author: Mafalda Sousa, mafsousa@ibmc.up.pt 
* Advanced Ligth Microscopy, I3S 
* PPBI-Portuguese Platform of BioImaging
* */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tiff") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.
run("Close All");
run("Clear Results");
processFolder(input);
selectWindow("Log");

saveAs("Text", output + File.separator + "results.txt");

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
	open(input + File.separator + file);

	//print("Processing: " + input + File.separator + file);
	

	original = getTitle();
	run("Enhance Contrast", "saturated=0.35");
	run("Split Channels");
	selectWindow("C2-" + original);
	waitForUser("Desenha rectangulo no background e ok!");
	run("Set Measurements...", "area mean redirect=None decimal=2");
	run("Measure");
	media = getResult("Mean", 0);
	run("Clear Results");
	selectWindow("C2-" + original);
	run("Subtract...", "value=" + media);
	waitForUser("Desenha rectangulo nas fibras e ok!");
	run("Duplicate...", "title=fibras");
	
	run("Duplicate...", "title=mask");
	run("Enhance Contrast", "saturated=0.35");
	//run("Threshold...");
	setAutoThreshold("Otsu dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Set Measurements...", "area mean redirect=[fibras] decimal=2");
	run("Analyze Particles...", "size=1.00-Infinity show=Masks display");
	if (nResults>1){
		run("Summarize");
		total_mean_1 = getResult("Mean", nResults-4);
		total_std_1 = getResult("Mean", nResults-3);
	}
	else{
		total_mean_1 = getResult("Mean", 0);
		total_std_1 = getResult("StdDev", 0);
	}

	//print("Total average of fibres = ", total_mean, "+/-" , total_std );
	saveAs("Results", output + File.separator + original + "_Results_fibras.csv");
	run("Clear Results");

	waitForUser("Desenha rectangulo no midbrain e ok!");
	run("Duplicate...", "title=midbrain");
	run("Duplicate...", "title=mask");
	run("Enhance Contrast", "saturated=0.35");
	//run("Threshold...");
	setAutoThreshold("Otsu dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Set Measurements...", "area mean redirect=[midbrain] decimal=2");
	run("Analyze Particles...", "size=1.00-Infinity show=Masks display"); 
	if (nResults>1){
		run("Summarize");
		total_mean_2 = getResult("Mean", nResults-4);
		total_std_2 = getResult("Mean", nResults-3);
	}
	else{
		total_mean_2 = getResult("Mean", 0);
		total_std_2 = getResult("StdDev", 0);
	}
	saveAs("Results", output + File.separator + original + "_Results_midbrain.csv");
	print(file,"\t", total_mean_1, "\t" , total_std_1,"\t", total_mean_2, "\t" , total_std_2 );
	run("Close All");
	run("Clear Results");

}
