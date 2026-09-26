local infile_path = tostring(ModPath) .. "assetlist.txt"
local outfile_path = tostring(ModPath) .. "hashlist.txt"


local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local deduplicate_table = {}
local data_table = {}

local infile = io.open(infile_path, "r")
if infile then
	io.input(infile)
	for line in io.input():lines() do
		line = trim(line)
		if deduplicate_table[line] == nil then
			table.insert(data_table, { str = line, idstring = tostring(Idstring(line):key()) })
			deduplicate_table[line] = ""
		end
	end
	io.close(infile)
else
	managers.mission._fading_debug_output:script().log(string.format("Error when load file"), Color.red)
end


local outfile, err_msg = io.open(outfile_path, 'a+')
if outfile then
	outfile:write("hashlist = {\n")
	for _, data in pairs(data_table) do
		outfile:write("\t[\"" .. data.idstring .. "\"] = \"" .. data.str .. "\",\n")
	end
	outfile:write("}\n")
	outfile:close()
	managers.mission._fading_debug_output:script().log(string.format("File save to " .. outfile_path), Color.green)
else
	managers.mission._fading_debug_output:script().log(string.format("Error when write to file"), Color.red)
end
