function Result=flipPeriod(Periods,MinFrame,MaxFrame)

    if isempty(Periods)
        Result=[MinFrame,MaxFrame];
        return
    end
        
    stChange=sortrows([[Periods(:,1);Periods(:,2)],[ones(size(Periods(:,1)));zeros(size(Periods(:,1)))]]);

    if(stChange(1,1)>MinFrame)
        stChange=[[MinFrame,1-stChange(1,2)];stChange];
    end
    
    if(stChange(end,1)<MaxFrame)
        stChange=[stChange;[MaxFrame,1-stChange(end,2)]];
    end
    
    if stChange(1,2)==1
         stChange(1,:)=[];
    end

    if stChange(end,2)==0
         stChange(end,:)=[];
    end

   Result=[stChange(stChange(:,2)==0,1),stChange(stChange(:,2)==1,1)];
    
end