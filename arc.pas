program arcanoid;
uses crt;

const 
	rowsCount = 4;
	blockLength = 10;
	gapBetweenBlocksLength = 4;
	scorePhrase = 'Score: ';
	winPhrase = 'YOU ARE WIN!';
	failPhrase = 'GAME OVER';
	ballSymbol = '*';
	blockSymbol = '#';
	startPhrase = 'READY?';

type blockCoordsType = array[1..rowsCount, 1..100] of integer;

function getStrokeOf(symbol: char; count: integer): string;
var platform: string = '';
var i: integer;

begin
	for i:=1 to count do
		platform := platform + symbol;
	getStrokeOf := platform
end;

procedure getKey(var code: integer);
var c: char;
begin
	c:= ReadKey;
	if c = #0 then begin
		c := ReadKey;
		code := -ord(c)
	end
	else
	begin
		code := ord(c);
	end
end;

procedure showMessage(msg: string; x, y: integer);
begin
	GotoXY(x, y);
	write(msg);
	GotoXY(1,1)
end;

procedure hideMessage(msg: string; x, y: integer);
var i: integer;
begin
	GotoXY(x, y);
	for i := 1 to length(msg) do
		write(' ');
	GotoXY(1,1)
end;

procedure moveMessage(msg: string; var x, y: integer; dx, dy: integer);
begin
	hideMessage(msg, x, y);
	x := x + dx;
	y := y + dy;
	showMessage(msg, x, y)
end;

procedure showBlocks(rowsCount, blockSize, gapSize: integer; blockSymbol: char; var blockCoords: blockCoordsType; var allBlocksCount: integer);
var i, j, k, blocksCount, noFilledCellCount, borderGapSize: integer;
    block, gap, borderGap: string;

begin
	TextColor(Cyan);
	blocksCount := (ScreenWidth - gapSize) div (blockSize + gapSize);
	allBlocksCount := rowsCount * blocksCount;
	noFilledCellCount := (ScreenWidth - gapSize) mod (blockSize + gapSize);
	gap := getStrokeOf(' ', gapSize);
	borderGapSize := gapSize + noFilledCellCount div 2;
	borderGap := getStrokeOf(' ', borderGapSize);
	block := getStrokeOf(blockSymbol, blockSize);
	for i :=1 to rowsCount do begin
		for j := 1 to 100 do 
			blockCoords[i][j] := 0;
	end;
	for i := 1 to rowsCount do begin
		GotoXY(1, i * 2);
		for j := 1 to blocksCount do
			if (noFilledCellCount <> 0) and (j = 1) then begin
			   write(borderGap, block);
			   for k := borderGapSize + 1 
			     to blockSize + borderGapSize
			       do
				       blockCoords[i][k] := 1;
		        end
			else begin
			   write(gap, block);
			   for k := borderGapSize + 1 + (gapSize + blockSize) * (j-1) 
			     to borderGapSize + blockSize + (blockSize + gapSize) *(j-1)
			       do
				       blockCoords[i][k] := 1;
		       end;
		write(borderGap)
	end;
	GotoXY(1,1)
end;

procedure  moveBall(ball: char; var x,y: integer; direct: integer);

begin
	TextColor(Yellow);
	case direct of 
	    0:
		    moveMessage(ball, x,y, -1,-1);
	    1: 
		    moveMessage(ball, x,y, 1,-1);
	    2:
		    moveMessage(ball, x,y, -1,1);
	    3:
		    moveMessage(ball, x,y, 1,1);
	 end;
	delay(100);
end;

procedure removeBlockByPoint(anyBlockPointX, anyBlockPointY: integer; var blockCoords: blockCoordsType);
var i: integer;
begin
	blockCoords[anyBlockPointY div 2][anyBlockPointX] := 0;
	GotoXY(anyBlockPointX, anyBlockPointY);
	write(' ');

	i:= 1;
	while blockCoords[anyBlockPointY div 2][anyBlockPointX - i] = 1 do begin
		blockCoords[anyBlockPointY div 2][anyBlockPointX - i] := 0;
		GotoXY(anyBlockPointX - i, anyBlockPointY);
		write(' ');
		i := i + 1;
	end;

	i := 1;
	while blockCoords[anyBlockPointY div 2][anyBlockPointX + i] = 1 do begin
		blockCoords[anyBlockPointY div 2][anyBlockPointX + i] := 0;
		GotoXY(anyBlockPointX + i, anyBlockPointY);
		write(' ');
		i := i + 1;
	end;
end;


function isBallBeatBlock(ballX,ballY: integer; blockCoords: blockCoordsType): boolean;
begin
	if ballY mod 2 = 1 then begin
		isBallBeatBlock := false;
		exit
	end;

	if blockCoords[ballY div 2][ballX] = 1 then
		isBallBeatBlock := true
	else
		isBallBeatBlock:= false
end;

function isBallBeatPlatform(ballX, ballY, platformX, platformY: integer; platform: string): boolean;
var i: integer;
begin
	for i := 0 to length(platform) - 1 do begin
		if (ballX = (platformX + i)) and (ballY = platformY) then begin
			isBallBeatPlatform := true;
			exit;
		end;
	end; 
	isBallBeatPlatform := false
