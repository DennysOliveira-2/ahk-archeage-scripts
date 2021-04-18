#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force



; Read from File Data to Variables
IniRead, targetLowHP_x, trueHealer.ini, targetLow, x, -55
IniRead, targetLowHP_y, trueHealer.ini, targetLow, y, -55
IniRead, targetLowHP_c, trueHealer.ini, targetLow, c, -55

IniRead, targetMaxHP_x, trueHealer.ini, targetMax, x, -55
IniRead, targetMaxHP_y, trueHealer.ini, targetMax, y, -55
IniRead, targetMaxHP_c, trueHealer.ini, targetMax, c, -55

IniRead, selfLowHP_x, trueHealer.ini, selfLow, x, -55
IniRead, selfLowHP_y, trueHealer.ini, selfLow, y, -55
IniRead, selfLowHP_c, trueHealer.ini, selfLow, c, -55

IniRead, selfMaxHP_x, trueHealer.ini, selfMax, x, -55
IniRead, selfMaxHP_y, trueHealer.ini, selfMax, y, -55
IniRead, selfMaxHP_c, trueHealer.ini, selfMax, c, -55

IniRead, configStatus, trueHealer.ini, configuration, status, 0

Sleep, 1000


Game_Handle := WinExist("ahk_exe archeage.exe")
if (Game_Handle){
    ; call := DllCall("SetParent", "UInt", GuiSetupHwnd, "UInt", Game_Handle)
} else {
    MsgBox, Archeage not found, quitting.
    ExitApp, 704 ; Target Game not Found
}
Gui, 1:New,     +HwndGuiSetupHwnd +AlwaysOnTop +Parent%Game_Handle% -Caption
Gui 1: +LastFound ; Set Gui1 to LastFound
; Define Gui1 Styles
WinSet, Trans, 225
WinSet, Style, -0x40000000  ; Removes WS_CHILD
WinSet, Style, +0x0         ; Adds WS_OVERLAPPED
WinSet, Style, -0x10000     ; Removes WS_MAXIMIZE
WinSet, Style, -0x20000000  ; Removez WS_MINIMIZE
WinSet, Style, 0x800000
Gui, Color, White        ; Set Main BG Color to Dark Blue
Gui, Font, White


Gui, Add, Text, x150 y5 cBlack, Press [F9] to toggle this GUI.
; #SECTION => Configuration
; Target Low HP
Gui, Add, Text, x5   y55 cBlack, Target HP to Heal ; Label Descriptor
Gui, Add, Edit, x105 y50 w26 r1 vEdit_TargetLowHP_X, %targetLowHP_x%
GuiControl, Disable, Edit_TargetLowHP_X
Gui, Add, Edit, x135 y50 w26 r1 vEdit_TargetLowHP_Y, %targetLowHP_y%
GuiControl, Disable, Edit_TargetLowHP_Y
Gui, Add, Edit, x165 y50 w26 r1 vEdit_TargetLowHP_C, %targetLowHP_c%
GuiControl, Disable, Edit_TargetLowHP_C
Gui, Add, Button, x195 y50 w80 h22 gBtn_SetTargetHpPoint, Set

; Self Low HP
Gui, Add, Text, x5   y85 cBlack, Self HP to Heal ; Label Descriptor
Gui, Add, Edit, x105 y80 w26 r1 vEdit_SelfLowHP_X, %selfLowHP_x%
GuiControl, Disable, vEdit_SelfLowHP_X
Gui, Add, Edit, x135 y80 w26 r1 vEdit_SelfLowHP_Y, %selfLowHP_y% ; Y position
GuiControl, Disable, vEdit_SelfLowHP_Y
Gui, Add, Edit, x165 y80 w26 r1 vEdit_SelfLowHP_C, %selfMaxHP_c% 
GuiControl, Disable, vEdit_SelfLowHP_C




Gui, Add, Button, w100 h20 x190 y170 gBtn_SaveConfig, Save

; Declares SubMenus and their Options
Menu, File_SMenu, Add, &Save Config, MenuClicked_Save
Menu, File_SMenu, Add, &Exit, MenuClicked_Exit
Menu, Tools_SMenu, Add
Menu, Help_SMenu, Add

; Adds Submenus to MenuBar
Menu, MenuBar, Add, &File,  :File_SMenu
Menu, MenuBar, Add, &Tools, :Tools_SMenu
Menu, MenuBar, Add, &Help,  :Help_SMenu

; Define MenuBar Styles
Menu, MenuBar, Color, White
Gui, Menu, MenuBar ; Show MenuBar


; Show Gui1
Gui, Show, x0 y0 w300 h200, SetupGui
Gui, Font, OxFFFFFF

Pause

; Targets
target1 := "/target Syrup"

