%function out = CellType(FileBase, ElLoc)
function out = CellType(FileBase, varargin)
[ElLoc] = DefaultArgs(varargin,{'c'});
Par = LoadPar([FileBase '.xml']);
if isstr(ElLoc)
    Els = find(strcmp(Par.ElecLoc,ElLoc));
else
    %error('ElLoc has to be string');
    Els =ElLoc;
    ElNum = num2str(ElLoc(:));
    ElLoc = reshape([ElNum repmat('_',length(Els),1)]',1,[]);
    ElLoc(end)='';
end

%load cell localization info, also it's a list of cells
%CluLoc = load([FileBase '.cluloc']);
CluLoc = ClusterLocation([FileBase]);
CluLoc = CluLoc(ismember(CluLoc(:,1),Els),:);
    
n = size(CluLoc,1);

%load type info
typeFn = [FileBase '.type-' ElLoc];
[el clu spkwdths ie] = textread(typeFn,'%d %d %s %d');

%load mono info
if ~FileExists([FileBase '.mono-' ElLoc])
    error('File %s doesnot exist\n',[FileBase '.mono-' ElLoc]);
else
    load([FileBase '.mono-' ElLoc],'-MAT'); 
end
%setdiff(CluLoc(:,1:2),[el clu],'rows')

wTypeS = {'n','x','w'};
wTypeN = [-1 0 1];

for ii=1:n %index over all cells in ElLoc from CluLoc
    typeind = find(el==CluLoc(ii,1) & clu==CluLoc(ii,2));
    out(ii).FileBase = FileBase;
    out(ii).El=CluLoc(ii,1);
    out(ii).Clu=CluLoc(ii,2);
    out(ii).CluLoc = CluLoc(ii,3);
    out(ii).MonoPreType=0;
    out(ii).MonoPostType=0;
    if isempty(typeind)
        warning('No entry in %s for El=%d, Clu=%d\n',typeFn,CluLoc(ii,1),CluLoc(ii,2));
        out(ii).WidthType=0;
        out(ii).IE = 0;
    else
        out(ii).WidthType = wTypeN(strcmp(wTypeS,spkwdths{typeind}));
        out(ii).IE = ie(typeind);
        monoindPre = find(mono.From.ElClu(:,1)==CluLoc(ii,1) & mono.From.ElClu(:,2)==CluLoc(ii,2));
        monoindPost = find(mono.To.ElClu(:,1)==CluLoc(ii,1) & mono.To.ElClu(:,2)==CluLoc(ii,2));
        if ~isempty(monoindPre)
            if length(monoindPre)>1
                if length(unique(mono.From.Type(monoindPre)))>1
                   fprintf('problem with MonoTypePre for cell %d-%d in File %s\n',CluLoc(ii,1),CluLoc(ii,2),FileBase);
                   display(mono.From.Type(monoindPre))
                   warning('problem with MonoTypePre');
                end
            end
            out(ii).MonoPreType = mono.From.Type(monoindPre(1));
        end
        if ~isempty(monoindPost)
            if length(monoindPost)>1 & length(unique(mono.From.Type(monoindPost)))>1
                    fprintf('Heterogeneours MonoTypePost for cell %d-%d in File %s\n',CluLoc(ii,1),CluLoc(ii,2),FileBase);
                    display(mono.From.Type(monoindPost))
                 out(ii).MonoPostType = 2;
            else
                 out(ii).MonoPostType = mono.From.Type(monoindPost(1));
            end
        end
    end
end

out = CatStruct(out);