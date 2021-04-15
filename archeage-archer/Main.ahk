#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
#Include, ../Utilities.ahk
#Include, CombatFunctions.ahk
#Include, SetterFunctions.ahk

;@Ahk2Exe-Set Version, 0.2.0
;@Ahk2Exe-Set Name, AAGodlyArcher
;@Ahk2Exe-Set Description, ArcheAge Unchained Archer Virtualized Automation and Helper Software for Monster Grind.
;@Ahk2Exe-SetMainIcon arrows.ico


; if not A_IsAdmin
; {
;     Run *RunAs "%A_ScriptFullPath%"
;     ExitApp
; }

hWnd := WinExist("ahk_exe archeage.exe")
if (hWnd){

} else {
    MsgBox, Archeage not found, quitting.
    Exit
}



Pause

; Timers Boot Up -> Still needed to declare them as most functions will reference them and change their values globally - haven't found a better way to design this yet.
timer_endless   := A_TickCount
timer_blazing   := A_TickCount
timer_charged   := A_TickCount
timer_meditate  := A_TickCount
timer_thwart    := A_TickCount
timer_hymn      := A_TickCount
timer_gcd       := A_TickCount

; Cooldowns (in milliseconds) -> To be set in a GUI for better UX in the future
cd_thwart   := 16000
cd_meditate := 35000
cd_blazing  := 10000
cd_charged  := 13000q
cd_hymn     := 16000
cd_global := 1000

gcd := 650

; Declare variables
Global targetBarX
Global targetBarY
Global targetBarC

Global deathWinPosX
Global deathWinPosY
Global deathWinPosC

Global manaExpendX
Global manaExpendY
Global manaExpendC


; -> Read Initial Values from File
IniRead, targetBarX,  archerArcher.ini, targetBar, x, -55
IniRead, targetBarY,  archerArcher.ini, targetBar, y, -55
IniRead, targetBarC,  archerArcher.ini, targetBar, c, -55

IniRead, manaExpendX,  archerArcher.ini, manaExpend, x, -55
IniRead, manaExpendY,  archerArcher.ini, manaExpend, y, -55
IniRead, manaExpendC,  archerArcher.ini, manaExpend, c, -55

IniRead, deathWinPosX, archerArcher.ini, deathWin, x, -55
IniRead, deathWinPosY, archerArcher.ini, deathWin, y, -55
IniRead, deathWinPosC, archerArcher.ini, deathWin, c, -55


Loop { 
    MouseGetPos, mPosX, mPosY

    ; If Target Bar not Set, Set it
    if (targetBarX == -55)
        SetTargetBar()
    
    
    if(WinActive(ahk_id %hWnd%))
    {
        if (IsDead())
        {
            Pause, On
        }

        ; -> Doesn't have a Target
        if (!HasTarget()) 
        {
            Send, {q Up}
            
            
            if (IsOffCooldown(timer_meditate, cd_meditate)) ; -> Is [Meditate] off-Cooldown? Cast it.
            {
                Send, {q Up} ; -> Clear Endless Arrow
                
                Sleep, 150
                
                
                Sleep, 250
                Send, 5
                SentientSleep(1000)
                
                SentientSleep(4000) ; -> Wait for Cast -> should create a function for SentientWait (sleep but check something )

                
                timer_meditate := A_TickCount 
                
            } 
            else if (IsOffCooldown(timer_thwart, cd_thwart)) ; -> Is [Thwart] off-Cooldown? Cast it.
            {
                Send, {q Up} ; -> Clear Endless Arrow
                Sleep, 150                
                
                Sleep, 400
                Send, 3 ; -> Send Thwart Key
                Sleep, 250
                
                timer_thwart := A_TickCount

            } 
            else if (IsManaHigh(manaExpendX, manaExpendY, manaExpendC) && IsOffCooldown(timer_hymn, cd_hymn)) ; -> Is [Healing Hymn] off-Cooldown and Mana is high enough? Cast it.
            {
                
                Send, {q Up} ; -> Clear Endless Arrow
                Sleep, 150

                Sleep, 850
                Send, z
                Sleep, 250

                timer_hymn := A_TickCount ; <- Reset Timer
                
            } ; 

            TryFindTarget(hWnd) ; -> Nothing to cast off-Combat, no priorities -> Try and Find a new Target
            if (!HasTarget())
            {
                SentientSleep(3000)
            } 
            else 
            {
                Sleep, %gcd%
            }
        } 
        else ; Has a Target
        {
            
            

            if (IsOffCooldown(timer_thwart, cd_thwart))
            {
                Send, {q Up} ; -> Clear Endless Arrow
                Sleep, 500

                Send, 3
                

                timer_thwart := A_TickCount
                Sleep, 100
            }
            ; else if (isOffCooldown(timer_charged, cd_charged)) 
            ; {
            ;     Send, {q Up} ; -> Clear Endless Arrow
            ;     Sleep, 450

            ;     Send, 2
            ;     Sleep, 25
            ;     Send, 2
            ;     Sleep, 25
            ;     Send, 2

            ;     timer_charged := A_TickCount
            ;     Sleep, 100
            ; }
            ; else if (IsOffCooldown(timer_blazing, cd_blazing)) 
            ; {
            ;     Send, {q Up} ; -> Clear Endless Arrow
            ;     Sleep, 450

            ;     Send, 1
            ;     Sleep, 25
            ;     Send, 1
            ;     Sleep, 25
            ;     Send, 1

            ;     timer_blazing := A_TickCount
            ;     Sleep, 100

            ; } 
            
            
            

            Sleep, 10

            Send, {q Down}

        }
    }
    ToolTip, 
}


