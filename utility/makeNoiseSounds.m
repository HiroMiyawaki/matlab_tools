
sampleRate=96e3; %in samples/sec
dur=30; %in sec
t=(1:dur*sampleRate)/sampleRate;

for freq=[4,12]
    s=sin(t*freq*1e3*pi*2);


    sound(s,sampleRate); 
    audiowrite(['~/Desktop/' num2str(freq,2) 'kHz.wav'],s,sampleRate,'BitsPerSample',16)
end 
 
typeList={'purpleNoise','blueNoise','whiteNoise','pinkNoise','brownNoise'}
DIM=size(t);
for BETA=-2:0:2;
% Generate the grid of frequencies. u is the set of frequencies along the
% first dimension
% First quadrant are positive frequencies.  Zero frequency is at u(1,1).
u = [(0:floor(DIM(1)/2)) -(ceil(DIM(1)/2)-1:-1:1)]'/DIM(1);
% Reproduce these frequencies along ever row
u = repmat(u,1,DIM(2));
% v is the set of frequencies along the second dimension.  For a square
% region it will be the transpose of u
v = [(0:floor(DIM(2)/2)) -(ceil(DIM(2)/2)-1:-1:1)]/DIM(2);
% Reproduce these frequencies along ever column
v = repmat(v,DIM(1),1);

% Generate the power spectrum
S_f = (u.^2 + v.^2).^(-BETA/2);

% Set any infinities to zero
S_f(S_f==inf) = 0;

% Generate a grid of random phase shifts
phi = rand(DIM);

% Inverse Fourier transform to obtain the the spatial pattern
x = ifft2(S_f.^0.5 .* (cos(2*pi*phi)+i*sin(2*pi*phi)));

% Pick just the real component
x = real(x);
x=x/max(abs(x));

audiowrite(['~/Desktop/' typeList{BETA+3} '.wav'],x,sampleRate,'BitsPerSample',16)

end

%%



sampleRate=96e3; %in samples/sec
dur=30; %in sec
t=(0:dur*sampleRate-1)/sampleRate;

for freq=[2,4,5,10]
    s=sin(t*freq*1e3*pi*2);
    
    mask=zeros(1,sampleRate);
    mask(450*sampleRate/1e3+(1:250*sampleRate/1e3))=1;
    mask=repmat(mask,1,dur);
    s=s.*mask;
    sound(s,sampleRate); 
    audiowrite(['~/Desktop/' num2str(freq,2) 'kHz-pip_250-750.wav'],s,sampleRate,'BitsPerSample',16)
end 


















