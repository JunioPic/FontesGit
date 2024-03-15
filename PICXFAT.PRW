#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

#DEFINE  ENTER CHR(13)+CHR(10)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ EmpUseRot  บ Autor ณ Meliora/Gustavo   Data ณ    /  /      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Liberacao de Uso da Customizacao para Empresa corrente     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/         

*----------------------------*
User Function EmpUseRot(_cRot)
*----------------------------*
Local aArea    := GetArea() 
Local _lLib    := .F.

IF !Empty(FunName())
	DbSelectArea('PA1');PA1->(DbSetORder(1))
	IF PA1->(DbSeek(xFilial('PA1')+_cRot+FunName()))
		_lLib := PA1->PA1_MSBLQL<>'1'	
	ENDIF
EndIF

RestArea(aArea)
Return(_lLib)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ xGatPrdPrc  บ Autor ณ Meliora/Gustavo   Data ณ    /  /     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gatilho para rastro dos precos...                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/         
*----------------------*
User Function xGatPrdPrc
*----------------------*
Local aArea      := GetArea() 
Local aArDA1     := DA1->(GetArea()) 
Local aArDA0     := DA0->(GetArea())           

Private _cAlsCb := iIF(FunName()=='MATA410','C5','CJ')
Private _cAlsIt := iIF(FunName()=='MATA410','C6','CK')
					
Private _nPPrcDj := aScan(aHeader,{|X| Upper(Alltrim(x[2]))== _cAlsIt+'_XPRCDJ' })
Private _nPPrcMi := aScan(aHeader,{|X| Upper(Alltrim(x[2]))== _cAlsIt+'_XPRCMI' })

Private _nPTabDj := aScan(aHeader,{|X| Upper(Alltrim(x[2]))== _cAlsIt+'_XTABDJ' })
Private _nPTabMi := aScan(aHeader,{|X| Upper(Alltrim(x[2]))== _cAlsIt+'_XTABMI' })
                                                             
Private _nPProd  := aScan(aHeader,{|X| Upper(Alltrim(x[2]))== _cAlsIt+'_PRODUTO'})
Private _nPQuant := aScan(aHeader,{|X| Upper(Alltrim(x[2]))== _cAlsIt+'_QTDVEN' })
Private _nPVenda := aScan(aHeader,{|X| Upper(Alltrim(x[2]))== _cAlsIt+'_PRCVEN' })
Private _nPPrUnit:= aScan(aHeader,{|X| Upper(Alltrim(x[2]))== _cAlsIt+'_PRUNIT' })
Private _nPValor := aScan(aHeader,{|X| Upper(Alltrim(x[2]))== _cAlsIt+'_VALOR' })

/*
//Valida Utilizacao da Customizacao
IF !U_EmpUseRot(iIF(_cAlsCb=='C5','01','09'))
	Return
EndIF
*/

