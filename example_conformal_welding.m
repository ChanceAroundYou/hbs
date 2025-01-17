addpath('./dependencies');
addpath('./dependencies/im2mesh');
addpath('./dependencies/mfile');
close all;
clear;

fname = 'img/fish3.jpg';
im = Mesh.imread(fname);
Plot.imshow(im);

% size of image
[height, width] = size(im);

%%%%%%% IMPORTANT SETTING %%%%%%%
boundary_point_num = 200;
circle_point_num = 1000;
% the size of unit disk
% e.g. it means the radius is 50 pixels now.
unit_disk_radius = 200;

%%%%%%% IMPORTANT SETTING %%%%%%%

%% Compute conformal welding.
density = unit_disk_radius;
bound = Mesh.get_bound(im, boundary_point_num);
[xq, yq] = conformal_welding(bound, circle_point_num, density);
Plot.welding_filled(xq, yq);

%% Reconstruct shape from conformal welding
reconstructed_bound = conformal_welding_reconstruct(xq, yq);
Plot.scatter(reconstructed_bound);

