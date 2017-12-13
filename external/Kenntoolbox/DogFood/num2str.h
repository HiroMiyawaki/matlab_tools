/*
 * MATLAB Compiler: 2.1
 * Date: Mon May  7 15:50:01 2001
 * Arguments: "-B" "macro_default" "-O" "all" "-O" "fold_scalar_mxarrays:on"
 * "-O" "fold_non_scalar_mxarrays:on" "-O" "optimize_integer_for_loops:on" "-O"
 * "array_indexing:on" "-O" "optimize_conditionals:on" "-x" "-W" "mex" "-L" "C"
 * "-t" "-T" "link:mexlibrary" "libmatlbmx.mlib" "-w" "ResSubset" 
 */

#ifndef MLF_V2
#define MLF_V2 1
#endif

#ifndef __num2str_h
#define __num2str_h 1

#ifdef __cplusplus
extern "C" {
#endif

#include "libmatlb.h"

extern void InitializeModule_num2str(void);
extern void TerminateModule_num2str(void);
extern _mexLocalFunctionTable _local_function_table_num2str;

extern mxArray * mlfNum2str(mxArray * x, mxArray * f);
extern void mlxNum2str(int nlhs, mxArray * plhs[], int nrhs, mxArray * prhs[]);

#ifdef __cplusplus
}
#endif

#endif
