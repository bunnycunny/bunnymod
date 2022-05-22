local hud_panel = Overlay:newgui():create_screen_workspace():panel()
hud_panel:bitmap({ 
	visible = 20,
	w = CommandManager.config.crosshair.w,
	h = CommandManager.config.crosshair.h,
	color = Color(CommandManager.config.crosshair.r, CommandManager.config.crosshair.g, CommandManager.config.crosshair.b):with_alpha(200),
	layer = 0,
	name = hit_confirm,
	blend_mode="add"
}):set_center(hud_panel:center())
