
#INCLUDE "ap5mail.ch"
#include "protheus.ch"  
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#DEFINE  ENTER CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Q215FIM  ºAutor  ³ Meliora/Zanni      º Data ³  29/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para impressão do Laudo de Qualidade      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico PIC                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function Q215FIM 
Local nOpcao := ParamIxb[11]

If nOpcao = 3 // somente na inclusao de resultados
	_nOpc := Aviso('Impressão de Laudo','Confirma a impressão do Certificado de Análise?',{'Ok','Cancela'})
	If _nOpc == 1
   	   U_ImpLaudo(QEK->QEK_PRODUT, QEK->QEK_LOTE)
    EndIf         	
Endif

Return .T.                                                             

/*\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\*/
User Function ImpLaudo(_cQEKPrd, _cQEKLote, _cNFisc, _cCli)

Local cUser := RetCodUsr()
Local cUsrPar := GETMV("PH_USRIMPL")

Default _cNFisc := ''                                          
Default _cCli   := ''


/*** FONTES ***/               
Private _cNFiscal := _cNFisc
Private _cCliente := _cCli
Private oFont18T  	:= TFont():New("Arial",,18,,.T.,,,,,.F.)
Private oFont16T  	:= TFont():New("Arial",,16,,.T.,,,,,.F.) 
Private oFont16  	:= TFont():New("Arial",,16,,.T.,,,,,.F.) 
Private oFont14TC 	:= TFont():New("Arial",,14,,.T.,,,,,.F.)
Private oFont14T  	:= TFont():New("Arial"      ,,14,,.T.,,,,,.F.) 
Private oFont14TI  	:= TFont():New("Arial"      ,,13,,.T.,,,,.T.,.F.) 
Private oFont11T  	:= TFont():New("Arial"      ,,12,,.T.,,,,,.F.) 
Private oFont11F  	:= TFont():New("Arial"      ,,12,,.F.,,,,,.F.) 
Private oFont13T  	:= TFont():New("Arial"      ,,12,,.T.,,,,,.F.) 
Private oFont13F  	:= TFont():New("Arial"      ,,12,,.F.,,,,,.F.) 
Private oFont10FA 	:= TFont():New("Arial"      ,,10,,.F.,,,,,.F.)
Private oFont10F 	:= TFont():New("Arial",,10,,.F.,,,,,.F.)
Private oFont11FA 	:= TFont():New("Arial"      ,,11,,.F.,,,,,.F.)

Private oFont09T  	:= TFont():New("Arial",,09,,.T.,,,,,.F.)
Private oFont07F  	:= TFont():New("Arial",,07,,.F.,,,,,.F.)
Private oFont09F  	:= TFont():New("Arial",,09,,.F.,,,,,.F.)
Private oFont09FA  	:= TFont():New("Arial",,09,,.F.,,,,,.F.)

Private oFont7TA  	:= TFont():New("Arial",,07,,.T.,,,,,.F.)
Private oFont12F  	:= TFont():New("Arial",,12,,.F.,,,,,.F.)
Private oFont10T  	:= TFont():New("Arial",,10,,.T.,,,,,.F.)
//Private oFont09F  	:= TFont():New("Arial",,09,,.F.,,,,,.F.)
//Private oFont09T  	:= TFont():New("Arial",,09,,.T.,,,,,.F.)
Private oFont14N  	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)

Private oFont10AT  	:= TFont():New("Arial"      ,,10,,.T.,,,,,.F.)
Private oFont10AF  	:= TFont():New("Arial"      ,,10,,.F.,,,,,.F.)

Private oHGRAY := TBrush():New( ,  CLR_YELLOW)

Private cIniFile  := GetADV97() 
Private _cRaiz    := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) 

/*** ABRE FOLHA ***/
Private oPrint     	:= Nil//TMSPrinter():New() 

/*** IMAGENS ***/
Private _cLogo      := "\system\LGRL01" //FisxLogo("1") //"\system\_RLgr01.bmp"
Private Titulo    	:= "Certificado de Análise"
Private _cPerg 	    := 'IMPLAUDO'
Private _aFicha     := {}   
Private cPathEst    := Alltrim(GetMv("MV_DIREST"))
MontaDir(cPathEst)
Private _nPag   := 0
_cAreaQEK := GetArea()

