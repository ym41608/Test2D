function [tarframes, scrframes] = matcher(mkeyFileName, imgFileName, matchings)
  
  % matching
  matcher_mex(['../../' mkeyFileName], imgFileName, matchings);

  % Get the matchings from text file
  vec = importdata(matchings);
  mat = vec2mat(vec(2:end),4);
  tarframes = mat(:,1:2).';
  scrframes = mat(:,3:4).';
  delete(imgFileName);
  delete(matchings);

end