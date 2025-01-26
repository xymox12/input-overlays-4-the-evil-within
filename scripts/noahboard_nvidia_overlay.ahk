#!Space:: Montage()

Montage(trans := 177){
  WinExist("A")                         ; Last Found Window
  WinGet ExStyle, ExStyle               ; Store the Extended Styles in the variable ExStyle.

  if (ExStyle & 0x80028) == 0x80028 {   ; WS_EX_LAYERED | WS_EX_TRANSPARENT | WS_EX_TOPMOST
    WinSet AlwaysOnTop, Off             ; Uses SetWindowPos instead of SetWindowLong.
    WinSet ExStyle, -0x80028            ; Remove clickthough and transparency.
	WinSet, Style, +0xC40000
  } else {
    WinSet AlwaysOnTop, On              ; Although WS_EX_TOPMOST (0x8) is an ExStyle, it requires SetWindowPos.
	WinSet, Style, -0xC40000,
	
	WinMove, , , , , 580, 280
	DllCall("SetMenu", "Ptr", WinExist(), "Ptr", 0)
  WinSet ExStyle, +0x80028            ; Add clickthough and transparency.
  ;WinSet Transparent, % trans         ; Set window transparency value.
	Winset, Transcolor, 000000 %trans%
	}
}
