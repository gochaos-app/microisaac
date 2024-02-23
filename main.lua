local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")
local osmicro = import("os")
local buffer = import("micro/buffer")
require("os")

function init()
	config.MakeCommand("p", isaac, config.NoComplete)

	config.MakeCommand("i", isaac_image, config.NoComplete)
	config.MakeCommand("openi", open_isaac, config.NoComplete)
	config.TryBindKey("F6", "command:openi", true)
	-- help text
	-- 
end


function isaac_image(bp, args)
	if #args < 1 then
		micro.InfoBar():Error("This command requires a prompt as an argument.")
		return
	end
	local current_dir = osmicro.Getwd()
	local prompt = args[1]
	local command = "~/.config/micro/plug/isaac/main_image.py \"" .. prompt .. "\" \"" .. current_dir .. "\""

	os.execute(command)
end

function isaac(bp, args)
	-- Verificar que se haya proporcionado un argumento
	if #args < 1 then
		micro.InfoBar():Error("This command requires a prompt as an argument.")
		return
	end
	local current_dir = osmicro.Getwd()
	local prompt = args[1]
	local command = "~/.config/micro/plug/isaac/main_chat.py \"" .. prompt .. "\" \"" .. current_dir .. "\""

	os.execute(command)
end

function open_isaac(bp)
	micro.CurPane():VSplitIndex(buffer.NewBuffer("", "isaac"), false)
	isaac_view = micro.CurPane()
	isaac_view:ResizePane(40)
	
    isaac_view.Buf.Type.Scratch = true
    isaac_view.Buf.Type.Readonly = true

	-- Set the various display settings, but only on our view (by using SetLocalOption instead of SetOption)
	-- NOTE: Micro requires the true/false to be a string
	-- Softwrap long strings (the file/dir paths)
    isaac_view.Buf:SetOptionNative("softwrap", true)
    -- No line numbering
    isaac_view.Buf:SetOptionNative("ruler", false)
    -- Is this needed with new non-savable settings from being "vtLog"?
    isaac_view.Buf:SetOptionNative("autosave", false)
    -- Don't show the statusline to differentiate the view from normal views
    isaac_view.Buf:SetOptionNative("statusformatr", "")
    isaac_view.Buf:SetOptionNative("statusformatl", "isaac")
    isaac_view.Buf:SetOptionNative("scrollbar", false) 
	update_prompts_responses()
end

function lines_from()
	local lines = {}
	current_dir = osmicro.Getwd()
	filepath = current_dir .. "/data.txt"
	for line in io.lines(filepath) do
		lines[#lines + 1] = line
	end
	return lines
end

function update_prompts_responses()
	highest_visible_indent = 0 
	isaac_view:ResizePane(74)
	current_dir = osmicro.Getwd()
	filepath = current_dir .. "/data.txt"
	content = lines_from()
	isaac_view.Buf.EventHandler:Remove(isaac_view.Buf:Start(), isaac_view.Buf:End())

	local display_content 
	for i = 1, #content do
		display_content = content[i]
		if i < #content then
			display_content = display_content .. "\n"
		end
		isaac_view.Buf.EventHandler:Insert(buffer.Loc(i-1, i+2), display_content)
	end
end

