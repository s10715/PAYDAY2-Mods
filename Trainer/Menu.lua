local mod_txt = ""
for line in io.lines(ModPath .. "mod.txt") do
	mod_txt = mod_txt .. line .. "\n"
end

local mod_table = json.decode(mod_txt)
if not mod_table.keybinds then return end


local menu_data = {
	title = "Trainer",
	button_list = {}
}
for idx,keybind in pairs(mod_table.keybinds) do
	-- divider line
	if idx == 8 or idx == 15 or idx == 24 or idx == 35 or idx == 37 then
		table.insert(menu_data.button_list, {})
	end
	if idx ~= 1 then
		table.insert(menu_data.button_list, {
			text = keybind.name,
			desc = keybind.description,
			callback_func = function()
				dofile(ModPath .. keybind.script_path)
			end,
		})
	end
end
table.insert(menu_data.button_list, {})
local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}
table.insert(menu_data.button_list, no_button)
managers.system_menu:force_close_all()
managers.system_menu:show_buttons(menu_data)
