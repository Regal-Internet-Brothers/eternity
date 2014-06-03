Strict

Public

' Imports:
#If BRL_GAMETARGET_IMPLEMENTED
	Import mojo.app
#Else
	Import mojoemulator
	Import time
#End

' Classes:
Class Eternity ' Effectively a namespace.
	' Global & Constant variables:
	
	' Second related:
	
	' The length of a second. (In milliseconds)
	Const SecondLength:Float = 1000.0
	
	' Minute related:
	
	' The length of a minute. (In seconds)
	Const MinuteLength:Float = 60.0
	
	' Hour related:
	
	' The length of an hour. (In minutes)
	Const HourLength:Float = MinuteLength ' 60.0
	
	' Day related:
	Const Sunday:String = "Sunday"
	Const Monday:String = "Monday"
	Const Tuesday:String = "Tuesday"
	Const Wednesday:String = "Wednesday"
	Const Thursday:String = "Thursday"
	Const Friday:String = "Friday"
	Const Saturday:String = "Saturday"
	
	Global Days:String[] = [Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]
	
	' The length of a day. (In hours)
	Const DayLength:Float = 24.0
	
	' Week related:
	
	' The length of a week. (In days)
	Const WeekLength:Int = 7
	
	' String formatting related:
	Const January:String = "January"
	Const February:String = "February"
	Const March:String = "March"
	Const April:String = "April"
	Const May:String = "May"
	Const June:String = "June"
	Const July:String = "July"
	Const August:String = "August"
	Const September:String = "September"
	Const October:String = "October"
	Const November:String = "November"
	Const December:String = "December"
	
	Global Formatting_Inst:String[] = ["st", "nd", "rd", "th"]
	Global Formatting_Months:String[] = [January, February, March, April, May, June, July, August, September, October, November, December]
	
	' Month related:
	
	' Day calculation table(s):
	Global DayCalculation_MonthTable:Int[] = [0, 3, 3, 6, 1, 4, 6, 2, 5, 0, 3, 5]
	Global DayCalculation_MonthTable_Leap:Int[] = [-1, 2]
	
	' The length used for the shortened names for months.
	Const ShortenedMonthSize:Int = 3
	
	' Shortened versions of each of the months' names:
	Global Months:String[] =
		[Formatting_Months[0][..ShortenedMonthSize], Formatting_Months[1][..ShortenedMonthSize], Formatting_Months[2][..ShortenedMonthSize],
		Formatting_Months[3][..ShortenedMonthSize], Formatting_Months[4][..ShortenedMonthSize], Formatting_Months[5][..ShortenedMonthSize],
		Formatting_Months[6][..ShortenedMonthSize], Formatting_Months[7][..ShortenedMonthSize], Formatting_Months[8][..ShortenedMonthSize],
		Formatting_Months[9][..ShortenedMonthSize], Formatting_Months[10][..ShortenedMonthSize], Formatting_Months[11][..ShortenedMonthSize]]
	
	' The lengths of each month of the year. (In days)
	Global MonthLengths:Int[] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] ' February's leap-day is handled separately.
	
	' The average length of a month.
	Const MonthAverage:Float = (YearLength / 12.0) ' 30.4375 ' If we use 365 and not 365.25, the number would be 30.416666666... Or just 30.416 would work.
	
	' Year related:
	
	' The length of a year in days.
	Const YearLength:Float = 365.25
	
	' The length of a year in months.
	Const YearInMonths:Float = YearLength / MonthAverage
	
	' The length of a year in weeks.
	Const YearInWeeks:Float = YearLength / WeekLength
	
	' Usually provided by the 'Mojo.App' module.
	Global Data:Int[]
	
	' All of the information we need about the current date:
	Global Calculated:Bool = False
	
	Global CurrentDate:Int
	Global CurrentDay:String
	Global CurrentMonth:String
	Global CurrentYear:Int
	
	' This will stay as 2000 for now. There's no real reason to change it.
	' If this code is used in any century but our current one, they'll just have to deal with incorrect day names.
	Const CurrentCentury:Int = 2000 ' 21st
		
	' Anything else can be easily extracted from the 'Data' variable.
	
	' Functions:
	
	' Date related functions:
	Function Month:Int(MonthData:String)	
		For Local Index:Int = 0 Until Months.Length()
			If (Months[Index] = MonthData) Then
				' Not normally my style, but I suppose it is faster.
				Return (Index+1)
			Endif
		Next
		
		Return 0
	End
	
	Function Calculate:Void(Refresh:Bool=False)
		If (Refresh Or Not Calculated) Then
			GetDate([], Refresh)
		Else
			GetDate(app.GetDate())
		Endif
		
		CalculateYear()
		CalculateMonth()
		CalculateDate()
		
		CalculateDay()
		
		Calculated = True
	
		Return
	End
	
	Function CalculateMonth:String(SetVariable:Bool=True, DateInfo:Int[]=[])
		' The 'GetDate' command will check if the array is there.
		GetDate(DateInfo)
		
		' Local variable(s):
		Local CM:= Months[Data[1]-1]
		
		' If we're supposed to be setting the current month, do so:
		If (SetVariable) Then
			CurrentMonth = CM
		Endif
		
		' Return the current month.
		Return CM
	End
	
	Function CalculateDay:String(SetVariable:Bool=True, DateInfo:Int[]=[])
		GetDate(DateInfo)
		
		Local M:Int = Month(CurrentMonth)-1
		Local LeapResponse:Bool = IsLeapYear(CurrentYear) And M+1 < DayCalculation_MonthTable_Leap.Length
		
		If (LeapResponse) Then
			M = DayCalculation_MonthTable_Leap[M]
		Else
			M = DayCalculation_MonthTable[M]
		Endif
		
		Local Y:= CurrentYear Mod 100
		
		' Local variables:
		Local Day:= Days[((CurrentDate + M + Y + (Y/4) + (CurrentCentury Mod 4)-1) Mod WeekLength)]
		
		IF (SetVariable) Then
			CurrentDay = Day
		Endif
		
		Return Day
	End
	
	Function CalculateDateStr:String(SetVariable:Bool=True, DateInfo:Int[]=[])
		' Run the standard command.
		CalculateDate(SetVariable, DateInfo)
			
		' Return the current day.
		Return (("0"+String(CurrentDate))[-2..])
	End
	
	Function CalculateDate:Int(SetVariable:Bool=True, DateInfo:Int[]=[])
		' The 'GetDate' command will check if the array is there.
		GetDate(DateInfo)
	
		' Local variable(s):
		Local CD:Int = Data[2]
		
		' If we're supposed to be setting the current day, do so:
		If (SetVariable) Then
			CurrentDate = CD
		EndIf
		
		' Return the current day.
		Return CD
	End
	
	Function CalculateYear:Int(SetVariable:Bool=True, DateInfo:Int[]=[])
		' The 'GetDate' command will check if the array is there.
		GetDate(DateInfo)
	
		' Local variable(s):
		Local CY:Int = Data[0]
		
		' If we're supposed to be setting the current year, do so:
		If (SetVariable) Then
			CurrentYear = CY
		Endif
	
		' Return the current year.
		Return CY
	End
	
	Function CalculateLeap:Float(Input:Float)
		Return (0.25*4.0-((CurrentYear + Input) Mod 4.0))
	End
	
	Function IsLeapYear:Bool(Y:Int)
		Return (((Y Mod 4) = 0) And ((Y Mod 100) <> 0) Or ((Y Mod 400) = 0))
	End
	
	Function GetDate:Int[](DateInfo:Int[]=[], Refresh:Bool=False)
		If (DateInfo.Length() Or Refresh) Then
			Return SetDateToRef(DateInfo)
		Else
			If (Data.Length() = 0) Then
				Data = app.GetDate()
			EndIf
		Endif
		
		Return Data
	End
	
	Function SetDate:Int[](DateInfo:Int[])
		' Clone the 'Data' variable to a clone of 'DateInfo'.
		Data = DateInfo.Resize(DateInfo.Length())
	
		Return Data
	End
	
	Function SetDateToRef:Int[](DataInfo:Int[])
		Data = DataInfo
	
		Return Data
	End
	
	Function InstanteMense:String(Data:String)
		If (Data.Length() = 0) Then Return Data
	
		' Remove any unwanted characters.
		Data = String(Int(Data))
		
		' Add an 'inst.' to the string specified:
		If (Data.Length() > 1 And Data[Data.Length()-2..][..1] = "1") Then
			Data += Formatting_Inst[3]
		Else
			Select Data[Data.Length()-1..]
				Case "1"
					Data += Formatting_Inst[0]
				Case "2"
					Data += Formatting_Inst[1]
				Case "3"
					Data += Formatting_Inst[2]
				Default
					Data += Formatting_Inst[3]
			End Select
		Endif
			
		' Return the final string.
		Return Data
	End
	
	Function Inst:String(Data:String)
		Return InstanteMense(Data)
	End
	
	Function FullMonth:String(MonthIN:String, FallbackToInput:Bool=True)
		' Local variable(s):
		Local MonthOUT:String
		
		If (FallbackToInput) Then MonthOUT = MonthIN
	
		For Local Index:Int = 0 Until Months.Length()
			If (MonthIN = Formatting_Months[Index][..ShortenedMonthSize]) Then
				MonthOUT = Formatting_Months[Index]
			
				Exit
			Endif
		Next
		
		Return MonthOUT
	End
	
	Function ShortMonth:String(Month:String)
		' I was originally going to have this act like 'FullMonth',
		' but there really isn't any point in that. (Unless I have different name lengths)
		Return Month[..ShortenedMonthSize]
	End
	
	' Time related functions:
	' Fills the date array with 7 integers representing the current date: year, month (1-12), day (1-31), hours (0-23), minutes (0-59), seconds (0-59) and milliseconds (0-999).
	
	Function TimeInMilliseconds:Int(Refresh:Bool=True)
		Calculate(Refresh)
		
		Return Data[6]
	End
		
	Function TimeInSeconds:Float(Refresh:Bool=True)	
		Calculate(Refresh)
		
		Return Float(Data[5] + Float(MillisecondsToSeconds(TimeInMilliseconds(False))))
	End
	
	Function TimeInMinutes:Float(Refresh:Bool=True)
		Calculate(Refresh)
		
		Return Float(Data[4] + Float(SecondsToMinutes(TimeInSeconds(False))))
	End
	
	Function TimeInHours:Float(Refresh:Bool=True)
		Calculate(Refresh)
	
		Return Float(Data[3] + Float(MinutesToHours(TimeInMinutes(False))))
	End
	
	Function TimeInDays:Float(Refresh:Bool=True)
		Calculate(Refresh)
		
		Return Float(CurrentDate + Float(HoursToDays(TimeInHours(False)))) ' Data[2]
	End
	
	Function TimeInMonths:Float(Refresh:Bool=True)
		Calculate(Refresh)
		
		Return Float(Data[1] + Float(DaysToMonths(TimeInDays(False))))
	End
	
	Function TimeInYears:Float(Refresh:Bool=True)
		Calculate(Refresh)
		
		Return Float(CurrentYear + Float(MonthsToYears(TimeInMonths(False)))) ' Data[0]
	End
	
	' Up-time related functions:
	Function Uptime:Int()
		Return Millisecs()
	End
	
	Function UptimeInSeconds:Float()
		Return MillisecondsToSeconds(Uptime())
	End
	
	Function UptimeInMinutes:Float()
		Return SecondsToMinutes(UptimeInSeconds())
	End
	
	Function UptimeInHours:Float()
		Return MinutesToHours(UptimeInMinutes())
	End
	
	Function UptimeInDays:Float()
		Return HoursToDays(UptimeInHours())
	End
	
	Function UptimeInWeeks:Float()
		Return DaysToWeeks(UptimeInDays())
	End
	
	Function UptimeInMonths:Float()
		Return WeeksToMonths(UptimeInWeeks())
	End
	
	Function UptimeInYears:Float()
		'Return (UptimeInWeeks() / 52)
		Return DaysToYears(UptimeInDays())
	End
	
	' Conversion related functions:
	Function SecondsToMilliseconds:Int(Seconds:Float)
		Return (Seconds * SecondLength)
	End
	
	Function MillisecondsToSeconds:Float(Milliseconds:Int)
		Return (Milliseconds / SecondLength)
	End
	
	Function SecondsToMinutes:Float(Seconds:Float)
		Return (Seconds / MinuteLength)
	End
	
	Function MinutesToSeconds:Float(Minutes:Float)
		Return (Minutes * SecondLength)
	End
	
	Function MinutesToHours:Float(Minutes:Float)
		Return SecondsToMinutes(Minutes)
		'Return (Minutes / HourLength)
	End
	
	Function HoursToMinutes:Float(Hours:Float)
		Return MinutesToSeconds(Hours)
		'Return (Hours * MinuteLength)
	End
	
	Function DaysToHours:Float(Days:Float)
		Return (Days * DayLength)
	End
	
	Function HoursToDays:Float(Hours:Float)
		Return (Hours / DayLength)
	End
	
	Function WeeksToDays:Float(Weeks:Float)
		Return (Weeks * WeekLength)
	End
	
	Function DaysToWeeks:Float(Days:Float)
		Return (Days / WeekLength)
	End
		
	Function MonthsToDays:Float(Months:Float)
		#Rem
		Local M:= New Int[Max(Int(Months), 1)]
	
		For Local Index:Int = 0 Until Max(Int(Months), 1)
			M[Index] = Index+1
		Next
		
		Return (MonthsToDays(M) + (MonthAverage * GetPrecision(Months)))
		#End
		
		Return (Months * MonthAverage)
	End
	
	Function MonthsToDays:Float(MonthsIN:Int[])
		Local Days:Float = 0.0
		
		For Local Index:Int = 0 Until MonthsIN.Length()
			If (MonthsIN[Index] > Months.Length()) Then Exit
			
			Days += MonthLengths[Max(MonthsIN[Index]-1, 0)]
		Next
		
		Return Days + CalculateLeap(MonthsToYears(Float(MonthsIN.Length())))
	End
	
	Function DaysToMonths:Float(Days:Float)
		Return (Days / MonthAverage)
	End
	
	Function WeeksToMonths:Float(Weeks:Float)
		' Not the most accurate, but it works.
		Return (WeeksToDays(Weeks) / MonthAverage)
	End
	
	Function MonthsToWeeks:Float(Months:Float)
		Return (MonthsToDays(Months) / WeekLength)
	End
	
	Function YearsToDays:Float(Years:Float)
		Return (Years * YearLength)
	End
	
	Function DaysToYears:Float(Days:Float)
		Return (Days / YearLength)
	End
	
	Function YearsToWeeks:Float(Years:Float)
		Return (Years * YearInWeeks)
	End
	
	Function WeeksToYears:Float(Weeks:Float)
		Return (Weeks / YearInWeeks)
	End
	
	Function YearsToMonths:Float(Years:Float)
		Return (Years * YearInMonths)
	End
	
	Function MonthsToYears:Float(Months:Float)
		Return (Months / YearInMonths)
	End
