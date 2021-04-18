#Include, ../Utilities.ahk
#Include, Main.ahk

; Timer for skills to only detect targets
Global snipe_timer         := A_TickCount
Global concussive_timer    := A_TickCount

; Cooldowns for skills above
Global snipe_cd        := 35000
Global concussive_cd   := 31000

IsManaHigh(pointer)
{
    ; Get current
    PixelGetColor, currentColor, pointer.x, pointer.y, RGB

    if (currentColor == pointer.c) ; If mana is ABOVE the point declared as enough, 
    {
        Return True
    } else {
        
        Return False
    }
}


TryFindTarget(gameWinId)
{
    
    WinGetPos, winPosX, winPosY, winWidth, winHeight, gameWinId

    if (IsMouseOver(gameWinId))
    {
        Sleep, 100
        
        ; 0 degrees
        FindSkills()

        ; 90 degrees
        If(!HasTarget())
        {
            RotateClockwise90()
            FindSkills()
        }

        ; 180 degrees
        If(!HasTarget())
        {
            RotateClockwise90()
            FindSkills()
        }

        ; 270 degrees
        If(!HasTarget())
        {
            RotateClockwise90()
            FindSkills()
        }
    }
}

RotateClockwise90()
{
    Send, {Home}

    Sleep, 100

    Random, rand, 15, 30
    Send, {w Down}
    Sleep, rand
    Send, {w Up}

    Random, rand, 15, 30
    Send, {s Down}
    Sleep, rand
    Send, {s Up}
    
    Sleep, 100
}

FindSkills()
{
    ; -> Try SHORT RANGE
    Send, 1
    Sleep, 25

    Send, 2
    Sleep, 25

    Send, q
    Sleep, 25

    ; -> Try LONG RANGE
    if (!HasTarget() And IsManaHigh(selfManaPointer)) {
            if (IsOffCooldown(snipe_timer, snipe_cd))
            {
                Send, 4
                Sleep, 750
                Send, 4
                Send, 4
            }
    }
}