#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "TbiConn.ch"                          

#include "TbiCode.ch"

#DEFINE ENTER Chr(13)+Chr(10) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ xEtiqFraEO  บAutor  ณ Meliora/Gustavo บ Data ณ  26/01/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Etiqueta de expedi็ใo - Fracionamento ou E.O.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especํfico PIC                                             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

//teste de mensagem git versใo 2.0//

//---------------------------------------------------------------------------------------------------------------------------------*
User Function xEtiqFraEO(_cCodProd,_cOrigem,_nQuant,_cLoteFb,_dDataFb,_cCAS,cNomFabr,_dDtFrac,_nTara,_cLoteIn,_dValidade,_cDCB,_cDCI, cFornec,cLojafo,cPais,_cOpfraceo, _lGrava)
//---------------------------------------------------------------------------------------------------------------------------------*
Local _nLin  := 0
Local _cRota := 'R'
Local cFonte := 'B'
Local cFarm  := GetMV("MV_XFARMCR")
//Local _cCAS_1:=''; Local _cCAS_2:=''; Local _cCAS_3:=''; Local _cCAS_4 := ''

Local _cTpImp  := UppER(AllTrim(GetMV('PC_ITERFRQ',.F.,'Z4M')))
Local _cLocImp := UppER(AllTrim(GetMV('PC_LETQFRQ',.F.,'PCP001' )))
Local _lUsaCB5 := .F. 
Local nXi	:= 0

Default _cCodProd :=''
Default _cOrigem  :=''
Default _nQuant   :=0
Default _cLoteFb  :=''
Default _dDataFb  :=StoD('')
Default _cCAS     := ''
Default cNomFabr  :=''
Default _dDtFrac  :=StoD('')
Default _nTara    :=0
Default _cLoteIn  :=''
Default _dValidade:=StoD('')         
Default _cDCB     := ''
Default _cDCI     := ''
Default _cOpfraceo := ''

IF _lUsaCB5
	If !CB5SetImp(_cLocImp)  
		Alert("Local de impressao "+_cLocImp+" nao encontrado! A etiqueta de fracionamento nao sera gerada",'Aviso')
		Return
	Endif 
	_cTpImp := AllTrim(CB5->CB5_MODELO)
EndIF

IF _cTpImp == 'Z4M'
	IF !_lUsaCB5
		MSCBPRINTER("Z4M","LPT1",,,.F.,,,,)
	EndIF
	_nLin  := 30 
 EndIf                                    
IF !_lUsaCB5
	MSCBCHKStatus(.F.)
EndIF

MSCBBEGIN(1,4)

DbSelectArea('SB1');SB1->(DbSetOrder(1));SB1->(DbSeek(xFilial('SB1')+_cCodProd))
		     
//Tratamento de informacoes para impressao do codigo da Etiqueta CB0                                               
cCodSep  	:= ''
cNFEnt	  	:= ''                                                     
cSeriee  	:= ''
cPedido   	:= ''
cEndereco 	:= ''
cArmazem 	:= SB1->B1_LOCPAD
cOp 		:= ''
cNumSeq 	:= ''
cLote 		:= _cLoteIn
cSLote 		:= ''
dValid 		:= _dValidade
cCC 		:= ''
cLocOri 	:= ''
cOPReq 		:= ''
cNumserie 	:= ''
cOrigem 	:= ''
_cCAS       := ALLTRIM(SB1->B1_XCAS)                 
If _lGrava
   _cCodigo := CBGrvEti('01',{SB1->B1_COD,_nQuant,cCodSep,cNFEnt,cSeriee,cFornec,cLojafo,cPedido,cEndereco,cArmazem,cOp,cNumSeq,NIL,NIL,NIL,cLote,cSLote,dValid,cCC,cLocOri,NIL,cOPReq,cNumserie,cOrigem})
   RecLock('CB0',.F.)
   IF _nTara > 0
   		Replace CB0->CB0_XTARA  With _nTara
   EndIF
   Replace CB0->CB0_XLOTEF With _cLoteFb
   Replace CB0->CB0_XQTDKG With _nQuant
   Replace CB0->CB0_XORIGE With cPais
   MsUnlock()
Else
   _cCodigo := CB0->CB0_CODETI
   _nQuant  := CB0->CB0_QTDE  
EndIf   

