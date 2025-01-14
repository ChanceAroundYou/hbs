addpath('./dependencies');
addpath('./dependencies/im2mesh');
addpath('./dependencies/mfile');
% addpath('./dependencies/aco-v1.1/aco');
close all;
clear all;

fname = 'img/4.jpg';
disp(fname);
im = Mesh.imread(fname);
Plot.imshow(im);

% size of image
[height, width] = size(im);
boundary_point_num = 200;
circle_point_num = 1000;


%%%%%%% IMPORTANT SETTING %%%%%%%
% the size of unit disk
% e.g. it means the radius is 50 pixels now.
unit_disk_radius = 200;

% the center of unit disk 
% e.g. it means the center is (100, 100) now.
% unit_disk_center_x = 100;
% unit_disk_center_y = 100;

%%%% the following method could fix 
%%%% the disk center into the middel of image.
unit_disk_center_x = height/2;
unit_disk_center_y = width/2;
%%%%%%% IMPORTANT SETTING %%%%%%%

%% Compute raw HBS, now it is only defined on unit disk.
density = unit_disk_radius;
bound = Mesh.get_bound(im, boundary_point_num);
[hbs, he, xq, yq, disk_face, disk_vert, face_center] = HBS(bound, circle_point_num, density);
Plot.plot_mu(hbs, disk_face, disk_vert);
Plot.welding_filled(flipud(xq), 1./circshift(yq, 485))

% %% Extend HBS from unit disk to rectangle.
% [extend_face, extend_vert] = Mesh.rect_mesh_from_disk(disk_face, disk_vert, height,width, density, unit_disk_center_x, unit_disk_center_y);
% extend_vert = extend_vert * density + [unit_disk_center_x, unit_disk_center_y];
% extend_hbs = zeros(size(extend_face,1),1);
% extend_hbs(1:size(disk_face,1)) = hbs;
% Plot.plot_mu(extend_hbs, extend_face, extend_vert)
% 
% %% Interplate HBS so that it has the same number of points as image.
% extend_op = Mesh.mesh_operator(extend_face, extend_vert);
% hbs_v = extend_op.f2v * extend_hbs;
% [face, vert] = Mesh.rect_mesh(height, width, 0);
% interp_map = scatteredInterpolant(extend_vert, hbs_v);
% hbs_interp_v = interp_map(vert);   
% Plot.plot_map(hbs_interp_v, vert);

% OUTPUT:
%   hbs_interp_v: m x 1 complex, m == height * width
%   vert: m x 2 real, corresponding vert coordinate in form of (x, y)

%% (Optial, pull back HBS into each face)
% op = Mesh.mesh_operator(face, vert);
% hbs_interp_f = op.v2f * hbs_interp_v;
% Plot.plot_mu(hbs_interp_f, face, vert);