//____________________________________________________________________________________________________________________
_lOk   := .T. 
_lView := .T. 
IF _lOk	       
	IF (FunName() $ 'MATA410')
		_cNomePDF := 'LAUDO_'+StrTran(StrTran(AllTrim(AllTrim(_cQEKPrd)+_cQEKLote),'-'),'/')+'_'+DtoS(dDataBase)+'-'+StrTran(Time(),':','')		
	Else 
		//_cNomePDF := 'LAUDO_'+'PV-'+SC5->C5_NUM
		_cNomePDF := 'LAUDO_'+'PV-'+SC5->C5_NUM+'_'+DtoS(dDataBase)+'-'+StrTran(Time(),':','')		
	EndIF
	
	fErase(cPathEst+_cNomePDF+'.pdf')
	IF oPrint == Nil
		lPreview 		:= .F.
	    IF cUser $ cUsrPar 
	     oPrint:= FWMSPrinter():New(_cNomePDF,6,.T.,,.T.,,,,,,,_lView)
		Else	
		 oPrint:= FWMSPrinter():New(_cNomePDF,IMP_SPOOL,.T.,,.T.,,,"Impressora Expedicao")
		ENDIF
		oPrint:SetResolution(78) //Tamanho estipulado para a Danfe
		oPrint:SetPortrait()
		oPrint:SetPaperSize(DMPAPER_A4)
		oPrint:SetMargin(60,60,60,60)
		IF cUser $ cUsrPar  
	      oPrint:nDevice  := IMP_PDF
		ENDIF
		oPrint:cPathPDF := cPathEst
		_cArq := cPathEst+_cNomePDF+'.pdf'
    ENDIF                                
	    Private PixelX := oPrint:nLogPixelX()
	    Private PixelY := oPrint:nLogPixelY()
	    oPrint:StartPage() 
Else
	oPrint:= TMSPrinter():New( "Certificado de Análise" )
	oPrint:Setup()
	oPrint:SetPortrait() // ou SetLandscape()
	oPrint:StartPage()   // Inicia uma nova página
EndIF
//_______________________________________________________[ QUANDRO CABEC ]_______________________________________________________

cProdOri := _cQEKPrd
cLoteOri := _cQEKLote