If cEmpAnt == "01"
	IF 	_nPPrcDj > 0
		IF _cAlsCb=='C5'
			aCols[n][_nPPrcDj]:= CriaVar(_cAlsIt+'_XPRCDJ')
		Else
			&((oGetDad:CTRB)+'->'+_cAlsIt+'_XPRCDJ') := CriaVar(_cAlsIt+'_XPRCDJ')
		EndIF  
	EndIF
	IF _nPPrcMi > 0
		IF _cAlsCb=='C5'
			aCols[n][_nPPrcMi] := CriaVar(_cAlsIt+'_XPRCMI')
		ELSE
			&((oGetDad:CTRB)+'->'+_cAlsIt+'_XPRCMI') := CriaVar(_cAlsIt+'_XPRCMI')
		EndIF
	EndIF
				
	IF !Empty( &('M->'+_cAlsCb+'_TABELA') )
		IF ReadVar()=='M->'+_cAlsIt+'_PRODUTO'
			IF _cAlsCb=='C5'
				aCols[n][_nPProd]  := &('M->'+_cAlsIt+'_PRODUTO')
			Else 
				&((oGetDad:CTRB)+'->'+_cAlsIt+'_PRODUTO') := &('M->'+_cAlsIt+'_PRODUTO')
			EndIF
		EndIF 
	
		DbSelectArea('DA0');DA0->(DbSetORder(1))
		DbSelectArea('DA1');DA1->(DbSetORder(1));DA1->(DbGoTop())
		IF DA0->(DbSeek(xFilial('DA0')+&('M->'+_cAlsCb+'_TABELA')))
			IF ( (Empty(DA0->DA0_DATDE) .Or. DA0->DA0_DATDE  <= dDataBase) .And. (Empty(DA0->DA0_DATATE) .Or. DA0->DA0_DATATE >= dDataBase) .And. DA0->DA0_ATIVO=='1')		
				IF DA1->(DbSeek(xFilial('DA1')+&('M->'+_cAlsCb+'_TABELA')+ iIF(_cAlsCb=='C5', aCols[n][_nPProd], &((oGetDad:CTRB)+'->'+_cAlsIt+'_PRODUTO')) ))
					IF 	_nPPrcDj > 0                            //Soma valor dos impostos (media de calculo PIC)
						_nNewVal := xPcValTab('DA1_XPRCDJ')
						IF _cAlsCb=='C5'
							aCols[n][_nPPrcDj]							:= (_nNewVal / u_xAlqUf(iIF(_cAlsCb=='C5', aCols[n][_nPProd], &((oGetDad:CTRB)+'->'+_cAlsIt+'_PRODUTO')),SA1->A1_EST))
						Else
							&((oGetDad:CTRB)+'->'+_cAlsIt+'_XPRCDJ') 	:= (_nNewVal / u_xAlqUf(iIF(_cAlsCb=='C5', aCols[n][_nPProd], &((oGetDad:CTRB)+'->'+_cAlsIt+'_PRODUTO')),SA1->A1_EST))
						EndIF
						
						IF _cAlsCb=='C5'
							aCols[n][_nPTabDj] := _nNewVal
						else
							&((oGetDad:CTRB)+'->'+_cAlsIt+'_XTABDJ') := _nNewVal
						EndIF
					EndIF
					IF _nPPrcMi > 0								//Soma valor dos impostos (media de calculo PIC)
						_nNewVal := xPcValTab('DA1_XPRCMI')
						IF _cAlsCb=='C5'
							aCols[n][_nPPrcMi] 							:= (_nNewVal / u_xAlqUf(iIF(_cAlsCb=='C5', aCols[n][_nPProd], &((oGetDad:CTRB)+'->'+_cAlsIt+'_PRODUTO')),SA1->A1_EST))	
						Else 
							&((oGetDad:CTRB)+'->'+_cAlsIt+'_XPRCMI') 	:= (_nNewVal / u_xAlqUf(iIF(_cAlsCb=='C5', aCols[n][_nPProd], &((oGetDad:CTRB)+'->'+_cAlsIt+'_PRODUTO')),SA1->A1_EST))	
						EndIF
						
						IF _cAlsCb=='C5'
							aCols[n][_nPTabMi]							:= _nNewVal
						Else
							&((oGetDad:CTRB)+'->'+_cAlsIt+'_XTABMI') 	:= _nNewVal
						EndIF
					EndIF
					IF _cAlsCb=='C5'
						aCols[n][_nPVenda]							:= iIF(_cAlsCb=='C5', aCols[n][_nPPrcMi], &((oGetDad:CTRB)+'->'+_cAlsIt+'_XPRCMI'))
					else 
						&((oGetDad:CTRB)+'->'+_cAlsIt+'_PRCVEN')  	:= iIF(_cAlsCb=='C5', aCols[n][_nPPrcMi], &((oGetDad:CTRB)+'->'+_cAlsIt+'_XPRCMI'))
					EndIF
					
			   		IF _cAlsCb=='C5'
			   			aCols[n][_nPPrUnit] 						:= CriaVar(_cAlsIt+'_PRUNIT')
			   		Else 
			   			&((oGetDad:CTRB)+'->'+_cAlsIt+'_PRUNIT') 	:= CriaVar(_cAlsIt+'_PRUNIT')
			   		EndIF
					
					IF _cAlsCb=='C5'
						_nValNet := A410Arred((aCols[n][_nPQuant]*aCols[n][_nPVenda]),(_cAlsIt+'_PRCVEN'))
					Else
						_nValNet := A410Arred((&((oGetDad:CTRB)+'->'+_cAlsIt+'_QTDVEN')*&((oGetDad:CTRB)+'->'+_cAlsIt+'_PRCVEN')),(_cAlsIt+'_PRCVEN'))
					EndIF
					
					IF _nValNet > 0
						If ExistTrigger(_cAlsIt+'_PRCVEN ') .And. _cAlsCb == 'C5'
							&('M->'+_cAlsIt+'_PRCVEN') := aCols[n][_nPVenda]
							RunTrigger(2,n,nil,,_cAlsIt+'_PRCVEN ')
						Endif
						
						IF _cAlsCb=='C5'
							aCols[n][_nPValor] := _nValNet	
						Else 
							&((oGetDad:CTRB)+'->'+_cAlsIt+'_VALOR') := _nValNet
						EndIF
						
						IF _cAlsCb=='C5'
							Ma410Rodap(Nil,aCols[n][_nPValor],0)
						Else
							oGetDad:ForceRefresh()
						EndIF
						GetDRefresh()
					EndIF			
				ENDIF
			Else
				MsgStop("Tabela de Pre็o Bloqueada ou fora de Vig๊ncia","Aten็ใo")
			EndIF
		EndIF
	EndIF
Else

	IF 	_nPPrcDj > 0
		IF _cAlsCb=='C5'
			aCols[n][_nPPrcDj]:= CriaVar(_cAlsIt+'_XPRCDJ')
		Else
			&((oGetDad:CTRB)+'->'+_cAlsIt+'_XPRCDJ') := CriaVar(_cAlsIt+'_XPRCDJ')
		EndIF
	EndIF
	IF _nPPrcMi > 0
		IF _cAlsCb=='C5'
			aCols[n][_nPPrcMi] := CriaVar(_cAlsIt+'_XPRCMI')
		ELSE
			&((oGetDad:CTRB)+'->'+_cAlsIt+'_XPRCMI') := CriaVar(_cAlsIt+'_XPRCMI')
		EndIF
	EndIF
				
	IF !Empty( &('M->'+_cAlsCb+'_TABELA') )
		IF ReadVar()=='M->'+_cAlsIt+'_PRODUTO'
			IF _cAlsCb=='C5'
				aCols[n][_nPProd]  := &('M->'+_cAlsIt+'_PRODUTO')
			Else 
				&((oGetDad:CTRB)+'->'+_cAlsIt+'_PRODUTO') := &('M->'+_cAlsIt+'_PRODUTO')
			EndIF
		EndIF 
	
		DbSelectArea('DA0');DA0->(DbSetORder(1))
		DbSelectArea('DA1');DA1->(DbSetORder(1));DA1->(DbGoTop())
		IF DA0->(DbSeek(xFilial('DA0')+&('M->'+_cAlsCb+'_TABELA')))
			IF ( (Empty(DA0->DA0_DATDE) .Or. DA0->DA0_DATDE  <= dDataBase) .And. (Empty(DA0->DA0_DATATE) .Or. DA0->DA0_DATATE >= dDataBase) .And. DA0->DA0_ATIVO=='1')		
				IF DA1->(DbSeek(xFilial('DA1')+&('M->'+_cAlsCb+'_TABELA')+ iIF(_cAlsCb=='C5', aCols[n][_nPProd], &((oGetDad:CTRB)+'->'+_cAlsIt+'_PRODUTO')) ))

					_nNewVal := xPcValTab('DA1_XPRCMI')
					IF _cAlsCb=='C5'
						aCols[n][_nPVenda]							:= (_nNewVal / u_xAlqUf(iIF(_cAlsCb=='C5', aCols[n][_nPProd], &((oGetDad:CTRB)+'->'+_cAlsIt+'_PRODUTO')),SA1->A1_EST))	
					else 
						&((oGetDad:CTRB)+'->'+_cAlsIt+'_PRCVEN')  	:= iIF(_cAlsCb=='C5', aCols[n][_nPPrcMi], &((oGetDad:CTRB)+'->'+_cAlsIt+'_XPRCMI'))
					EndIF
					
			   		IF _cAlsCb=='C5'
			   			aCols[n][_nPPrUnit] 						:= CriaVar(_cAlsIt+'_PRUNIT')
			   		Else 
			   			&((oGetDad:CTRB)+'->'+_cAlsIt+'_PRUNIT') 	:= CriaVar(_cAlsIt+'_PRUNIT')
			   		EndIF
					
					IF _cAlsCb=='C5'
						_nValNet := A410Arred((aCols[n][_nPQuant]*aCols[n][_nPVenda]),(_cAlsIt+'_PRCVEN'))
					Else
						_nValNet := A410Arred((&((oGetDad:CTRB)+'->'+_cAlsIt+'_QTDVEN')*&((oGetDad:CTRB)+'->'+_cAlsIt+'_PRCVEN')),(_cAlsIt+'_PRCVEN'))
					EndIF
					
					IF _nValNet > 0
						If ExistTrigger(_cAlsIt+'_PRCVEN ') .And. _cAlsCb == 'C5'
							&('M->'+_cAlsIt+'_PRCVEN') := aCols[n][_nPVenda]
							RunTrigger(2,n,nil,,_cAlsIt+'_PRCVEN ')
						Endif
						
						IF _cAlsCb=='C5'
							aCols[n][_nPValor] := _nValNet	
						Else 
							&((oGetDad:CTRB)+'->'+_cAlsIt+'_VALOR') := _nValNet
						EndIF
						
						IF _cAlsCb=='C5'
							Ma410Rodap(Nil,aCols[n][_nPValor],0)
						Else
							oGetDad:ForceRefresh()
						EndIF
						GetDRefresh()
					EndIF			
				ENDIF
			Else
				MsgStop("Tabela de Pre็o Bloqueada ou fora de Vig๊ncia","Aten็ใo")
			EndIF
		EndIF
	EndIF
