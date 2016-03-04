clear all; close all; clc;
addpath('function');
addpath(genpath('6_algorithms'));

% conditions
c = ['tr'; 'zo'; 'or'; 'ir'; 'fl'; 'ml'; 'fm'];

% speed
s = 1:5;

% marker
m = ['wi'; 'du'; 'ci'; 'be'; 'fi'; 'ma'];

% in_mat
Ih = 540;
Iw = 960;
focal_length = 3067.45 / 4;
in_mat = [focal_length,0,Iw/2+0.5,0;0,focal_length,Ih/2+0.5,0;0,0,1,0;0,0,0,1];

% nm_mat
Tw = 1600;
Th = 1600;
nm_mat = eye(3);
nm_mat(1:2, :) = 0.5 * (3300/12350) * [1/Tw, 0, -1/(2*Tw) - 0.5; 0, -1/Th, 1/(2*Th) + 0.5];

for ci = 1:7
  if ci < 5
    si = 1:5;
  else
    si = 1;
  end
  for sii = si
    for mi = 1:6
      str = [];
      if ci < 5
        str = [m(mi, :) '_' c(ci, :) '_' int2str(s(sii))];
      else
        str = [m(mi, :) '_' c(ci, :)];
      end
      fprintf([str '\n']);
      idx = importdata(['3_index/' str '.txt']);
      txt = fopen(['7_result/OPnP/' str '.txt'], 'w');
      for i = idx
        corres = importdata(['7_result/ASIFT/' str '_' int2str(i) '.txt']);
        P = corres(1:3, :);
        Q = corres(4:5, :);
        [R, t] = OPnP(P, Q);
        if (size(R, 1) ~= 3 || size(R, 2) ~= 3)
          ex_mat = zeros(3, 4);
        else
          ex_mat = [R, t];
        end
        fprintf(txt,'%f %f %f %f %f %f %f %f %f %f %f %f\n', ex_mat(:).');
      end
      fclose(txt);
    end
  end
end