%
%
%
function [ExcPairs,InhPairs] = CCG_jitter_pair(spiket,spikeind,Cells,BinSize,HalfBins,jscale,njitter,alpha)
nCells = length(Cells);

InhPairs = [];
ExcPairs = [];

SampleRate = 32552.1;
one_ms = SampleRate/1000;

plot_output = 0;

ii=0;jj=0;

[GSPE,GSPI]=CCG_jitter(spiket,spikeind,clu1,clu2,BinSize,HalfBins,jscale,njitter,alpha,plot_output);
tR = -HalfBins:HalfBins;

MonoWindow1=find((tR>=1)&(tR<=4));     % Mono Window 1ms ~ 7ms
MonoWindow2=find((tR>=-4)&(tR<=-1));

%%%%%%%%%%% Excitatory
if     any(GSPE(MonoWindow1)==1)
    %         if    any(out.GlobalPvalMax(MonoWindow1)<=.05)
    ii=ii+1;
    ExcPairs(ii,1)=Cells(cell_i);
    ExcPairs(ii,2)=Cells(cell_j);
    %             keyboard
elseif any(GSPE(MonoWindow2)==1)
    %         elseif any(out.GlobalPvalMax(MonoWindow2)<=.05)
    ii=ii+1;
    ExcPairs(ii,1)=Cells(cell_j);
    ExcPairs(ii,2)=Cells(cell_i);
    %             keyboard
end
%%%%%%%%%%% Inhibitory
if     any(GSPI(MonoWindow1)==1)
    %         if any(out.GlobalPvalMin(MonoWindow1)<=.05)
    jj=jj+1;
    InhPairs(jj,1)=Cells(cell_i);
    InhPairs(jj,2)=Cells(cell_j);
elseif any(GSPI(MonoWindow2)==1)
    %         elseif any(out.GlobalPvalMin(MonoWindow2)<=.05)
    jj=jj+1;
    InhPairs(jj,1)=Cells(cell_j);
    InhPairs(jj,2)=Cells(cell_i);
end
