function [p,h] = HMslivermanTest(x,nBoot)
    h = HMgetHcrit(x);

    varX=var(x);
    
    p=0;
    for ite=1:nBoot
        y=1/sqrt(1+h^2/varX)*(x + h * normrnd(0,1,size(x)));
        f=ksdensity(y,'bandwidth',h);
        peaks=findpeaks(f);
        p=p+(length(peaks)>1);
    end
    
    p = p/nBoot;
end

%%
function hcrit = HMgetHcrit(x)
    [f,~,hcrit]=ksdensity(x);
    peak=findpeaks(f);
    nPos=max([100,round(sqrt(length(x)))]);
    while length(peak)>1
        hcrit=hcrit*2;
        f=ksdensity(x,'npoints',nPos,'bandwidth',hcrit);
        peak=findpeaks(f);
    end
    nextHcrit=0;

    while abs(hcrit-nextHcrit)>eps
        f=ksdensity(x,'npoints',nPos,'bandwidth',(hcrit+nextHcrit)/2);
        peaks=findpeaks(f);
        if length(peaks)>1
            nextHcrit=(nextHcrit+hcrit)/2;
        else
            hcrit=(nextHcrit+hcrit)/2;
        end
    end
end