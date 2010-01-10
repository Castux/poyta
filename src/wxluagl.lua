require "wx"
require "GLWindow"

function init_gui()
		
	-- Main window
	ID_FRAME = 999
	frame = wx.wxFrame( wx.NULL, ID_FRAME, "pöytä client",
			wx.wxDefaultPosition, wx.wxSize(600, 400),
			wx.wxDEFAULT_FRAME_STYLE )
	
	-- create a simple file menu
	local fileMenu = wx.wxMenu()
	fileMenu:Append(wx.wxID_EXIT, "E&xit", "Quit the program")

	-- create a menu bar and append the file menu
	local menuBar = wx.wxMenuBar()
	menuBar:Append(fileMenu, "&File")

	-- attach the menu bar into the frame
	frame:SetMenuBar(menuBar)
	
	frame:Connect(wx.wxID_EXIT, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			frame:Close(true)
		end
	)
	
	-- Now the cool stuff: openGL context and canvas
	glwindow = GLWindow:new(frame)
	
	-- A text control
	ID_TEXT = 998
	local console = wx.wxTextCtrl(frame, ID_TEXT, "",
		wx.wxDefaultPosition, wx.wxSize(200, 400),
		wx.wxTE_MULTILINE + wx.wxTE_READONLY)
	
	Console.widget = console
	
	-- Text input: command line
	ID_CL = 997
	local command_line = wx.wxTextCtrl( frame, ID_CL, "",
		wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxTE_PROCESS_ENTER)
	
	command_line:Connect(ID_CL, wx.wxEVT_COMMAND_TEXT_ENTER,
		function(event)
			Console:execute(command_line:GetValue())
			command_line:Clear()
		end
	)
	
	-- Place these in sizers
	
	-- VBox
	local vbox = wx.wxBoxSizer(wx.wxVERTICAL)
	vbox:Add(console, 1, wx.wxEXPAND + wx.wxALL, 2)
	vbox:Add(command_line, 0, wx.wxEXPAND + wx.wxALL, 2)
	
	-- HBox
	local hbox = wx.wxBoxSizer(wx.wxHORIZONTAL)
	hbox:Add(vbox, 0, wx.wxEXPAND, 2)
	hbox:Add(glwindow.glcanvas, 1, wx.wxEXPAND, 2)
	
	frame:SetAutoLayout(true)
	frame:SetSizer(hbox)
	
	
	-- Start the whole thing
	
	frame:Show(true)
	glwindow:initGL()
	

	-- Make this realtime
	wx.wxGetApp():Connect(-1, wx.wxEVT_IDLE, function(event)
		
		local dt,t = glwindow:updateTimer()
	
		-- Call main callback
		update_cb(dt,t)
		
		-- Draw GL context
		glwindow:draw()
		
		-- Make sure we receive another idle event right away
		event:RequestMore()
	end)
	
	-- This has to be effectively the last function call ever
	-- All the rest is callbacks (apparently)
	wx.wxGetApp():MainLoop()
end

function update_cb(dt,t)
	
	rtri = rtri or 0
	
	rtri = rtri + 90*dt
end

function draw_cb()
	
	rtri = rtri or 0
	
	-- Do gl stuff
	gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT') -- Clear Screen And Depth Buffer

	gl.LoadIdentity()             -- Reset The Current Modelview Matrix
	gl.Translate(0, 0, -6)     -- Move Left 1.5 Units And Into The Screen 6.0
	gl.Rotate(rtri, 1, 0.001, 0)

	gl.Begin('TRIANGLES')         -- Drawing Using Triangles
		gl.Color ( 1, 0, 0)         
		gl.Vertex( 0, 1, 0)
		gl.Color ( 0, 1, 0)         
		gl.Vertex(-1,-1, 1)         
		gl.Color ( 0, 0, 1)         
		gl.Vertex( 1,-1, 1)         
		
		gl.Color ( 1, 0, 0)         
		gl.Vertex( 0, 1, 0)    
		gl.Color ( 0, 1, 0)         
		gl.Vertex(-1,-1, -1)         
		gl.Color ( 0, 0, 1)         
		gl.Vertex( 1,-1, -1)
		
		gl.Color ( 1, 0, 0)         
		gl.Vertex( 0, 1, 0)    
		gl.Color ( 0, 1, 0)         
		gl.Vertex(-1,-1, -1)         
		gl.Color ( 0, 1, 0)         
		gl.Vertex(-1,-1, 1)
		
		gl.Color ( 1, 0, 0)         
		gl.Vertex( 0, 1, 0)    
		gl.Color ( 0, 0, 1)         
		gl.Vertex(1,-1, -1)         
		gl.Color ( 0, 0, 1)         
		gl.Vertex(1,-1, 1)
		
	gl.End()
	
	
end

function mousepressed_cb(x,y,but)
	print("Pressed",x,y,but)
end

function mousereleased_cb(x,y,but)
	print("Released",x,y,but)
end


