require "wx"
require "GLWindow"

function main()
		
	-- Main window
	ID_FRAME = 999
	frame = wx.wxFrame( wx.NULL, ID_FRAME, "wxLua + LuaGL test",
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
	
	-- Other stuff
	rtri = 0
	
	-- Now the cool stuff: openGL context and canvas
	glwindow = GLWindow:new(frame)
		
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
	


end

function update_cb(dt,t)
	
	rtri = rtri + 90*dt
end

function draw_cb()

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


main()

wx.wxGetApp():MainLoop()