If FunName() $ 'MATA410/MATA650' 		//Type('_cQEKPrd') == 'C'                             
	DbSelectArea('SD2');SD2->(DbSetOrder(8))
	IF SD2->(DbSeek(xFilial('SD2')+SC5->C5_NUM))
		While SD2->(!Eof()) .And. xFilial('SD2')+SD2->D2_PEDIDO==SC5->C5_FILIAL+SC5->C5_NUM
		   _cLoteOri :='';_cProdOri:='' 
		   _cQEKPrd  := SD2->D2_COD
		   _cQEKLote := SD2->D2_LOTECTL
		   _cNFisc   := SD2->D2_DOC
		   _cCli     := SA1->A1_NOME
		   _cTipo    := SD2->D2_TP
		    
		  If _cTipo == "MP" //ALTERAÇÃO PARA GERAR LAUDO DA EMBALAGEM ORIGINAL DATA DA ALTERAÇÃO 22/03/2024 POR JUNIOR GUERREIRO
		    _cQryU:=" SELECT D4_COD, D4_LOTECTL "+ENTER
			_cQryU+=" FROM "+RetSqlName('SD4')+" SD4  "+ENTER
			_cQryU+=" INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.D_E_L_E_T_=''   AND B1_FILIAL='"+xFilial('SB1')+"' AND B1_COD=D4_COD AND B1_DESC LIKE '%EO%' "+ENTER
			_cQryU+=" INNER JOIN "+RetSqlName('SD3')+" SD3 ON SD3.D_E_L_E_T_='' AND D3_FILIAL='"+xFilial('SD3')+"' AND D3_LOTECTL='"+SD2->D2_LOTECTL+"' AND D3_COD='"+SD2->D2_COD+"' "+ENTER
			_cQryU+=" WHERE SD4.D_E_L_E_T_= ' '  "+ENTER
			_cQryU+=" AND D4_FILIAL='"+xFilial('SD4')+"' "+ENTER
			_cQryU+=" AND D4_OP=D3_OP "+ENTER
			If Select("_LST") > 0   	
				_LST->(DbCloseArea())
			EndIf
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryU),"_LST",.F.,.T.)
			DbSelectArea("_LST")
			_LST->(DbGotop())
			IF !Empty(_LST->D4_COD)
				 _cProdOri:=_LST->D4_COD
				 _cLoteOri:=_LST->D4_LOTECTL
			EndIF
		  else
		    _cQryU:=" SELECT DISTINCT D3_COD, D3_LOTECTL "+ENTER
			_cQryU+=" FROM "+RetSqlName('SD3')+" SD3  "+ENTER
			_cQryU+=" INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.D_E_L_E_T_=''   AND B1_FILIAL='"+xFilial('SB1')+"' AND B1_COD=D3_COD "+ENTER
			_cQryU+=" AND D3_FILIAL='"+xFilial('SD3')+"' AND D3_LOTECTL='"+SD2->D2_LOTECTL+"' AND D3_COD='"+SD2->D2_COD+"' "+ENTER
			_cQryU+=" WHERE SD3.D_E_L_E_T_= ' '  "+ENTER
			_cQryU+=" AND D3_FILIAL='"+xFilial('SD4')+"' "+ENTER
			//_cQryU+=" AND D4_OP=D3_OP "+ENTER
			If Select("_LST") > 0   	
				_LST->(DbCloseArea())
			EndIf
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryU),"_LST",.F.,.T.)
			DbSelectArea("_LST")
			_LST->(DbGotop())
			IF !Empty(_LST->D3_COD)
				 _cProdOri:=_LST->D3_COD
				 _cLoteOri:=_LST->D3_LOTECTL
			EndIF
		  EndIF 	
			If FunName() == 'MATA650' 
			   _cQuery := "Select Distinct QEK.R_E_C_N_O_ QEK_REC"
			   _cQuery += "	From "+RetSqlName('QEK')+" QEK, "+RetSqlName('SD7')+" SD7 "
			   _cQuery += "	Where QEK_PRODUT = '"+cProdOri+"'  And "
			   _cQuery += "	    QEK_NTFISC  = D7_DOC And"
			   _cQuery += "	    QEK_SERINF  = D7_SERIE And"
			   _cQuery += "	    QEK_LOTE    = D7_LOTECTL And"
			   _cQuery += "	    D7_XLOTEIN  = '"+cLoteOri+"' And"
			   _cQuery += "		QEK.D_E_L_E_T_ = '' And SD7.D_E_L_E_T_ = ''"			
			Else 
			   _cQuery := "Select Distinct QEK.R_E_C_N_O_ QEK_REC"
			   _cQuery += "	From "+RetSqlName('QEK')+" QEK, "+RetSqlName('SD7')+" SD7 "
			   _cQuery += "	Where QEK_PRODUT = '"+_cProdOri+"'  And "
			   _cQuery += "	    QEK_NTFISC  = D7_DOC And"
			   _cQuery += "	    QEK_SERINF  = D7_SERIE And"
			   _cQuery += "	    QEK_LOTE    = D7_LOTECTL And"
			   _cQuery += "	    D7_XLOTEIN  = '"+_cLoteOri+"' And"
			   _cQuery += "		QEK.D_E_L_E_T_ = '' And SD7.D_E_L_E_T_ = ''"			
			EndIf

		   DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"_QEK",.F.,.T.)
		   _nRecQEK := _QEK->QEK_REC
		   _QEK->(DbCloseArea())
		
		   If Empty(_nRecQEK)
		      Aviso('Certificado de Análise','Laudo não localizado para o Produto '+AllTrim(_cQEKPrd)+' Lote '+AllTrim(_cQEKLote),{'Abandona'})
		      RestArea(_cAreaQEK)
		      SD2->(DbSkip())
		      Loop
		   Else
		      QEK->(DbGoTo(_nRecQEK))
		   EndIf
		   IF _nPag > 0
		   		oPrint:EndPage()
		  		oPrint:StartPage()
		   EndIF
		   MsgRun("Gerando laudo de análise [Pedido: "+SC5->C5_NUM+"], aguarde...","",{|| CursorWait(), ImpCert(_cQEKLote,_cQEKPrd) ,CursorArrow()})	      
 	       If FunName() == 'MATA650' 
 	       		Exit
 	       EndIf
		   SD2->(DbSkip())
		EndDo
	EndIF
Else
	MsgRun("Gerando laudo de análise, aguarde...","",{|| CursorWait(), ImpCert(_cQEKLote,_cQEKPrd) ,CursorArrow()})
EndIf


IF oPrint <> Nil
    
	IF cUser $ cUsrPar 
	       oPrint:Preview()
	ELSE
	       oPrint:Print()
	ENDIF

	FreeObj(oPrint)
	MS_FLUSH()
	oPrint := Nil
EndIF

RestArea(_cAreaQEK)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ MXFINR902 º Autor ³ 	Meliora/Gustavo	 º Data ³  01/07/14     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio FATURA ELETRONICA..   .                            ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Uso especifico Metax                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/               
*-----------------------------------------*
Static Function ImpCert(_cQEKLote,_cQEKPrd)
*-----------------------------------------*
/*** VARIAVEIS DO SISTEMA ***/  
Private _NPULALIN   := 2900//2850
Private _nLin     	:= 0000
Private _NSpace10   := 10
Private _NSpace20   := 20
Private _NSpace30   := 30                                 
Private _NSpace40   := 40                                 
Private _NSpace50   := 50   
Private _NSpace60   := 60                               

DbSelectArea('SM0');SM0->(DbsetOrder(1))
	
