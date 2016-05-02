function ex_mat = TestImage(Marker, img, in_mat, minDim, minTz, maxTz, delta, photometricInvariance, method, needcompile, verbose)
    
    % adding 2 subdirectories to Matlab PATH
	AddPaths
	
	if (~exist('needcompile','var'))
		needcompile = 0;
	end
    
	if (needcompile == 1)
	    % compiling the relevant Mex-files
		CompileMex;
	end
  
  [ex_mat, ex_mats] = DPE(Marker,img,in_mat,minDim,photometricInvariance,minTz,maxTz,delta,method,verbose);
end

