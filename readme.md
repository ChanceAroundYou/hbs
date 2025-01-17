# Shape Analysis and Reconstruction Toolkit

This MATLAB toolkit provides functions for analyzing and reconstructing shapes using HBS (Hierarchical Basis Splines) and conformal welding techniques.

## Main Components

### HBS Module
- **HBS.m**: Generates HBS representation from input shapes
- **HBS_reconstruct.m**: Reconstructs shapes from HBS representation

### Conformal Welding Module  
- **conformal_welding.m**: Computes conformal welding from input shapes
- **conformal_welding_reconstruct.m**: Reconstructs shapes from conformal welding

## Usage

1. Generate HBS representation:
```matlab
[hbs, he, x, y, face, vert, face_center] = HBS(shape, circle_point_num, mesh_density)
```

2. Reconstruct shape from HBS:
```matlab
[reconstructed_shape, inner, outer, nvert, nface] = HBS_reconstruct(hbs, face, vert, mesh_height, mesh_width, mesh_density)
```

3. Compute conformal welding:
```matlab
[x, y] = conformal_welding(shape, circle_point_num, mesh_density)
```

4. Reconstruct shape from conformal welding:
```matlab
reconstructed_shape = conformal_welding_reconstruct(x, y)
```

## Example

Try `example_HBS.m` and `example_conformal_welding.m`.

## Dependencies

This project requires the following MATLAB toolboxes:
- Image Processing Toolbox
- Curve Fitting Toolbox

All other dependencies are included in the dependencies/ directory.