EndIf

DA0->(DbCloseArea())
DA1->(DbCloseArea())
RestArea(aArea)
RestArea(aArDA0)
RestArea(aArDA1)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ XGATPROD		  บAutor  ณ Alexandre Takaki   บ Data ณ 19/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ GATILHO PARA PREENCHER O CAMPO PREวO DO PRODUTO DE ACORDO COM 	บฑฑ
ฑฑบ          ณ A TABELA DE PREวO, PARA COTAวีES/ORวAMENTOS                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TAKAKI			  		                                      	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function XGATPROD()
	
	Local aArea      	:= GetArea() 
	Local aArDA1     	:= DA1->(GetArea()) 
	Local aArDA0     	:= DA0->(GetArea()) 
	Local cProduto		:= ""
	Local _nNewVal		:= 0
	//Local _XnValNet		:= 0
	Local nPrcVenda		:= 0
	
	Private _XnPPrcDj 	:= aScan(aHeader,{|X| Upper(Alltrim(x[2]))== "CK_XPRCDJ" })
	Private _XnPPrcMi 	:= aScan(aHeader,{|X| Upper(Alltrim(x[2]))== "CK_XPRCMI" })
	
	If !Empty( M->CJ_TABELA )
		cProduto := ALLTRIM(TMP1->CK_PRODUTO)
		
		DbSelectArea("DA0")
		DA0->(DbSetORder(1))
		
		DbSelectArea("DA1")
		DA1->(DbSetORder(1))
		DA1->(DbGoTop())
		
		If DA0->( DbSeek(xFilial("DA0")+M->CJ_TABELA) )
		
			If ( (Empty(DA0->DA0_DATDE) .Or. DA0->DA0_DATDE  <= dDataBase) .And. (Empty(DA0->DA0_DATATE) .Or. DA0->DA0_DATATE >= dDataBase) .And. DA0->DA0_ATIVO == "1")
			
				If DA1->(DbSeek(xFilial("DA1")+M->CJ_TABELA+cProduto))
					
					If 	_XnPPrcDj > 0
						_nNewVal := xPcTabCot('DA1_XPRCDJ')
						nPrcVenda := (_nNewVal / u_xAlqUf(cProduto,SA1->A1_EST))
					EndIf
					
					If _XnPPrcMi > 0								
						_nNewVal := xPcTabCot('DA1_XPRCMI')
						nPrcVenda := (_nNewVal / u_xAlqUf(cProduto,SA1->A1_EST))
					EndIf
					
					GetDRefresh()
					
				EndIf
			
			Else
	
				MsgStop("Tabela de Pre็o Bloqueada ou fora de Vig๊ncia","Aten็ใo")
	
			EndIf
		
		EndIf
		
	EndIf
	
	DA0->(DbCloseArea())
	DA1->(DbCloseArea())
	
	RestArea(aArea)
	RestArea(aArDA0)
	RestArea(aArDA1)
	
Return(nPrcVenda)

*----------------------------------*
Static Function xPcTabCot(_cCampo)
*----------------------------------*

Local _nValorTb := 0
	
_nPrcVen   	:= &('DA1->'+_cCampo)
_nMoedaTab 	:= DA1->DA1_MOEDA
_nFator    	:= DA1->DA1_PERDES
_nValorTb 	:= xMoeda(_nPrcVen,_nMoedaTab, M->CJ_MOEDA,,TamSx3("D2_PRCVEN")[2])

Return(_nValorTb)

*----------------------------------*
Static Function xPcValTab(_cCampo)
*----------------------------------*

Local _nValorTb := 0

_nPrcVen   :=  &('DA1->'+_cCampo)
_nMoedaTab := DA1->DA1_MOEDA
_nFator    := DA1->DA1_PERDES
_nValorTb := xMoeda(_nPrcVen,_nMoedaTab, &('M->'+_cAlsCb+'_MOEDA'),,TamSx3("D2_PRCVEN")[2])

Return(_nValorTb)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ ValUnitNet  บ Autor ณ Meliora/Gustavo   Data ณ    /  /     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calcula Pre็o Unitแrio Sem Impostos...                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/         

*-----------------------*
User Function ValUnitNet
*-----------------------*

