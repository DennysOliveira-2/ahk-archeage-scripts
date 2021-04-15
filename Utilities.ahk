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

