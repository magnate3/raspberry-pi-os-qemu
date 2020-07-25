#ifndef	_P_BASE_H
#define	_P_BASE_H

#include "mm.h"

#define DEVICE_BASE 		0x3F000000	
#define PBASE 			(VA_START + DEVICE_BASE)
#define LPBASE 			(VA_START + 0x40000000)

#endif  /*_P_BASE_H */