xImpCb(@_nLin, _cQEKLote,_cQEKPrd)

_nLinBx2 := _nLin
_nLin+=_NSpace30
_nLin+=_NSpace60

Return                                                                         

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ PFATR01 º Autor ³ 	Meliora/Gustavo	 º Data ³  29/09/14     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio TABELA DE PRECO                                    ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Uso especifico PIC                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*--------------------------------------------*
Static Function	_xEndFol(_nLinBx2,_nLin)
*--------------------------------------------*
oPrint:EndPage()
oPrint:StartPage()
xImpCb(@_nLin)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ PFATR01 º Autor ³ 	Meliora/Gustavo	 º Data ³  29/09/14     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio TABELA DE PRECO                                    ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Uso especifico PIC                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*---------------------------*
Static Function xImpCb(_nLin,_cQEKLote,_cQEKPrd)
*---------------------------* 
//Local _aEmp := xEmpFil(cFilAnt)
Local _cQuery:=""

Local _nX	:= 0

//Private _nLin  := 50 

xImpCabec(_cQEKLote,_cQEKPrd)

_cQuery := "Select QE1_DESCPO, QE8_TEXTO, QEQ_MEDICA, QE8_METODO"
_cQuery += "	From "+RetSqlName('QER')+" QER, "+RetSqlName('QEQ')+" QEQ, "+RetSqlName('QE1')+" QE1, "+RetSqlName('QE8')+" QE8"
_cQuery += "	Where QE1_ENSAIO = QER_ENSAIO And"
_cQuery += "	      QEQ_CODMED = QER_CHAVE And"
_cQuery += "		  QE8_PRODUT = QER_PRODUT And"
_cQuery += "		  QE8_ENSAIO = QER_ENSAIO And"
_cQuery += "		  QE8_REVI = QER_REVI And "
_cQuery += "		  QER_PRODUT = '"+QEK->QEK_PRODUT+"' and"
_cQuery += "		  QER_LOTE   = '"+QEK->QEK_LOTE+"' ANd"
_cQuery += "		  QER_NISERI = '"+Left(AllTrim(QEK->QEK_NTFISC)+Space(09),09)+(QEK->QEK_SERINF)+QEK->QEK_ITEMNF+"' And"
_cQuery += "		  QER_REVI   = '"+QEK->QEK_REVI+"' ANd"
_cQuery += "		  QER.D_E_L_E_T_ = '' And QEQ.D_E_L_E_T_ = '' And QE1.D_E_L_E_T_ = '' And QE8.D_E_L_E_T_ = ''"
_cQuery += "     Order By QE8_SEQLAB"
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"TMPQE",.F.,.T.)
_l2 := .F.
Do While TMPQE->(!EoF())
	xNewPage(@_nLin,_cQEKLote,_cQEKPrd)
	
   oPrint:Say(_nLin,0040,TMPQE->QE1_DESCPO,					oFont10F)	
   If Len(AllTrim(TMPQE->QE8_TEXTO)) > 40
      oPrint:Say(_nLin,0840,Left(TMPQE->QE8_TEXTO,40),					oFont10F)	
      oPrint:Say(_nLin+30,0840,Substr(TMPQE->QE8_TEXTO,41),					oFont10F)	
      _l2 := .T.
   Else
      oPrint:Say(_nLin,0840,TMPQE->QE8_TEXTO,					oFont10F)	
   EndIf
      
   //oPrint:Say(_nLin,1660,TMPQE->QEQ_MEDICA,					oFont10F)	
	_cMsgComen := AllTrim(TMPQE->QEQ_MEDICA)
	_nLPos     := 0      
	IF !Empty(_cMsgComen)
		_nQtdLMemo := 24
		_nLinhas := MlCount(_cMsgComen,_nQtdLMemo)
		For _nX:=1 To _nLinhas
			oPrint:Say(_nLin,1660, OemToAnsi(MemoLine(_cMsgComen,_nQtdLMemo,_nX)), oFont10F)
			_nLin+=_NSpace30
			_nLPos := _nLin
		Next _nX
		IF _nLinhas > 0
			_nLin := (_nLin - (_nLinhas*_NSpace30))
		EndIF
	ENDIF		
   
   oPrint:Say(_nLin,2100,TMPQE->QE8_METODO,					oFont10F)
      	
   _nLin := (_nLPos + _NSpace40)
   
   If _l2
      _nLin +=_nSpace30
      _l2:=.F. 
   EndIf
                        
   TMPQE->(DbSkip())
EndDo                
TMPQE->(DbCloseArea())


