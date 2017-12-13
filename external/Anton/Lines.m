%function lHandles  = Lines(x,y,col,style,width)
% plots vertical lines at x coortinated
% from y(1) to y(2) , sets color col
function h = Lines(varargin)
ax = axis;
[x, y,col,style,width] = DefaultArgs(varargin,{[],[], 'k','-',1});
if size(col,1)<size(col,2) 
    col = col';
end
if isempty(y) 
    if isempty(y); y=ax(3:4); end
    nl= length(x);
    x = x(:)'; y =y(:);
    x = repmat(x,2,1);
    y = repmat(y,1,nl);
    h= line(x,y);
elseif isempty(x) 
    if isempty(x) x=ax(1:2); end
    nl= length(y);
    x = x(:); y =y(:)';
    x = repmat(x,1,nl);
    y = repmat(y,2,1);
    h= line(x,y);
end

if isstr(col)
    set(h,'Color',col);
    set(h,'LineStyle',style);
    set(h,'LineWidth',width);
elseif size(col,2)==1
    ColorOrder = get(gca, 'ColorOrder'); 
    col = ColorOrder(col,:);
    for i=1:length(h)
        set(h(i),'Color',col(i,:));
	set(h(i),'LineStyle',style);
    set(h(i),'LineWidth',width);
       % fprintf('%d %d%d%d\n', i, col(i,:));
    end
end

