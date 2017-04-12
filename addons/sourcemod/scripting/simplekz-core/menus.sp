/*
	Menus
*/

#include "simplekz-core/menus/measure.sp"
#include "simplekz-core/menus/options.sp"
#include "simplekz-core/menus/pistol.sp"
#include "simplekz-core/menus/style.sp"
#include "simplekz-core/menus/tp.sp"

void CreateMenus()
{
	CreateTPMenuAll();
	CreateOptionsMenuAll();
	CreateStyleMenuAll();
	CreatePistolMenuAll();
	CreateMeasureMenuAll();
} 