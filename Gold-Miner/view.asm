.386
.model flat,stdcall
option casemap:none

INCLUDELIB acllib.lib
INCLUDELIB lrfLib.lib
include include\acllib.inc
include include\vars.inc
include include\model.inc
include include\msvcrt.inc

calPsin PROTO C :dword, :dword
calPcos PROTO C :dword, :dword
myitoa PROTO C :dword, :ptr sbyte
printf proto C :dword,:vararg

colorBLACK EQU 00000000h
colorWHITE EQU 00ffffffh
colorEMPTY EQU 0ffffffffh

Item STRUCT
	exist DWORD ?; 1存在，0已不存在（得分）
	typ DWORD ?; 类别
	posX DWORD ?; 位置横坐标
	posY DWORD ?; 位置纵坐标
	radius DWORD ?; 半径
	weight DWORD ?; 重量
	value DWORD ?; 价值
Item ENDS; 一个实例占4*7=28B
extern Items :Item

.data	
srcini byte "..\resource\icon\window.jpg", 0
srcgame1 byte "..\resource\icon\game1.jpg", 0
srcdigger byte "..\resource\icon\digger.jpg", 0
srcfire byte "..\resource\icon\fire.jpg", 0
srcluckyleave byte "..\resource\icon\luckyleave.jpg", 0
srcstrengthwater byte "..\resource\icon\strengthwater.jpg", 0
srcstonebook byte "..\resource\icon\stonebook.jpg", 0
srcseller byte "..\resource\icon\seller.jpg", 0
srcwords byte "..\resource\icon\words.jpg", 0 
srcgold byte "..\resource\icon\gold.jpg", 0 

imgini ACL_Image <>
imggame1 ACL_Image <>
imgdigger ACL_Image <>
imgfire ACL_Image <>
imgluckyleave ACL_Image <>
imgstrengthwater ACL_Image <>
imgstonebook ACL_Image <>
imgseller ACL_Image <>
imgwords ACL_Image <>
imggold ACL_Image <>



strrestTime byte "10",0
strmusic byte "Music",0
strprice1 byte "53",0
strprice2 byte "370",0
strprice3 byte "156",0
strprice4 byte "87",0
strmenu byte "Menu",0
strng byte "Next Game !",0
strScore byte 10 DUP(0)
strTime byte 10 DUP(0)
titleScore byte "得 分：", 0
titleTime byte "时 间：", 0


.code


FlushScore proc C num: dword
	push ebx
	mov ebx, num
	mov playerScore, ebx
	invoke myitoa, ebx, offset strScore
	pop ebx
	ret
FlushScore endp
FlushTime proc C num: dword
	push ebx
	mov ebx, num
	mov restTime, ebx
	invoke myitoa, ebx, offset strTime
	pop ebx
	ret
FlushTime endp

DrawItem proc C x: dword, y: dword, r: dword, t: dword		;只能在启动了paint时调用此函数
	push eax
	push ebx
	mov eax,x
	mov ebx,r
	sub eax,ebx
	mov x,eax
	mov eax,y
	sub eax,ebx
	mov y,eax
	add ebx,ebx
	mov r,ebx
	pop ebx
	mov eax,t
	.if eax==0
		invoke loadImage, offset srcgold, offset imggold
		invoke putImageScale, offset imggold, y, x, r, r
	.endif
	pop eax
	ret
DrawItem endp

;@brief:主调函数
Flush proc C 
	mov ebx, curWindow
	;选择生成的窗口
	cmp ebx, 0  
	jz open
	cmp ebx, 1
	jz mainwindow
	cmp ebx,2
	jz store

