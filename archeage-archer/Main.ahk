; To-DO:
; Update Control Text from each Pointer when they change
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

;@Ahk2Exe-Set Version, 0.2.0
;@Ahk2Exe-Set Name, AAGodlyArcher
;@Ahk2Exe-Set Description, ArcheAge Unchained Archer Virtualized Automation and Helper Software for Monster Grind.
;@Ahk2Exe-SetMainIcon arrows.ico


; if not A_IsAdmin
; {
;     Run *RunAs "%A_ScriptFullPath%"
;     ExitApp
; }

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
Global Pointers := {TargetPointer: targetPointer, SelfManaPointer: selfManaPointer, DeathPointer: deathPointer}
; Debug -> MsgBox, % "targetPointer.x -> " targetPointer.x " | targetPointer.y -> " targetPointer.y " | targetPointer.c -> " targetPointer.c

; Load Modules (To be done as an dynamic Module Loader in the future)
; Something like Modules := LoadModules(ModulesDirectory)
; The application should provide basic modules, like TargetFinder but should let Users create theirs and it will be Included in this region.HasKey(Key)
Global Modules := { TargetFinder: _IniRead(ConfigFullPath, "EnabledModules", "TargetFinder") }


; |============================= GUI Setup =============================|
; -> Check if Targeted Game is Open
Game_Handle := WinExist("ahk_exe archeage.exe")
if (!Game_Handle) {
    MsgBox, Archeage not found, quitting.
    ExitApp, 704 
}

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
WinSet, Style, +0x10000000L ; Add WS_VISIBLE

Gui,    Color,  White       ; Set Main BG Color to Dark Blue
Gui,    Font,   White       ; Set font Styling

; Non-tab specific Controls
Gui, Tab
Gui, Add, Text,     x150 y15 cBlack, Press [F9] to toggle this GUI. ; Header Text
Gui, Add, Button, w100 h20 x190 y270 gSaveRoutine, Save ; Save Config Button

; Spell Tab Controls

; Pointers Tab Controls
Gui, Tab, Pointers
For key, value in Pointers
{
    color := SubStr(value.c, 3)
    Gui, Font, Bold
    Gui, Add, Text, w200 vControl_Text%key% c%color%, % "X: [" value.x "] Y: [" value.y "] C: [" color  "]"
    
    Gui, Font
    Gui, Add, Button, w120 gSet%key%Routine, Set %key%
    Gui, Font
}

; Preferences Tab Controls
Gui, Tab, Preferences
Gui, Add, Text, x+5 y+5 r2 w210, User Preferences                                       Do not forget to hit SAVE before exiting.
Gui, Add, Checkbox,  vCheckbox_EnabledAction gToggleAction, Enable Guide

; Modules Tab Controls
Gui, Tab, Modules 
Gui, Add, Text, x+5 y+5 , Enabled Modules

For key, value in Modules
{
    if (value == 1) {
        Gui, Add, CheckBox, vCheckbox_%key% gModuleChangedRoutine Checked, %key%
    } else {
        Gui, Add, CheckBox, vCheckbox_%key% gModuleChangedRoutine, %key%
    }
}
; Gui, Add, CheckBox, x15 y55 vC_ToBeDone         gModChangedRoutine, To Be Done

; Declares SubMenus and their Options
Menu, File_SMenu,   Add,    &Save,     SaveRoutine
Menu, File_SMenu,   Add,    &Exit,     ExitRoutine
Menu, Tools_SMenu,  Add,    &Debug,    DebugRoutine
Menu, Help_SMenu,   Add,    &About,    AboutRoutine

; Adds Submenus to MenuBar
Menu, MenuBar,      Add,    &File,     :File_SMenu
Menu, MenuBar,      Add,    &Tools,    :Tools_SMenu
Menu, MenuBar,      Add,    &Help,     :Help_SMenu

; Define MenuBar Styles
Menu, MenuBar,      Color,  White

; Append menu "MenuBar" to LastFound Gui
Gui, Menu, MenuBar 

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
    
    if(WinActive(ahk_id %Game_Handle%))
    {
        if (IsDead())
        {
            Pause, On
        }
        
        if (Current_State == state.ACTIVE)
        {
            ; -> Doesn't have a Target
            if (!HasTarget(targetPointer)) 
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

                if (!HasTarget(targetPointer))
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

HasTarget(pointer)
{
    PixelGetColor, current, pointer.x, pointer.y
    ; MsgBox, % "current is [" current "] and target is [" targetBarC "]"

    if (current == pointer.c) {
        Return True
    } else {
        Return False
    }
}

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
        if (HasTarget(targetPointer))
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

_IniRead(filename, section, key)
{
    IniRead, output, %filename%, %section%, %key% , null
    Return %output%
}

_IniWrite(value, filename, section, key)
{
    extractedValue := %value%
    
    IniWrite, %value%, %filename%, %section%, %key%
    Return 1
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
    }
    Else 
    {
        ; Shows GUI and store Last State
        ; MsgBox, % "Debug> Iterating through SHOW GUI"
        Gui, Show
        Gui_Visible := True

        Next_State := Current_State   ; Stores Current_State so it can start over when the GUI is minimized again
        Current_State := state.PAUSED ; Sets Current_State to PAUSED
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



SetTargetPointerRoutine:
{
    Gui, Hide
    MouseGetPos, mPosX, mPosYq
    While !GetKeyState("LButton") {
        MouseGetPos, mPosX, mPosY
        ToolTip, Click on the beginning of your target Mana Bar, mPosX + 30, mPosY + 40
    }
    
    
    PixelGetColor, curColor, mPosX, mPosY
    targetPointer.x := mPosX
    targetPointer.y := mPosY
    targetPointer.c := curColor

    
    _IniWrite(targetPointer.x, ConfigFullPath, "targetPointer", "x")
    _IniWrite(targetPointer.y, ConfigFullPath, "targetPointer", "y")
    _IniWrite(targetPointer.c, ConfigFullPath, "targetPointer", "c")
    
    Gui, Show

    ToolTip, 
    
    UpdateAllPointers()
}

SetSelfManaPointerRoutine:
{

}

SetDeathPointerRoutine:
{

}

UpdateAllPointers()
{
    ; Update Text Control Appearance
    For key, value in Pointers
    {
        color := value.c
        
        
        Gui, Font, c%color% Bold
        GuiControl, Font, Control_Text%key%
        GuiControl, Text, Control_Text%key% , % "X: [" value.x "] Y: [" value.y "] C: [" value.c  "]"
        
        
    }
    
    Gui, Submit, NoHide     
}

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
    MsgBox, % "Gui_Visible: " Gui_Visible " | Current_State: " Current_State
}

!F5::Configurate() ; -> Boot up the configuration setup for Target & Self bars localization
!F6::SetDeathWindow()
F8::DebugF()
F9::ToggleGui()