#ifndef __c1_VrSubsystem_h__
#define __c1_VrSubsystem_h__

/* Include files */
#include "sf_runtime/sfc_sf.h"
#include "sf_runtime/sfc_mex.h"
#include "rtwtypes.h"
#include "multiword_types.h"

/* Type Definitions */
#ifndef typedef_SFc1_VrSubsystemInstanceStruct
#define typedef_SFc1_VrSubsystemInstanceStruct

typedef struct {
  SimStruct *S;
  ChartInfoStruct chartInfo;
  uint32_T chartNumber;
  uint32_T instanceNumber;
  int32_T c1_sfEvent;
  boolean_T c1_isStable;
  boolean_T c1_doneDoubleBufferReInit;
  uint8_T c1_is_active_c1_VrSubsystem;
  real_T (*c1_u)[320];
  real_T (*c1_y)[128];
} SFc1_VrSubsystemInstanceStruct;

#endif                                 /*typedef_SFc1_VrSubsystemInstanceStruct*/

/* Named Constants */

/* Variable Declarations */
extern struct SfDebugInstanceStruct *sfGlobalDebugInstanceStruct;

/* Variable Definitions */

/* Function Declarations */
extern const mxArray *sf_c1_VrSubsystem_get_eml_resolved_functions_info(void);

/* Function Definitions */
extern void sf_c1_VrSubsystem_get_check_sum(mxArray *plhs[]);
extern void c1_VrSubsystem_method_dispatcher(SimStruct *S, int_T method, void
  *data);

#endif
