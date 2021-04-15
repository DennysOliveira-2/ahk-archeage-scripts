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

; Check for Configuration
if (configStatus == 0)
{
    MsgBox, Config file not found, press F6 to start the configuration procedure.    
}

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