.386
.model flat,stdcall
option casemap:none

includelib msvcrt.lib
includelib acllib.lib

include include\test.inc
include include\vars.inc
include include\windows.inc
include include\model.inc
include include\acllib.inc
include include\msvcrt.inc
include include\view.inc
include include\controller.inc
printf PROTO C :ptr sbyte, :VARARG



.data

winTitle byte "黄金矿工", 0

szFmt5 BYTE '断点...', 0ah, 0

Item STRUCT
	exist DWORD ?; 1存在，0已不存在（得分）
	typ DWORD ?; 类别
	posX DWORD ?; 位置横坐标
	posY DWORD ?; 位置纵坐标
	radius DWORD ?; 半径
	weight DWORD ?; 重量
	value DWORD ?; 价值
Item ENDS; 一个实例占4*7=28B
extern Items:Item; vars中定义的物体数组


.code  


main proc; 

	;初始化绘图环境和窗口
	invoke init_first  
	invoke initWindow, offset winTitle, 425, 50, 700, 500
	
	;设置当前窗口为1
	mov eax, 0
	mov curWindow, eax
	;重置得分
	mov eax, 0
	mov playerScore, eax; 
	;重置目标得分
	mov eax, 0
	mov goalScore, eax
	invoke Flush
	

	;invoke InitGame; 调用initGame
	invoke registerMouseEvent,iface_mouseEvent ;注册控制流事件。注意，如果要定义按钮动作，进入这个函数内进行函数代码的添加

	invoke init_second; 阻塞在init时，才会触发定时器的回调函数
	ret

main endp


end main
		