clear all; close all; clc;

% compile
compile = 1;

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
  cd '6_algorithms/APEmatlab';
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
      fprintf([str '\n']);
      marker = imresize(im2double(imread(['5_markers/' m(mi, :) '.png'])), 0.25);
      video_obj = VideoReader(['1_videos/' str '.mp4']);
      idx = importdata(['3_index/' str '.txt']);
      txt = fopen(['7_result/APEmatlab/' str '.txt'], 'w');
      for i = idx
        img = im2double(read(video_obj, i));
        cd '6_algorithms/APEmatlab';
        ex_mat = TestImage_APE(marker, img, in_mat, 0.25 * (3300/12350), 0.2, 0.8, 0.20, 1, 0, 1);
        cd '../..';
        fprintf(txt,'%f %f %f %f %f %f %f %f %f %f %f %f\n', ex_mat(:).');
      end
      fclose(txt);
    end
  end
end