function Res=SchmittTrigger(Input,Higher,Lower,Init)
% Res = SchmittTrigger(In,Lower,Higher,Init)
% 
%   When the input is higher than a certain chosen threshold, the output is
%   high. When the input is below a different (lower) chosen threshold, the
%   output is low, and when the input is between the two levels, the output
%   retains its value.
%
% Input: input signal (vector)
% HigherThreshold: value of higher threshold
% LowerThreshold: value of lower threshold
% InitialState: value of initial state. 1: high, otherwise: low (default 1)
%
% Res:begeining and ending frames of high state

    if(nargin<4)
        Init=1;
    end

    if size(Input,1)>size(Input,2)
        Input=Input';
    end
    
    if size(Input,1)~=1
        display(' ')
        display('WARNING: Input can not contain multiple line signals');
        return
    end
        
    if(Lower>Higher)
        display(' ')
        display('WARNING: lower thresholed is larger than higher threhold. They were swapped');
        temp=Lower;
        Lower=Higher;
        Higher=temp;
    end

    fBeg=find([0,diff(Input>Higher)]==1);
    fEnd=find([0,diff(Input<Lower)]==1);

    if(Init==1)
        fBeg=[1,fBeg];
    else
        fEnd=[1,fEnd];    
    end
    
    changes=sortrows([fBeg,fEnd;ones(size(fBeg)),zeros(size(fEnd))]',1);
        
    changes([1,diff(changes(:,2)')]==0,:)=[];
    
    
    fBeg=changes(changes(:,2)==1,1);
    fEnd=changes(changes(:,2)==0,1);

    if(~isempty(fBeg))
        if(~isempty(fEnd))
            if(fEnd(end)<fBeg(end))
                fEnd=[fEnd;length(Input)];
            end
        else
                fEnd=[fEnd;length(Input)];
        end
    else
        if(~isempty(fEnd))      
           fBeg=[1;fBeg];
        end
    end
    
    if fEnd(1)<fBeg(1)
        if Init==1
            fBeg=[1;fBeg];
        else
            fEnd=fEnd(2:end);
        end
    end
    
        
    

    
    Res=[fBeg,fEnd];
    

end