; Skill Timers
aranzeb_timer       := A_TickCount
ressurgence_timer   := A_TickCount
renewal_timer       := A_TickCount
gcd_timer           := A_TickCount
meditate_timer      := A_TickCount

; Skill Cooldowns
aranzeb_cd  := 30 * 60 * 1000
ressur_cd   := 10000
renew_cd    := 30000
meditate_cd := 37000
g_cd        := 1000

; Skill Keys
ode_key         := "1"
ballad_key      := "2"
chantey_key     := "3"

ressur_key      := "4"
antithesis_key  := "5"
hymn_key        := "6"
mirror_key      := "7"
renew_key       := "8"
meditate_key    := "9"
aranzeb_key     := "-"



; First Iteration
If (Not A_IsPaused)
{
    clipboard := target1
    Sleep, 2000

    Send, {Enter}
    Sleep, 250
    Send, ^v
    Sleep, 250
    Send, {Enter}

    Sleep, 500
    Send,  %aranzeb_key%
    Sleep, 2000
   
}


Loop
{
    if (WinActive(ahk_id %Game_Handle%))
    {
        
        exhaust_meditate    := A_TickCount - meditate_timer
        exhaust_aranzeb     := A_TickCount - aranzeb_timer
        exhaust_ressurgence := A_TickCount - ressurgence_timer
        exhaust_renewal     := A_TickCount - renewal_timer
        exhaust_gcd         := A_TickCount - gcd_timer

        PixelGetColor, current_targetLowHP, targetLowHP_x, targetLowHP_y
        PixelGetColor, current_targetMaxHP, targetMaxHP_x, targetMaxHP_y
        PixelGetColor, current_selfLowHP, selfLowHP_x, selfLowHP_y
        PixelGetColor, current_selfMaxHP, selfMaxHP_x, selfMaxHP_y


        if(exhaust_gcd >= g_cd)
        {
            if (current_selfLowHP != selfLowHP_c) ; my hp is low
            {
                ; heals self

                Send, !4
                Sleep, 1000

                Send, !5
                Sleep, 3000

                Send, !6
                Sleep, 1000


            } 
            else if (current_targetLowHP != targetLowHP_c) ; my target hp is low
            { 

                ; heals the target
                
                MouseGetPos, mPosX, mPosY

                Send, 4
                Sleep, 1000

                Send, 5
                Sleep, 3000

                Send, 6    
                Sleep, 1000

                ToolTip, "", mPosX, mPosY


            } 
            else ; no one needs heals, do below
            { 
                if (exhaust_renewal >= renew_cd) ; check if Renew needs to be casted
                { 
                    Sleep, 500
                    
                    Send, %renew_key%
                    
                    Sleep, 250
                    renewal_timer := A_TickCount
                } 
                else if (exhaust_meditate >= meditate_cd)  ; check if Meditate is up to be casted
                {
                    Sleep, 500

                    Send, %meditate_key%

                    Sleep, 250

                    meditate_timer := A_TickCount
                } else () ; if none of the renewable skills needs to be casted, song
                {
                    Sleep, 500
                    Send, %ode_key%
                    
                    Sleep, 3000
                    Send, %ballad_key%

                    Sleep, 3000
                    Send, %chantey_key%

                    Sleep, 500
                }
            }

            gcd_timer := A_TickCount ; Reset GCD Counter
        }
    }

}

; Setter Functions
SetTargetLowHP()
{
    MouseGetPos, mPosX, mPosYq
    While !GetKeyState("LButton") {
        MouseGetPos, mPosX, mPosY
        ToolTip, Click on the lowest point to start healing on your Target HP Bar, mPosX + 30, mPosY + 40
    }
    
    MouseGetPos, targetLowHP_x, targetLowHP_y
    PixelGetColor, targetLowHP_c, targetLowHp_x, targetLowHP_y
    
    IniWrite, %targetLowHP_x%, trueHealer.ini, targetLowHP, x
    IniWrite, %targetLowHP_y%, trueHealer.ini, targetLowHP, y
    IniWrite, %targetLowHP_c%, trueHealer.ini, targetLowHP, c

    ToolTip, 
}

SetTargetMaxHP()
{
    MouseGetPos, mPosX, mPosYq
    While !GetKeyState("LButton") {
        MouseGetPos, mPosX, mPosY
        ToolTip, Click on the point to stop healing on your Target HP Bar, mPosX + 30, mPosY + 40
    }
    
    MouseGetPos, targetMaxHP_x, targetMaxHP_y
    PixelGetColor, targetMaxHP_c, targetMaxHP_x, targetMaxHP_y
    
    IniWrite, %targetMaxHP_x%, trueHealer.ini, targetMaxHP, x
    IniWrite, %targetMaxHP_y%, trueHealer.ini, targetMaxHP, y
    IniWrite, %targetMaxHP_c%, trueHealer.ini, targetMaxHP, c

    ToolTip,
}


