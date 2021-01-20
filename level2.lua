
-- Written by: Gavin Cernek
-- 3/2/2020

local composer = require("composer");	-- Require for composer
local physics = require("physics");		-- Require for physics
physics.start();	-- Starts physics
local scene = composer.newScene();	-- Starts new scene 

physics.setDrawMode("normal");	-- Sets draw mode and gravity 
physics.setGravity(0, 0);

local ball;			-- Initial ball for the game
local secondBall;	-- Secondary ball after green block is broken
local paddle;			-- Paddle to defelct the balls 
local blocks = {};	 -- Table to store the blocks 

local life = 1;			
local blockSize = 0;	-- How many blocks there are total
local blocksLeft = 0;		-- How many blocks haven't been destroyed
local yellowCount = 0;	-- Counters for special blocks 
local grayCount = 0;
local greenCount = 0;

function scene:create(event)		-- Create function when the scene is created 

	local sceneGroup = self.view;	-- Setting up the group and phase of the scene 
	local phase = event.phase;

	local top = display.newRect(0, 0, display.contentWidth, 20);		-- Displays the borders of the game 
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
	physics.addBody(right, "static");		-- Adds physics bodies to all the borders
	physics.addBody(left, "static");
	physics.addBody(bottom, "static");

	sceneGroup:insert(top);
	sceneGroup:insert(bottom);		-- Inserts the borders into the scene 
	sceneGroup:insert(right);
	sceneGroup:insert(left);
end