Local aArea     := GetArea()
Local _lRet     := .F.

Local _nPProdut := aScan(aHeader,{|X| Upper(Alltrim(x[2]))=='C6_PRODUTO'})
Local _nPTes    := aScan(aHeader,{|X| Upper(Alltrim(x[2]))=='C6_TES'})    

Local _nPQtdVen := aScan(aHeader,{|X| Upper(Alltrim(x[2]))=='C6_QTDVEN'})
Local _nPPrcBrt := aScan(aHeader,{|X| Upper(Alltrim(x[2]))=='C6_XPRCBRT'})
Local _nPPrcVnd := aScan(aHeader,{|X| Upper(Alltrim(x[2]))=='C6_PRCVEN'}) 
Local _nPValor  := aScan(aHeader,{|X| Upper(Alltrim(x[2]))=='C6_VALOR'})
Local _nPPrcDj  := aScan(aHeader,{|X| Upper(Alltrim(x[2]))=='C6_XPRCDJ'})                        
Local _nPTabDj  := aScan(aHeader,{|X| Upper(Alltrim(x[2]))=='C6_XTABDJ'})                      

Local _nQtdIT    := 1
Local _nValNet   := 0
Local _nCampoBrt := iIF('C6_XPRCBRT'$ReadVar(),M->C6_XPRCBRT,aCols[n][_nPPrcBrt])

//Valida Utilizacao da Customizacao
IF !U_EmpUseRot('01')
	Return
EndIF

//Nao calcula item deletado
IF aCols[n][Len(aHeader)+1]
	Return(.F.) 
EndIF

//Conferencia de VAlor utilizado
IF _nCampoBrt <= 0 //&(_cCampoBrt) <= 0
	MsgStop("Informe um pre็o bruto de venda vแlido!","Aten็ใo")
	Return(.F.)	
EndIF

//Validacao do TES
DbSelectArea('SF4')
IF !ExistCpo('SF4',aCols[n][_nPTes]) .Or. Vazio(aCols[n][_nPTes]) 
	MsgStop("Informe um c๓digo de TES vแlido!","Aten็ใo")
	Return(.F.)
EndIF

//Preco Tabela      , Prc Tab+Impostos, Preco de Venda
_aCalcVlr := {aCols[n][_nPTabDj], 0               , _nCampoBrt}

MaFisIni(	Iif(Empty(SC5->C5_CLIENT),SC5->C5_CLIENTE,SC5->C5_CLIENT),;	// 1-Codigo Cliente/Fornecedor
			SC5->C5_LOJAENT,;												// 2-Loja do Cliente/Fornecedor
			"C",;															// 3-C:Cliente , F:Fornecedor
			"N",;			   												// 4-Tipo da NF
			SA1->A1_TIPO,;	   												// 5-Tipo do Cliente/Fornecedor
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			"MATA461")
			
//Agrega os itens para a funcao fiscal
MaFisAdd(	aCols[n][_nPProdut],; 	// 1-Codigo do Produto ( Obrigatorio )
			aCols[n][_nPTes],;	 	// 2-Codigo do TES ( Opcional )
			_nQtdIT,; 		 		// 3-Quantidade ( Obrigatorio )
			aCols[n][_nPPrcDj],;	// 4-Preco Unitario ( Obrigatorio )
			0,;    		   			// 5-Valor do Desconto ( Opcional )
			"",;	   				// 6-Numero da NF Original ( Devolucao/Benef )
			"",;					// 7-Serie da NF Original ( Devolucao/Benef )
			0,;						// 8-RecNo da NF Original no arq SD1/SD2
			0,;						// 9-Valor do Frete do Item ( Opcional )
			0,;						// 10-Valor da Despesa do item ( Opcional )
			0,;						// 11-Valor do Seguro do item ( Opcional )
			0,;						// 12-Valor do Frete Autonomo ( Opcional )
			aCols[n][_nPPrcDj],;	// 13-Valor da Mercadoria ( Obrigatorio )
			0)

_nFR_ITTot := MaFisRet(1,"IT_TOTAL")
_nFR_NFTot := MaFisRet(,"NF_TOTAL")   	
_nFR_NFMer := MaFisRet(,"NF_VALMERC")
	
_aCalcVlr[2] := _nFR_ITTot 
			
//Finaliza rotinas do Fiscal
MaFisEnd()

_nValNet := A410Arred((_aCalcVlr[1]*_aCalcVlr[3]) / _aCalcVlr[2],"C6_PRCVEN")
IF _nValNet > 0
	aCols[n][_nPPrcVnd] := _nValNet
	If ExistTrigger('C6_PRCVEN ')
		M->C6_PRCVEN := aCols[n][_nPPrcVnd]
		RunTrigger(2,n,nil,,'C6_PRCVEN ')
	Endif
	aCols[n][_nPValor] := A410Arred(aCols[n][_nPQtdVen]*aCols[n][_nPPrcVnd],"C6_PRCVEN")
	GetDRefresh()
	_lRet := .T.
EndIF
	
RestArea(aArea)
Return(_lRet)

*--------------------*
User Function xBlqCpo
*--------------------*
Local _lBloq    := .T.
Local aArea     := GetArea()
Local _cTpCust  := '01'
Local _cDefault := 'C6_XPRCBRT'
Local _cBloqFx  := 'C6_PRCVEN'

//Valida Utilizacao da Customizacao
_lUltCust := U_EmpUseRot(_cTpCust)

_lBloq := ( AllTrim(StrTran(ReadVar(),'M->','')) == iIF(_lUltCust,_cDefault,_cBloqFx) )

RestArea(aArea)
Return(_lBloq)
                 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ ValUnitNet  บ Autor ณ Meliora/Gustavo   Data ณ    /  /     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ::Rotina para recalculo, gatilho nos campos::              บฑฑ
