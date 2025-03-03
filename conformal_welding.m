function [x, y] = conformal_welding(bound, circle_point_num, mesh_density)
% INPUT:
% bound: n x 1 complex, ANTI-CLOCKWISE boundary points of given shape
% circle_point_num: int, optional, number of interpolated points when
%                   generate conformal welding
% mesh_density: int, optional, a mesh with `k` verts and `m` faces will be 
%               generated to be used in compute hbs. and `k`, `m` are
%               related to this `mesh_density`, refer to the source code of
%               `Mesh.unit_disk_mesh` for more details
%
% OUTPUT:
% xq: circle_point_num x 1 complex, x of comformal welding after normalized
%     and interpolated
% yq: circle_point_num x 1 complex, y of comformal welding after normalized
%     and interpolated

%%%%%%%%%%%%%%%%%%%% init params
if nargin == 1
    circle_point_num = 1e3;
end

if nargin == 2
    mesh_density = 100;
end
%%%%%%%%%%%%%%%%%%%%
hbs_upper_bound = 0.9999;
circle_interval = (2 / circle_point_num)*pi; 
[face, vert] = Mesh.unit_disk_mesh(mesh_density, circle_interval);
face_center = Mesh.get_face_center(face, vert);
inner_vert_idx = (circle_point_num+1:size(vert,1))';

%%%%%%%%%%%%%%%%%%%% get phi1
[outer_points, ~, outer_params] = Zipper.zipper(bound);
if any(isnan(outer_points))
    error('Failed in getting phi1')
end
    
%%%%%%%%%%%%%%%%%%%% get phi2
[inner_points, ~, ~] = Zipper.zipper(flipud(bound));
if any(isnan(inner_points))
    error('Failed in getting phi2')
end


%%%%%%%%%%%%%%%%%%%% normalize phi1
[x, ~, ~] = Normalization.postnorm_outer(outer_points, outer_params);
x = flipud(x);

%%%%%%%%%%%%%%%%%%%% normalize phi2
[y, ~, ~] = Normalization.postnorm_inner(inner_points);
y = Tools.mobius(y, 0.5*1i, 0);

%[y, ~, ~] = Normalization.postnorm_inner_0to0(inner_points, inner_params);

xqa = (0:circle_interval:2*pi-circle_interval)';
xq = exp(xqa*1i);
xa = angle(x); 
[xua, uidx, ~] = unique(xa);
yu = y(uidx);

x = exp(xqa*1i);
y = interp1([xua-2*pi;xua;xua+2*pi],[yu;yu;yu],xqa,'linear');
y = y/y(1);

%%%%%%%%%%%%%%%%%%% normalize hbs
r = 0;

while 1
xua = mod(xua - r/2, 2*pi);
yq = interp1([xua-2*pi;xua;xua+2*pi],[yu;yu;yu],xqa,'linear');
yq = exp(angle(yq/yq(1))*1i);

he_inner = Poisson.integral(Tools.real2complex(vert(inner_vert_idx,:)), xq, yq);
he = [yq;he_inner];
hbs = bc_metric(face, vert, Tools.complex2real(he), 2);
hbs = Tools.mu_chop(hbs, hbs_upper_bound);

excluded_idx = isnan(hbs)+all(face_center==0,2);

r = angle(sum(hbs(~excluded_idx)));
if abs(r) <= 5e-3
    he_angle = angle(sum(hbs.*Tools.real2complex(face_center)));
    if he_angle < 0 || he_angle == pi
        r = r + 2*pi;
    else
        break
    end
end
end
end
