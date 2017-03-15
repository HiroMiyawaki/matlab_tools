function addXY2Fet(FileBase,Position,Periods,PosSampleRate,SampleRate,ShankList)

    frame =[];
    
    for n = 1:size(Periods,1)
        temp=Position.t(Position.t>= Periods(n,1) & Position.t<= Periods(n,2));
        temp = (temp-Periods(n,1)+1/PosSampleRate)/1e6*SampleRate;
        if(~isempty(frame))
            temp = temp + frame(end);
        end
        frame = [frame,temp];
    end
    
    X=Position.x*Position.xMax;
    Y=Position.y*Position.yMax;
    for n =1:length(ShankList)
        shank= ShankList(n);
        [Fet, nFeatures]=loadFet([FileBase,'.fet.',num2str(shank)]);
    
    
        estX = round(interp1(frame,X,Fet(:,nFeatures)));
        estY = round(interp1(frame,Y,Fet(:,nFeatures)));
        


        fh = fopen([FileBase,'.fet.',num2str(shank)],'w');
       fprintf(fh,'%d\n', nFeatures+2);
%        fprintf(fh,'%d\n', nFeatures);
        for m=1:size(Fet,1)
         
            if(isnan(estX(m))) estX(m)=0;end
            if(isnan(estY(m))) estY(m)=0;end
            fprintf(fh,'%d ', Fet(m,1:(nFeatures-1)));
%            fprintf(fh,'%d ', Fet(m,1:(nFeatures-3)));
            fprintf(fh,'%d %d ', estX(m),estY(m));
            fprintf(fh,'%d\n', Fet(m,nFeatures));
        end

        fclose(fh);
    end
 
        
end


% Fet = LoadFet(FileName)
%
% A simple matlab function to load a .fet file

function [Fet, nFeatures] = loadFet(FileName,Spikes2Load);

    if nargin<2;Spikes2Load = inf;end

    Fp = fopen(FileName, 'r');

    if Fp==-1
        error(['Could not open file ' FileName]);
    end

    nFeatures = fscanf(Fp, '%d', 1);
    Fet = fscanf(Fp, '%f', [nFeatures, Spikes2Load])';

    fclose(Fp);
end