ฑฑบ            Campos:                                                    บฑฑ
ฑฑบ            C5_CLIENTE | C5_LOJACLI | C5_TABELA | C6_PRODUTO | C6_TES  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/         
*------------------------*
User Function xRefVCols
*------------------------*
Local aArea     := GetArea()
Local _nLnIni   := 1
Local _nLnFim   := Len(aCols)
Local _nPProdut := aScan(aHeader,{|X| Upper(Alltrim(x[2]))=='C6_PRODUTO'})
Local _nPPrcBrt := aScan(aHeader,{|X| Upper(Alltrim(x[2]))=='C6_XPRCBRT'})
Local n			:= 0

//Valida Utilizacao da Customizacao
IF !U_EmpUseRot('01')
	Return
EndIF

IF 'C6' $ ReadVar()
	_nLnIni := _nLnFim := n
	IF Empty(aCols[n][_nPPrcBrt]) .Or. Empty(aCols[n][_nPPrcBrt])
		Return
	EndIF
Else 
	IF Empty(aCols[1][_nPProdut])
		Return
	EndIF
EndIF

For n:=_nLnIni To _nLnFim
	FWMsgRun(, {|| u_ValUnitNet() }, "Processando a rotina...", "Formatando Itens...")      
NExt n

RestArea(aArea)
Return 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ xAlqUf     บ Autor ณ Meliora/Gustavo   Data ณ    /  /      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ::Fun็ใo para calculo da aliquota tributario m้dia::       บฑฑ
ฑฑบ            PIS + COFINS + IPI                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  

*--------------------------------*
User Function xAlqUf(_cProd,_cEst)
*--------------------------------*
Local _nAliq  := 0
Local aArea   := GetArea()
Local aArB1   := SB1->(GetArea())
Local _cMvUf  := Upper(AllTrim(GetMV('MV_XESTICM',.F.,'')))
Local _nMvUf  := VAL(iIF(Alltrim(_cEst)$_cMvUf, SubStr(_cMvUf,At(_cEst,_cMvUf)+Len(_cEst),02), '0'))
Local _nVlPis := GetMV("MV_TXPIS",.F.,0)
Local _nVlCof := GetMV("MV_TXCOF",.F.,0)
Local _nVlVar := GetMV("MV_TXIRCSL",.F.,0) 	//jfranca
Local _cOriP  := GetMV("MV_XORIPRO")
Local _nOrImp := GetMV("MV_XORIMPO",.F.,0)

//pis + cofins + icms = 7,65
//EMP      PIS    COF            
//PIC     1.65    7.6
//PAH     0.65    3.0



DbselectArea('SB1') 
SB1->(DbSetOrder(1)) 
IF SB1->(DbSeek(xFilial('SB1')+_cProd))
	IF (AllTrim(SB1->B1_ORIGEM) $ _cOriP .And. _cEst <> "SP") //.And. SB1->B1_XCAMEX == 'N' //jfranca
		_nMvUf := _nOrImp
	EndIF
EndIF   

IF cEmpAnt = '01'
    //Calculo novo ->(1-(0,18+((0,0165+0,076)*0,82))) ou (100,00/ 0,744150)
	_nAliq := 1-((_nMvUf+((_nVlPis + _nVlCof)*(1-(_nMvUf/100))))/100) 
Else
	// Calculo novo -> Junior Guerreiro -- 30/03/2023
	_nAliq := 1-((_nMvUf+_nVlVar+((_nVlPis + _nVlCof)*(1-(_nMvUf/100))))/100)

Endif

RestArea(aArB1)
RestArea(aArea)
Return(_nAliq)




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ PIC410CRED  บ Autor ณ Meliora/Gustavo   Data ณ  20/10/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Mensagem para quando pedido de venda estiver bloqueado     บฑฑ
ฑฑบ            por CREDITO                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/         
*-----------------------*
User Function PIC410CRED
*-----------------------*
//Valida Utilizacao da Customizacao
IF !U_EmpUseRot('03')
	Return
EndIF

//Valida se existe item bloqueado por cr้dito
IF u_xC9BLCRED(SC5->C5_NUM)  
	Aviso('Aten็ใo',"Pedido Bloqueado por Cr้dito, favor solicitar a libera็ใo!",{"Fechar"})	
	//IF RecLock('SC5',.F.)
	//	Replace SC5->C5_BLQ With '1'
	//	SC5->(MsUnLock())
	//EndIF
EndIF

Return




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ xC9BLCRED   บ Autor ณ Meliora/Gustavo   Data ณ  20/10/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rastreia pedido de venda para bloqueio de credito          บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   

//altera็ใo e exclusใo de Fonte para pagamento a vista -- Fonte substituido por bloqueio de regras no sistema --20/11/2022