End

' Functions (Private):
Private

' Not exactly fast, but it works:
Function GetPrecision:Float(F:Float)
	Local StrFloat:= String(F)
	
	Return Float("0." + String(StrFloat[StrFloat.Find(".")+1..]))
End

Public

' Functions (Public):
Function CurrentTime:String()
	' Example: "07:52:54"
	Return (("0"+String(Int(Eternity.TimeInHours())))[-2..] + ":" + ("0"+String(Int(Eternity.TimeInMinutes())))[-2..] + ":" + ("0"+String(Int(Eternity.TimeInSeconds())))[-2..])
End

Function CurrentDate:String(Formatted:Bool=False)
	Eternity.Calculate()

	If (Formatted) Then
		Return (Eternity.FullMonth(Eternity.CurrentMonth) + " " + Eternity.InstanteMense(Eternity.CurrentDate) + " " + Eternity.CurrentYear)
	Endif
	
	Return (Eternity.CalculateDateStr() + " " + Eternity.CurrentMonth + " " + Eternity.CurrentYear) ' "20 Jan 2013"
End

' Unused:

' Day-name related:
#Rem
	Global Sunday:String = "Sunday"
	Global Monday:String = "Monday"
	Global Tuesday:String = "Tuesday"
	Global Wednesday:String = "Wednesday"
	Global Thursday:String = "Thursday"
	Global Friday:String = "Friday"
	Global Saturday:String = "Saturday"
	
	Global Days:String[] = [Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]
#End