SetSelfLowHP()
{
    MouseGetPos, mPosX, mPosYq
    While !GetKeyState("LButton") {
        MouseGetPos, mPosX, mPosY
        ToolTip, Click on the point to START healing on your SELF HP Bar, mPosX + 30, mPosY + 40
    }
    
    MouseGetPos, selfLowHP_x, selfLowHP_y
    PixelGetColor, selfLowHP_c, selfLowHP_x, selfLowHP_y
    
    IniWrite, %selfLowHP_x%, trueHealer.ini, selfLowHP, x
    IniWrite, %selfLowHP_y%, trueHealer.ini, selfLowHP, y
    IniWrite, %selfLowHP_c%, trueHealer.ini, selfLowHP, c

    ToolTip,
}

SetSelfMaxHP()
{
    MouseGetPos, mPosX, mPosYq
    While !GetKeyState("LButton") {
        MouseGetPos, mPosX, mPosY
        ToolTip, Click on the point to STOP healing on your SELF HP Bar, mPosX + 30, mPosY + 40
    }
    
    MouseGetPos, selfMaxHP_x, selfMaxHP_y
    PixelGetColor, selfMaxHP_c, selfMaxHP_x, selfMaxHP_y
    
    IniWrite, %selfMaxHP_x%, trueHealer.ini, selfMaxHP, x
    IniWrite, %selfMaxHP_y%, trueHealer.ini, selfMaxHP, y
    IniWrite, %selfMaxHP_c%, trueHealer.ini, selfMaxHP, c

    ToolTip,
    
}

Configurate()
{
    SetTargetLowHP()
    Sleep, 500
    SetTargetMaxHP()
    Sleep, 500
    SetSelfLowHP()
    Sleep, 500
    SetSelfMaxHP()    
    Sleep, 500

    IniWrite, 1, trueHealer.ini, configuration, status
}


F5::Pause, Toggle
F6::Configurate()

Btn_SaveConfig:
{
    MsgBox, Config is saved.
    Return
}

Btn_SetTargetHpPoint:
{
    MsgBox, Set Target.
    Return
}

MenuClicked_Exit:
{
    MsgBox 4,, Are you sure you want to exit?
    IfMsgBox, No
        Return
    IfMsgBox, Yes
        ExitApp, 701 ; CloseEvent called by User
}

MenuClicked_Save:
{
    TrayTip, ScriptName, Configuration saved.
    Return
}


Set_Parent_by_id(Window_ID, Gui_Number) ; title text is the start of the title of the window, gui number is e.g. 99 
{ 
  Gui, %Gui_Number%: +LastFound 
  Return DllCall("SetParent", "uint", WinExist(), "uint", Window_ID) ; success = handle to previous parent, failure =null
} 
*/



Set_Parent_by_title(Window_Title_Text, Gui_Number) ; title text is the start of the title of the window, gui number is e.g. 99 
{ 
  WinGetTitle, Window_Title_Text_Complete, %Window_Title_Text% 
  Parent_Handle := DllCall( "FindWindowEx", "uint",0, "uint",0, "uint",0, "str", Window_Title_Text_Complete) 
  Gui, %Gui_Number%: +LastFound 
  Return DllCall( "SetParent", "uint", WinExist(), "uint", Parent_Handle ) ; success = handle to previous parent, failure =null
} 



/* 
or to use the class instead of the title: 

Set_Parent_by_class(Window_Class, Gui_Number) ; class e.g. Shell_TrayWnd, gui number is e.g. 99 
{ 
  Parent_Handle := DllCall( "FindWindowEx", "uint",0, "uint",0, "str", Window_Class, "uint",0) 
  Gui, %Gui_Number%: +LastFound 
  Return DllCall( "SetParent", "uint", WinExist(), "uint", Parent_Handle ) ; success = handle to previous parent, failure =null
} 
*/ 

GuiClose(GuiSetupHwnd)
{
    MsgBox 4,, Are you sure you want to exit?
    IfMsgBox, No
        return true  ; true = 1
    IfMsgBox, Yes
        ExitApp, 701 ; CloseEvent called by User
        return false
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


hexToDecimal(str){
    static _0:=0,_1:=1,_2:=2,_3:=3,_4:=4,_5:=5,_6:=6,_7:=7,_8:=8,_9:=9,_a:=10,_b:=11,_c:=12,_d:=13,_e:=14,_f:=15
    str:=ltrim(str,"0x `t`n`r"),   len := StrLen(str),  ret:=0
    Loop,Parse,str
      ret += _%A_LoopField%*(16**(len-A_Index))
    return ret
}
