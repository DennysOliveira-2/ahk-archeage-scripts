; To-DO:
; Dynamic Spell List
; Spell List with Priority Selectable
; Pointer Setters
; Clean Up a little bit 
; Create Timers in a Object for each Spell in SpellList when the Guide is Enabled

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
#Include, ../Utilities.ahk
#Include, CombatFunctions.ahk
#Include, SetterFunctions.ahk

;@Ahk2Exe-Set Version, 0.3.0
;@Ahk2Exe-Set Name, ArcherGuide
;@Ahk2Exe-Set Description, ArcheAge Unchained Virtualized Automation and Helper Software for Monster Grinding
;@Ahk2Exe-SetMainIcon arrows.ico

If (A_IsCompiled)
{
    if (!A_IsAdmin)
    {
        MsgBox, % "This needs to be run in Administrator mode for it to properly work."
        ; Run *RunAs "%A_ScriptFullPath%"
        ExitApp
    }
}


; |============================= Read Config from Local User Saved Data =============================|
; -> Declare Config Standard Variables
Global state := { PAUSED: 0, ACTIVE: 1, CHARACTER_DEAD: 2} ; State Enum
Global Current_State            := state.PAUSED
Global Next_State               := state.PAUSED
Global Gui_Visible              := True
Global ConfigDir                := A_AppData "\Bardsnight\AA ArcherGuide\"
Global ConfigFullPath           := ConfigDir "user.preferences"

; -> Load Variables for Pixel Pointers and Read Values from 'user.preferences' file at %ConfigDir%
Global targetPointer      := { x: _IniRead(ConfigFullPath, "targetPointer",   "x"), y: _IniRead(ConfigFullPath, "targetPointer",   "y"), c: _IniRead(ConfigFullPath, "targetPointer",   "c") }
Global selfManaPointer    := { x: _IniRead(ConfigFullPath, "selfManaPointer", "x"), y: _IniRead(ConfigFullPath, "selfManaPointer", "y"), c: _IniRead(ConfigFullPath, "selfManaPointer", "c") }
Global deathPointer       := { x: _IniRead(ConfigFullPath, "deathPointer",    "x"), y: _IniRead(ConfigFullPath, "deathPointer",    "y"), c: _IniRead(ConfigFullPath, "deathPointer",    "c") }
Global Pointers := { TargetPointer: targetPointer, SelfManaPointer: selfManaPointer, DeathPointer: deathPointer }

; Load Modules (To be done as an dynamic Module Loader in the future)
; Something like Modules := LoadModules(ModulesDirectory)
; The application should provide basic modules, like TargetFinder but should let Users create theirs and it will be Included in this region.HasKey(Key)
Global Modules := { TargetFinder: _IniRead(ConfigFullPath, "EnabledModules", "TargetFinder") }


; -> Check if Targeted Game is Open
Game_Handle := WinExist("ahk_class ArcheAge")
WinGetTitle, Game_Window_Title, "ahk_id %Game_Handle%"
if (!Game_Handle) { ; If the targeted game isn't found, Exit.
    MsgBox, Archeage not found, quitting.
    ExitApp, 704 
}

; |=================================== GUI Setup ===================================|
; -> Create a GUI, name it by 1 and set it as LastFound to iterate with WinSet
Gui, 1:New,     +HwndGui_Handle +AlwaysOnTop +Parent%Game_Handle% -Caption +LastFound
Gui, Add, Tab3, x5 y30 w290 h230, Preferences|Spells|Pointers|Modules
Gui, Tab

; -> Define Gui1 Styles
WinSet, Trans, 225
WinSet, Style, -0x40000000  ; Removes WS_CHILD    
WinSet, Style, +0x0         ; Adds WS_OVERLAPPED  
WinSet, Style, -0x10000     ; Removes WS_MAXIMIZE 
WinSet, Style, -0x20000000  ; Removez WS_MINIMIZE 
WinSet, Style, +0x800000    ; 
Gui,    Color,  Gray        ; Set Main BG Color to Dark Blue

; Non-tab specific Controls
Gui, Tab
Gui, Add, Text,     x150 y15 cBlack, Press [F9] to toggle this GUI. ; Header Text
Gui, Add, Button, w100 h20 x190 y270 gSaveRoutine, Save ; Save Config Button

; Spell Tab Controls
#Include, GUI/Tabs/Spells.ahk

; Pointer Tab Controls
#Include, GUI/Tabs/Pointers.ahk

; Preferences Tab Controls
#Include, GUI/Tabs/Preferences.ahk

; Modules Tab Controls
#Include, GUI/Tabs/Modules.ahk

; GUI Menu
#Include, GUI/Menu/MenuBar.ahk

; Show LastFound Gui
Gui, Font, OxFFFFFF
Gui, Show, x0 y0 w300 h300, SetupGui


