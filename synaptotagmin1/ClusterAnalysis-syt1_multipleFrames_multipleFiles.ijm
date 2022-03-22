/// MAKE SURE TO CHANGE THIS SETTING FIRST:
/// OPTIONS > CONVERSIONS > SCALE WHEN CONVERTING > FALSE

setBatchMode(true);

function leftPad(n, width) {
	s =""+n;
	while (lengthOf(s)<width)
		s = "0"+s;
	return s;
}

thr_lo = 5  // cluster bin
thr_hi = 65535  // cluster bin
th_cluster_area = 0.015  // cluster area threshold

tol_feat_det = 5;  //peak find - Tolerance parameter for rough feature finding. Lower will find more peaks.

run("Close All");

dir = getDirectory("Select the directory...");
filelist = getFileList(dir);

noFiles = filelist.length;

for (idx = 0; idx < noFiles; idx++) {
	foldername = leftPad(idx+1, 3);
	imgfolder = dir + File.separator + foldername;
	File.makeDirectory(imgfolder);

	print(imgfolder);
	
	// Open image
	path = dir + File.separator + filelist[idx];
	name = File.getName(path);
	run("Bio-Formats", "open=["+path+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	rename("sted");
	run("32-bit");
	run("Properties...", "unit=um pixel_width=0.03 pixel_height=0.03 voxel_depth=0 global");

	// Correction for bleaching
	selectWindow("sted");
	noSlices = nSlices + 1;
	run("Brightness/Contrast...");
	resetMinAndMax();
	//setMinAndMax(0, 100);
	run("8-bit");
	run("Bleach Correction", "correction=[Histogram Matching]");

	// Reset variables
	glob_slide_rsfp = newArray(0);
	glob_pos = newArray(0);
	glob_rsfp_x = newArray(0);
	glob_rsfp_y = newArray(0);
	glob_a_rsfp = newArray(0);
	glob_b_rsfp = newArray(0);
	glob_area_rsfp = newArray(0);
	glob_int_rsfp = newArray(0);
	glob_intRaw_rsfp = newArray(0);
	glob_mean_rsfp = newArray(0);
	glob_puncta_rsfp = newArray(0);
	
	for (ff = 1; ff < noSlices; ff++) {
		
		selectWindow("sted");
		setSlice(ff);
		//print(ff);
		run("Duplicate...", "title=sted_2");
		run("Duplicate...", "title=sted_3");
		run("Duplicate...", "title=sted_filt");
		
		selectWindow("sted_filt");
		// identification of the macro-cluster 
		// Gaussian Blur
		run("Gaussian Blur...", "sigma=1");
		// Threshold
		setAutoThreshold("Default no-reset");
		setThreshold(thr_lo, thr_hi);
		run("Convert to Mask");
		// morphological roi cleaning
		run("Erode");
		run("Dilate");
		run("Duplicate...", "title=sted_filt_save");
		
		selectWindow("sted_filt");
		// Detect clusters
		run("Analyze Particles...", "size="+th_cluster_area+"-Infinity display clear add");
		
		selectWindow("sted_filt_save");
		punctaTiff = "/cluster_bin" +ff+".tif";
		saveAs("Tiff", imgfolder+punctaTiff);
		
		selectWindow("sted_3");
		roiManager("Show All");
		count=roiManager("count");
		array=newArray(count);
		for(i=0; i<count;i++) {
				array[i] = i;
		}
		roiManager("Select", array);
		clusterROI = "/clusters_frame" +ff+".zip";
		if (RoiManager.size > 0) {
			roiManager("save selected", imgfolder+clusterROI);
		}
		
		// Measure and save cluster mean, area...
		run("Set Measurements...", "area mean standard centroid fit integrated redirect=None decimal=3");
		if (RoiManager.size > 0) {
			roiManager("multi-measure measure_all");
			N_clusters = nResults;
			pos = newArray(N_clusters);
			mean_rsfp = newArray(N_clusters);
			area_rsfp = newArray(N_clusters);
			rsfp_x = newArray(N_clusters);
			rsfp_y = newArray(N_clusters);
			int_rsfp = newArray(N_clusters);
			intRaw_rsfp = newArray(N_clusters);
			a_rsfp = newArray(N_clusters);
			b_rsfp = newArray(N_clusters);
			for (i = 0; i < N_clusters; i++) {
				pos[i] = i;
				mean_rsfp[i] = getResult("Mean", i);
				int_rsfp[i] = getResult("IntDen", i);
				intRaw_rsfp[i] = getResult("RawIntDen", i);
				area_rsfp[i] = getResult("Area", i);
				a_rsfp[i] = getResult("Major", i);
				b_rsfp[i] = getResult("Minor", i);
				rsfp_x[i] = getResult("X", i);
				rsfp_y[i] = getResult("Y", i);
				}
			run("Clear Results");
		} else {
			pos = newArray(0);
			mean_rsfp = newArray(0);
			area_rsfp = newArray(0);
			rsfp_x = newArray(0);
			rsfp_y = newArray(0);
			int_rsfp = newArray(0);
			intRaw_rsfp = newArray(0);
			a_rsfp = newArray(0);
			b_rsfp = newArray(0);
			N_clusters = 0;
		}
		
		// Fragmentation/number of puncta
		selectWindow("sted_2");
		run("Gaussian Blur...", "sigma=0.5");
		if (N_clusters > 1) {
			roiManager("Combine"); 
		} else if (N_clusters == 1) {
			roiManager("Select", 0);
		}
		width = getWidth;
		height = getHeight;
		
		getPixelSize(unit, pw, ph, pd);
		run("Clear Results");
		
		run("Find Maxima...", "noise"+tol_feat_det+" output=[Point Selection]");
		
		title = getTitle();
		wid = getWidth();
		hei = getHeight();
		
		// Puncta identification
		getSelectionCoordinates(xCoordinates, yCoordinates);
		for(i=0; i<lengthOf(xCoordinates); i++) {
		setResult("X", i, xCoordinates[i]);
		setResult("Y", i, yCoordinates[i]);
		}
		updateResults();
		punctaName = "/puncta_xy_frame" +ff +".txt";
		saveAs("Results", imgfolder+punctaName);
		
		//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		// Creation of a fake image that has a pixel for each maxima
		newImage("fragments", "8-bit black", width, height, 1);
		makeSelection("point",xCoordinates,yCoordinates);
		run("Draw", "slice");
		run("Divide...", "value=255");
		//measure the number inside each roi
		selectWindow("fragments");
		if (RoiManager.size > 0) {
			roiManager("Show All");
			run("Set Measurements...", "area mean standard centroid fit integrated redirect=None decimal=3");
			roiManager("multi-measure measure_all");
			N_rsfp = nResults;
			puncta_rsfp = newArray(N_rsfp);
			slide_rsfp = newArray(N_rsfp);
			for (i = 0; i < N_rsfp; i++) {
				puncta_rsfp[i] = getResult("IntDen", i);
				slide_rsfp[i] = ff;
			}
		} else {
			puncta_rsfp = newArray(0);
			slide_rsfp = newArray(0);
		}
		
		glob_slide_rsfp = Array.concat(glob_slide_rsfp,slide_rsfp);
		glob_pos = Array.concat(glob_pos,pos);
		glob_rsfp_x = Array.concat(glob_rsfp_x,rsfp_x);
		glob_rsfp_y = Array.concat(glob_rsfp_y,rsfp_y);
		glob_a_rsfp = Array.concat(glob_a_rsfp,a_rsfp);
		glob_b_rsfp = Array.concat(glob_b_rsfp,b_rsfp);
		glob_area_rsfp = Array.concat(glob_area_rsfp,area_rsfp);
		glob_int_rsfp = Array.concat(glob_int_rsfp,int_rsfp);
		glob_intRaw_rsfp = Array.concat(glob_intRaw_rsfp,intRaw_rsfp);
		glob_mean_rsfp = Array.concat(glob_mean_rsfp,mean_rsfp);
		glob_puncta_rsfp = Array.concat(glob_puncta_rsfp,puncta_rsfp);
		
		selectWindow("sted_2");
		punctaTiff = "/puncta_xy_frame" +ff+".tif";
		saveAs("Tiff", imgfolder+punctaTiff);
		
		run("Clear Results");
		close("fragments");
		close("sted_2");
		close("sted_3");
		close("sted_filt");
		if (RoiManager.size > 0) {
			roiManager("Delete");
		}
	}
	run("Close All");
		
	//Table creation
	GlobTable = "GlobalResults";
	Table.create(GlobTable);
	Table.setColumn("time", glob_slide_rsfp, GlobTable);
	Table.setColumn("cluster", glob_pos, GlobTable);
	Table.setColumn("x0", glob_rsfp_x, GlobTable);
	Table.setColumn("y0", glob_rsfp_y, GlobTable);
	Table.setColumn("major", glob_a_rsfp, GlobTable);
	Table.setColumn("minor", glob_b_rsfp, GlobTable);
	Table.setColumn("Area", glob_area_rsfp, GlobTable);
	Table.setColumn("SumIntensity", glob_int_rsfp, GlobTable);
	Table.setColumn("RawIntensity", glob_intRaw_rsfp, GlobTable);
	Table.setColumn("MeanIntensity", glob_mean_rsfp, GlobTable);
	Table.setColumn("NumPuncta", glob_puncta_rsfp, GlobTable);

	saveAs("Results", imgfolder+"/GlobalResult.txt");
	close("GlobalResult.txt");
	
	run("Close All");

	//NumberofRows = Table.size;
	//Table.deleteRows(0, NumberofRows-1);
}

setBatchMode(false);
