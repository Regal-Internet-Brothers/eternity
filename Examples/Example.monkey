Strict

Public

' Imports:
Import eternity
Import mojo

' Functions:
Function Main:Int()
	New Application()

	' Return the default response.
	Return 0
End

' Classes:
Class Application Extends App
	' Functions:
	Function CalculateDate:Void()
		Eternity.Calculate()
		
		Print("Current day: " + Eternity.CurrentDay)
		Print("Current date: " + Eternity.CurrentDate)
		Print("Current month: " + Eternity.CurrentMonth)
		Print("Current year: " + Eternity.CurrentYear)
		
		Print("CalculateDateStr: " + Eternity.CalculateDateStr())
	
		Return
	End

	' Methods:
	Method OnCreate:Int()
		SetUpdateRate(60)
		
		CalculateDate()
		Print("MonthsToDays(DaysToMonths): " + Eternity.MonthsToDays(12.0))
		
		RectY = 64
			
		' Return the default response (0 and below are errors).
		Return 1
	End
	
	Method OnRender:Int()
		Cls(205, 205, 205)
		
		DrawRect(RectX, MouseY()-32, 64, 64)
	
		' Return the default response.
		Return 0
	End
	
	Method OnUpdate:Int()	
		' Input related:
		If (KeyHit(KEY_ESCAPE)) Then
			OnClose()
		Endif
		
		If (KeyHit(KEY_F1)) Then
			'Print("Uptime: " + String(Eternity.UptimeInSeconds()))
			Print(Eternity.InstanteMense(String(112232)))
		Endif
		
		'Print("Time: " + CurrentTime())
		'Print("Date: " + CurrentDate(True))
		
		If (KeyHit(KEY_F5)) Then
			CalculateDate()
		Endif
		
		' Update the rectangle's position:
		RectX += 3.5
		
		If (RectX > DeviceWidth()) Then RectX = -64
	
		' Return the default response.
		Return 0
	End
	
	Method OnClose:Int()
		Super.OnClose()
		
		Print("Now closing...")
		
		'Error("")
	
		Return 0
	End
	
	' Fields:
	Field RectX:Float, RectY:Float
End