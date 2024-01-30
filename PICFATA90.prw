#INCLUDE "PROTHEUS.CH"                     	
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

#DEFINE ENTER Chr(13)+Chr(10) 

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±ºPrograma  ³ PICFATA90 º Autor ³ Meliora/Gustavo    º Data ³ 21/10/14  ±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ±±
//±±ºDescricao ³ Rotina para Separação de Faturamento - PIC...             ±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*---------------------*
User Function PICFATA90
*---------------------*
Private _aArea  := GetArea()
Private _aArSC5 := SC5->(GetArea())
Private _aArSC9 := SC9->(GetArea())
Private _aArSC6 := SC6->(GetArea())
Private _aArSB8 := SB8->(GetArea())

Private _cFilSZQ := ''
Private SALDO 
Private QUANT

Private _aITIMP := {}
Private _aCBIMP := {}

Private _aLido  := {Array(02)};_aLido[Len(_aLido)][1]:='';_aLido[Len(_aLido)][2]:=0

Private _oOk    := LoadBitmap( GetResources(), "BR_VERDE"    ) 
Private _oNo    := LoadBitmap( GetResources(), "BR_VERMELHO" ) 
Private _oXX    := LoadBitmap( GetResources(), "BR_CANCEL" ) 
Private _oOF    := LoadBitmap( GetResources(), "BR_PRETO" ) 
                                   
Private _cImgCodBar := '\system\ImgCodBa.BMP'
Private oImgCodBar                 
Private _cImgCB     := '\System\Img_Fundo.BMP'
Private oImgFR
Private oImgNF 
Private _cLogo      := '\System\Logo.BMP'
Private oImgLogo 
Private _cUsuario   := ALLTRIM(UPPER(SUBSTR(CUSUARIO,7,15)))

Private oImgColNew
Private _cImgColNew := '\system\ImgColNew.bmp'

Private oImgColDev
Private _cImgColDev := '\system\ImgColDev.bmp'

Private _nTotIt   := 0
Private _oTotIt
Private _oPedido
Private _cPedido  := Space(TamSX3('C5_NUM')[1])
Private _oCliente
Private _cCliente := Space(TamSX3('A1_NOME')[1])
               
Private _oCodBar1
Private _cCodBar1:=''
Private _oCodBar
Private _cCodBar := Space(TamSX3('B1_CODBAR')[1])


Private _oUltLido
Private _cUltLido := _aLido[Len(_aLido)][01]

Private OBRWP
Private OBRWI

Private _nSegu      := 0


IF !FILE(_cLogo)
	_cLogo := ''
ENDIF                                      

DbSelectArea('SC5')
DbSelectArea('SC9')

//³ Fontes do windows usadas                                          
DEFINE FONT oFont1  NAME "Arial Black" SIZE 25,35
DEFINE FONT oFont1C NAME "Courier New" SIZE 35,45 BOLD
DEFINE FONT oFont2  NAME "Arial Black" SIZE 15,26
DEFINE FONT oFont3  NAME "Arial Black" SIZE 6,17
DEFINE FONT oFontN  NAME "Arial Black" SIZE 8,15     


_cUsuario  := ALLTRIM(UPPER(SUBSTR(CUSUARIO,7,15)))
_cEmpresa  := SM0->M0_CODIGO
_cCorrente := SM0->M0_CODFIL

cMarca   := GetMark()
linverte := .F.

//³ Resolucao da tela		
aSize  := MsAdvSize()
_nTop  := 600
_nRight:= 1220
_nSize := 611

IF Select("PICSC9") > 0
	PICSC9->(DbCloseArea()) 
EndIF  


cArq := CriaTrab("",.F.)
MsgRun("Pesquisando pesagens, aguarde...","",{|| CursorWait(), GrPICSC9() ,CursorArrow()})

