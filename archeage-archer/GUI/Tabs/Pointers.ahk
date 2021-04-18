; Open Tab Pointers
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

; Close Tab
Gui, Tab