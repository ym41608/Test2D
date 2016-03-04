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

void writeDescriptor(char* pngFileName, char* keyFileName) {
  // Read image
  float * iarr1;
  size_t w1, h1;
  if (NULL == (iarr1 = read_png_f32_gray(pngFileName, &w1, &h1))) {
      std::cerr << "Unable to load image file " << pngFileName << std::endl;
      return;
  }
  std::vector<float> ipixels1(iarr1, iarr1 + w1 * h1);
	free(iarr1); /*memcheck*/
	
	float zoom1=0;	
	int wS1=0, hS1=0;
	vector<float> ipixels1_zoom;	
  ipixels1_zoom.resize(w1*h1);	
	ipixels1_zoom = ipixels1;
	wS1 = w1;
	hS1 = h1;
	zoom1 = 1;
  int num_of_tilts1 = 7;
  int verb = 0;
	// Define the SIFT parameters
	siftPar siftparameters;	
	default_sift_parameters(siftparameters);

	vector< vector< keypointslist > > keys1;
  int num_keys1 = 0;
  time_t tstart, tend;	
	tstart = time(0);

	num_keys1 = compute_asift_keypoints(ipixels1_zoom, wS1, hS1, num_of_tilts1, verb, keys1, siftparameters);
  tend = time(0);
	mexPrintf("Keypoints computation accomplished in %f seconds.\n", difftime(tend, tstart));
  
  std::ofstream file_key1(keyFileName);
	if (file_key1.is_open())
	{
		// Follow the same convention of David Lowe: 
		// the first line contains the number of keypoints and the length of the desciptors (128)
		file_key1 << num_keys1 << "  " << VecLength << "  " << std::endl;
		for (int tt = 0; tt < (int) keys1.size(); tt++)
		{
			for (int rr = 0; rr < (int) keys1[tt].size(); rr++)
			{
				keypointslist::iterator ptr = keys1[tt][rr].begin();
				for(int i=0; i < (int) keys1[tt][rr].size(); i++, ptr++)	
				{
          file_key1 << tt << " " << rr << " ";
					file_key1 << zoom1*ptr->x << "  " << zoom1*ptr->y << "  " << zoom1*ptr->scale << "  " << ptr->angle;
					
					for (int ii = 0; ii < (int) VecLength; ii++)
					{
						file_key1 << "  " << ptr->vec[ii];
					}
					
					file_key1 << std::endl;
				}
			}	
		}
	}
	else 
	{
		std::cerr << "Unable to open the file keys1."; 
	}

	file_key1.close();
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  
  char* pngFileName = mxArrayToString(prhs[0]);
  char* keyFileName = mxArrayToString(prhs[1]);
  writeDescriptor(pngFileName, keyFileName);
}