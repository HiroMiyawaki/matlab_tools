function Par = DefaultPPar
% default values for parameters

% written in pdata 
Par.VersionNumber = 16;
Par.InternalFreq = 312.5;
Par.ExcludeSameTetrode=1;
Par.SpaceGrid = 64;
Par.PhGrid = 16;
Par.Epsilon = 1e-12;
Par.EpsilonPh = 1;
Par.nCrossVal = 10;
Par.MaxIter = 30;
Par.ConvergeThresh = 1e-6;
Par.DevUpThresh = 1e-6;
Par.DevUpTerminateThresh = 1e-8;
Par.Ridge = .25; % changed from .5!!!!
Par.MuCeiling = 100;
Par.UnitAddMult = 10;
Par.UnitAddMaxSteps = 10;
Par.LinkFn = 1;

% used in WritePdataFile
Par.MapSize = 400;
Par.ResRate = 20000; 
Par.WhlRate = 20000/512;
Par.ThPhRate = 1250;
Par.ExcludeInterneurons = 1;
Par.JustThisCell = 0; % if set, only does one cell.