_nLin +=_nSpace50                                                         
_cRodape := QE6->QE6_XRODAP
Do While !Empty(_cRodape)           
   _nPos := At(Chr(13)+Chr(10), _cRodape)
   If Empty(_nPos)
      _cRod := _cRodape
      _cRodape := ''
   Else
      _cRod := StrTran(StrTran(StrTran(Left(_cRodape, _nPos), Chr(13)+Chr(10)), Chr(13)), Chr(10))
      _cRodape := Substr(_cRodape, _nPos+1)
   EndIf   
   oPrint:Say(_nLin+50,0050,_cRod,					oFont11T)	
   _nLin +=_nSpace30                                                         
EndDo   
_nLin +=_nSpace50                                                         
_nLin +=_nSpace50  
_nLin +=_nSpace60                                                       
                
xRodape()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ PFATR01 º Autor ³ 	Meliora/Gustavo	 º Data ³  29/09/14     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio TABELA DE PRECO                                    ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Uso especifico PIC                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*--------------------------*
Static Function xEmpFil(_cFil)
*--------------------------*
Local _aRet      := {} 

aADD(_aRet, AllTrim(RetField('SM0',1,cEmpAnt+_cFil,'M0_NOMECOM')))
aADD(_aRet, AllTrim(RetField('SM0',1,cEmpAnt+_cFil,'M0_ENDCOB')))
aADD(_aRet, AllTrim(RetField('SM0',1,cEmpAnt+_cFil,'M0_BAIRCOB')))
aADD(_aRet, AllTrim(RetField('SM0',1,cEmpAnt+_cFil,'M0_CIDCOB')))
aADD(_aRet, AllTrim(RetField('SM0',1,cEmpAnt+_cFil,'M0_ESTCOB')))
aADD(_aRet, TransForm(RetField('SM0',1,cEmpAnt+_cFil,'M0_CEPENT'),'@r 99999-999'))
aADD(_aRet, TransForm(RetField('SM0',1,cEmpAnt+_cFil,'M0_TEL'),'@r 99 9999-9999'))
aADD(_aRet, TransForm(RetField('SM0',1,cEmpAnt+_cFil,'M0_INSC'),'@r 999.999.999.999'))
aADD(_aRet, TransForm(RetField('SM0',1,cEmpAnt+_cFil,'M0_CGC'),"@r 99.999.999/9999-99"))
Return(_aRet)
  
                         
*---------------------------------*
Static Function xImpCabec(_cQEKLote,_cQEKPrd)
*---------------------------------*
Local _cProc     := ""
Local _cLoteInt  := ""
Local _cValid    := ""
Local _cDataFabr := ""
Local _cLoteFabr := ""
//Local _nX		:= 0

If Empty(_cNFiscal)
   SB1->(DbSeek(xFilial('SB1')+QEK->QEK_PRODUT))
Else
   SB1->(DbSeek(xFilial('SB1')+_cQEKPrd))
EndIf   

SA2->(DbSeek(xFilial('SA2')+QEK->QEK_FORNECE+QEK->QEK_LOJFOR))                   
                   
//Meliora/Gustavo - Novo posicionamento
DbSelectArea('SA5')
DbOrderNickName('A5_XAMARRA')
IF !SA5->(DbSeek(xFilial('SA5')+QEK->QEK_XAMARR,.T.))	
	MsgInfo('Campo Prod x For Seq não localizado, favor efetuar amarração correta na Entrada do Laudo!'+ENTER+ENTER+;
			'Código de Amarração não localizado na tabela Prod x For: '+ENTER+;
			'Amarração: '+QEK->QEK_XAMARR+ENTER+;
			'Fornecedor:'+QEK->QEK_FORNECE+'-'+QEK->QEK_LOJFOR+ENTER+;
			'Produto: '+AllTrim(QEK->QEK_PRODUT),;
			'#A5_XAMARRA#')
	DbSelectArea('SA5');DbSetOrder(1)
	SA5->(DbSeek(xFilial('SA5')+QEK->QEK_FORNECE+QEK->QEK_LOJFOR+QEK->QEK_PRODUT))   
EndIF

SYA->(DbSeek(xFilial('SYA')+QEK->QEK_XPAIS)) //SA2->A2_PAIS))              
SD1->(DbSelectArea("SD1"),DbSetOrder(1),DbSeek(xFilial('SD1')+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_FORNECE+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_ITEMNF))
SD7->(DbSelectArea("SD7"),DbSetOrder(2),DbSeek(xFilial('SD7')+Left(QEK->QEK_CERFOR,6)+QEK->QEK_PRODUT))
SA2->(DbSelectArea("SA2"),DbSetOrder(1),DbSeek(xFilial('SA2')+SA5->A5_FABR+SA5->A5_FALOJA))

If SB1->B1_IMPORT == 'S'
   _cProc := '2-Produto importado'
