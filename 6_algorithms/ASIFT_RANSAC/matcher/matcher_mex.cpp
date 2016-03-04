#include "mex.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <vector>
using namespace std;

#ifdef _OPENMP
#include <omp.h>
#endif

#include "demo_lib_sift.h"
#include "io_png/io_png.h"

#include "library.h"
#include "frot.h"
#include "fproj.h"
#include "compute_asift_keypoints.h"
#include "compute_asift_matches.h"

void matcher(char* mkeyFileName, char* imgFileName, char* matchingFileName) {
  // Read image
  float * iarr2;
  size_t w2, h2;
  if (NULL == (iarr2 = read_png_f32_gray(imgFileName, &w2, &h2))) {
      std::cerr << "Unable to load image file " << imgFileName << std::endl;
      return;
  }
  std::vector<float> ipixels2(iarr2, iarr2 + w2 * h2);
	free(iarr2); /*memcheck*/
	
	float zoom1=0, zoom2=0;	
	int wS2=0, hS2=0;
	vector<float> ipixels2_zoom;	
  ipixels2_zoom.resize(w2*h2);	
	ipixels2_zoom = ipixels2;
  int wS1 = 1600;
  int hS1 = 1600;
	wS2 = w2;
	hS2 = h2;
  zoom1 = 1;
	zoom2 = 1;
  int num_of_tilts1 = 7;
  int num_of_tilts2 = 7;
  int verb = 0;
	// Define the SIFT parameters
	siftPar siftparameters;	
	default_sift_parameters(siftparameters);

	vector< vector< keypointslist > > keys2;
  int num_keys2 = 0;
  time_t tstart, tend;	
	tstart = time(0);

	num_keys2 = compute_asift_keypoints(ipixels2_zoom, wS2, hS2, num_of_tilts2, verb, keys2, siftparameters);
  tend = time(0);
	mexPrintf("  Keypoints computation accomplished in %f seconds.\n", difftime(tend, tstart));
  
  // get first key
  int num_keys1, length1;
  vector< vector< keypointslist > > keys1(0);
  std::ifstream file_key1(mkeyFileName);
  if (file_key1.is_open()) {
    file_key1 >> num_keys1;
    file_key1 >> length1;
    for (int i = 0; i < num_keys1; i++) {
      int t, r;
      file_key1 >> t;
      while(t >= keys1.size())
        keys1.push_back(vector< keypointslist >(0));
      file_key1 >> r;
      while(r >= keys1[t].size())
        keys1[t].push_back(keypointslist());
      
      keypoint newkeypoint;
      file_key1 >> newkeypoint.x;
      file_key1 >> newkeypoint.y;
      file_key1 >> newkeypoint.scale;
      file_key1 >> newkeypoint.angle;
      for (int j = 0; j < length1; j++) {
        int value;
        file_key1 >> value;
        newkeypoint.vec[j] = value;
      }
      keys1[t][r].push_back(newkeypoint);
    }
  }
  else 
	{
		mexPrintf("Unable to open the file keys1.");// << ; 
	}
  file_key1.close();
  
  // Match ASIFT keypoints
	int num_matchings;
	matchingslist matchings;	
	cout << "Matching the keypoints..." << endl;
	tstart = time(0);
	num_matchings = compute_asift_matches(num_of_tilts1, num_of_tilts2, wS1, hS1, wS2, 
										  hS2, verb, keys1, keys2, matchings, siftparameters);
	tend = time(0);
	mexPrintf("  Keypoints matching accomplished in %f seconds\n", difftime(tend, tstart));
  
  // write matche
  std::ofstream file(matchingFileName);
	if (file.is_open())
	{		
		// Write the number of matchings in the first line
		file << num_matchings << std::endl;
		
		matchingslist::iterator ptr = matchings.begin();
		for(int i=0; i < (int) matchings.size(); i++, ptr++)		
		{
			file << zoom1*ptr->first.x << "  " << zoom1*ptr->first.y << "  " <<  zoom2*ptr->second.x << 
			"  " <<  zoom2*ptr->second.y << std::endl;
		}		
	}
	else 
	{
		mexPrintf("Unable to open the file matchings."); 
	}

	file.close();
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  
  char* mkeyFileName = mxArrayToString(prhs[0]);
  char* imgFileName = mxArrayToString(prhs[1]);
  char* matchingFileName = mxArrayToString(prhs[2]);
  matcher(mkeyFileName, imgFileName, matchingFileName);
}