mainwindow:
	;测试：为item赋初值。可删，在model中赋值
	;push ebx
	;mov ebx,300
	;mov Items[0].posX,ebx
	;mov Items[0].posY,ebx
	;mov ebx, 0
	;mov Items[0].typ,ebx
	;mov ebx, 30
	;mov Items[0].radius, ebx
	;pop ebx
	invoke FlushScore, playerScore
	invoke FlushTime, restTime
	invoke loadImage, offset srcgame1, offset imggame1
	invoke loadImage, offset srcdigger, offset imgdigger

	;显示主界面
	invoke beginPaint
	invoke putImageScale, offset imggame1, 0, 0, 700, 500	;绘制背景
	invoke putImageScale, offset imgdigger, 325, 15, 50, 65		;绘制矿工
	;绘制物品
	push ebx					
	push edi
	mov edi,0
	mov ebx,itemNum
	.while edi<ebx
		invoke DrawItem, Items[edi].posX, Items[edi].posY, Items[edi].radius, Items[edi].typ
		inc edi
	.endw
	pop edi
	pop ebx
	invoke setTextSize, 15
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 630, 10, offset strmusic	;显示音乐选项
	invoke setTextSize, 15
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 630, 30, offset strmenu	;显示菜单选项
	invoke setTextSize, 15
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 10, 10, offset titleScore	;显示“得分”
	invoke setTextSize, 15
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 60, 10, offset strScore	;显示分数
	invoke setTextSize, 15
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 10, 30, offset titleTime	;显示"时间"
	invoke setTextSize, 15
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 60, 30, offset strTime	;显示剩余时间
	invoke endPaint
	jmp finish

open:
	;载入图片
	invoke loadImage, offset srcini, offset imgini
	;显示主界面
	invoke beginPaint
	invoke putImageScale, offset imgini, 0, 0, 700, 500		;80, 125, 125, 50
	invoke setTextSize, 15
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 630, 10, offset strmusic
	invoke endPaint
	jmp finish

store:
	invoke FlushScore, playerScore
	;invoke loadImage, offset srcwords, offset imgwords
	invoke loadImage, offset srcgame1, offset imggame1
	invoke loadImage, offset srcseller, offset imgseller
	invoke loadImage, offset srcluckyleave, offset imgluckyleave
	invoke loadImage, offset srcstonebook, offset imgstonebook
	invoke loadImage, offset srcstrengthwater, offset imgstrengthwater
	invoke loadImage, offset srcfire, offset imgfire
	;显示主界面
	invoke beginPaint
	invoke putImageScale, offset imggame1, 0, 0, 700, 500
	invoke putImageScale, offset imgseller, 500, 50, 210, 250
	;invoke putImageScale, offset imgwords, 200, 60, 200, 80
	;以下为显示商品信息
	push eax
	mov eax, tool1
	.if eax == 1			;如果tool1==1则显示商品1
		invoke putImageScale, offset imgstonebook, 400, 150, 80, 80
		invoke setTextSize, 20
		invoke setTextColor, 00cc9988h
		invoke setTextBkColor, colorWHITE
		invoke paintText, 430, 250, offset strprice1
	.endif
	mov eax, tool2
	.if eax == 1
		invoke putImageScale, offset imgfire, 300, 150, 80, 80
		invoke setTextSize, 20
		invoke setTextColor, 00cc9988h
		invoke setTextBkColor, colorWHITE
		invoke paintText, 330, 250, offset strprice2
	.endif
	mov eax, tool3
	.if eax == 1
		invoke putImageScale, offset imgstrengthwater, 200, 150, 80, 80
		invoke setTextSize, 20
		invoke setTextColor, 00cc9988h
		invoke setTextBkColor, colorWHITE
		invoke paintText, 230, 250, offset strprice3
	.endif
	mov eax, tool4
	.if eax == 1
		invoke putImageScale, offset imgluckyleave, 100, 150, 80, 80
		invoke setTextSize, 20
		invoke setTextColor, 00cc9988h
		invoke setTextBkColor, colorWHITE
		invoke paintText, 130, 250, offset strprice4
	.endif
	pop eax
	invoke setTextSize, 15
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 630, 10, offset strmusic	;显示音乐选项
	invoke setTextSize, 15
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 630, 30, offset strmenu	;显示菜单选项
	invoke setTextSize, 50
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 200, 350, offset strng	;显示Next Game
	invoke line, 0, 300, 700 ,300
	invoke setTextSize, 15
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 10, 10, offset titleScore	;显示“得分”
	invoke setTextSize, 15
	invoke setTextColor, 00cc9988h
	invoke setTextBkColor, colorWHITE
	invoke paintText, 60, 10, offset strScore	;显示分数

	invoke endPaint
	jmp finish

finish:	
	ret 
Flush endp
end Flush