; |============================= Automation Functionalities =============================|
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
cd_charged  := 13000
cd_hymn     := 16000
cd_global   := 1000
gcd         := 650

Loop { 
    MouseGetPos, mPosX, mPosY
    ; ToolTip, % "Current State:" Current_State " | Next_State := " Next_State, 300, 25
    

    if(WinActive("ahk_id" Game_Handle))
    {
    ToolTip, % "Pointer x" targetPointer.x " | " targetPointer.y " | " targetPointer.c, 300, 25
        
        
        if (Current_State == state.ACTIVE)
        {
            if (IsDead()) {
                ToggleGui()
                WarnDeath()
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
                else if (IsManaHigh(selfManaPointer) && IsOffCooldown(timer_hymn, cd_hymn)) ; -> Is [Healing Hymn] off-Cooldown and Mana is high enough? Cast it.
                {
                    
                    Send, {q Up} ; -> Clear Endless Arrow
                    Sleep, 150

                    Sleep, 850
                    Send, z
                    Sleep, 250

                    timer_hymn := A_TickCount ; <- Reset Timer
                    
                } ; 

                if (Modules.TargetFinder == 1)
                {
                    TryFindTarget(Game_Handle) ; -> Nothing to cast off-Combat, no priorities -> Try and Find a new Target
                }

                if (!HasTarget())
                {
                    SentientSleep(2000)
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
                                    Send, 4


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
    }
    ToolTip, 
}

HasTarget()
{
    MsgBox, % "x "targetPointer.x "y " targetPointer.y "c " targetPointer.c
    PixelGetColor, current, targetPointer.x, targetPointer.y, RGB
    
    if (current == targetPointer.c) {
        Return True
    } else {
        Return False
    }
}

IsDead()
{
    PixelGetColor, cur, deathPointer.x, deathPointer.y, RGB

    if (cur == deathPointer.c)
    {
        ; MsgBox, Died. Pausing script.
        Return True
    } 
    else 
    {
        Return False
    }
}

SentientSleep(timeInMs) {
    ; What should happen before the loop starts

    startTime := A_TickCount ; 1000
    current :=  ; 1001 - 1000
    
    While ((A_TickCount - startTime) <= timeInMs)
    {
        ; Do Function Checks every 50s to Break the SentientSleep if needed
        if (HasTarget()) {
            Break
        }

        Sleep, 50
    }

    ; Whatever happens after the loop time
}


; -> Script Functions
WarnDeath()
{
    ; Do Something to warn the user about his character Death, besides pausing execution
}

ToggleGui()
{
        
    If (Gui_Visible = True)
    {
        ; Hide the GUI and set state to the last state
        ; MsgBox, % "Debug> Iterating through HIDE GUI"
        Gui, Hide
        Gui_Visible := False
        Current_State := Next_State
        WinActivate, "ahk_exe notepad.exe"
    }
    Else 
    {
        ; Shows GUI and store Last State
        ; MsgBox, % "Debug> Iterating through SHOW GUI"
        Gui, Show
        Gui_Visible := True

        Next_State := Current_State   ; Stores Current_State so it can start over when the GUI is minimized again
        Current_State := state.PAUSED ; Sets Current_State to PAUSED
        WinActivate, 
    }  
}


; |===== GUI Coroutines =====|
; SaveRoutine called by User
SaveRoutine:
{
    Return
}

; ExitRoutine called by User
ExitRoutine:
{
    MsgBox 4,, Are you sure you want to exit?
    IfMsgBox, No
        Return
    IfMsgBox, Yes
        ExitApp, 701 ; Status Code Base (700) + Called by User (001)
}

DebugRoutine:
{
        MsgBox, % "Gui_Visible: " Gui_Visible " | Current_State: " Current_State
    Return
}

AboutRoutine:
{
    Return
}

ModuleChangedRoutine:
{
    Gui, Submit, NoHide
    ; In the future, I should check existent modules in a array and iterate their values (maybe?)

    ; Update Module Checkboxes as they change and update Active Modules State
    Modules := { TargetFinder: Checkbox_TargetFinder  }

    For key, value in Modules
    {
        _IniWrite(value, ConfigFullPath, "EnabledModules", key)
    }

    ; To-do
    ; For key, value in modules 
    ; {

    ; }

    Return
}

#Include, Routines/Setters/Pointers.ahk

ToggleAction:
{
    Gui, Submit, NoHide
    if (Checkbox_EnabledAction == 1)
    {
        Next_State := state.ACTIVE 
    } else {
        Next_State := state.PAUSED
    }
    Return
}

DebugF()
{
    MsgBox, % "Next_State: " Next_State " | Current_State: " Current_State " | " 
}

F8::DebugF()
F9::ToggleGui()