Else
   _cProc := '1-Produto Nacional'   
EndIf

If Empty(_cNFiscal)
   _cLoteInt:=SD7->D7_XLOTEIN
Else   
   _cLoteInt:=_cQEKLote
EndIf   


If Empty(QEK->QEK_XORDEM)

   _cValid := DtoC(SD1->D1_DTVALID)
   SB8->(DbSetOrder(2))
   If SB8->(DbSeek(xFilial('SB8')+SD1->D1_NUMLOTE+SD1->D1_LOTECTL+SD1->D1_COD+SB1->B1_LOCPAD))
      _cValid := Dtoc(SB8->B8_DTVALID)
   EndIf
   _cDataFabr := DtoC(SD1->D1_DFABRIC)   
   _cLoteFabr := SD1->D1_LOTECTL

Else
 
   DbSelectArea('SC2')
   DbSetOrder(1)
   DbSeek(xFilial('SC2')+QEK->QEK_XORDEM)
  
   _cValid    := Dtoc(SC2->C2_XDTVALD)   
   _cDataFabr := Dtoc(SC2->C2_XDTFAB)  
   _cLoteFabr := SC2->C2_XLOTEF

Endif


_nLin  := 0010
_cLogo := FisxLogo("1") 
oPrint:SayBitmap(_nLin-20,0060,_cLogo,500,250)
oPrint:Say(_nLin,1000,OemToAnsi('CERTIFICADO DE ANÁLISE') 		,oFont16T)	

_nLin+=_nSpace30
_nLin+=_nSpace50
_nLin+=_nSpace60
_nLin+=_nSpace30
_nPag++
oPrint:Say(_nLin,1980,'PAG.: '+cValToChar(_nPag)		    ,oFont09F)	

_nLin+=_nSpace10
_nLin+=_nSpace10
oPrint:Say(_nLin,1980,'DATA/HORA: '+DtoC(dDataBase)+' '+Time()		,oFont09F)	

_nLin+=_nSpace30
oPrint:Say(_nLin,1980,'Laudo: '+QEK->QEK_CERQUA,			oFont10T)	
oPrint:Say(_nLin,2090,' ',			oFont10F)	

_nLin+=_nSpace60
_nLin+=_nSpace10
oPrint:Say(_nLin,0190,'Cliente: ',					oFont11T)	
oPrint:Say(_nLin,0320,_cCLiente,			        oFont11F)	
oPrint:Say(_nLin,1980,'Nota Fiscal: ',				oFont11T)
oPrint:Say(_nLin,2210,_cNFiscal,					oFont11F)	

_nLin+=_nSpace30
_nLin+=_nSpace10
oPrint:Say(_nLin,0175,'Produto: ',       			oFont11T)	
oPrint:Say(_nLin,0320,SB1->B1_DESC,		oFont11F)	

_nLin+=_nSpace30
_nLin+=_nSpace10
oPrint:Say(_nLin,0070,'Nome Químico: ',				oFont11T)	
oPrint:Say(_nLin,0320,SUBSTR(SB1->B1_X_ESPEC,1,115),	oFont11F)	

_nLin+=_nSpace30
_nLin+=_nSpace10
oPrint:Say(_nLin,0320,SUBSTR(SB1->B1_X_ESPEC,116,LEN(SB1->B1_X_ESPEC)-115),	oFont11F)	

_nLin+=_nSpace30
_nLin+=_nSpace10
oPrint:Say(_nLin,0060,'Código Produto: ',	         oFont11T)	
oPrint:Say(_nLin,0320,SB1->B1_COD,			         oFont11F)	
oPrint:Say(_nLin,1000,'Origem: ',	 		         oFont11T)	
oPrint:Say(_nLin,1130,SYA->YA_DESCR,		         oFont11F)
oPrint:Say(_nLin,1800,'Lote Interno:  ' +_cLoteInt,  oFont11T)	
oPrint:Say(_nLin,2100, ' '  ,		                 oFont11F)

_nLin+=_nSpace30
_nLin+=_nSpace10	

oPrint:Say(_nLin,1000,'Procedência: ',		         oFont11T)	
oPrint:Say(_nLin,1200,_cProc,				         oFont11F)	
oPrint:Say(_nLin,1800,'Fabricação:    ' +_cDataFabr, oFont11T)	
oPrint:Say(_nLin,2100, ' ' ,		                 oFont11F)

_nLin+=_nSpace30
_nLin+=_nSpace10         

oPrint:Say(_nLin,0100,'Lote Original: ',		   oFont11T)	
oPrint:Say(_nLin,0320,_cLoteFabr,			       oFont11F)		
oPrint:Say(_nLin,1800,'Validade:        ' +_cValid,oFont11T)	
oPrint:Say(_nLin,2100, ' ' ,			           oFont11F)	