function scene:show(event)		-- Show function to do things during and before the scene 

	local sceneGroup = self.view;		-- Setting up the group and phase of the scene
	local phase = event.phase;

	if (phase == "will") then		-- Before the scene comes on screen,

		local function createBlock (xPos, yPos, id, color)		-- Function that creates a block given an x, y coordinate, id, and color 

			if (color == "red") then
				local enemyBlock = display.newRect(xPos, yPos, 100, 100);
				enemyBlock:setFillColor(1, 0.2, 0.2);
				sceneGroup:insert(enemyBlock);

				blocks[id] = enemyBlock;				-- Sets the appropriate fields for a red cube and adds the event listener for a tap
				blocks[id].HP = 1;
				blocks[id].color = "red";
				blocks[id].enemy = true;
			
			elseif (color == "blue") then
				local enemyBlock = display.newRect(xPos, yPos, 100, 100);
				enemyBlock:setFillColor(0.478, 0.612, 0.902);
				sceneGroup:insert(enemyBlock);

				blocks[id] = enemyBlock;				-- Sets the appropriate fields for a blue cube and adds the event listener for a tap
				blocks[id].HP = 2;
				blocks[id].color = "blue";
				blocks[id].enemy = true;
			end

			physics.addBody(blocks[id], "kinematic");
			blockSize = blockSize + 1;					-- Adds physics body to the block and update the blockSize and blocksLeft
			blocksLeft = blockSize;
		end

		local function createBall ()		-- Function to create the second ball 

			timer.performWithDelay(10, function()		-- After 10ms,

				secondBall = display.newCircle (display.contentCenterX + 40, display.contentCenterY - 50, 20);
				physics.addBody (secondBall, "dynamic", {bounce = 1, radius = 20});		-- Create the ball and add a physics body 
				secondBall:setFillColor(0.33, 1, 0.33);
																					
				secondBall:applyForce(5, 30, secondBall.x, secondBall.y)		-- Apply a force to it and add the collision event listener
				secondBall:addEventListener("collision", ballCollision);

				sceneGroup:insert(secondBall);
			end);
		end

		function ballCollision (event)    -- Function to destroy a block upon collision with a ball 

			if (event.phase == "began") then       -- If the collision began, 
				if (event.other.enemy == true) then    -- If the other object is an enemy, 
					if (event.other.HP > 1) then     -- If the object has more than 1 HP,

						if (event.other.color == "blue") then  -- If the object is blue, 
							event.other.color = "red";
							event.other:setFillColor(1, 0.2, 0.2);   -- It is now red 
						end

						event.other.HP = event.other.HP - 1;    -- Update HP

					else     -- If the HP is 1 or less,

						if (event.other.color == "yellow") then    -- If the object is yellow, 

							for i in ipairs(blocks) do   -- For each block,

								if (blocks[i].color == "blue") then   -- If the block is blue,
									blocks[i].color = "red";
									blocks[i].HP = 1;  						-- It is now red
									blocks[i]:setFillColor(1, 0.2, 0.2);

								elseif (blocks[i].color == "red") then    -- If the block is red,
									blocks[i].color = "blue";
									blocks[i].HP = 2;              -- It is now blue 
									blocks[i]:setFillColor(0.478, 0.612, 0.902);
								end
							end

						elseif (event.other.color == "green") then   -- If the object is green,

							createBall();   -- Create the second ball 
						end

						event.other.color = nil;
						event.other:removeSelf(); 		-- Remove the block from the game 
						blocksLeft = blocksLeft - 1;

						if (blocksLeft - grayCount == 0) then   -- If all blocks are destroyed, 

							if (ball ~= nil) then
								ball:removeSelf();
								ball = nil;
							end 						-- Remove the balls 

							if (secondBall ~= nil) then
								secondBall:removeSelf();
								secondBall = nil;
							end

							for i in ipairs(blocks) do    -- Remove all gray blocks 

								if (blocks[i].color ~= nil) then
									blocks[i].color = nil;
									blocks[i]:removeSelf();
								end
							end

							sceneText = display.newText("You Won!", display.contentCenterX, display.contentCenterY, native.Systemfont, 100);
							sceneText2 = display.newText("Congratulations!", display.contentCenterX, display.contentCenterY + 100, native.Systemfont, 100);
							sceneGroup:insert(sceneText);
							sceneGroup:insert(sceneText2); 			-- Display winning text

							timer.performWithDelay(1500, function()
								composer.gotoScene("titleScreen");   -- Go to titleScreen
							end);
						end
					end

				elseif (event.other == bottom) then  -- If a ball collides with the bottom border, 
					
					life = life - 1;   -- Decrement life total 

					if (life == 0) then   -- If the life total is 0,

						if (ball ~= nil) then
							ball:removeSelf();  -- Remove the balls 
							ball = nil;
						end

						if (secondBall ~= nil) then
							secondBall:removeSelf();
							secondBall = nil;
						end

						for i in ipairs(blocks) do    -- Remove all gray blocks 

							if (blocks[i].color ~= nil) then
								blocks[i].color = nil;
								blocks[i]:removeSelf();
							end
						end

						sceneText = display.newText("Game Over", display.contentCenterX, display.contentCenterY, native.Systemfont, 100);
						sceneText2 = display.newText("You Lose...", display.contentCenterX, display.contentCenterY + 100, native.Systemfont, 100);
						sceneGroup:insert(sceneText);
						sceneGroup:insert(sceneText2);     -- Display losing text 

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
		
		for i = 1, 21 do   		-- Loop to create the blocks 

			local blockChoice = math.random(1, 2);  -- Choose a number between one and two 

			if (i == 1) then  -- If this is the first block,
				if (blockChoice == 1) then     -- If blockChoice was 1, the block is red 
					createBlock(300, 250, i, "red");  -- Call to the createBlock function with the x, y position, id, and color 

				elseif (blockChoice == 2) then  -- If blockChoice was 2, the block is blue 
					createBlock(300, 250, i, "blue");
				end

			elseif (i == 2) then			-- Repeat the same process for all 21 blocks 
				if (blockChoice == 1) then
					createBlock(160, 390, i, "red");

				elseif (blockChoice == 2) then
					createBlock(160, 390, i, "blue");
				end
			
			elseif (i == 3) then
				if (blockChoice == 1) then
					createBlock(300, 390, i, "red");

				elseif (blockChoice == 2) then
					createBlock(300, 390, i, "blue");
				end

			elseif (i == 4) then
				if (blockChoice == 1) then
					createBlock(440, 390, i, "red");

				elseif (blockChoice == 2) then
					createBlock(440, 390, i, "blue");
				end

			elseif (i == 5) then
				if (blockChoice == 1) then
					createBlock(300, 530, i, "red");

				elseif (blockChoice == 2) then
					createBlock(300, 530, i, "blue");
				end

			elseif (i == 6) then
				if (blockChoice == 1) then
					createBlock(750, 600, i, "red");

				elseif (blockChoice == 2) then
					createBlock(750, 600, i, "blue");
				end

			elseif (i == 7) then
				if (blockChoice == 1) then
					createBlock(610, 740, i, "red");

				elseif (blockChoice == 2) then
					createBlock(610, 740, i, "blue");
				end

			elseif (i == 8) then
				if (blockChoice == 1) then
					createBlock(750, 740, i, "red");

				elseif (blockChoice == 2) then
					createBlock(750, 740, i, "blue");
				end

			elseif (i == 9) then
				if (blockChoice == 1) then
					createBlock(890, 740, i, "red");

				elseif (blockChoice == 2) then
					createBlock(890, 740, i, "blue");
				end

			elseif (i == 10) then
				if (blockChoice == 1) then
					createBlock(750, 880, i, "red");

				elseif (blockChoice == 2) then
					createBlock(750, 880, i, "blue");
				end

			elseif (i == 11) then
				if (blockChoice == 1) then
					createBlock(300, 950, i, "red");

				elseif (blockChoice == 2) then
					createBlock(300, 950, i, "blue");
				end	

			elseif (i == 12) then
				if (blockChoice == 1) then
					createBlock(160, 1100, i, "red");

				elseif (blockChoice == 2) then
					createBlock(160, 1100, i, "blue");
				end

			elseif (i == 13) then
				if (blockChoice == 1) then
					createBlock(300, 1100, i, "red");

				elseif (blockChoice == 2) then
					createBlock(300, 1100, i, "blue");
				end

			elseif (i == 14) then
				if (blockChoice == 1) then
					createBlock(440, 1100, i, "red");

				elseif (blockChoice == 2) then
					createBlock(440, 1100, i, "blue");
				end	

			elseif (i == 15) then
				if (blockChoice == 1) then
					createBlock(300, 1240, i, "red");

				elseif (blockChoice == 2) then
					createBlock(300, 1240, i, "blue");
				end

			elseif (i == 16) then
				if (blockChoice == 1) then
					createBlock(140, 100, i, "red");

				elseif (blockChoice == 2) then
					createBlock(140, 100, i, "blue");
				end

			elseif (i == 17) then
				if (blockChoice == 1) then
					createBlock(300, 100, i, "red");

				elseif (blockChoice == 2) then
					createBlock(300, 100, i, "blue");
				end

			elseif (i == 18) then
				if (blockChoice == 1) then
					createBlock(460, 100, i, "red");

				elseif (blockChoice == 2) then
					createBlock(460, 100, i, "blue");
				end

			elseif (i == 19) then
				if (blockChoice == 1) then
					createBlock(620, 100, i, "red");

				elseif (blockChoice == 2) then
					createBlock(620, 100, i, "blue");
				end

			elseif (i == 20) then
				if (blockChoice == 1) then
					createBlock(800, 100, i, "red");

				elseif (blockChoice == 2) then
					createBlock(800, 100, i, "blue");
				end

			elseif (i == 21) then
				if (blockChoice == 1) then
					createBlock(960, 100, i, "red");

				elseif (blockChoice == 2) then
					createBlock(960, 100, i, "blue");
				end	
			end
		end

		while (yellowCount ~= 2) do   -- While there are less than 2 yellow blocks, 

			local makeYellow = math.random(1, blockSize);  -- Pick a random block 

			if (blocks[makeYellow].color ~= "yellow") then  -- If the selected block isn't yellow already,
				blocks[makeYellow]:setFillColor(1, 1, 0);
				blocks[makeYellow].color = "yellow";       -- Make it yellow 
				blocks[makeYellow].HP = 1;

				yellowCount = yellowCount + 1;   -- Increment yellowCount
			end
		end

		while (grayCount ~= 3) do   -- While there are less than 3 gray blocks, 

			local makeGray = math.random(1, blockSize);    -- Pick a random block

			if (blocks[makeGray].color ~= "yellow" and blocks[makeGray].color ~= "gray") then  		-- If the selected block isn't gray or yellow already,
				blocks[makeGray]:setFillColor(0.5, 0.5, 0.5);
				blocks[makeGray].color = "gray";
				blocks[makeGray].enemy = false;                                -- Make it gray and remove the enemy tag and event listener
				
				grayCount = grayCount + 1;  -- Increment grayCount
			end
		end

		while (greenCount ~= 1) do   -- While there are less than 1 green blocks,

			local makeGreen = math.random(1, blockSize);   -- Pick a random block 

			if (blocks[makeGreen].color ~= "yellow" and blocks[makeGreen].color ~= "gray") then    -- If the selected block isn't gray or yellow already,
				blocks[makeGreen]:setFillColor(0.33, 1, 0.33);
				blocks[makeGreen].color = "green";              -- Make it green 
				blocks[makeGreen].HP = 1;
				
				greenCount = greenCount + 1;   -- Increment greenCount
			end
		end

		ball:applyForce(5, 30, ball.x, ball.y);    -- Apply force to the initial ball 
	end
end


function scene:hide(event)     -- Hide function to reset the scene

	local sceneGroup = self.view;
	local phase = event.phase;

	if (phase == "will") then  -- If the scene is about to go off, 

		life = 1;
		blockSize = 0;
		blocksLeft = 0;
		yellowCount = 0;     -- Reset all variables 
		grayCount = 0;
		greenCount = 0;

		if (ball ~= nil) then
			ball:removeSelf();
			ball = nil;           -- Make sure balls are removed 
		end

		if (secondBall ~= nil) then
			secondBall:removeSelf();
			secondBall = nil;
		end

		sceneText:removeSelf();    -- Remove screen text 
		sceneText2:removeSelf();

		sceneGroup:insert(paddle);   -- Remove paddle 
		
		paddle:removeSelf();
		paddle = nil;

		for i in ipairs(blocks) do   -- Remove all blocks remaining 

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