IF !Empty(_cCodigo)
                                     
	_cQuant		:= AllTrim(TransForm(SB1->B1_XPESETQ,'@e 999,999.999'))
	_cDataFb	:= DtoC(_dDataFb)
	_cDtFrac	:= DtoC(_dDtFrac)
	_cTara 		:= AllTrim(TransForm(_nTara,'@e 999,999.999'))
	_cValidade	:= DtoC(_dValidade)
	_cOpfrac    := SubStr(CB0->CB0_OP,1,6)
	If Alltrim(FunName()) != "U_PEST002"
		_cOpfraceo  := Alltrim(mv_par13)
	Endif
	cQuanteo    := TRANSFORM(mv_par04, '@e 999,999.999') 

	IF _cTpImp == 'Z4M'		
		_nLin := 27 //13.5
		                          
		IF !Empty(_cDesc := Posicione("SYA",1,xFilial("SYA")+_cOrigem,"YA_DESCR" ))
			_cOrigem := AllTrim(_cDesc)
		EndIF

		_nLin += 4
		MSCBSAY(_nLin,005,"Produto: " +PadR(SB1->B1_DESC,40) 	,_cRota,cFonte,"10")
			
		If mv_par13 == ""
		_nLin -= 3
		MSCBSAY(_nLin,005,"Lote: " +_cLoteFb + "Lote Int: "+_cLoteIn, _cRota,cFonte,"10")
		MSCBSAY(_nLin,065,"Orig.: "+_cOrigem,_cRota,cFonte,"10")
        Else
		_nLin -= 3 //15
        MSCBSAY(_nLin,005,"Lote: "+_cLoteFb+ "Lote Int: "+_cLoteIn,_cRota,cFonte,"10")
		MSCBSAY(_nLin,065,"Orig.: "+_cOrigem,_cRota,cFonte,"10")
		EndIf
	
		_nLin -= 3
		iF SB1->B1_XPESETQ == 0
        MSCBSAY(_nLin,005,"Fabr: " 		+_cDataFb + "       " + "Val: "	    +_cValidade + "     " + "Peso: " +ALLTRIM(cQuanteo) + ' ' + 'KG', _cRota, cFonte,"10")
        Else
		MSCBSAY(_nLin,005,"Fabr: " 		+_cDataFb + "       " + "Val: "	    +_cValidade + "     " + "Peso: "+_cQuant+' '+AllTrim(SB1->B1_PESO) + ' ' + 'KG', _cRota, cFonte,"10")
		EndIf
        _nLin -= 3 //13    
        MSCBSAY(_nLin,005,"Fabricante.: " +SubStr(cNomFabr,1,22) + "     " + "DCB.: "+_cDCB,_cRota,cFonte,"10")	
        _nLin -= 14	
		MSCBSAYBAR(_nLin,066,_cCodigo,_cRota,"MB07",09,.F.,.F., .F. , "C" , 2, 2 , .F., .T. )
		_nLin -= 2
		MSCBSAY(_nLin,072,_cCodigo,_cRota,cFonte,"10")
		_nLin -= 1
		
	   _nLinC := 19
	   MSCBSAY(_nLinC, 005, 'CAS :',  _cRota,cFonte,"10")
	   
	   nLinhas := MLCount(SB1->B1_XCAS, 45)
     For nXi := 1 To nLinhas
        cTxtLinha := MemoLine(SB1->B1_XCAS, 45, nXi)
          
          If !Empty(cTxtLinha)
            MSCBSAY(_nLinC, 013, +ALLTRIM(cTxtLinha),  _cRota,cFonte,"10")
            _nLinC -= 3
          EndIF
          
     Next nXi
     
		If Alltrim(FunName()) != "U_PEST002"
			If mv_par13 == ""
				MSCBSAY(008,030,"Guia Frac.: "  +_cOpfrac   ,_cRota,"B","10")
				MSCBSAY(008,005,+ "Dt.Fra.:"    +_cDtFrac   , _cRota,cFonte,"10")
				MSCBSAY(006,005,"Farm. Resp.: " +cFarm      ,_cRota,"B","10")			
			else
				MSCBSAY(008,030,"Guia Frac.: "  +_cOpfraceo	,_cRota,"B","10")
				MSCBSAY(008,005,+ "Dt.Fra.:"    +_cDtFrac   ,_cRota,cFonte,"10")
				MSCBSAY(006,005,"Farm. Resp.: " +cFarm		,_cRota,"B","10")
			EndIf
		else
			    MSCBSAY(008,030,"Guia Frac.: "  +_cOpfraceo ,_cRota,"B","10")
				MSCBSAY(008,005,+ "Dt.Fra.:"    +_cDtFrac   ,_cRota,cFonte,"10")
				MSCBSAY(006,005,"Farm. Resp.: " +cFarm	    ,_cRota,"B","10")	
		Endif 
	EndIF
	
	MSCBInfoEti("Etiqueta Fracionamento","04x10")
	MSCBEND()   
