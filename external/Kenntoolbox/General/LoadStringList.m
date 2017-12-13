function StringList = LoadStringList(FileName)
% StringList = LoadStringList(FileName)
%
% This function takes a text file and returns a
% cellular array of strings, each of which corresponds
% to a line in the file.
%
% NB lines beginning with % are ignored

StringList = cell(1);
fp = fopen(FileName);
i=1;
while ~feof(fp)
	Line = fgetl(fp);
	if (Line(1) ~= '%')
		StringList{i} = Line;
		i = i+1;
	end;
end;
fclose(fp);