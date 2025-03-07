/* Lif to Tiff series
 * v0.3
*
* Read Lif files from input folder and save each serie (Position) as tiff file in the output folder (Batch mode)
* 
* This macro should NOT be redistributed without author's permission. 
* Explicit acknowledgement to the ALM facility should be done in case of published articles (approved in C.E. 7/17/2017):     
* 
* "The authors acknowledge the support of i3S Scientific Platform Advanced Light Microscopy, 
* member of the national infrastructure PPBI-Portuguese Platform of BioImaging (supported by POCI-01-0145-FEDER-022122)."
* 
* Date: November/2018
* Author: Mafalda Sousa, mafsousa@ibmc.up.pt 
* Advanced Ligth Microscopy, I3S 
* PPBI-Portuguese Platform of BioImaging
* */
 
#@ File (label = "Select input original images directory", style = "directory") inDir
#@ File (label = "Select uutput directory", style = "directory") outDir
#@ String (label = "File suffix", value = ".lif") ext

setBatchMode(true);
filelist = getFileList(inDir); //load array of all files inside input directory

//for each lif file...
for (f=0; f< filelist.length; f++) {
	run("Bio-Formats Macro Extensions");
	filename = filelist[f];
	Ext.setId(inDir+"/"+filelist[f]);
	Ext.getSeriesCount(seriesCount);

	//for each serie...
	for (i=1; i<= seriesCount; i++) {
	     series_name = "series_" + i;
	     print(series_name);
	
	     // open file, requires LOCI tools (aka Bio-Formats)
	     run("Bio-Formats Importer", "open="+ inDir + File.separator + filename +  " color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT use_virtual_stack " + series_name);
	     title = getTitle();
	     //
	     //Process your file here
	     //
	     //save series file into tif	     
	     saveAs("Tiff", outDir + File.separator + title + ".tiff");
	     run("Close All");
	     
	}
}
setBatchMode(false);
print("-- Done --");