SetKey( VK_F2,  {|| FATA90ACC('F2') })
SetKey( VK_F3,  {|| FATA90ACC('F3') })
SetKey( VK_F4,  {|| FATA90ACC('F4') })
SetKey( VK_F5,  {|| FATA90ACC('F5') })
SetKey( VK_F6,  {|| FATA90ACC('F6') })
SetKey( VK_F12, {|| oTela:END() })
		
// aHeaders 							
_aTitCB := {}
AADD(_aTitCB,{"ITEM"    	,,"Item"     	})
AADD(_aTitCB,{"QUANT"    	,,"Quantidade"  })
AADD(_aTitCB,{"PROD"  		,,"Produto" 	})
AADD(_aTitCB,{"XDESC" 		,,"Descrição"   })
AADD(_aTitCB,{"UM"			,,"Uni.Medida"  })
AADD(_aTitCB,{"LOTE"   		,,"Lote"      	})                                                         
AADD(_aTitCB,{"SEP"  		,,"Separação"	})                                                         
AADD(_aTitCB,{"SALDO"   	,,"S A L D O "  })

DbSelectarea("PICSC9")
PICSC9->(Dbgotop())

//legenda de cores 
_aCoresCB:={}					
Aadd(_aCoresCB,{"SALDO == QUANT"				,"DISABLE"})
Aadd(_aCoresCB,{"SALDO == 0"   					,"ENABLE" })		    	
Aadd(_aCoresCB,{"SALDO <> QUANT .And. SALDO > 0","BR_AMARELO" })		    	

//³ Tela principal da rotina							
DEFINE MSDIALOG oTela TITLE OemToAnsi("Separação de Pedidos (Código de Barras) - "+SM0->M0_CODIGO+"/"+SM0->M0_CODFIL+" - "+ AllTrim(Upper(SM0->M0_FILIAL))) FROM 000,000 TO _nTop,_nRight PIXEL Style 128
oTela:lEscClose := .F. 
 
//TITULO DA TELA                           
@ 002,002 BITMAP oImgCodBar FILENAME _cImgCodBar PIXEL OF oTela SIZE 252,080 NOBORDER ADJUST
@ 000,000 TO 080,252 LABEL '' PIXEL OF oImgCodBar
@ 003,040 Say OemToAnsi("Separação") SIZE 190,20 FONT oFont1C OF oImgCodBar PIXEL COLOR CLR_HRED
@ 027,015 Say OemToAnsi("Cód.Bar.:")  SIZE 070,20  FONT oFont2 OF oImgCodBar PIXEL COLOR CLR_BLACK
//@ 100,050 MSGet _oCodBar1 Var _cCodBar1 Size 010,010 Pixel
@ 025,085 MSGet _oCodBar   Var _cCodBar   Size 150,020 When(!Empty(_cPedido)) /*Valid(xVldCb(@_cCodBar))*/  Color CLR_RED FONT oFont2 NOBORDER Pixel Of oImgCodBar On Change(xVldCb(@_cCodBar)) 
@ 060,015 Say OemToAnsi("Ultima Leitura")  SIZE 070,20  FONT oFontN OF oImgCodBar PIXEL COLOR CLR_BLACK
@ 055,085 MSGet _oUltLido  Var _cUltLido  Size 150,015 When(.F.) Color CLR_RED FONT oFontN NOBORDER Pixel Of oImgCodBar 


@ 002,256 TO 082,507  LABEL '' PIXEL OF oTela
@ 003,270 Say OemToAnsi("Dados Pedido") SIZE 300,020  FONT oFont1C OF oTela PIXEL COLOR CLR_HBLUE
@ 027,265 Say OemToAnsi("Pedido")       SIZE 050,020  FONT oFont2 OF oTela PIXEL COLOR CLR_BLACK
@ 025,320 MSGet _oPedido  Var _cPedido  Size 170,020  Picture('@!') When (Empty(_cPedido)) Valid(xVldPV(@_cPedido)) FONT oFont2 OF oTela PIXEL Color CLR_HRED On Change(xVldPV(@_cPedido)) 
@ 057,265 Say OemToAnsi("Cliente")      SIZE 050,020  FONT oFont2 OF oTela PIXEL COLOR CLR_BLACK
@ 055,320 MSGet _oCliente Var _cCliente Size 170,020 When(.F.) 		FONT oFont2 OF oTela PIXEL Color CLR_HRED
                                               	
