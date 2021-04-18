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


Gui, Tab