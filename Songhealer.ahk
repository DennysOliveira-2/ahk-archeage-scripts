#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force

Pause

target1 := "/target Syrup"
biscuit := 0

aranzebTimer := A_TickCount
meditateTimer := A_TickCount

Loop
{
    Send, !4
    Sleep, 1000
    ;Send, !5
    ;Sleep, 3000
    ;Send, !6
    ;Sleep, 1000

    elapsed := A_TickCount - aranzebTimer
    if (elapsed >= (30 * 60 * 1000))
    {
        Sleep, 2000
        Send, 0
        Send, 0
        Sleep, 15
        Send, 0
        Send, 0
        Sleep, 2000
    }

    ; Set Target
    clipboard := target1
    Send, {Enter}
    Sleep, 250
    Send, ^v
    Sleep, 250
    Send, {Enter}
    
    Sleep, 1000

    ; Cast the following on target:

    ; Song Chantey
    Send, 3
    Random, short, 1250, 1500
    Sleep, short

    Send, 7 ; Mirror Light if available
    Random, short, 1000, 2000
    Sleep, short

    Send, 4 ; Resssurgence
    Random, short, 1000, 2000
    Sleep, short

    ; Song Chantey
    Send, 3
    Random, short, 1250, 1500
    Sleep, short

    ; Hymn
    Send, 6
    Random, short, 1000, 1500
    Sleep, short

    ; Song Chantey
    Send, 3
    Random, short, 1250, 1500
    Sleep, short

    ; Hymn
    Send, 6
    Random, short, 1000, 1500
    Sleep, short

    ; Antithesis
    Send, 5
    Random, short, 1000, 1500
    Sleep, short


 
    elapsed := A_TickCount - meditateTimer
    if (elapsed >= 46000)
    {
        Sleep, 1000
        Send, 9
        Sleep, 5000

        Send, 2
        Sleep, 2000
        Send, 3
        Sleep, 3000
    } else {
        Sleep, 5000

        Send, 2
        Sleep, 2000
        Send, 3
        Sleep, 3000
    }
}

!s::Pause, Toggle

