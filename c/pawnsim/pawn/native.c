#include <stdint.h>

#include "het.h"
#include "gio.h"

#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "os_task.h"

#include "native.h"


/*
 * Delay (milliseconds)
 */
static cell AMX_NATIVE_CALL pawn_delay(AMX *amx, const cell *params){
	int millis = (int)params[1];
	vTaskDelay(millis*1000/configTICK_RATE_HZ);
	return 0;
}


int amx_ObcNativeInit(AMX *amx)
{
	static AMX_NATIVE_INFO obc_Natives[] = {
		{ "delay", pawn_delay },
		{ 0, 0 } /* terminator */
	};

	return amx_Register(amx, obc_Natives, -1);
}
