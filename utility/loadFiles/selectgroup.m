%function [spikeT,spikeG] = selectgroup(T,G,Gsubset)
%
%Create spike time (spikeT) and spike group (spikeG) series for a subset 
%(Gsubset) of cells out of original spike time (T) and spike group (G) series
 
function [spikeT,spikeG] = selectgroup(T,G,Gsubset)

indxvector=find(ismember(G,Gsubset));
spikeT=T(indxvector(1:end));
spikeG=G(indxvector(1:end));

