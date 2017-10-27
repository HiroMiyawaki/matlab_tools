clear

mapFileName='~/Desktop/buz32+64sp+16.map'

n=0;

%Buz 32
n=n+1;
probe{n}=[1,8,2,7,3,6,4,5];
probe{n}=[probe{n},probe{n}+8,probe{n}+16,probe{n}+24];
toUse{n}=true(1,32);

omnetics{n}=[18 27 28 29 17 30 31 32  1  2  3 16  4  5  6  15
    20 21 22 23 19 24 25 26  7  8  9 14 10 11 12 13];
preamp{n}=[ 8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
     7  6  5  4  3  2  1  0 31 30 29 28 27 26 25 24]+1;

%Buz 64sp
n=n+1;
probe{n}=[1,10,2,9,3,8,4,7,5,6];
probe{n}=[probe{n},probe{n}+10,probe{n}+20,probe{n}+30,probe{n}+44,probe{n}+54,37,38,39,36];

omnetics{n}=[37 39 40 42 43 45 46 48 17 19 20 22 23 25 26 28
    36 38 35 41 34 44 33 47 18 32 21 31 24 30 27 29
    64 62 60 58 56 54 52 50 15 13 11  9  7  5  3  1
    63 61 59 57 55 53 51 49 16 14 12 10  8  6  4  2];

preamp{n}=[16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46
    17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47
    15 13 11  9  7  5  3  1  63 61 59 57 55 53 51 49
    14 12 10  8  6  4  2  0  62 60 58 56 54 52 50 48]+1;

preamp{n}=rot90(preamp{n},2);
toUse{n}=true(1,64);


%ECG and EMG
n=n+1;
probe{n}=1:16;
omnetics{n}=probe{n};
preamp{n}=probe{n};
toUse{n}=[false(1,3),true,false,true,false(1,10)];

% AUX (x3)
n=n+1;
probe{n}=1:9;
omnetics{n}=probe{n};
preamp{n}=probe{n};
toUse{n}=[true(1,3),false(1,3),true(1,3)];


% ADC
n=n+1;
probe{5}=1:8;
omnetics{n}=probe{n};
preamp{n}=probe{n};
toUse{n}=[true(1,8)];

%---

for n=1:length(omnetics)
    omnetics{n}=reshape(omnetics{n},1,[]);
end
for n=1:length(preamp)
    preamp{n}=reshape(preamp{n},1,[]);
end

order=1:sum(cellfun(@length,probe));

%%
chOnShank=[];
for n=1:length(probe)
    chOnShank=[chOnShank,probe{n}+sum(cellfun(@length,probe(1:n-1)))];
end


chOnConnector=[];
for n=1:length(omnetics)
    chOnConnector=[chOnConnector,omnetics{n}+sum(cellfun(@length,omnetics(1:n-1)))];
end

chOnPreamp=[];
for n=1:length(preamp)
    chOnPreamp=[chOnPreamp,preamp{n}+sum(cellfun(@length,preamp(1:n-1)))];
end

chToUse=[];
for n=1:length(toUse)
    chToUse=[chToUse,toUse{n}];
end

shankMap=sortrows([order;chOnShank]',2)';
for n=1:size(shankMap,2)
    channelMap(n,:)=[chOnPreamp(n),shankMap(1,chOnConnector(n))];
end
channelMap=sortrows(channelMap,2)';



%%

if isempty(mapFileName)
    func=@(x) fprintf(x{:})
else
    fh=fopen(mapFileName,'w')
    func=@(x) fprintf(fh,x{:});
end    

func({'{\r\n'})
func({'    "0": {\r\n'})

func({'      "mapping": [\r\n'})
for n=1:size(channelMap,2)
    func({'        %d',channelMap(1,n)})
    if n<size(channelMap,2)
         func({',\r\n',channelMap(1,n)})
    else
         func({'\r\n',channelMap(1,n)})
    end
end
func({'      ],\r\n'})

func({'      "reference": [\r\n'})
for n=1:size(channelMap,2)
    func({'        -1'})
    if n<size(channelMap,2)
         func({',\r\n',channelMap(1,n)})
    else
         func({'\r\n',channelMap(1,n)})
    end
end 
func({'      ],\r\n'})

func({'      "enabled": [\r\n'})
for n=1:size(channelMap,2)
    if chToUse(n)
        func({'        true'})
    else
        func({'        false'})
    end
    if n<size(channelMap,2)
         func({',\r\n',channelMap(1,n)})
    else
         func({'\r\n',channelMap(1,n)})
    end
end 
func({'      ],\r\n'})
func({'    },\r\n'})

func({'    "refs": {\r\n'})
func({'      "channels": [\r\n'})
func({'        -1,\r\n'})
func({'        -1,\r\n'})
func({'        -1,\r\n'})
func({'        -1\r\n'})
func({'      ]\r\n'})
func({'    },\r\n'})

func({'    "recording": {\r\n'})
func({'      "channels": [\r\n'})
for n=1:size(channelMap,2)
    if chToUse(n)
        func({'        true'})
    else
        func({'        false'})
    end
    if n<size(channelMap,2)
         func({',\r\n',channelMap(1,n)})
    else
         func({'\r\n',channelMap(1,n)})
    end
end 

func({'      ]\r\n'})
func({'    }\r\n'})
func({'  }\r\n'})

if ~isempty(mapFileName)
    fclose(fh);
end