end;

var 
	keyCode, x, y, ballX, ballY, score, allBlocksCount: integer;
	platform, stringStore: string;
	direct: 0..3;
	blockCoords: blockCoordsType;
	platformSymbol: char = '+';
	isFailed: boolean = false;
	isWin: boolean = false;
	finalInputCode, startInputCode: integer;

begin
	clrscr;
	GotoXY((ScreenWidth - length(startPhrase)) div 2, ScreenHeight div 2);
	TextColor(LightMagenta);
	write(startPhrase);
	repeat 
	     	getKey(startInputCode);
	until (startInputCode = 13) or (startInputCode = 32); 
	clrscr;
	score := 0;
	showBlocks(rowsCount, blockLength, gapBetweenBlocksLength, blockSymbol, blockCoords, allBlocksCount);
	platform := getStrokeOf(platformSymbol, 20);
	x:= (ScreenWidth - length(platform)) div 2;
	y:= ScreenHeight - 2;
	randomize;
	ballX := ScreenWidth div 2;
	ballY := ScreenHeight div 2;
	direct := random(4);
	TextColor(LightMagenta);
	TextBackground(Black);
	showMessage(scorePhrase + '0', 1, 1);
	showMessage(platform, x, y);
	showMessage(ballSymbol, ballX, ballY);
	while true do begin
	      if isWin then begin
		      clrscr;
		      GotoXY((ScreenWidth - length(winPhrase)) div 2, ScreenHeight div 2);
		      write(winPhrase);
		      repeat 
		      	getKey(finalInputCode);
		      until (finalInputCode = 13) or (finalInputCode = 32); 
		      break;
	      end;
	      if isFailed then begin
		      clrscr;
		      GotoXY((ScreenWidth - length(failPhrase)) div 2, ScreenHeight div 2);
		      write(failPhrase);
		      repeat 
		      	getKey(finalInputCode);
		      until (finalInputCode = 13) or (finalInputCode = 32); 
		      break;
	      end;
	      if KeyPressed then begin
		getKey(keyCode);
		if (keyCode = 32) or (keyCode = 13) then
			break;
		
		TextColor(LightMagenta);	
		case keyCode of
		  -75:
			  if x > 0 then begin
			  	moveMessage(platform, x, y, -1, 0);
			  	moveMessage(platform, x, y, -1, 0);
			  end;
		  -77:
			  if (x + length(platform) - 1) < ScreenWidth then begin
			  	moveMessage(platform, x, y, 1, 0);
			  	moveMessage(platform, x, y, 1, 0);
			  end;
		  end;
		end;
			if (direct = 0) and (ballX <= 1) then
				direct := 1
			else if (direct = 0) and (ballY <= 1) then
				direct := 2
			else if (direct = 1) and (ballX >= Screenwidth) then
				direct := 0
			else if (direct = 1) and (ballY <= 1) then 
				direct := 3
			else if (direct = 2) and (ballX <= 1) then
				direct := 3
			else if (direct = 2) and (ballY >= ScreenHeight) then
				isFailed := true
			else if (direct = 3) and (ballX >= ScreenWidth) then
				direct := 2
			else if (direct = 3) and (ballY >= ScreenHeight) then
				isFailed := true;

		     if isBallBeatBlock(ballX, ballY, blockCoords) then begin
				score := score + 1;
				str(score, stringStore);
				showMessage(scorePhrase + stringStore, 1, 1);
				if score = allBlocksCount then begin
					isWin := true;
					continue;
				end;
		     end;

			if isBallBeatBlock(ballX, ballY, blockCoords) and (direct = 0) then begin
				direct := 2;	
				removeBlockByPoint(ballX, ballY, blockCoords);
			end
	       	     else if isBallBeatBlock(ballX, ballY, blockCoords) and (direct = 1) then begin
				direct := 3;
				removeBlockByPoint(ballX, ballY, blockCoords);
		     end
		     else if isBallBeatBlock(ballX, ballY, blockCoords) and (direct = 2) then begin
				direct := 0;
				removeBlockByPoint(ballX, ballY, blockCoords);
		     end
		     else if isBallBeatBlock(ballX, ballY, blockCoords) and (direct = 3) then begin
				direct := 1;
				removeBlockByPoint(ballX, ballY, blockCoords);
		     end;
	
			if isBallBeatPlatform(ballX, ballY, x, y, platform) and (direct = 0) then
				direct := 2
		      else if isBallBeatPlatform(ballX, ballY, x, y, platform) and (direct = 1) then
				direct := 3
		      else if isBallBeatPlatform(ballX, ballY, x, y, platform) and (direct = 2) then
				direct := 0
		      else if isBallBeatPlatform(ballX, ballY, x, y, platform) and (direct = 3) then
				direct := 1;
			
			moveBall(ballSymbol, ballX, ballY, direct); 
			TextColor(LightMagenta);
			showMessage(platform,x,y);
			continue
		end;

	clrscr;
end.

