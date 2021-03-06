clear all; close all; clc;

% compile
compile = 1;

% method
method = 'IPPE'; %'OPnP'

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

if compile
  cd '6_algorithms/DPE';
  CompileMex;
  cd '../..';
end

for ci = 1:6 % fm latter
  if ci < 5
    si = 1:5;
  else
    si = 1;
  end
  for sii = si
    for mi = 2:6
      str = [];
      if ci < 5
        str = [m(mi, :) '_' c(ci, :) '_' int2str(s(sii))];
      else
        str = [m(mi, :) '_' c(ci, :)];
      end
      marker = imresize(im2double(imread(['5_markers/' m(mi, :) '.png'])), 0.25);
      video_obj = VideoReader(['1_videos/' str '.mp4']);
      idx = importdata(['3_index/' str '.txt']);
      ex_mat_ini = importdata(['7_result/APEmatlab/' str '.txt']);
      txt = fopen(['7_result/Refine' method '/' str '.txt'], 'w');
      for i = 1:length(idx)
        fprintf([str '  %d frame\n'], idx(i));
        img = im2double(read(video_obj, idx(i)));
        cd '6_algorithms/DPE';
        [ex_mat ex_mats] = TestImage_Refine(reshape(ex_mat_ini(i,:), [3 4]), marker, img, in_mat, 0.25 * (3300/12350), 0.35, 1.4, 0.01, 1, method, 0);
        cd '../..';
        fprintf(txt,'%f %f %f %f %f %f %f %f %f %f %f %f\n', ex_mat(:).');
        ex_mat_one = ex_mats(:,:,1);
        fprintf(txt,'%f %f %f %f %f %f %f %f %f %f %f %f\n', ex_mat_one(:).');
      end
      fclose(txt);
    end
  end
end