/*
*-------------------------------*
User Function xC9BLCRED(_cPedVen)
*-------------------------------*
Local _aArea   := GetArea()
Local _aArSC9  := SC9->(GetArea())
Local _aArSC5  := SC5->(Getarea())
Local _lRetBlq := .F. 
Local _cCondPG  := ''          
Local _cCondPGMV:= GETMV("MV_AVISTA") //-- QsDoBrasil -- Item 01

Default _cPedVen := ''

DbSelectArea("SC5");SC5->(DbSetOrder(1))
If SC5->(DbSeek(xFilial("SC5") + _cPedVen))     
	   
	_cCondPG := SC5->C5_CONDPAG //-- QSdoBrasil -- Item 01 -- 02/09/2015 -- Condi็ใo de pagamento.     

	DbSelectArea("SC9");SC9->(DbSetOrder(1))
	If SC9->(DbSeek(xFilial("SC9") + SC5->C5_NUM)) .And. SC5->C5_TIPO == 'N'  
	
		If _cCondPG $ _cCondPGMV //'001' //-- QSdoBrasil -- Item 01 -- 02/09/2015 --  Se a condi็ใo de pagamento for a vista '001', for็a o bloqueio de cr้dito.    
		
			Do While SC9->(!EOF()) .And. SC9->C9_FILIAL==xFilial('SC9') .And. SC9->C9_PEDIDO==SC5->C5_NUM
				DbSelectArea("SC6");SC6->(DbSetOrder(1))
				If SC6->(DbSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM))
			
					_lTesFin := Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC")=='S'   
					
					If _lTesFin = .T. //Se a TES gera duplicata
						If _lRetBlq = .F.
							_lRetBlq := .T. 
						EndIf
						
						RecLock("SC9",.F.) //Preenche o campo de bloqueio de cr้dito.
						    SC9->C9_BLCRED := "01"
						MsUnLock()
						
					EndIf   

				EndIF
				SC9->(DbSkip())
	   
			EndDo    
		
		
		Else  //Outras condi็๕es de pagamento.
		
	    	Do While SC9->(!EOF()) .And. SC9->C9_FILIAL==xFilial('SC9') .And. SC9->C9_PEDIDO==SC5->C5_NUM
				DbSelectArea("SC6");SC6->(DbSetOrder(1))
				If SC6->(DbSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM))
			
					_lTesFin := Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC")=='S'
					IF (_lRetBlq := ( _lTesFin .And. SC9->C9_BLCRED $ '01|04|06' ))
						Exit
					EndIF
				EndIF
				SC9->(DbSkip())
	   
			EndDo
		EndIf
	Endif
	
	           
EndIF
Restarea(_aArSC5)
Restarea(_aArSC9)
Restarea(_aArea)

Return(_lRetBlq) 
*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ PIC410VOL  บ Autor ณ Meliora/Gustavo   Data ณ  20/10/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Mensagem para quando pedido de venda estiver bloqueado     บฑฑ
ฑฑบ            por CREDI]TO                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/    

*-----------------------*
User Function PIC410VOL
*-----------------------*

Local nPesoL 		:= 0
Local nPesoB 		:= 0
Local cEspecie      := "VOLUME(S)"
Local nVolume		:= 0

If INCLUI .Or. ALTERA
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
	    Do While SC6->(!EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM==SC5->C5_NUM	
	    
	    	nProPL  := Posicione("SB1", 1, xFilial("SB1") + SC6->C6_PRODUTO, "B1_PESO")
			nProPB  := Posicione("SB1", 1, xFilial("SB1") + SC6->C6_PRODUTO, "B1_PESBRU")     	
			nQtdEmb := Posicione("SB5", 1, xFilial("SB5") + SC6->C6_PRODUTO, "B5_QE1")     	
	  
	    	nVolume	+= SC6->C6_QTDVEN / nQtdEmb   
	    	nPesoL  += SC6->C6_QTDVEN * nProPL
	    	nPesoB	+= SC6->C6_QTDVEN * nProPB    	
	    	
	    	SC6->(DbSkip())
	    EndDo
	EndIf
	
	If SC5->(RecLock("SC5", .F.))
		Replace SC5->C5_VOLUME1 With nVolume
		Replace SC5->C5_PESOL 	With nPesoL
		Replace SC5->C5_PBRUTO 	With nPesoB	
		Replace SC5->C5_ESPECI1 With cEspecie	
		SC5->(MsUnLock())
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ PIC410SEP    บ Autor ณ Meliora/Gustavo  Data ณ  20/10/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rastreia pedido de venda para bloqueio de credito          บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   
*-----------------------*
User Function PIC410SEP
*-----------------------*
//Valida Utilizacao da Customizacao
IF !U_EmpUseRot('07')
	Return
EndIF

//Valida se existe item bloqueado por cr้dito
IF u_xC9BLSEP(SC5->C5_NUM)  
	Aviso('Aten็ใo',"Pedido Aguardando Separa็ใo...",{"Fechar"})	
EndIF

Return

*-------------------------------*
User Function xC9BLSEP(_cPedVen)
*-------------------------------*
Local _aArea   := GetArea()
Local _aArSC9  := SC9->(GetArea())
Local _aArSC5  := SC5->(Getarea())
Local _lRetBlq := .F.
Default _cPedVen := ''

DbSelectArea("SC5");SC5->(DbSetOrder(1))
If SC5->(DbSeek(xFilial("SC5") + _cPedVen))     

	DbSelectArea("SC9");SC9->(DbSetOrder(1))
	If SC9->(DbSeek(xFilial("SC9") + SC5->C5_NUM)) .And. SC5->C5_TIPO == 'N'
	    Do While SC9->(!EOF()) .And. SC9->C9_FILIAL==xFilial('SC9') .And. SC9->C9_PEDIDO==SC5->C5_NUM
				u_xLibSep(SC5->C5_NUM,.F.)			
			SC9->(DbSkip())
		EndDo
	Endif           
EndIF
Restarea(_aArSC5)
Restarea(_aArSC9)
Restarea(_aArea)

Return(_lRetBlq) 

*--------------------------------*
User Function xLibSep(_cPed,_lLib)
*--------------------------------*
IF 	RecLock('SC9',.F.)
	Replace SC9->C9_XLIBOK With iIF(_lLib, GetMV('PC_BLOQSEP',.F.,'X'), Space(TamSx3('C9_XLIBOK')[1])) 
	SC9->(MsUnLock())
EndIF
Return
         
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ ID_M410FAT   บ Autor ณ Meliora/Gustavo   Data ณ  27/10/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao botao Prepara Doc de Saida (tela pedido devenda  บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   
*-----------------------*
User Function ID_M410FAT
*-----------------------*
Local _lRet := .T.
 
 
//Valida Utilizacao da Customizacao
IF !U_EmpUseRot('07') //[07] Controle de Separacao
	Return(_lRet)
EndIF

//IF !(_lRet := u_xBloqFat(3)) //[3] Totalmente Liberado da Separacao
//	MsgInfo('ษ obrigat๓rio libera็ใo da Spera็ใo para faturamento total!','Aten็ใo')
//EndIF
Return(_lRet)
              
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ AF017FRE   บ Autor ณ Meliora/Gustavo   Data ณ  28/10/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Altera็ใo de informacoes do pedido de venda                บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  

*---------------------*
User Function PM410VOL
*---------------------*
Local oDlgGet
//Local lOk       := .T.
Local nOpcGet   := 2 

Local _oVolume1
Local _nVolume1	:= SC5->C5_VOLUME1

Local _oPesoL
Local _nPesoL	:= SC5->C5_PESOL  //CriaVar('C5_PESOL') //Space(TamSX3('C5_PESOL')[1])//SC5->C5_PESOL

Local _oPesoB
Local _nPesoB	:= SC5->C5_PBRUTO //CriaVar('C5_PBRUTO') //Space(TamSX3('C5_PBRUTO')[1])//SC5->C5_PBRUTO

Local cTransp  	:= SC5->C5_TRANSP
Local cNTransp 	:= Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME")
Local oNTransp

Local aComboBx	:= CTBCBOX("C5_TPFRETE")
Local cComboBx  := SC5->C5_TPFRETE

Local oConf
Local lConf := .F.

//PERMISSAO DE USO DA TELA ( DE ACORDO COM LIBRACAO DO PEDIDO ) - SEPARACAO PARCIAL OU SEPARACAO TOTAL
//If cEmpAnt == "02"
//	IF !(_lCont := ( u_xBloqFat(2) .OR. u_xBloqFat(3) ))
//		MsgInfo('Altera็ใo liberada apenas para pedidos com status:'+ENTER+ENTER+' - Em separa็ใo'+ENTER+' - Separa็ใo total','Acesso bloqueado - Pedido: '+SC5->C5_NUM)
//		Return
//	EndIF
//EndIf


DEFINE MSDIALOG oDlgGet FROM  100,4 TO 298,463 TITLE "Altera็ใo do Pedido de Venda - "+SC5->C5_NUM PIXEL Style 128
oDlgGet:lEscClose := .F.

	@ 02,02 TO 97,230 PIXEL


	@ 07,10 SAY "Tipo Frete" SIZE 70,9 of oDlgGet PIXEL
	@ 16,10 ComboBox cComboBx Items aComboBx Size 072,050 PIXEL OF oDlgGet When IIf(cEmpAnt $ ("01,02,04"), .T., .F.)
		
	@ 32,10 SAY "Transportadora" SIZE 070,009 of oDlgGet PIXEL
	@ 41,10 MSGET cTransp  SIZE 050,009 F3("SA4") OF oDlgGet PIXEL VALID(ExistCpo("SA4",cTransp), cNTransp:=Posicione("SA4",1,xFilial("SA4")+cTransp,"A4_NOME")) HASBUTTON When IIf(cEmpAnt $ "01,02,04", .T., .F.)
	@ 41,70 MSGET oNTransp VAR cNTransp SIZE 150,9 OF oDlgGet PIXEL WHEN .F.
	
	   @ 57,10 SAY "Volume" SIZE 70,9 of oDlgGet PIXEL
	   @ 66,10 MSGET _oVolume1 VAR _nVolume1 Picture("@E 9,999,999") SIZE 050,9 When(!lConf) OF oDlgGet PIXEL VALID(_nVolume1==0.Or._nVolume1>0) HASBUTTON	
	
	If cEmpAnt $ ("01,02,04") 
		
		@ 57,70 SAY  "Peso Liquido" SIZE 70,9 of oDlgGet PIXEL
		@ 66,70 MSGET _oPesoL VAR _nPesoL Picture(PesqPict('SC5','C5_PESOL')) SIZE 050,9 When(!lConf) OF oDlgGet PIXEL  HASBUTTON	
		
		@ 57,140 SAY "Peso Bruto"   SIZE 70,9 of oDlgGet PIXEL
		@ 66,140 MSGET _oPesoB VAR _nPesoB Picture(PesqPict('SC5','C5_PBRUTO')) SIZE 050,9 When(!lConf) OF oDlgGet PIXEL  HASBUTTON		
		
	EndIf		
			
	@ 82,10 CheckBox oConf Var lConf Prompt "Libera็ใo de Faturamento" Valid(xChkLbFat(_nVolume1,@lConf,_oVolume1,oConf,oDlgGet))  Size 080,008 PIXEL OF oDlgGet When IIf(cEmpAnt $ "01,02,04", .T., .F.)

	
	//DEFINE SBUTTON FROM 80,140 TYPE 1 ACTION (oDlgGet:End(),nOpcGet:=1) ENABLE OF oDlgGet
	//DEFINE SBUTTON FROM 80,140 TYPE 1 ACTION (IIf(.T.,(oDlgGet:End(),nOpcGet:=1),Nil)) ENABLE OF oDlgGet 	
	//DEFINE SBUTTON FROM 80,140 TYPE 1  ACTION(nOpcGet:=1,oDlgGet:End()) ENABLE OF oDlgGet PIXEL
	
	//DEFINE SBUTTON FROM 80,180 TYPE 2 ACTION (oDlgGet:End(),nOpcGet:=2) ENABLE OF oDlgGet
	
	@ 082,140 BUTTON OemToAnsi("Confirmar")  SIZE 35,12 ACTION(oDlgGet:End(),nOpcGet:=2)
	@ 082,175 BUTTON OemToAnsi("Cancelar")   SIZE 35,12 ACTION(oDlgGet:End())
	//@ 80,180 BUTTON OemToAnsi("OK") SIZE 35,10 ACTION(oDlgGet:End(),nOpcGet:=2)
	
ACTIVATE MSDIALOG oDlgGet CENTERED

If nOpcGet == 2
	Begin Transaction
		//Alteracao Cabecalho do Pedido
		IF 	RecLock("SC5",.F.)
				If cEmpAnt $ "01,02,04" 
					Replace SC5->C5_TPFRETE With SubStr(cComboBx,1,1)                                     
					Replace SC5->C5_TRANSP	With cTransp
					Replace SC5->C5_PESOL   With _nPesoL//Val(Transform(_nPesoL,'@e 999.999'))
					Replace SC5->C5_PBRUTO  With _nPesoB//Val(Transform(_nPesoB,'@e 999.999'))   
   				    Replace SC5->C5_VOLUME1	With _nVolume1					
				Else
					Replace SC5->C5_PESOL   With _nPesoL//Val(Transform(_nPesoL,'@e 999.999'))
					Replace SC5->C5_PBRUTO  With _nPesoB//Val(Transform(_nPesoB,'@e 999.999'))
   				    Replace SC5->C5_VOLUME1	With _nVolume1
				EndIf
			SC5->(MsUnlock())	
		EndIF
		//Liberacao de Faturamento
		IF lConf    
			_lLibNota := .T.
			DbSelectArea('SC9')
			SC9->(DbSetOrder(1))
			IF SC9->(DbSeek(xFilial('SC9')+SC5->C5_NUM))
			
				//Faz varredura para verificacao se todos os itens foram separados grava flg e conferencia de seracao
				Do While SC9->(!Eof()) .And. SC9->C9_FILIAL==xFilial('SC9') .And. SC9->C9_PEDIDO==SC5->C5_NUM
					IF SubStr(SC9->C9_XLIBOK,1,1)=='X'
						IF 	RecLock("SC9",.F.)
								Replace SC9->C9_XLIBOK With SubStr(SC9->C9_XLIBOK,1,1)+'X'
							SC9->(MsUnlock())	
						EndIF
					Else 
						_lLibNota := .F.	
					EndIF
					SC9->(DbSkip())
				EndDo 
				     
				//Libera Flag para faturamento
			  IF cEmpAnt $ "01,02,04"
				IF _lLibNota                    
					DbSelectArea('SC9');SC9->(DbGoTop())
					IF SC9->(DbSeek(xFilial('SC9')+SC5->C5_NUM))
						Do While SC9->(!Eof()) .And. SC9->C9_FILIAL==xFilial('SC9') .And. SC9->C9_PEDIDO==SC5->C5_NUM
								IF 	RecLock("SC9",.F.)
										Replace SC9->C9_XLIBTOT With 'S'
									SC9->(MsUnlock())	
								EndIF
							SC9->(DbSkip())
						EndDo
					EndIF					
				EndIF
			  Else
			   DbSelectArea('SC9');SC9->(DbGoTop())
					IF SC9->(DbSeek(xFilial('SC9')+SC5->C5_NUM))
						Do While SC9->(!Eof()) .And. SC9->C9_FILIAL==xFilial('SC9') .And. SC9->C9_PEDIDO==SC5->C5_NUM
								IF 	RecLock("SC9",.F.)
										Replace SC9->C9_XLIBTOT With 'S'
									SC9->(MsUnlock())	
								EndIF
							SC9->(DbSkip())
						EndDo
					EndIF
			  EndIf
			EndIF
			SC9->(DbCloseArea())
		EndIF
	End Transaction
EndIf

Return Nil     
*-------------------------------------------------*
Static Function  xChkLbFat(_nVolume1,lConf,_oVolume1,oConf,oDlgGet)
*-------------------------------------------------*
Local _lRet := .T.
IF _nVolume1==0
	MsgInfo('ษ obrigat๓rio informar o Volume!','Aten็ใo')
	lConf := .F.
EndIF            
_oVolume1:Refresh(); oConf:Refresh(); oDlgGet:Refresh(); _oVolume1:SetFocus()

Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ PIC410AVN   บ Autor ณ Meliora/Gustavo   Data ณ  31/10/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Mensagem e trava para controle Anvisa...                   บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
*---------------------*
User Function PIC410AVN
*---------------------*
Local _lRet := .T.

//Valida Utilizacao da Customizacao
IF !U_EmpUseRot('05') //[05] Controle de Anvisa
	Return(_lRet)
EndIF
  
//Valida tratamento para controle Anvisa
//_lRet := u_VldAnvisa(2)               
If !Empty(SC5->C5_BLQ)
   _lRet := .f.     
Endif

Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ PIC410AVN   บ Autor ณ Meliora/Gustavo   Data ณ  31/10/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Mensagem e trava para controle Anvisa...                   บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
User Function xAtuPeso()

Local nPesoL 	  := 0
Local nPesoB 	  := 0
Local cEspecie    := "VOLUME(S)"
//Local nVolume	  := 0

DbSelectArea("SC5")
SC5->(DbSetOrder(1))
Do While SC5->(!Eof()) .And. SC5->C5_FILIAL == xFilial("SC5")
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
	    Do While SC6->(!EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM==SC5->C5_NUM	
	    
	    	nProPL  := Posicione("SB1", 1, xFilial("SB1") + SC6->C6_PRODUTO, "B1_PESO")
			nProPB  := Posicione("SB1", 1, xFilial("SB1") + SC6->C6_PRODUTO, "B1_PESBRU")     	
			nQtdEmb := Posicione("SB5", 1, xFilial("SB5") + SC6->C6_PRODUTO, "B5_QE1")     	
	  
	    	//nVolume	+= SC6->C6_QTDVEN / nQtdEmb   
	    	nPesoL  += SC6->C6_QTDVEN * nProPL
	    	nPesoB	+= SC6->C6_QTDVEN * nProPB    	
	    	
	    	SC6->(DbSkip())
	    EndDo
	EndIf	
	If SC5->(RecLock("SC5", .F.))
		//Replace SC5->C5_VOLUME1 With Round(nVolume,2)
		Replace SC5->C5_PESOL 	With nPesoL
		Replace SC5->C5_PBRUTO 	With nPesoB	
		Replace SC5->C5_ESPECI1 With cEspecie	
		SC5->(MsUnLock())
	EndIf   
	nPesoL := 0
	nPesoB := 0
	SC5->(DbSkip())
EndDo

MsgInfo("FIM")

Return    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ PIC410AVN   บ Autor ณ Meliora/Gustavo   Data ณ  31/10/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Mensagem e trava para controle Anvisa...                   บฑฑ
ฑฑบ                                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PIC/Pharmaspecial                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
User Function xCliOri(cDoc, cSerie,nTipo)

cDesc := ""

If nTipo == 1
	cPedido := Posicione("SD2", 3, xFilial("SD2") + cDoc + cSerie, "D2_PEDIDO")
	cCliOri := Posicione("SC5", 1, xFilial("SC5") + cPedido, "C5_XCLIORG") 
	cLojOri := Posicione("SC5", 1, xFilial("SC5") + cPedido, "C5_XLOJORG")
	cDesc := Posicione("SA1", 1, xFilial("SA1") + cCliOri + cLojOri, "A1_NREDUZ")   
ElseIf nTipo == 2
	cDesc := Posicione("SD2", 3, xFilial("SD2") + cDoc + cSerie, "D2_PEDIDO")	
EndIf

Return cDesc

