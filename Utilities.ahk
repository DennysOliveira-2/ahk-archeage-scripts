#NoEnv 

IsOffCooldown(ByRef timer, cooldown)
{

    current := A_TickCount - timer
    if (current >= cooldown)
    {
        timer := A_TickCount
        Return True
    } else {
        Return False
    }
}

; This function receives as parameter a Window ahk_id to compare with mouse-over window ahk_id
; Returns True if the mouse is over the window in question, false if not.
IsMouseOver(thisWindowId)
{
    MouseGetPos, , , mWinId
    
    if (mWinId == thisWindowId) 
    {
        Return True
    } 
    else 
    {
        Return False
    }
}

hexToDecimal(str){
    static _0:=0,_1:=1,_2:=2,_3:=3,_4:=4,_5:=5,_6:=6,_7:=7,_8:=8,_9:=9,_a:=10,_b:=11,_c:=12,_d:=13,_e:=14,_f:=15
    str:=ltrim(str,"0x `t`n`r"),   len := StrLen(str),  ret:=0
    Loop,Parse,str
      ret += _%A_LoopField%*(16**(len-A_Index))
    return ret
}

decToHex( int, pad=0 ) { 
    ; "Pad" may be the minimum number of digits that should appear on the right of the "0x".

	Static hx := "0123456789ABCDEF"

	If !( 0 < int |= 0 )

		Return !int ? "0x0" : "-" decToHex( -int, pad )

	s := 1 + Floor( Ln( int ) / Ln( 16 ) )

	h := SubStr( "0x0000000000000000", 1, pad := pad < s ? s + 2 : pad < 16 ? pad + 2 : 18 )

	u := A_IsUnicode = 1

	Loop % s

		NumPut( *( &hx + ( ( int & 15 ) << u ) ), h, pad - A_Index << u, "UChar" ), int >>= 4

	Return h
}