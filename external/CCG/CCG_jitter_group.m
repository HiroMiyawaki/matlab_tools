%
%
%
function [ExcPairs,InhPairs,GapPairs] = CCG_jitter_group(spiket,spikeind,Cells,SampleRate,jscale,njitter,alpha)
tic;
nCells = length(Cells);

InhPairs = [];
ExcPairs = [];
GapPairs = [];

one_ms = SampleRate/1000;
BinSize = one_ms;
HalfBins = 25;

tR = -HalfBins:HalfBins;
        
plot_output = 0;

% ii=0;jj=0;kk=0;
    fprintf(['Evaluating ' num2str(nCells) ' cellpairs ... '])
for cell_i=1:nCells-1;
%     disp(['evaluating all pairs for cell #' num2str(cell_i) '/' num2str(nCells) ' ...'])
    for cell_j=cell_i+1:nCells;
        clu1=Cells(cell_i);
        clu2=Cells(cell_j);
%         [GSPE,GSPI]=CCG_jitter(spiket,spikeind,clu1,clu2,BinSize,HalfBins,jscale,njitter,alpha,plot_output);
        [GSPE,GSPI]=CCG_jitter(spiket(spikeind==clu1),spiket(spikeind==clu2),SampleRate,BinSize,HalfBins,jscale,njitter,alpha,plot_output);
%         Ran1 = struct('Type','jitter','nRand',njitter,'Tau',5*one_ms,'Alpha',[5 95]);
%         out = CCGSignif(spiket,spikeind,BinSize,HalfBins,SampleRate,'count',[clu1 clu2],Ran1,0);
%         
%         if plot_output
%             bar(out.tbin,out.CCG,'w')
%             line(out.tbin,out.GlobalPvalMax,'linestyle','--','color','b')
%             line(out.tbin,out.PointBands(:,1),'linestyle','--','color','r')
%             line(out.tbin,out.GlobalBandsMax,'linestyle','--','color','m')
%             line(out.tbin,out.PointBands(:,2),'linestyle','--','color','r')
%             line(out.tbin,out.GlobalBandsMin,'linestyle','--','color','m')
%             axis tight
%         end
        
%         GSPExcG(cell_i,cell_j,:) = GSPE;
%         GSPInhG(cell_i,cell_j,:) = GSPI;

%         MonoWindow1=find((out.tbin>=1)&(out.tbin<=7));     % Mono Window 1ms ~ 7ms
%         MonoWindow2=find((out.tbin>=-7)&(out.tbin<=-1));
        MonoWindow1=find((tR>=1)&(tR<=5));     % Mono Window 1ms ~ 7ms
        MonoWindow2=find((tR>=-5)&(tR<=-1));
        MonoWindow3=find((tR>-1)&(tR<1));

        %%%%%%%%%%% Excitatory
        if     any(GSPE(MonoWindow1)==1)
%         if    any(out.GlobalPvalMax(MonoWindow1)<=.05)
%             ii=ii+1;
%             ExcPairs(ii,1)=Cells(cell_i);
%             ExcPairs(ii,2)=Cells(cell_j);
            ExcPairs = [ExcPairs Cells([cell_i cell_j])];
        elseif any(GSPE(MonoWindow2)==1)
%         elseif any(out.GlobalPvalMax(MonoWindow2)<=.05)
%             ii=ii+1;
%             ExcPairs(ii,1)=Cells(cell_j);
%             ExcPairs(ii,2)=Cells(cell_i);
            ExcPairs = [ExcPairs Cells([cell_j cell_i])];
        elseif any(GSPE(MonoWindow3)==1)
%         elseif any(out.GlobalPvalMax(MonoWindow2)<=.05)
%             kk=kk+1;
%             GapPairs(ii,1)=Cells(cell_i);
%             GapPairs(ii,2)=Cells(cell_j);
            GapPairs = [GapPairs Cells([cell_i cell_j])];
        end
        %%%%%%%%%%% Inhibitory
        if     any(GSPI(MonoWindow1)==1)
%         if any(out.GlobalPvalMin(MonoWindow1)<=.05)
% %             jj=jj+1;
%             InhPairs(jj,1)=Cells(cell_i);
%             InhPairs(jj,2)=Cells(cell_j);
            InhPairs = [InhPairs Cells([cell_i cell_j])];
        elseif any(GSPI(MonoWindow2)==1)
%         elseif any(out.GlobalPvalMin(MonoWindow2)<=.05)
%             jj=jj+1;
%             InhPairs(jj,1)=Cells(cell_j);
%             InhPairs(jj,2)=Cells(cell_i);
            InhPairs = [InhPairs Cells([cell_j cell_i])];
        end
    end
end

endt=toc;