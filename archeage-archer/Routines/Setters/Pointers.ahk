SetTargetPointerRoutine:
{
    Gui, Hide
    MouseGetPos, mPosX, mPosYq
    While !GetKeyState("LButton") {
        MouseGetPos, mPosX, mPosY
        ToolTip, % "Please, click on the beginning of your target Mana Bar", mPosX + 30, mPosY + 40
    }
    
    
    PixelGetColor, curColor, mPosX, mPosY, RGB
    targetPointer.x := mPosX
    targetPointer.y := mPosY
    targetPointer.c := curColor

    
    _IniWrite(targetPointer.x, ConfigFullPath, "targetPointer", "x")
    _IniWrite(targetPointer.y, ConfigFullPath, "targetPointer", "y")
    _IniWrite(targetPointer.c, ConfigFullPath, "targetPointer", "c")
    
    
    ToolTip, 
    UpdateAllPointers()
    Sleep, 75
    Gui, Show
    Return
}

SetSelfManaPointerRoutine:
{
    Gui, Hide
    MouseGetPos, mPosX, mPosYq
    While !GetKeyState("LButton") {
        MouseGetPos, mPosX, mPosY
        ToolTip, % "Please, click on the middle point of your self Mana Bar.", mPosX + 30, mPosY + 40
    }
    
    PixelGetColor, curColor, mPosX, mPosY, RGB
    selfManaPointer.x := mPosX
    selfManaPointer.y := mPosY
    selfManaPointer.c := curColor
    
    _IniWrite(selfManaPointer.x, ConfigFullPath, "selfManaPointer", "x")
    _IniWrite(selfManaPointer.y, ConfigFullPath, "selfManaPointer", "y")
    _IniWrite(selfManaPointer.c, ConfigFullPath, "selfManaPointer", "c")
    
    
    ToolTip, 
    UpdateAllPointers()
    Sleep, 75
    Gui, Show
    Return
}

SetDeathPointerRoutine:
{
    Gui, Hide
    MouseGetPos, mPosX, mPosYq
    While !GetKeyState("LButton") {
        MouseGetPos, mPosX, mPosY
        ToolTip, % "Please, click somewhere at your Death Window that has a fixed color.", mPosX + 30, mPosY + 40
    }
    
    
    PixelGetColor, curColor, mPosX, mPosY, RGB
    deathPointer.x := mPosX
    deathPointer.y := mPosY
    deathPointer.c := curColor

    
    _IniWrite(deathPointer.x, ConfigFullPath, "deathPointer", "x")
    _IniWrite(deathPointer.y, ConfigFullPath, "deathPointer", "y")
    _IniWrite(deathPointer.c, ConfigFullPath, "deathPointer", "c")
    
    
    ToolTip, 
    UpdateAllPointers()
    Sleep, 75
    Gui, Show
    Return
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