
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
