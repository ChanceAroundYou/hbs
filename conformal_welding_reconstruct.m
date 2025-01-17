function bound = conformal_welding_reconstruct(xq, yq)
bound = geodesicwelding(yq, [], yq, xq);
end

