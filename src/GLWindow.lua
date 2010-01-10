require "wx"
require "LuaGL"
require "LuaGlu"


-- Special GLWindow widget
-- Pseudo singleton class

local ID_CANVAS = 1000

GLWindow = {}

-- Take as argument the parent wxWindow

function GLWindow:new(frame)
	
	local gl_attrib = {wx.WX_GL_RGBA, wx.WX_GL_MIN_RED, 1, wx.WX_GL_MIN_GREEN, 1,
		wx.WX_GL_MIN_BLUE, 1, wx.WX_GL_DEPTH_SIZE, 1,
		wx.WX_GL_DOUBLEBUFFER, 0}
	
	self.glcanvas = wx.wxGLCanvas(frame, ID_CANVAS, wx.wxDefaultPosition,
		wx.wxDefaultSize, 0, "GLCanvas", gl_attrib)
	
	self.glcontext = wx.wxGLContext(self.glcanvas)
	
	-- Redraw event
	
	self.glcanvas:Connect(ID_CANVAS, wx.wxEVT_PAINT, function(event)
		self:draw()
	end)

	-- Mouse input events
	
	self.glcanvas:Connect(ID_CANVAS, wx.wxEVT_LEFT_DOWN, function(event)
		
		local x,y = event:GetPositionXY()
		mousepressed_cb(x,y,1)
		event:Skip()
	end)
	
	self.glcanvas:Connect(ID_CANVAS, wx.wxEVT_RIGHT_DOWN, function(event)
		
		local x,y = event:GetPositionXY()
		mousepressed_cb(x,y,2)
		event:Skip()
	end)
	
	self.glcanvas:Connect(ID_CANVAS, wx.wxEVT_LEFT_UP, function(event)
		
		local x,y = event:GetPositionXY()
		mousereleased_cb(x,y,1)
		event:Skip()
	end)
	
	self.glcanvas:Connect(ID_CANVAS, wx.wxEVT_RIGHT_UP, function(event)
		
		local x,y = event:GetPositionXY()
		mousereleased_cb(x,y,2)
		event:Skip()
	end)
	
	self.glcanvas:Connect(ID_CANVAS, wx.wxEVT_MOUSEWHEEL, function(event)
		
		local x,y = event:GetPositionXY()
		local dir = event:GetWheelRotation()
		
		if dir > 0 then
			dir = 3
		else
			dir = 4
		end
		
		mousepressed_cb(x,y,dir)
		event:Skip()
	end)
	
	self.glcanvas:Connect(ID_CANVAS, wx.wxEVT_MOTION, function(event)
		
		local x,y = event:GetPositionXY()
		self.mouse_x = x
		self.mouse_y = y
		
		event:Skip()
	end)
		
	-- Timer
	self.timer = wx.wxStopWatch()
	self.last_t = self.timer:Time()
	self.frame_count = 0

	
	
	return GLWindow
end

function GLWindow:initGL()
	
	local w,h = self.glcanvas:GetSizeWH()

	gl.ShadeModel('SMOOTH')            -- Enable Smooth Shading
	gl.ClearColor(0, 0, 0, 0.5)        -- Black Background
	gl.ClearDepth(1.0)                 -- Depth Buffer Setup
	gl.Enable('DEPTH_TEST')            -- Enables Depth Testing
	gl.DepthFunc('LEQUAL')             -- The Type Of Depth Testing To Do
	gl.Enable('COLOR_MATERIAL')
	gl.Hint('PERSPECTIVE_CORRECTION_HINT','NICEST')

	gl.Viewport(0, 0, w, h)

	gl.MatrixMode('PROJECTION')   -- Select The Projection Matrix
	gl.LoadIdentity()             -- Reset The Projection Matrix

	if h == 0 then h = 1 end       -- Avoid division by zero
	glu.Perspective(80, w/h, 1, 5000) -- Calculate The Aspect Ratio And Set The Clipping Volume

	gl.MatrixMode('MODELVIEW')    -- Select The Model View Matrix
	gl.LoadIdentity()             -- Reset The Model View Matrix
end


function GLWindow:draw()
	
	self.glcanvas:SetCurrent(self.glcontext)
	
	draw_cb()
	
	self.glcanvas:SwapBuffers()
	
end

function GLWindow:updateTimer()
	
	self.frame_count = self.frame_count + 1
	
	local t = self.timer:Time()
	local dt = t - self.last_t
	
	self.last_t = t
	
	return dt/1000,t/1000
end