@ 002,509 TO 082,611  LABEL '' PIXEL OF oTela
@ 006,520 Say OemToAnsi('F2  - Finaliza Separação') FONT oFontN PIXEL OF oTela 
@ 018,520 Say OemToAnsi('F3  - Separação Parcial') 	FONT oFontN PIXEL OF oTela 
@ 030,520 Say OemToAnsi('F4  - Cancela Separação') 	FONT oFontN PIXEL OF oTela 
@ 041,520 Say OemToAnsi('F5  - Estorna Item') 		FONT oFontN PIXEL OF oTela 
@ 052,520 Say OemToAnsi('F6  - Imp. Etiqueta') 		FONT oFontN PIXEL OF oTela 
@ 064,520 Say OemToAnsi('F12 - Sair') 				FONT oFontN PIXEL OF oTela 			
 		
//Quadro Legenda Cabeçalho
@ 087,002 TO 099,123
@ 090,005 BITMAP oBmp RESNAME "BR_VERDE" oF oTela SIZE 50, 250 NOBORDER WHEN .F. PIXEL
@ 090,015 Say OemToAnsi('Separado') PIXEL OF oTela 
@ 090,050 BITMAP oBmp RESNAME "BR_AMARELO" oF oTela SIZE 50, 250 NOBORDER WHEN .F. PIXEL
@ 090,060 Say OemToAnsi('Parcial') PIXEL OF oTela
@ 090,088 BITMAP oBmp RESNAME "BR_VERMELHO" oF oTela SIZE 50, 250 NOBORDER WHEN .F. PIXEL
@ 090,098 Say OemToAnsi('Pendente') PIXEL OF oTela

//Infomacoes - Quantidade
@ 081,153 Say OemToAnsi("Item (s)") FONT oFont3 OF oTela PIXEL
@ 090,153 MSGet _oTotIt Var Transform(_nTotIt,'@e 999')  When .F. Size 016,05 Color CLR_RED NOBORDER Pixel Of oTela
                            
//ITENS               
OBRWP := MsSelect():New("PICSC9","","",_aTitCB,@lInverte,@cMarca,{103,002,298,_nSize},,,,,_aCoresCB)
   			OBRWP:oBrowse:BCHANGE := {|| _oCodBar:setfocus() }
	       	OBRWP:oBrowse:oFont := TFont():New("Arial", 05, 15)
	       	OBRWP:OFONT:BOLD := .T.
	       	OBRWP:OBROWSE:OFONT:BOLD := .T.
	
ACTIVATE DIALOG oTela CENTER

RestArea(_aArea)
RestArea(_aArSC5)
RestArea(_aArSC9)

Return                                                                       

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±ºPrograma  ³ PICFATA90 º Autor ³ Meliora/Gustavo    º Data ³ 21/10/14  ±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ±±
//±±ºDescricao ³ Rotina para Separação de Faturamento - PIC...             ±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*------------------------------*
Static Function xVldPV(_cPedido)
*------------------------------*
Local _lAnvisa 	:= .F.

