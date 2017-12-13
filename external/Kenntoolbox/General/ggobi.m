% [colors glyphs] = ggobi(data, colors, glyphs, labels)
%
% initiates an ggobi process from the array data
% colors is an optional array of colors.
% The entries of colors should be numbers in the
% range 1 to 10, which are then translated to the
% color names used by xgobi.
%
% glyphs is an optional array of glyph numbers -
% to find out what number means what glyph look at
% the 'Glyph' menu on the 'Brush' screen of ggobi.
% "Points" is 31.
%
% Any Infs or NaNs will cause removal of that data line
%
% labels gives labels for the _points_.  This should be a
% cell array or character array.
%
% to get labels for columns, pass a structure array as data
% -then you get the structure fields as labels
%
% optional output arguments give final brushing - also not yet
% implemented.

function ggobi(data, colors, glyphs, labels)

% generate file name
FileBase = tempname;

% is data a structure array?
if isstruct(data)
	FieldNames = fieldnames(data);
	for i=1:length(FieldNames)	
		d = getfield(data, FieldNames{i});
		d2(:,i) = d(:);
%		d2(:,i) = eval(['[data.' FieldNames{i} ']'])';
	end
	data = d2;
	
	fp = fopen([FileBase '.col'], 'w');
	fprintf(fp, '%s\n', FieldNames{:});
	fclose(fp);
end

% Look for missing data
% delete rows with NaNs or infs, but remember original row number
Infinities = ~isfinite(data);
OriginalRow = 1:size(data,1);
if (any(Infinities(:)))
	% find rows with infinities 
	InfinityRows = find(any(Infinities,2));
	% delete those rows
	data(InfinityRows, :) = [];	
	OriginalRow(InfinityRows) = [];
	if exist('colors'), if length(colors)>1, colors(InfinityRows) = []; end; end;
	if exist('glyphs'), if length(glyphs)>1, glyphs(InifinityRows) = []; end; end;
	if exist('labels'), if length(labels)>1, labels(InifinityRows) = []; end; end;
	disp([num2str(length(InfinityRows)), ' rows containing infinities were deleted.']);
end;

nPoints = size(data,1);



if nargin>=2 & ~isempty(colors);
	% make color file
	
	if (length(colors)==1)
		colors = repmat(colors, nPoints, 1);
	elseif (length(colors) ~= nPoints)
		error('Number of colors should be same as number of points');
	end;
	
	
%	colors = colors(:);
%	ColorIndex = 1+colors-min(colors);
    [ColName, uCol, ColorIndex] = unique(colors);
	% print out color map
    if 0
	for i=1:length(ColName)
        if isnumeric(ColName(i))
    		fprintf('Color %d -> %s\n', ColName(i), ColorNames(i,:));
        else
    		fprintf('Color %s -> %s\n', ColName(i), ColorNames(i,:));
        end
	end
end
	
	%strmat = ColorNames(ColorIndex,:);
	
	fp = fopen([FileBase, '.colors'], 'w');
		
	fprintf(fp,'%d\n',1+mod(ColorIndex*2,7));
	
	fclose(fp);
	

end;

if nargin >=3 & ~isempty(glyphs)
	% make glyphs file
	if length(glyphs) == 1
		glyphs = repmat(glyphs, nPoints, 1);
	end;
	
	if length(glyphs) ~= nPoints
		error('number of glyphs should be same as number of points or 1');
	end;
	fp = fopen([FileBase, '.glyphs'], 'w');
	fprintf(fp, '%d\n', glyphs);
	fclose(fp);
end;

% row labels
fp = fopen([FileBase, '.row'], 'w');
if (nargin >=4 & ~isempty(labels))
    labmat = strvcat(labels);
    labmat = [labmat, repmat(10,size(labmat,1),1)];
    fprintf(fp, '%s', labmat');
else
	fprintf(fp, '%d\n', OriginalRow);
end
fclose(fp);

msave([FileBase, '.dat'], data);

% now run xgobi and clean up any old files...
eval(['! ~/bin/ggobi ', FileBase, '&'])
%pause(0.1);
%eval(['! rm ', FileBase, '.*']);
