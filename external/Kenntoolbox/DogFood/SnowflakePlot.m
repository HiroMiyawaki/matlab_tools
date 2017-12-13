function out = SnowflakePlot(v)
% SnowDat = SnowflakePlot(v)
%
% plots a tri-variate data set, discarding the overall mean
% in a symmetrical way. v should be a nx3 matrix.
% 
% optional output returns 2d transformed data.

SnowMat = [-1/sqrt(3) -1 ; -1/sqrt(3) 1; 2/sqrt(3) 0];

h = ishold;

SnowDat = v*SnowMat;
plot(SnowDat(:,1), SnowDat(:,2), '.');

hold on

xl = xlim;
yl = ylim;
m = max(abs(SnowDat(:)));


plot([0 0], [0 m], 'r'); 
text(m*.05,m*.95,'v2-v1','color','r')

plot([0 m], [0 -m/sqrt(3)], 'r');
text(m*.75,-m/sqrt(3),'v3-v2','color','r')

plot([0 -m], [0 -m/sqrt(3)], 'r');
text(-m*.9,-m/sqrt(3),'v1-v3','color','r')

plot([-m m], [0 0], 'k:');
plot([-m/sqrt(3) m/sqrt(3)], [-m m], 'k:');
plot([-m/sqrt(3) m/sqrt(3)], [m -m], 'k:');

if (h==0), hold off; end;

if nargout>=1, out = SnowDat; end