DbSelectArea('SC5')
SC5->(DbSetOrder(1))
IF (_lOk := SC5->(DbSeek(xFilial('SC5')+_cPedido)))

     _lAnvisa 	:= U_CrtAnvisa(SC5->C5_CLIENTE, SC5->C5_LOJACLI)
    
	//TRATAMENTO PARA BLOQUEIO DE ANVISA
	If  cEmpAnt == "02"
		u_GrvAnvisa(_lAnvisa)
	Endif

	DbSelectArea('SA1');SA1->(DbSetOrder(1))	
	SA1->(DbSeek(xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

	_cCliente := SA1->A1_NOME
    
    If SC5->C5_BLQ = '0'  
       MsgInfo('Bloqueio Anvisa. Pedido: '+_cPedido,'Atenção')
       _lOk  := .f.
	Else
       GrPICSC9()
	Endif
	
	IF _lOk
		xAtuTela()	
	EndIF      
Else
	_lOk := Empty(_cPedido)
EndIF


IF !_lOk
	MsgInfo('Informe um pedido de venda Válido...'+ENTER+ENTER+'Pedido: '+_cPedido,'Atenção')
	xClearTela()
	_oPedido:Refresh()
	_oPedido:Setfocus()
EndIF

Return(_lOk)

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±ºPrograma  ³ PICFATA90 º Autor ³ Meliora/Gustavo    º Data ³ 21/10/14  ±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ±±
//±±ºDescricao ³ Rotina para Separação de Faturamento - PIC...             ±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*-----------------------*
Static Function xAtuTela
*-----------------------*
_oUltLido:Refresh()
oTela:Refresh()
OBRWP:oBrowse:Refresh()
//GetDRefresh()
_oCodBar:Refresh()
_oCodBar:Setfocus()     

ObjectMethod(oTela,"Refresh()") 
//_oCodBar:Setfocus()
//oImgCodBar:Setfocus()
Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±ºPrograma  ³ PICFATA90 º Autor ³ Meliora/Gustavo    º Data ³ 21/10/14  ±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ±±
//±±ºDescricao ³ Rotina para Separação de Faturamento - PIC...             ±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß	
*------------------------------*
Static Function xVldCb(_cCodBar)
*------------------------------*
Local _lCodBar  := .T.
Local _lOk      := .F.
//Local _nIOldSB1 := SB1->(IndexOrd())
                             
/*
_nIndexSB1 := 5 //CODIGO DE BARRAS

For _nIdx:=1 To 2 
	DbSelectArea('SB1')
	SB1->(DbsetOrder(_nIndexSB1))
	SB1->(DbGoTop())
	IF SB1->(DbSeek(xFilial('SB1')+_cCodBar))	
		Exit	
	ENDIF
	_nIndexSB1 := iIF(_nIndexSB1==5,1,5)
Next _nIdx                       
*/                               

cCodNew := IIf(Len(Alltrim(_cCodBar)) == 10, _cCodBar,SubStr(_cCodBar, 5))
                                     	
DbSelectArea('CB0')          
CB0->(DbSetOrder(1))
CB0->(DbGoTop()) 
If !CB0->(DbSeek(xFilial('CB0')+cCodNew))
   	Aviso('Cod.Barras','Etiqueta não localizada na base de código de barras -> '+cCodNew,{'Retornar'})
   	DbSelectArea('PICSC9');PICSC9->(DbGoTop())
	cCodNew := Space(TamSX3('B1_CODBAR')[1])
	_cCodBar := Space(TamSX3('B1_CODBAR')[1])                                
	xAtuTela()   
   Return(_lCodBar)
EndIf      

//Validacao do processo de leitura das etiquetas
IF !Empty(CB0->CB0_XPDSEP)
   	Aviso('Cod.Barras','Etiqueta já utilizada. Pedido: '+CB0->CB0_XPDSEP,{'Fechar'})
   	DbSelectArea('PICSC9');PICSC9->(DbGoTop())
	cCodNew := Space(TamSX3('B1_CODBAR')[1])
	_cCodBar := Space(TamSX3('B1_CODBAR')[1])                                
	xAtuTela()     
   Return(_lCodBar)
EndIF


DbSelectArea('SB1');SB1->(DbsetOrder(1));SB1->(DbGoTop())
IF SB1->(DbSeek(xFilial('SB1')+CB0->CB0_CODPRO))
	DbSelectArea('PICSC9');PICSC9->(DbGoTop())
	While PICSC9->(!Eof())     
	    IF (_lOk := PICSC9->PROD==SB1->B1_COD .And. iIF(!Empty(PICSC9->LOTE), AllTrim(PICSC9->LOTE)==AllTrim(CB0->CB0_LOTE), .T.) )
	    	xGrav(iIF(SB1->B1_QE==0,1,SB1->B1_QE))
	    	Exit
	    EndIF
		PICSC9->(DbSkip())
	EndDo	
EndIF    

IF !_lOk 
	DbSelectArea('PICSC9');PICSC9->(DbGoTop())
	MsgInfo('Produto vinculado a etiqueta, não contem para separação.'+ENTER+ENTER+' Etiqueta: '+AllTrim(SB1->B1_COD)+' - '+AllTrim(SB1->B1_DESC),'Etiqueta x Produto')	
EndIF

DbSelectArea('PICSC9');PICSC9->(DbGoTop())
cCodNew := Space(TamSX3('B1_CODBAR')[1])
_cCodBar := Space(TamSX3('B1_CODBAR')[1])                                
xAtuTela()

Return(_lCodBar)    

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±ºPrograma  ³ PICFATA90 º Autor ³ Meliora/Gustavo    º Data ³ 21/10/14  ±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ±±
//±±ºDescricao ³ Rotina para Separação de Faturamento - PIC...             ±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*---------------------------*
Static Function xGrav(_nSoma)
*---------------------------*
Default _nSoma := 1

IF SB1->B1_QE == 0 .And. AllTrim(SB1->B1_UM) $ 'KG/L/ML'
	MsgInfo(AllTrim(SB1->B1_COD)+' - '+AllTrim(SB1->B1_DESC)+ENTER+'Un.: '+SB1->B1_UM+' Qtd.Emp.: '+cValToChar(SB1->B1_QE)+ENTER+ENTER+'Revise o Cadastro!','Cadastro de Produto')
	Return
EndIF
                     
IF _nSoma > 0 
	IF PICSC9->SALDO == 0
		MsgInfo('Coleta Finalizada para o Produto!'+ENTER+ENTER+;
				'Item.: '+PICSC9->ITEM+ENTER+;
				'Prod.: '+PICSC9->XDESC+ENTER+;
				'Saldo: '+cValToChar(PICSC9->SALDO),'Atenção')
		Return
	EndIF 
EndIF

Begin Transaction
	DbSelectArea('SC9')
	SC9->(DbGoTo(PICSC9->RECSC9))
	IF PICSC9->RECSC9 == SC9->(Recno())
	
		IF 	RecLock('SC9',.F.)   
				Replace SC9->C9_XLIBFAT  With (SC9->C9_XLIBFAT+_nSoma)
			SC9->(MsUnLock())		
		EndIF
		
		IF 	RecLock('PICSC9',.F.)
				Replace PICSC9->SEP   With (PICSC9->SEP+_nSoma)
				Replace PICSC9->SALDO With (PICSC9->QUANT-PICSC9->SEP)		
			PICSC9->(MsUnLock())
		EndIF
		
		//Grava Flag na etiqueta para nao reutilizacao
		IF 	RecLock('CB0',.F.)   
				Replace CB0->CB0_XPDSEP  With SC9->C9_PEDIDO
			CB0->(MsUnLock())		
		EndIF
		
		//Atualiza controle de ultima leitura
		IF _nSoma < 0
		   	aDel(_aLido,Len(_aLido))
			aSize(_aLido,Len(_aLido)-1)
		   	IF Len(_aLido)==0
		   		_aLido  := {Array(02)};_aLido[Len(_aLido)][1]:='';_aLido[Len(_aLido)][2]:=0
		   	EndIF
		Else
			IF Empty(_aLido[Len(_aLido)][1])
				_aLido[Len(_aLido)][1]:=(PICSC9->ITEM+' - '+PICSC9->XDESC) ;_aLido[Len(_aLido)][2]:=PICSC9->RECSC9
			Else 
				aADD(_aLido,{(PICSC9->ITEM+' - '+PICSC9->XDESC), PICSC9->RECSC9})	
			EndIF
		EndIF
		_cUltLido := _aLido[Len(_aLido)][01]
		
	Else
		MsgInfo('Registro não localizado no SC9'+ENTER+ENTER+'Recno: '+cValToChar(PICSC9->RECSC9),'Atenção')
	EndIF
End Transaction
Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±ºPrograma  ³ PICFATA90 º Autor ³ Meliora/Gustavo    º Data ³ 21/10/14  ±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ±±
//±±ºDescricao ³ Rotina para Separação de Faturamento - PIC...             ±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*-----------------------*
Static Function GrPICSC9
*-----------------------*

IF Select("PICSC9") > 0
	PICSC9->(DbCloseArea()) 
EndIF
_nTotIt := 0
_cQuery := " SELECT C9_ITEM ITEM, C9_QTDLIB QUANT, C9_PRODUTO PROD, B1_DESC XDESC, B1_UM UM, C9_LOTECTL LOTE, C9_XLIBFAT SEP, (C9_QTDLIB-C9_XLIBFAT) SALDO, SC9.R_E_C_N_O_ RECSC9 "+ENTER
_cQuery += "   FROM "+RetSqlName('SC9')+" SC9 "+ENTER
_cQuery += "   INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.D_E_L_E_T_= ' ' AND B1_FILIAL= '"+xFilial('SB1')+"' AND B1_COD=C9_PRODUTO "+ENTER
_cQuery += "     WHERE SC9.D_E_L_E_T_ = ' '  "+ENTER
_cQuery += "       AND C9_FILIAL      = '"+xFilial('SC9')+"'  "+ENTER
_cQuery += "       AND C9_BLCRED      = ' '  "+ENTER
_cQuery += "       AND C9_BLEST       = ' '  "+ENTER
_cQuery += "       AND C9_PEDIDO      = '"+_cPedido+"' "+ENTER

_cQuery := ChangeQuery(_cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), 'PICSC9', .F., .T.)

COPY TO &cArq

PICSC9->(DbCloseArea())
DbUseArea(.T., "DBFCDX", cArq,"PICSC9", .F., .F.)                                                                                      
cArqNtx := Criatrab(Nil,.f.)                                                   
        
Indregua("PICSC9",cArqNtx,"ITEM+PROD+LOTE",,,"...")
PICSC9->(dbGotop())

While !PICSC9->(Eof())	
	_nTotIt++
	PICSC9->(dbSkip())      
EndDo
PICSC9->(dbGotop())

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±ºPrograma  ³ PICFATA90 º Autor ³ Meliora/Gustavo    º Data ³ 21/10/14  ±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ±±
//±±ºDescricao ³ Rotina para Separação de Faturamento - PIC...             ±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*------------------------------*
Static Function FATA90ACC(_cAcc)
*------------------------------*
Default _cAcc := ''

IF _cAcc == 'F2' //FINALIZA SEPARACAO	
	IF MsgYesNo('Deseja Finalizar a Separação ?')		
		TcSQLExec("Update "+RetSqlName('SC9')+" Set C9_XLIBOK = 'X' Where D_E_L_E_T_= ' ' AND C9_FILIAL = '"+xFilial('SC9')+"' AND C9_BLEST<>'10' AND C9_BLCRED <> '10' AND C9_QTDLIB=C9_XLIBFAT AND C9_PEDIDO='"+SC5->C5_NUM+"' ")
		xScanLTot()
		//Caso for transportadora especifica abre tela de liberacao:
		IF AllTrim(SC5->C5_TRANSP) $ GetMv('PC_EXLBSA4',.F.,'')  
			u_PM410VOL()
		EndIF
	EndIF
	xClearTela()

ElseIF _cAcc == 'F4' //CANCELA SEPARACAO
 IF MsgYesNo('Deseja Cancelar TODA a Separação ?')	
		TcSQLExec("Update "+RetSqlName('SC9')+" Set C9_XLIBOK  = '  ', C9_XLIBFAT = 0, C9_XLIBTOT = 'N' Where D_E_L_E_T_= ' ' AND C9_FILIAL = '"+xFilial('SC9')+"' AND C9_BLEST<>'10' AND C9_BLCRED <> '10' AND C9_PEDIDO='"+SC5->C5_NUM+"' ")
		TcSQLExec("Update "+RetSqlName('CB0')+" Set CB0_XPDSEP = '  ' Where D_E_L_E_T_= ' ' AND CB0_FILIAL = '"+xFilial('CB0')+"' AND CB0_XPDSEP='"+SC5->C5_NUM+"' ")
	EndIF
	xClearTela()
		
ElseIF _cAcc == 'F5' //ESTORNA ITEM 

	DbSelectArea('PICSC9');PICSC9->(DbGoTop())
	While PICSC9->(!Eof())     
	    IF (_lOk := PICSC9->RECSC9==_aLido[Len(_aLido)][2])
	    	xGrav(iIF(SB1->B1_QE==0,-1,SB1->B1_QE*-1))
	    	Exit
	    EndIF
		PICSC9->(DbSkip())
	EndDo			
	IF !_lOk
		DbSelectArea('PICSC9');PICSC9->(DbGoTop())
	EndIF

ElseIf _cAcc == 'F6' //IMPRIMI ETIQUETA
	
	if cEmpAnt == '02'
	  
	  u_xEtqcaixasep()

	endif
EndIF

xAtuTela()
_oPedido:Refresh()
_oPedido:Setfocus()
Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±ºPrograma  ³ PICFATA90 º Autor ³ Meliora/Gustavo    º Data ³ 21/10/14  ±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ±±
//±±ºDescricao ³ Rotina para Separação de Faturamento - PIC...             ±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*------------------------*
Static Function xClearTela
*------------------------*
_cPedido  := Space(TamSX3('C5_NUM')[1])
_cCliente := Space(TamSX3('A1_NOME')[1])
_cCodBar  := Space(TamSX3('B1_CODBAR')[1])
_aLido    := {Array(02)};_aLido[Len(_aLido)][1]:='';_aLido[Len(_aLido)][2]:=0
_cUltLido := _aLido[Len(_aLido)][01]
GrPICSC9()          
xAtuTela()
Return

*-----------------------*
Static Function xScanLTot
*-----------------------*
Local _aArea    := GetArea()
Local _aArC9    := SC9->(GetArea())
Local _lLibNota := .T.

DbSelectarea("PICSC9");PICSC9->(Dbgotop())
While PICSC9->(!Eof()) 
   	IF PICSC9->SALDO <> 0
   		_lLibNota := .F.
   		Exit
   	EndIF
	PICSC9->(DbSkip())
EndDo
	
IF _lLibNota
	DbSelectarea("PICSC9");PICSC9->(Dbgotop())
	While PICSC9->(!Eof()) 
	   	DbSelectArea('SC9');SC9->(DbSetOrder(1));SC9->(DbGoTo(PICSC9->RECSC9))
		IF PICSC9->RECSC9 == SC9->(Recno())
			IF 	RecLock('SC9',.F.) 
					Replace SC9->C9_XLIBTOT With 'S'
				SC9->(MsUnLock())
			EndIF
	   	EndIF
		PICSC9->(DbSkip())
	EndDo	
Else 
	MsgInfo('Processo consta saldo em aberto, não será liberado para Faturamento!','Liberacao')
EndIF           

RestArea(_aArea)
RestArea(_aArC9)
Return
