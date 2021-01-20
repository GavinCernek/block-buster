
-- Written by: Gavin Cernek
-- 3/2/2020

local composer = require("composer");	-- Requires for composer and widgets for buttons
local widget = require("widget");
local scene = composer.newScene();		-- Specifies a new scene 

function scene:create(event)	-- Function to create the scene before it comes on screen

	local sceneGroup = self.view;	-- Setting up the group and phase of the scene 
	local phase = event.phase;

	local bg = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight);
	bg:setFillColor(1, 0.33, 0.33);				-- Sets the background to a purple color and puts it into the sceneGroup
	sceneGroup:insert(bg);

	local startText = display.newText("BLOCK", display.contentCenterX, 130, native.systemFont, 155);		-- Title text 
	startText:setFillColor(1, 1, 1);
	sceneGroup:insert(startText);

	local startText2 = display.newText("BUSTER", display.contentCenterX, 270, native.systemFont, 155);		-- Title text 
	startText2:setFillColor(1, 1, 1);
	sceneGroup:insert(startText2);

	local function changeLvl (event)				-- Function to switch scenes to go to level 1 or level 2
		if (event.target.id == "lvl1" and event.phase == "ended") then
			composer.gotoScene("level1");		-- Go to level 1
		
		elseif (event.target.id == "lvl2" and event.phase == "ended") then
			composer.gotoScene("level2");		-- Go to level 2
		end
	end

	local btnOpt =			-- Options for the buttons
	{
		frames = {
			{ x = 20, y = 10, width = 405, height = 125}, --frame 1
			{ x = 470, y = 10, width = 405, height = 125}, --frame 2
		}
	};

	local buttonSheet = graphics.newImageSheet("button.png", btnOpt);		-- Images for the buttons 

	local lvl1Btn = widget.newButton (		-- Builds the level 1 button
		{
			x = display.contentCenterX,
			y = display.contentCenterY - 200,
			id = "lvl1",
			label = "Level 1",
			fontSize = 75,
			labelColor = { default = { 0, 0, 0 }, over = { 0, 0, 0 } },
			sheet = buttonSheet,
			defaultFrame = 1,
			overFrame = 2,
			onEvent = changeLvl,		-- When clicked, go to level 1
		}
	);
	sceneGroup:insert(lvl1Btn);

	local lvl2Btn = widget.newButton (		-- Builds level 2 button
		{
			x = display.contentCenterX,
			y = display.contentCenterY + 200,
			id = "lvl2",
			label = "Level 2",
			fontSize = 75,
			labelColor = { default = { 0, 0, 0 }, over = { 0, 0, 0 } },
			sheet = buttonSheet,
			defaultFrame = 1,
			overFrame = 2,
			onEvent = changeLvl,		-- When clicked, go to level 2
		}
	);
	sceneGroup:insert(lvl2Btn);

	local authorText = display.newText("Written By: Gavin Cernek", display.contentCenterX, 1500, native.systemFont, 90);
	authorText:setFillColor(1, 1, 1);									-- Text about the author 
	sceneGroup:insert(authorText);

	local dateText = display.newText("3/2/2020", display.contentCenterX, 1700, native.systemFont, 90);
	dateText:setFillColor(1, 1, 1);
	sceneGroup:insert(dateText);
end

function scene:show(event)
end

function scene:hide(event)
end

function scene:destroy(event)
end


scene:addEventListener("create", scene);		-- Scene eventListeners attached to the four different scene functions
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;		-- Retunrs the created scene 