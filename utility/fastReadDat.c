/*=================================================================
 * fastReadDat.c - simple function to read dat/lfp file
 *
 * Create an mxArray and use mxGetPr to point to the starting
 * address of its real data. Fill mxArray with the contents 
 * of "data" and return it in plhs[0].
 *
 * Input:   
 *  (char *) datFileName : name of dat/lfp file, should be absolute path.
 *  (int16) numChannels : number of total channels in dat file
 *  (int16 *) chToRead : column vector contains list of channel to read (1-base)
 *  (int64 *) frameToRead : row vector contains list of frame to read (1-base)
 *  
 * Output: 
 *  (int16 *) dat : waveform
 *
 * typical example of usage on MATLAB
 *   [~,fileinfo]=fileatrib('foo.dat');
 *   nCh=64; ch=(1:8)'; frame=2718281:3141592;
 *   dat=fastReadDat(fileinfo.Name,int16(nCh),int16(ch),int64(frame));
 *   % dat would be  8 x 423312 matrix
 *
 * Hiro Miyawaki at the Osaka City Univ, 2018 Aug
 *	
 *=================================================================*/

#include "mex.h"
#include <stdio.h>

void mexFunction(int nlhs,mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //inputs
    char *datname;
    INT16_T nChannel;
    INT64_T *frames;      // 1xF input matrix
    INT16_T *channels;       // Cx1 input matrix


    // output matrix  
    INT16_T *lfp;

    // size of matrix 
    mwSize nReadFrame;           
    mwSize nReadChanel;           
    
    FILE* fp;
    INT64_T curFrame;
    INT16_T curCh;  
    int sizeCheck;
    //
    

    mwSize chIdx,frameIdx;
    
    // check input number
    if(nrhs != 4) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
                          "4 inputs required: datFileName, numChannels, chToRead,frameToRead");
    }
    
    // check formats
    
    //datFileName
    if ( mxIsChar(prhs[0]) != 1)
      mexErrMsgIdAndTxt( "MATLAB:fastReadDat:datFileNotString",
              "datFileName must be a string.");    
    
    
    //numChannels
    if( !mxIsInt16(prhs[1]) || mxIsComplex(prhs[1]))        
    {
        mexErrMsgIdAndTxt( "MATLAB:fastReadDat:nChNotInt",
            "Input numChannels must be int");
    }        
    if(mxGetN(prhs[1])*mxGetM(prhs[1])!=1 ) 
    {
        mexErrMsgIdAndTxt( "MATLAB:fastReadDat:nChNotScalar",
            "Input numChannels must be a scalar");
    }    

    //chToRead
    if( !mxIsInt16(prhs[2]) || mxIsComplex(prhs[2]))        
    {
        mexErrMsgIdAndTxt( "MATLAB:fastReadDat:chToReadNotInt",
            "Input chToRead must be int");
    }        
    if(mxGetN(prhs[2])!=1 ) 
    {
        mexErrMsgIdAndTxt( "MATLAB:fastReadDat:chToReadNotRowVector",
            "Input chToRead must be a row vector");
    } 
    //frameToRead
    if( !mxIsInt64(prhs[3]) || mxIsComplex(prhs[3]))        
    {
        mexErrMsgIdAndTxt( "MATLAB:fastReadDat:frameToReadNotInt64",
            "Input frameToRead must be int64");
    }        
    if(mxGetM(prhs[3])!=1 ) 
    {
        mexErrMsgIdAndTxt( "MATLAB:fastReadDat:frameToReadNotColumnVector",
            "Input frameToRead must be a column vector");
    }     
    
    datname=mxArrayToString(prhs[0]);
    nChannel=mxGetScalar(prhs[1]);
    channels=(INT16_T *)mxGetData(prhs[2]);
    frames=(INT64_T *)mxGetData(prhs[3]);
    
    nReadChanel = mxGetM(prhs[2]);    
    nReadFrame = mxGetN(prhs[3]);    
                
    lfp = mxCalloc(nReadChanel*nReadFrame, sizeof(INT16_T));
    
    fp = fopen( datname, "rb" );
    if( fp == NULL ){
        mexErrMsgIdAndTxt( "MATLAB:fastReadDat:datCantOpen",
            "Can't open datfile");
    }    
    curFrame=0;
    for(frameIdx=0; frameIdx<nReadFrame;frameIdx++)
    {
        fseek(fp,nChannel*(frames[frameIdx]-curFrame-1)*2,SEEK_CUR);
        curCh=0;
        for (chIdx = 0; chIdx < nReadChanel; chIdx++)
        {      
            
            fseek(fp,(channels[chIdx]-curCh-1)*2,SEEK_CUR);

            if(fread(&lfp[chIdx+nReadChanel*frameIdx],sizeof(INT16_T),1,fp)<1)
            {
                mexErrMsgIdAndTxt( "MATLAB:fastReadDat:datReadFailure",
                    "Can't read datfile correctly");
            }    
            
            curCh=channels[chIdx];
             
        }
        fseek(fp,(nChannel-curCh)*2,SEEK_CUR);    
        curFrame=frames[frameIdx];
    }

    fclose(fp);
    
    /* Create a 0-by-0 mxArray; you will allocate the memory dynamically */
    plhs[0] = mxCreateNumericMatrix(0, 0, mxINT16_CLASS, mxREAL);
    mxSetData(plhs[0], lfp);
    mxSetM(plhs[0], nReadChanel); 
    mxSetN(plhs[0], nReadFrame);
 
    /* Do not call mxFree(lfp) because plhs[0] points to lfp */
    
}
    
    
    
    
    
    
    
    
    
    