EndIF

MSCBCLOSEPRINTER()
  
Return


//MODELO DE PARAMETROS PARA IMPRESSAO
//*--------------------*
User Function xImpFraq
//*--------------------*

Local _k := 0

_cCodProd := '000717'
_cOrigem  := 'Espanha'
_nQuant   := 12.3
_cLoteFb  := '0000875006'
_dDataFb  := dDataBase
_cCAS     := '0123456789abcdefghijklmnoprstuvxz-ABCFGTRS-0123456789abcdefghijklmnoprstuvxz'
_cFab     := 'CRODA' 

_dDtFrac 	:= dDataBase
_nTara   	:= 0.18
_cLoteIn 	:= 'PS-0060035/F03'
_dValidade 	:= dDataBase
_cOpfraceo  := '002050'
_cDCB       := '05161'
_cDCI       := '99999'

For _k:=1 To 1
	//Impressao e geracado do CB0 - Etiqueta Fracionamento ou E.O.
	u_xEtiqFraEO(_cCodProd,_cOrigem,_nQuant,_cLoteFb,_dDataFb,_cCAS,_cFab,_dDtFrac,_nTara,_cLoteIn,_dValidade,_cDCB,_cDCI,_cOpfraceo)
Next _k

Return                                   

/*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\*/
User Function ImpEtiqEO

Local _nI := 0

_cPerg := 'XIMPETIQA'

 mv_par01 := ""
 mv_par02 := ""
 mv_par03 := ""
 mv_par04 := ""
 mv_par05 := ""
 mv_par06 := ""
 mv_par07 := ""
 mv_par08 := ""
 mv_par09 := ""
 mv_par10 := ""
 mv_par11 := ""
 mv_par12 := ""
 mv_par13 := ""
 
 AjustaSX1(_cPerg)

If Pergunte(_cPerg, .T.)
   For _nI := 1 To mv_par11      
   
      SYA->(DbSeek(xFilial('SYA')+mv_par02))                        
      SB1->(DbSeek(xFilial('SB1')+mv_par01))                                                           
      SA2->(DbSeek(xFilial('SA2')+mv_par09+mv_par10))
	  
   	  //Impressao e geracado do CB0 - Etiqueta Fracionamento ou E.O.
   	  u_xEtiqFraEO(mv_par01,SYA->YA_DESCR,mv_par04,mv_par08,mv_par06,AllTrim(SB1->B1_XCAS),SA2->A2_NREDUZ,mv_par12,mv_par03,mv_par05,mv_par07,AllTrim(SB1->B1_XDCB),AllTrim(SB1->B1_XDCI),mv_par09,mv_par10,mv_par02,mv_par13,.T.)
   Next	  
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AjustaSX1	  บAutor  ณ Alexandre Takaki   บ Data ณ 08/03/2019  บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 																	บฑฑ
ฑฑบ          ณ 												      				บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC				  		                                      	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)
	
	Local _sAlias := Alias()
	Local aRegs   := {}
	Local i,j
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	
	cPerg := PADR(cPerg,10)
	
	AADD(aRegs,{cPerg,"01","Cod. Produto ?"			,"","","mv_ch1","C",15,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","",""})
	AADD(aRegs,{cPerg,"02","Cod. Pais ?"			,"","","mv_ch2","C",03,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SYA","","",""})
	AADD(aRegs,{cPerg,"03","Tara ?"					,"","","mv_ch3","N",06,3,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Peso ?"					,"","","mv_ch4","N",06,3,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Lote Interno ?"			,"","","mv_ch5","C",20,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Data Fabric ?"			,"","","mv_ch6","D",08,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Data Validade ?"		,"","","mv_ch7","D",08,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Lote Fabric ?"			,"","","mv_ch8","C",20,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"09","Cod. Fornecedor ?"		,"","","mv_ch9","C",06,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","",""})
	AADD(aRegs,{cPerg,"10","Loja Fornecedor ?"		,"","","mv_chA","C",02,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","",""})
	AADD(aRegs,{cPerg,"11","Quantidade ?"			,"","","mv_chB","N",03,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"12","Data Fracionada ?"		,"","","mv_chC","D",08,0,0,"G","","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"13","Guia Fracionada ?"		,"","","mv_chD","C",06,0,0,"G","","MV_PAR13","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	
Return()
