/*
 * MATLAB Compiler: 2.0.1
 * Date: Wed Jan 26 11:51:55 2000
 * Arguments: "-xw" "PointCorrel" 
 */

#ifndef MLF_V2
#define MLF_V2 1
#endif

#ifndef __ylabel_h
#define __ylabel_h 1

#include "matlab.h"

extern mxArray * mlfNYlabel(int nargout, mxArray * string, ...);
extern mxArray * mlfYlabel(mxArray * string, ...);
extern void mlfVYlabel(mxArray * string, ...);
extern void mlxYlabel(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]);

#endif