_nLin+=_nSpace30
_nLin+=_nSpace10
oPrint:Say(_nLin,0140,'Fabricante: ',		    oFont11T)	
oPrint:Say(_nLin,0320,SA2->A2_NOME,		 	    oFont11F)	

_nLin+=_nSpace30
_nLin+=_nSpace10
oPrint:Say(_nLin,0230,'DCB: ',					oFont11T)	
oPrint:Say(_nLin,0320,SB1->B1_XDCB,				oFont11F)	

_nLin+=_nSpace30
_nLin+=_nSpace10
oPrint:Say(_nLin,0236,'DCI: ',					oFont11T)	
oPrint:Say(_nLin,0320,SB1->B1_XDCI,				oFont11F)	


_nLin+=_nSpace30
_nLin+=_nSpace10
oPrint:Say(_nLin,0230,'CAS: ',					oFont11T)	
oPrint:Say(_nLin,0320,SB1->B1_XCAS,				oFont11F)	

//MELIORA/GUSTAVO - TRATAMENTO PARA RASTRO DE PRODUTO MAE - IMPRESSAO DE LAUDO 23/06/2015
IF FunName() $ 'QIEA215'
	QE6->(DbSeek(xFilial('QE6')+SB1->B1_COD))
ElseIF QE6->QE6_TIPO == 'PA'
	_nBKSB1 := SB1->(Recno())
	_cPRMae := " Select B1_COD PRODUTO "+ENTER
	_cPRMae += "  From "+RetSqlName('SG1')+" SG1  "+ENTER
	_cPRMae += "   INNER JOIN "+RetSqlName('SB1')+" SB1 ON SB1.D_E_L_E_T_='' AND B1_FILIAL ='"+xFilial('SB1')+"' AND B1_COD=G1_COMP AND B1_DESC LIKE '%EO%' "+ENTER
	_cPRMae += "    Where SG1.D_E_L_E_T_='' AND B1_FILIAL ='"+xFilial('SG1')+"' AND G1_COD='"+SB1->B1_COD+"' 	 "+ENTER
	If Select("_PRMAE") > 0   	
		_PRMAE->(DbCloseArea())
	EndIf
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cPRMae),"_PRMAE",.F.,.T.)
	DbSelectArea("_PRMAE");_PRMAE->(DbGotop())
	IF !Empty(_PRMAE->PRODUTO)
		QE6->(DbSeek(xFilial('QE6')+_PRMAE->PRODUTO))
	ENDIF
	DbSelectArea('SB1');SB1->(DbGoTo(_nBKSB1))
  Else //ALTERAÇÃO PARA GERAR ALUDO DA EMBALAGEM ORIGINAL DATA DA ALTERAÇÃO 20/04/2022 POR JUNIOR GUERREIRO
    _nBKSB1 := SB1->(Recno())
	_cPRMae := " Select B1_COD PRODUTO "+ENTER
	_cPRMae += "  From "+RetSqlName('SB1')+" SB1  "+ENTER
	_cPRMae += "    Where SB1.D_E_L_E_T_='' AND B1_FILIAL ='"+xFilial('SB1')+"' AND B1_COD='"+SB1->B1_COD+"' 	 "+ENTER
	If Select("_PRMAE") > 0   	
		_PRMAE->(DbCloseArea())
	EndIf
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cPRMae),"_PRMAE",.F.,.T.)
	DbSelectArea("_PRMAE");_PRMAE->(DbGotop())
	IF !Empty(_PRMAE->PRODUTO)
		QE6->(DbSeek(xFilial('QE6')+_PRMAE->PRODUTO))
	ENDIF
	DbSelectArea('SB1');SB1->(DbGoTo(_nBKSB1))
EndIF

_nLin+=_nSpace30
_nLin+=_nSpace50
_nLin+=_nSpace60
_nLin+=_nSpace50 
 /*                                                       
_cMsgComen := QE6->QE6_XCABEC

IF !Empty(_cMsgComen)
	_nQtdLMemo := 100
	_nLinhas := MlCount(_cMsgComen,_nQtdLMemo)
	For _nX:=1 To _nLinhas
		oPrint:Say(_nLin,0050, OemToAnsi(MemoLine(_cMsgComen,_nQtdLMemo,_nX)),					oFont11T)
		_nLin+=_nSpace50                                                    
	Next _nX
ENDIF    
	*/
_nLin+=_nSpace30                                                       

