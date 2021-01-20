
-- Written by: Gavin Cernek
-- 3/2/2020

local composer = require("composer");	-- Require for composer
local physics = require("physics");    -- Require for physics
physics.start();      -- Starts physics engine 
local scene = composer.newScene();    -- Creates new scene 

physics.setDrawMode("normal");    -- Sets draw mode and gravity   
physics.setGravity(0, 0);

local ball;     -- Initial ball for the game 
local paddle;      -- Paddle to deflect ball 
local blocks = {};   -- Table to hold all blocks 

local life = 1;      -- Life total 
local blockSize = 0;    -- How many blocks there are total 
local blocksLeft = 0;   -- How many blocks are left in the game 
local yellowCount = 0;  -- Counters for special blocks 
local grayCount = 0;
local shift = 1;    -- Shift variable for creating blocks 

function scene:create(event)   -- Create function for when the scene is about to be created 

	local sceneGroup = self.view;	-- Setting up the group and phase of the scene 
	local phase = event.phase;

	local top = display.newRect(0, 0, display.contentWidth, 20);    -- Sets borders for the game 
	top.anchorX = 0;
	top.anchorY = 0;

	local right = display.newRect(display.contentWidth - 20, 0, 20, display.contentHeight);
	right.anchorX = 0;
	right.anchorY = 0;

	local left = display.newRect(0, 0, 20, display.contentHeight);
	left.anchorX = 0;
	left.anchorY = 0;

	bottom = display.newRect(0, display.contentHeight - 20, display.contentWidth, 20);
	bottom.anchorX = 0;
	bottom.anchorY = 0;

	physics.addBody(top, "static");
	physics.addBody(right, "static");
	physics.addBody(left, "static");      -- Adds physics bodies to all the borders 
	physics.addBody(bottom, "static");

	sceneGroup:insert(top);
	sceneGroup:insert(bottom);    -- Inserts the borders into the scene 
	sceneGroup:insert(right);
	sceneGroup:insert(left);
end


