local TeleMapAll={
   [1]={
      [1]=618,
      [2]=405,
      [3]=400,
	  [4]=3557,
	  [5]=440,
	  [6]=1637,
	  [7]=490,
	  [8]=15,
	  [9]=1377,
	  [10]=493,
	  [11]=14,
	  [12]=141,
	  [13]=331,
	  [14]=406,
	  [15]=3524,
	  [16]=3525,
	  [17]=16,
	  [18]=215,
	  [19]=357,
	  [20]=17,
	  [21]=361,
	  [22]=1657,
	  [23]=1638,
	  [24]=148,
   },
   [2]={
      [1]=139,
      [2]=1,
      [3]=4080,
      [4]=36,
	  [5]=267,
	  [6]=1497,
	  [7]=3433,
	  [8]=8,
	  [9]=85,
	  [10]=10,
	  [11]=1519,
	  [12]=3430,
	  [13]=38,
	  [14]=11,
	  [15]=51,
	  [16]=46,
	  [17]=12,
	  [18]=33,
	  [19]=3,
	  [20]=28,
	  [21]=40,
	  [22]=4,
	  [23]=44,
	  [24]=47,
	  [25]=41,
	  [26]=1537,
	  [27]=3487,
	  [28]=130,
	  [29]=45,
   },
   [3]={
      [1]=3522,
      [2]=3483,
      [3]=3520,
      [4]=3703,
	  [5]=3519,
	  [6]=3518,
	  [7]=3523,
	  [8]=3521,
   },
   [4]={
      [1]=4197,
      [2]=210,
      [3]=3537,
      [4]=495,
	  [5]=2817,
	  [6]=4742,
	  [7]=394,
	  [8]=66,
	  [9]=3711,
	  [10]=4395,
	  [11]=67,
	  [12]=65,
   },
}
   
function MouseMoveXY()
   local left, top = WorldMapDetailFrame:GetLeft(), WorldMapDetailFrame:GetTop()
   local width, height = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
   local scale = WorldMapDetailFrame:GetEffectiveScale()
   local telemap, telezone=GetCurrentMapContinent(), GetCurrentMapZone()
   local telezoneID = TeleMapAll[telemap][telezone]
   local x, y = GetCursorPosition()
   local cx = (x/scale - left) / width
   local cy = (top - y/scale) / height
   
   if cx < 0 or cx > 1 or cy < 0 or cy > 1 then
      return
   end
		if telezoneID==3557 then return (".go xyz -3967 -11704 -139.1 530") end
		if telezoneID==1637 then return (".go xyz 1606 -4393 10.24 1") end
		if telezoneID==1657 then return (".go xyz 9932 2497 1317.82 1") end
		if telezoneID==1638 then return (".go xyz -1251 75 128 1") end
		if telezoneID==1497 then return (".go xyz 1608 240 -52.16 0") end
		if telezoneID==1519 then return (".go xyz -8852 652 96.46 0") end
		if telezoneID==1537 then return (".go xyz -4916 -961 501.5 0") end
		if telezoneID==3487 then return (".go xyz 9737 -7485 13.57 530") end
		if telezoneID==3703 then return (".go xyz -1820 5329 -12.42 530") end
		if telezoneID==4395 then return (".go xyz 5906 640 645.45 571") end
   return (".go zonexy " .. " ".. cx*100 .. " " .. cy*100 .. " " .. telezoneID)
end