function colMap = rbMap(nCol)

if ~exist('nCol','var')
    nCol=256;
end

if mod(nCol,2)==0
    nHalf=nCol/2;
    colMap=repmat(([linspace(0,1,nHalf),linspace(1,0,nHalf)])',1,3);
else
    nHalf=(nCol-1)/2;
    colMap=repmat(([linspace(0,1,nHalf+1),linspace(1,0,nHalf+1)])',1,3);
    colMap(nHalf+1,:)=[];
end
    
colMap(1:nHalf,3)=1;
colMap(end-nHalf+1:end,1)=1;