function scene:show(event)     -- Show function to run when the scene is about to come on screen 

	local sceneGroup = self.view;
	local phase = event.phase;

	if (phase == "will") then   -- Before the scene is about to come on,

		local function createBlock (xPos, yPos, id, color)   -- Function to create blocks given a coordinate, id, and color 

			if (color == "red") then                                          
				local enemyBlock = display.newRect(xPos, yPos, 100, 100);
				enemyBlock:setFillColor(1, 0.2, 0.2);
				sceneGroup:insert(enemyBlock);                               -- Creates a red block and applies the proper fields 

				blocks[id] = enemyBlock;
				blocks[id].HP = 1;
				blocks[id].color = "red";
				blocks[id].enemy = true;
			
			elseif (color == "blue") then
				local enemyBlock = display.newRect(xPos, yPos, 100, 100);
				enemyBlock:setFillColor(0.478, 0.612, 0.902);
				sceneGroup:insert(enemyBlock); 								-- Creates a blue block and applies the proper fields 

				blocks[id] = enemyBlock;
				blocks[id].HP = 2;
				blocks[id].color = "blue";
				blocks[id].enemy = true;
			end

			physics.addBody(blocks[id], "kinematic");
			blockSize = blockSize + 1;  					-- Applies physics body to the block and updates the blockSize and blocksLeft
			blocksLeft = blockSize;
		end

		function ballCollision (event) 		-- Function to destroy a block upon collision with the ball 

			if (event.phase == "began") then  			-- If the collision just began 
				if (event.other.enemy == true) then  -- If the object is an enemy,
					if (event.other.HP > 1) then   -- If the object has more than 1 HP,

						if (event.other.color == "blue") then   -- If its blue,
							event.other.color = "red";
							event.other:setFillColor(1, 0.2, 0.2);    -- Make it red 
						end

						event.other.HP = event.other.HP - 1;   -- Update HP

					else    -- If the object has 1 or less HP,

						if (event.other.color == "yellow") then    -- If the object is yellow, 

							for i in ipairs(blocks) do   -- For every block,

								if (blocks[i].color == "blue") then  -- If it is blue, 
									blocks[i].color = "red";
									blocks[i].HP = 1;  						-- Make it red 
									blocks[i]:setFillColor(1, 0.2, 0.2);

								elseif (blocks[i].color == "red") then   -- If it is red, 
									blocks[i].color = "blue";
									blocks[i].HP = 2;  								-- Make it blue,
									blocks[i]:setFillColor(0.478, 0.612, 0.902);
								end
							end
						end

						event.other.color = nil;
						event.other:removeSelf();  		-- Remove the block 
						blocksLeft = blocksLeft - 1;


						if (blocksLeft - grayCount == 0) then   -- If all blocks are gone, 
							
							if (ball ~= nil) then
								ball:removeSelf();     -- Remove the ball 
								ball = nil;
							end

							sceneText = display.newText("Level 1 Complete!", display.contentCenterX, display.contentCenterY, native.Systemfont, 100);
							sceneText2 = display.newText("On To The Next Level!", display.contentCenterX, display.contentCenterY + 100, native.Systemfont, 100);
							sceneGroup:insert(sceneText);
							sceneGroup:insert(sceneText2);    -- Display winning text

							timer.performWithDelay(1500, function()
								composer.gotoScene("level2");   		-- Go to level 2
							end);
						end
					end

				elseif (event.other == bottom) then    -- If the ball collides with the bottom border,
					
					life = life - 1;   -- Decrement life total

					if (life == 0) then   -- If the life total is 0,

						if (ball ~= nil) then
							ball:removeSelf();   -- Remove the ball
							ball = nil;
						end

						sceneText = display.newText("Game Over", display.contentCenterX, display.contentCenterY, native.Systemfont, 100);
						sceneText2 = display.newText("You Lose...", display.contentCenterX, display.contentCenterY + 100, native.Systemfont, 100);
						sceneGroup:insert(sceneText);
						sceneGroup:insert(sceneText2);   		-- Display losing text

						timer.performWithDelay(1500, function()
							composer.gotoScene("titleScreen");     -- Go to titleScreen
						end);
					end
				end
			end
		end

		local function movePaddle (event)		-- Function to move the paddle 
			if (event.phase == "began") then 		-- If the touch event has begun
				paddle.markX = paddle.x;  
				paddle.moving = true;   	-- Mark the paddle as moving and mark the start point 

			elseif (paddle.moving and event.phase == "moved") then  -- If the paddle has been moved,
				local x = (event.x - event.xStart) + paddle.markX;   -- Update its location

				if (x > 170 and x < 905) then  -- If the new location is within the game boundaries,
					paddle.x = x;  -- Update its location 
				end
			
			elseif (event.phase == "ended") then  -- When the paddle is done moving,
				paddle.moving = false;  -- Set it to no longer moving 
			end
		end

		ball = display.newCircle (display.contentCenterX, display.contentCenterY - 50, 20);
		physics.addBody (ball, "dynamic", {bounce = 1, radius = 20}); 								-- Displays the initial ball 
		ball:setFillColor(1, 0.647, 0); 												

		ball:addEventListener("collision", ballCollision); 		-- Adds event listener to the ball 
		sceneGroup:insert(ball);

		paddle = display.newRect(display.contentCenterX, display.contentHeight - 100, 300, 100);
		physics.addBody(paddle, "kinematic");  															-- Displays the paddle and adds the event listener
		paddle:setFillColor(0.7, 0.2, 0.6);

		paddle:addEventListener("touch", movePaddle);
		sceneGroup:insert(paddle);
		
		for i = 1, 24 do  		-- Loop to create the blocks 

			local blockChoice = math.random(1, 2);   -- Pick a number between 1 and 2

			if (i <= 6) then   -- For the first 6 blocks,

				if (blockChoice == 1) then 					-- If blockChoice is 1,
					createBlock(155 * shift, 120, i, "red");    -- Make the block red and move it over by the shift value

				elseif (blockChoice == 2) then      		-- If the blockChoice is 2,
					createBlock(155 * shift, 120, i, "blue");   -- Make the block blue and move it over by the shift value
				end

				shift = shift + 1;    -- Increment shift 

				if (i == 6) then   -- If it is the last block in the row, return shift to one for the next row
					shift = 1;
				end

			elseif (i > 6 and i <= 12) then   	-- Repeat the same process for another row 

				if (blockChoice == 1) then
					createBlock(155 * shift, 260, i, "red");

				elseif (blockChoice == 2) then
					createBlock(155 * shift, 260, i, "blue");
				end	

				shift = shift + 1;

				if (i == 12) then
					shift = 1;
				end

			elseif (i > 12 and i <= 18) then   -- Repeat the process for another row 

				if (blockChoice == 1) then
					createBlock(155 * shift, 400, i, "red");

				elseif (blockChoice == 2) then
					createBlock(155 * shift, 400, i, "blue");
				end

				shift = shift + 1;

				if (i == 18) then
					shift = 1;
				end

			elseif (i > 18) then  				-- Repeat for the last row 

				if (blockChoice == 1) then
					createBlock(155 * shift, 540, i, "red");

				elseif (blockChoice == 2) then
					createBlock(155 * shift, 540, i, "blue");
				end	

				shift = shift + 1;
			end
		end

		while (yellowCount ~= 2) do  		-- If there are less than 2 yellow blocks,
			
			local makeYellow = math.random(1, blockSize);   -- Pick a random block

			if (blocks[makeYellow].color ~= "yellow") then   -- If the block isn't already yellow,
				blocks[makeYellow]:setFillColor(1, 1, 0);     
				blocks[makeYellow].color = "yellow";     -- Make it yellow 
				blocks[makeYellow].HP = 1;

				yellowCount = yellowCount + 1;
			end
		end

		while (grayCount ~= 4) do 		-- While there are less than 4 gray blocks 

			local makeGray = math.random(1, blockSize);    -- Pick a random block 

			if (blocks[makeGray].color ~= "yellow" and blocks[makeGray].color ~= "gray") then   -- If the block isn't already yellow or gray, 
				blocks[makeGray]:setFillColor(0.5, 0.5, 0.5);
				blocks[makeGray].color = "gray";  				-- Make it gray 
				blocks[makeGray].enemy = false;     -- Mark it as not an enemy 
				
				grayCount = grayCount + 1;
			end
		end

		ball:applyForce(5, 30, ball.x, ball.y);    -- Apply force to the initial ball 
	end
end


function scene:hide(event)    -- Hide function to reset the scene 

	local sceneGroup = self.view;
	local phase = event.phase;

	if (phase == "will") then   -- As the scene exits the screen,

		life = 1;
		blockSize = 0;
		blocksLeft = 0;    -- Reset the variables
		yellowCount = 0;
		grayCount = 0;
		shift = 1;

		sceneText:removeSelf();
		sceneText2:removeSelf();    -- Remove the screen text 

		sceneGroup:insert(paddle);    -- Remove paddle 

		paddle:removeSelf();
		paddle = nil;

		for i in ipairs(blocks) do   -- Remove all remaining blocks 

			if (blocks[i].color ~= nil) then
				blocks[i]:removeSelf();
				blocks[i] = nil;
			end
		end
	end
end

function scene:destroy(event)

	local sceneGroup = self.view;
	
end


scene:addEventListener("create", scene);
scene:addEventListener("show", scene);		-- Event listeners for scene functions 
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;		-- Returns the scene 