If !Empty(QE6->QE6_XMANUS)
   oPrint:Say(_nLin,0080,'MANUSEIO E ARMAZENAMENTO :',			oFont11T)	
   oPrint:Say(_nLin,0600,Left(QE6->QE6_XMANUS,100),				oFont11F)	
   If !Empty(Substr(QE6->QE6_XMANUS,101))
      _nLin+=_nSpace30
      oPrint:Say(_nLin,0600,Substr(QE6->QE6_XMANUS,101),		oFont11F)	
      _nLin+=_nSpace30                                                        
      _nLin+=_nSpace30
   Else               
      _nLin+=_nSpace30                                                        
      _nLin+=_nSpace30
   EndIf
EndIf   
If !Empty(QE6->QE6_XDERRA)
   oPrint:Say(_nLin,0080,'DERRAMAMENTO OU VAZAMENTO :',			oFont11T)	
   oPrint:Say(_nLin,0650,Left(QE6->QE6_XDERRA,100),				oFont11F)	
   If !Empty(Substr(QE6->QE6_XDERRA,101))
      _nLin+=_nSpace30
      oPrint:Say(_nLin,0650,Substr(QE6->QE6_XDERRA,101),		oFont11F)	
      _nLin+=_nSpace30                                                        
      _nLin+=_nSpace30
   Else               
      _nLin+=_nSpace30                                                        
      _nLin+=_nSpace30
   EndIf
EndIf   
If !Empty(QE6->QE6_XTRATA)
   oPrint:Say(_nLin,0080,'TRATAMENTO E DIPOSIÇÃO :',				oFont11T)	
   oPrint:Say(_nLin,0600,Left(QE6->QE6_XTRATA,100),				oFont11F)	
   If !Empty(Substr(QE6->QE6_XTRATA,101))
      _nLin+=_nSpace30
      oPrint:Say(_nLin,0600,Substr(QE6->QE6_XTRATA,101),		oFont11F)	
      _nLin+=_nSpace30                                                        
   Else               
      _nLin+=_nSpace30                                                        
   EndIf
EndIf   

_nLin+=_nSpace10                                                         
oPrint:FillRect({_nLin, 0020, _nLin+050, 0800}, oHGRAY)         
oPrint:Say(_nLin+30,320,'Características',					oFont11T)	
oPrint:FillRect({_nLin, 0820, _nLin+050, 1620}, oHGRAY)         
oPrint:Say(_nLin+30,1080,'Especificação',					oFont11T)	
oPrint:FillRect({_nLin, 1640, _nLin+050, 2020}, oHGRAY)         
oPrint:Say(_nLin+30,1750,'Resultado',					oFont11T)	
oPrint:FillRect({_nLin, 2040, _nLin+050, 2420}, oHGRAY)         
oPrint:Say(_nLin+30,2180,'Método',					oFont11T)	
_nLin +=_nSpace50                                                         
_nLin +=_nSpace50                                                         

Return

*-----------------------------*
Static Function xNewPage(_nLin,_cQEKLote,_cQEKPrd)
*-----------------------------*
IF _nLin >= 2400
	xRodape()
	oPrint:EndPage()
	oPrint:StartPage()
	xImpCabec(_cQEKLote,_cQEKPrd)
EndIF

Return

*----------------------*
Static Function xRodape
*----------------------*
Private _cRaiz    := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) 
Private _cAssina  := _cRaiz+"AssinaturaBruna.BMP"
//oPrint:SayBitmap(2500,200,_cAssina ,500,450) 
//_nLin := 3000

_nLin := 2780
oPrint:SayBitmap(_nLin,200,_cAssina ,500,450) 
_nLin += 200

_aEmp := xEmpFil('01')
oPrint:Say(_nLin,0800,OemToAnsi(AllTrim(_aEmp[1])) 		,oFont14T)
_nLin+=_NSpace30+_NSpace30+_NSpace10
oPrint:Say(_nLin,0800,OemToAnsi( AllTrim(_aEmp[2])+' - '+AllTrim(_aEmp[3])+' - '+AllTrim(_aEmp[4])+' - '+AllTrim(_aEmp[5])  ) 		,oFont13F)
_nLin+=_NSpace30+_NSpace30
oPrint:Say(_nLin,0800,OemToAnsi( 'Fone: '+AllTrim(_aEmp[7])+' - CNPJ: '+AllTrim(_aEmp[9])+' - I.E: '+AllTrim(_aEmp[8])  ) 	,oFont13F)
_nLin+=_NSpace30+_NSpace30               

If cEmpAnt == '01'
   oPrint:Say(_nLin,0800,OemToAnsi('www.pic-web.com.br - pic@pic-web.com.br')											 		,oFont13F)
Else
   oPrint:Say(_nLin,0800,OemToAnsi('www.pharmaspecial.com.br - pharmaspecial@pharmaspecial.com.br')											 		,oFont13F)
EndIf
_nLin+=(500-_nLin)

Return
