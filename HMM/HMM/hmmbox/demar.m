% A demonstration of the HMM software using an AR observation
% model on sleep spindle data

load demar

plotseg(Xseries,[],[],40,ns,-5,10);
disp(' ');
disp('Sleep spindle data');
disp('Press a key to continue');
disp(' ');
pause

p=8;

ns = round(ns);
% Set global observation noise level
V=0.1;

% Load Dynamic AR model (assume constant noise level)
disp(' ');
disp('Pass a Kalman filter AR model over the time series');

% Get Dynamic AR model (assume constant noise level)
%disp('Results calculated on the fly');
%kftype='dar';
%[A,ev,error,gain,sigma_obs,sigma_wu,pvol,q,sigma_wu_q0]=dar(Xseries,p,V,0.01);

disp('Results loaded from disk');
disp('Press a key to continue');
pause

disp(' ');
disp('Now train a Gaussian Mixture Model on AR features derived from');
disp('the Kalman filter AR model.');
disp('The resulting GMM will be used to initialise the AR models in an HMM.');
disp('Press a key to continue');
pause

ev_thresh=0.5;
% only some of the data points will be used
sA=A(find(ev>ev_thresh),:);

disp('Please wait ...');
hmm.K=2;
hmm = hmminit(sA,hmm,'full');


for k=1:hmm.K,
  hmm.state(k).p=length(hmm.state(k).Mu);
  hmm.state(k).a=hmm.state(k).Mu';
  hmm.state(k).v=0.1;
end

disp(' ');
disp('Now train the HMM using Baum/Welch');
disp('Press a key to continue');
disp(' ');
pause

hmm.obsmodel='AR';

% Update observation model
hmm.train.obsupdate=ones(1,hmm.K);   

% Update state transition matrix
hmm.train.pupdate=1;   
hmm.P=init_trans(hmm.K,50,ns);

hmm.train.tol=0.01;
hmm.train.init=1;    % Already initialised


T=length(Xseries);
Xseries=Xseries(:);
% Train HMM
hmm=hmmtrain(Xseries,T,hmm);

% Initialise P and Pi to ideal values
%hmm.P=[0.99 0.01 0; 0 0.99 0.01; 0 0 1];
%hmm.Pi=[1 0 0];

%B = obslike (Xseries,T,1,hmm);
%OK these look good
        
[block,LL]=hmmdecode(Xseries,T,hmm);
        

for k=1:hmm.K,
  [p,f] = ar_spec (hmm.state(k).Mu,1,ns);
  subplot(hmm.K,1,k);
  plot(f,p);
end
title('Before');

figure
for k=1:hmm.K,
  [p,f] = ar_spec (hmm.state(k).a,hmm.state(k).v,ns);
  subplot(hmm.K,1,k);
  plot(f,p);
end
title('After');

disp(' ');
disp('These plots show the spectra associated with each state before and after Baum/Welch training');


%hmm.P=relabelmatrix(hmm.P,newlabels);
%block(1).q_star=relabelstates(block.q_star,newlabels);

plotseg(Xseries,exp_state,block(1).q_star-hmm.K-1,40,ns,-4,9);
disp(' ');
disp('This plot shows the sleep spindle data along with ');
disp('an experts labelling - middle - and the labelling from the HMM - bottom.');