; Setter Functions --> to be moved to a different file and refactored into functions that return a object containing the specific requested properties.
SetTargetBar()
{
    MouseGetPos, mPosX, mPosYq
    While !GetKeyState("LButton") {
        MouseGetPos, mPosX, mPosY
        ToolTip, Click on the HP Bar, mPosX + 30, mPosY + 40
    }
    
    targetBarX := mPosX
    targetBarY := mPosY
    PixelGetColor, targetBarC, mPosX, mPosY


    IniWrite, %targetBarX%, archerArcher.ini, targetBar, x
    IniWrite, %targetBarY%, archerArcher.ini, targetBar, y
    IniWrite, %targetBarC%, archerArcher.ini, targetBar, c

    ToolTip, 

    
}

SetSelfManaToExpend()
{
    MouseGetPos, mPosX, mPosYq
    While !GetKeyState("LButton") {
        MouseGetPos, mPosX, mPosY
        ToolTip, Click on your MPBar at a middle point for casts, mPosX + 30, mPosY + 40
    }
    
    manaExpendX := mPosX
    manaExpendY := mPosY
    PixelGetColor, manaExpendc, mPosX, mPosY


    IniWrite, %manaExpendX%, archerArcher.ini, manaExpend, x
    IniWrite, %manaExpendY%, archerArcher.ini, manaExpend, y
    IniWrite, %manaExpendC%, archerArcher.ini, manaExpend, c

    ToolTip, 
}

SetDeathWindow()
{
    MouseGetPos, mPosX, mPosYq
    While !GetKeyState("LButton") {
        MouseGetPos, mPosX, mPosY
        ToolTip, Click on your Death Window, mPosX + 30, mPosY + 40
    }
    
    deathWinPosX := mPosX
    deathWinPosY := mPosY
    PixelGetColor, deathWinPosC, mPosX, mPosY


    IniWrite, %deathWinPosC%, archerArcher.ini, deathWin, x
    IniWrite, %deathWinPosY%, archerArcher.ini, deathWin, y
    IniWrite, %deathWinPosC%, archerArcher.ini, deathWin, c

    ToolTip, 
}

HasTarget()
{
    PixelGetColor, current, targetBarX, targetBarY
    ; MsgBox, % "current is [" current "] and target is [" targetBarC "]"

    if (current == targetBarC) {
        Return True
    } else {
        Return False
    }
}
; DEPRECATED
; ShouldCastHymn(timer, cooldown)
; {
;     exhaust := A_TickCount - timer
;     if (exhaust >= cooldown)
;     {
;         Return True
;     } else {
;         Return False
;     }

; }
IsDead()
{
    PixelGetColor, curr, deathWinPosX, deathWinPosY

    if (curr == deathWinPosC)
    {
        MsgBox, Died. Pausing script.
        Pause, On

        Return True
    } 
    else 
    {
        Return False
    }
}

SentientSleep(timeInMs)
{
    startTime := A_TickCount ; 1000
    current :=  ; 1001 - 1000
    
    While ((A_TickCount - startTime) <= timeInMs)
    {
        if (HasTarget())
        {
            Break
        } else {
            Sleep, 50
        }
        ; Do Function Checks to Break the SentientSleep if needed
        ; if (HaveTarget())
        ; {
        ;     Break
        ; } else {
        ;     Sleep, 100
        ; }
    }

    ; Whatever happens after the time specified
}


; -> Script Functions
TogglePause()
{
    Pause, Toggle
    Send, {q Up} ; -> Clear Endless Arrow Key
}

Configurate()
{
    SetTargetBar()
    Sleep, 500
    SetSelfManaToExpend()
}

F5::Pause, Toggle ; -> Toggle the script Active or Paused state. Cooldowns will remain counting even while paused.
!F5::Configurate() ; -> Boot up the configuration setup for Target & Self bars localization
!F6::SetDeathWindow()