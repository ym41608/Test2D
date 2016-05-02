function [ex_mat ex_mats] = TestImage_Refine(ex_mat_ini, M, I, in_mat, minDim, minTz, maxTz, delta, photometricInvariance, method, verbose)
    
    % adding 2 subdirectories to Matlab PATH
	AddPaths
  
  % preCalculation
	[marker, img, bounds, steps, dim] = preCal(in_mat, M, I, minDim, minTz, maxTz, delta, verbose);
  
  % refine
  [ex_mat ex_mats] = Refine(M, I, in_mat, ex_mat_ini, minDim, delta, bounds, steps, dim, photometricInvariance, method, verbose);
  
end

