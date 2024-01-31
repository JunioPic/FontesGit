#INCLUDE "FWPrintSetup.ch"
#INCLUDE "topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "rwmake.ch"
user function RelComp()

    Local cQuery   := ""
    Local nLin1 := 50
    Local _cPerg := 'XCONVER'


    Private cMensg01 := GETMV("MV_MSCOM01")
    Private cMensg02 := GETMV("MV_MSCOM02")
    private cMensg03 := GETMV("MV_MSCOM03")
    Private cMensg04 := GETMV("MV_MSCOM04")
    Private cMensg05 := GETMV("MV_MSCOM05")
    Private cMensg06 := GETMV("MV_MSCOM06")
    Private cMensg07 := GETMV("MV_MSCOM07")
    Private cMensg08 := GETMV("MV_MSCOM08")
   
    
    Private nTotal   := 0
    Private nIpi     := 0
    Private nTotalF  := 0
    Private nTotaldesp := 0
    Private nTotaldesc := 0
    Private dEmissao := ""
    Private dData    := Dtoc(dDatabase)
    Private hHora    := Time()
    Private cPedCom  := ALLTRIM(SC7->C7_NUM)
    Private nLin := 50
    Private nLinF := 585
    Private nNext := 0
    Private oPrinter
    Private oFont1
    Private oFont2
    Private oHGRAY := TBrush():New( , CLR_HGRAY)
    Private lPreview
    Private cLogo := FisxLogo("1")
   
    
	    /*** FONTES ***/
	Private oFont18T  	:= TFont():New("Courier New",,18,,.T.,,,,,.F.)
	Private oFont16T  	:= TFont():New("Courier New",,16,,.T.,,,,,.F.)
	Private oFont14TC 	:= TFont():New("Courier New",,14,,.T.,,,,,.F.)
	Private oFont14T  	:= TFont():New("Arial"      ,,14,,.T.,,,,,.F.)
	Private oFont18TA 	:= TFont():New("Arial"      ,,18,,.T.,,,,,.F.)
	Private oFont14TI  	:= TFont():New("Arial"      ,,13,,.T.,,,,.T.,.F.)
	Private oFont11F  	:= TFont():New("Arial"      ,,11,,.F.,,,,,.F.)
	Private oFont13T  	:= TFont():New("Arial"      ,,12,,.T.,,,,,.F.)
	Private oFont13F  	:= TFont():New("Arial"      ,,12,,.F.,,,,,.F.)
	Private oFont10FA 	:= TFont():New("Arial"      ,,10,,.F.,,,,,.F.)
	Private oFont10F 	:= TFont():New("Courier New",,10,,.F.,,,,,.F.)
	Private oFont11FA 	:= TFont():New("Arial"      ,,11,,.F.,,,,,.F.)
	
	Private oFont09T  	:= TFont():New("Courier New",,09,,.T.,,,,,.F.)
	Private oFont07F  	:= TFont():New("Courier New",,07,,.F.,,,,,.F.)
	Private oFont09F  	:= TFont():New("Courier New",,09,,.F.,,,,,.F.)
	Private oFont09FA  	:= TFont():New("Arial",,09,,.F.,,,,,.F.)
	
	Private oFont7TA  	:= TFont():New("Courier New",,07,,.T.,,,,,.F.)
	Private oFont12F  	:= TFont():New("Courier New",,12,,.F.,,,,,.F.)
	Private oFont10T  	:= TFont():New("Courier New",,10,,.T.,,,,,.F.)
	Private oFont14N  	:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)
	
	Private oFont10AT  	:= TFont():New("Arial"      ,,10,,.T.,,,,,.F.)
	Private oFont10AF  	:= TFont():New("Arial"      ,,10,,.F.,,,,,.F.)
	
    Private  NSpace10   := 10
    Private  NSpace20   := 20
    Private  NSpace30   := 30
    Private  NSpace40   := 40
    Private  NSpace50   := 50


     AjustaSX1(_cPerg)
	
      IF !Pergunte(_cPerg,.T.)
	       Return
      EndIF 

  If oPrinter == Nil
    lPreview := .T.
    oPrinter := FWMSPrinter():New(cPedCom ,6,.F.,,.T.)
    oPrinter:SetResolution(72) //Tamanho estipulado para a Danfe
    oPrinter:SetLandScape() 
    oPrinter:SetPaperSize(9)
    oPrinter:SetMargin(005,005,005,005)
    oPrinter:cPathPDF :="C:\TEMP\"    
    EndIf
    
    /*
    &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
      --Ajuste na query para tratar itens deletados na tabela de cotação de moedas--
              -- Ajuste realizado no dia 24/01/2024 -- Junior Guerreiro--
    &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
    */
    
     cQuery := " SELECT                                                           " + CRLF
     cQuery += " SC7.C7_ITEM AS ITEM,                                             " + CRLF
     cQuery += " SC7.C7_UM AS UNIDADE,                                            " + CRLF
     cQuery += " SC7.C7_DATPRF,                                                   " + CRLF
     cQuery += " SC7.C7_EMISSAO,                                                  " + CRLF
     cQuery += " SC7.C7_PRODUTO,                                                  " + CRLF
     cQuery += " SC7.C7_DESCRI,                                                   " + CRLF
     cQuery += " SC7.C7_QUANT AS QUANTIDADE,                                      " + CRLF
     cQuery += " (SC7.C7_QUANT - SC7.C7_QUJE) AS SALDO,                           " + CRLF
     cQuery += " SC7.C7_PRECO AS PRECO,                                           " + CRLF
     cQuery += " SC7.C7_TOTAL AS TOTAL,                                           " + CRLF
     cQuery += " SC7.C7_IPI AS IPI,                                               " + CRLF
     cQuery += " SC7.C7_PICM,                                                     " + CRLF
     cQuery += " SC7.C7_VLDESC,                                                   " + CRLF
     cQuery += " SB1.B1_POSIPI,                                                   " + CRLF
     cQuery += " CONCAT(SC7.C7_FORNECE, ' - ', SA2.A2_NOME) AS FORNECEDOR,        " + CRLF
     cQuery += " SA2.A2_END AS ENDERECO,                                          " + CRLF
     cQuery += " SA2.A2_BAIRRO AS BAIRRO,                                         " + CRLF
     cQuery += " SA2.A2_EST AS ESTADO,                                            " + CRLF
     cQuery += " SA2.A2_MUN AS CIDADE,                                            " + CRLF
     cQuery += " SA2.A2_CEP AS CEP,                                               " + CRLF
     cQuery += " SA2.A2_DDD AS DDD,                                               " + CRLF 
     cQuery += " SA2.A2_TEL AS TELEFONE,                                          " + CRLF
     cQuery += " SA2.A2_CGC AS CNPJ,                                              " + CRLF
     cQuery += " SA2.A2_INSCR AS INSCRICAO,                                       " + CRLF
     cQuery += " SA2.A2_CONTATO AS CONTATO,                                       " + CRLF
     cQuery += " CONCAT(RTRIM(SE4.E4_COND), ' DDL ', '/', SE4.E4_DESCRI) AS CONDICAO,   " + CRLF
     cQuery += " SC7.C7_MOEDA AS TPMOEDA,                                        " + CRLF
     cQuery += " SYF.YF_MOEDA AS NMMOEDA,                                        " + CRLF
     cQuery += " SC7.C7_TXMOEDA AS VLMOEDA,                                      " + CRLF
     cQuery += " SA2.A2_EMAIL AS EMAIL,                                          " + CRLF
     cQuery += " SC7.C7_OBS AS OBS,                                              " + CRLF
     cQuery += " SC7.C7_TPFRETE,                                                 " + CRLF 
     cQuery += " SC7.C7_FRETE,                                                   " + CRLF 
     cQuery += " SC7.C7_FRETCON,                                                 " + CRLF 
     cQuery += " SC7.C7_DESPESA,                                                 " + CRLF 
     cQuery += " SM2.M2_MOEDA2 AS DOLAR,                                         " + CRLF 
     cQuery += " SM2.M2_MOEDA3 AS EURO,                                          " + CRLF
     cQuery += " SY1.Y1_NOME,                                                    " + CRLF 
     cQuery += " SY1.Y1_EMAIL,                                                   " + CRLF
     cQuery += " SC7.C7_NUMSC,                                                   " + CRLF  
     cQuery += " SC1.C1_OBS                                                      " + CRLF  
     cQuery += " FROM " +RetSqlName("SC7")+ " SC7(NOLOCK), " + CRLF
     cQuery += "      " +RetSqlName("SA2")+ " SA2(NOLOCK), " + CRLF
     cQuery += "      " +RetSqlName("SE4")+ " SE4(NOLOCK), " + CRLF
     cQuery += "      " +RetSqlName("SYF")+ " SYF(NOLOCK), " + CRLF
     cQuery += "      " +RetSqlName("SB1")+ " SB1(NOLOCK), " + CRLF
     cQuery += "      " +RetSqlName("SY1")+ " SY1(NOLOCK), " + CRLF
     cQuery += "      " +RetSqlName("SC1")+ " SC1(NOLOCK), " + CRLF
     cQuery += "      " +RetSqlName("SM2")+ " SM2(NOLOCK)  " + CRLF
     cQuery += " WHERE SC7.C7_NUM = '" + cPedCom + "'      " + CRLF
     cQuery += " AND SC7.C7_FILIAL = '" + xFilial ("SC7") + "'" + CRLF
     cQuery += " AND SE4.E4_FILIAL = '" + xFilial ("SE4") + "'" + CRLF
     cQuery += " AND SB1.B1_FILIAL = '" + xFilial ("SB1") + "'" + CRLF
     cQuery += " AND SC1.C1_FILIAL = '" + xFilial ("SC1") + "'" + CRLF
     cQuery += " AND SA2.A2_COD = SC7.C7_FORNECE              " + CRLF
     cQuery += " AND SE4.E4_CODIGO = SC7.C7_COND              " + CRLF
     cQuery += " AND SB1.B1_COD = SC7.C7_PRODUTO              " + CRLF
     cQuery += " AND SYF.YF_MOEFAT = SC7.C7_MOEDA             " + CRLF
     cQuery += " AND SY1.Y1_COD = SC7.C7_XCOMPR               " + CRLF
     cQuery += " AND SC1.C1_PRODUTO = SC7.C7_PRODUTO          " + CRLF
     cQuery += " AND SC1.C1_NUM = SC7.C7_NUMSC                " + CRLF
     cQuery += " AND SC1.C1_ITEMPED = SC7.C7_ITEM             " + CRLF          
     cQuery += " AND SM2.M2_DATA = SC7.C7_EMISSAO             " + CRLF
     cQuery += " AND SC7.D_E_L_E_T_ = ' '                     " + CRLF
     cQuery += " AND SA2.D_E_L_E_T_ = ' '                     " + CRLF
     cQuery += " AND SE4.D_E_L_E_T_ = ' '                     " + CRLF
     cQuery += " AND SYF.D_E_L_E_T_ = ' '                     " + CRLF
     cQuery += " AND SM2.D_E_L_E_T_ = ' '                     " + CRLF
     cQuery += " ORDER BY ITEM                                " + CRLF
     
    If Select("QRC") > 0
        Dbselectarea("QRC")
        QRC->(DbClosearea())        
    EndIf
    
    TcQuery cQuery New Alias "QRC"
    
    TCSetField( 'QRC', "C7_DATPRF", "D" )
    TCSetField( 'QRC', "C7_EMISSAO", "D" )

    _nTpmoeda  := QRC->TPMOEDA
    _cNFrete   := ALLTRIM(QRC->C7_TPFRETE)
    _nFretfob  := QRC->C7_FRETCON
    _nFretcif  := QRC->C7_FRETE
    _nFreteout := 0
    _nFrete := 0
    _cConvert := MV_PAR01
    dEmissao := Dtoc(QRC->C7_EMISSAO)
    
     oPrinter:StartPage()
     oPrinter:Box (030, 015, 595, 825)
     xCadEmp(dEmissao)
    
     nLin1 := 50
     nLin2 := 195

    nLin += 10
     oPrinter:Line( nLin, 015, nLin, 825) 
    nLin += 10
    oPrinter:Say(nLin, 330, "DADOS DO FORNECEDOR",                                       oFont14TC)
    nLin += 10                                                                                     
    oPrinter:Say(nLin, 030, "FORNECEDOR: ",                                              oFont10T)
    oPrinter:Say(nLin, 090, +ALLTRIM(QRC->FORNECEDOR),      oFont10F)
    nLin += 10
    oPrinter:Say(nLin, 030, "ENDEREÇO: ",                                                oFont10T)
    oPrinter:Say(nLin, 075, +ALLTRIM(QRC->ENDERECO),                                     oFont10F)
    nLin += 10
    oPrinter:Say(nLin, 030, "BAIRRO: ",                                                  oFont10T)
    oPrinter:Say(nLin, 075, +ALLTRIM(QRC->BAIRRO),                                       oFont10F)
    oPrinter:Say(nLin, 320, "CEP: ",                                                     oFont10T)
    oPrinter:Say(nLin, 340, +ALLTRIM(QRC->CEP),                                          oFont10F)
    oPrinter:Say(nLin, 445, "INSC. EST.: ",                                              oFont10T)
    oPrinter:Say(nLin, 500, +ALLTRIM(TransForm(QRC->INSCRICAO, '@r 999.999.999-99')),    oFont10F)
    nLin += 10
    oPrinter:Say(nLin, 030, "CIDADE: ",                                                  oFont10T)
    oPrinter:Say(nLin, 075, +ALLTRIM(QRC->CIDADE),                                       oFont10F)
    oPrinter:Say(nLin, 320, "UF: ",                                                      oFont10T)
    oPrinter:Say(nLin, 340, +ALLTRIM(QRC->ESTADO),                                       oFont10F) 
    oPrinter:Say(nLin, 445, "CNPJ: ",                                                    oFont10T)
    oPrinter:Say(nLin, 475, +ALLTRIM(TransForm(QRC->CNPJ, '@r 99.999.999/9999-99')),     oFont10F)
    nLin += 10
    oPrinter:Say(nLin, 030, "CONTATO: ",                                                 oFont10T)
    oPrinter:Say(nLin, 075, +ALLTRIM(QRC->CONTATO),                                      oFont10F)
    oPrinter:Say(nLin, 220, "TEL: ",                                                     oFont10T)
    oPrinter:Say(nLin, 240, '('+ALLTRIM(QRC->DDD)+')'+ALLTRIM(TransForm(QRC->TELEFONE, '@r 9999-9999')),  oFont10F)
    oPrinter:Say(nLin, 320, "E-MAIL: ",                                                  oFont10T)
    oPrinter:Say(nLin, 355, +ALLTRIM(QRC->EMAIL),                                        oFont10F)
    
    nLin += 10
     oPrinter:Line( nLin, 015, nLin, 825)
    
    nLin += 10
    oPrinter:Say(nLin, 330, "DADOS INTERNOS",            oFont14TC)
    nLin += 10
    oPrinter:Say(nLin, 030, "COMPRADOR(A):",             oFont10T)
    oPrinter:Say(nLin, 095, +ALLTRIM(QRC->Y1_NOME),      oFont10F)
    oPrinter:Say(nLin, 200, "E-MAIL:",                   oFont10T)
    oPrinter:Say(nLin, 240, +ALLTRIM(QRC->Y1_EMAIL),     oFont10F)
    nLin += 10
    oPrinter:Say(nLin, 030, "TIPO MOEDA:",               oFont10T)
    if _nTpmoeda == 1
      _nVlmoeda := 1.00
      oPrinter:Say(nLin, 090, +CValToChar(_nTpmoeda) + " - " +ALLTRIM(QRC->NMMOEDA) + "/" +CValToChar(_nVlmoeda), oFont10F)
    elseif _nTpmoeda == 2
      _nVlmoeda := QRC->DOLAR
      oPrinter:Say(nLin, 090, +CValToChar(_nTpmoeda) + " - " +ALLTRIM(QRC->NMMOEDA) + "/" +CValToChar(_nVlmoeda), oFont10F)
    else
      _nVlmoeda := QRC->EURO
      oPrinter:Say(nLin, 090, +CValToChar(_nTpmoeda) + " - " +ALLTRIM(QRC->NMMOEDA) + "/" +CValToChar(_nVlmoeda),  oFont10F)    
    endif
    
    oPrinter:Say(nLin, 200, "COND. PGTO:",                           oFont10T)
    oPrinter:Say(nLin, 260, +ALLTRIM(QRC->CONDICAO),                 oFont10F)
    oPrinter:Say(nLin, 450, "TIPO FRETE:",                           oFont10T)
    iF _cNFrete == "C"
      oPrinter:Say(nLin, 510,"CIF",                                  oFont10F)
    ElseIf _cNFrete == "F"
      oPrinter:Say(nLin, 510,"FOB",                                  oFont10F)
    ElseIf _cNFrete == "T"
      oPrinter:Say(nLin, 510,+CValToChar("POR CONTA DE TERCEIROS"),               oFont10F)
    ElseIf _cNFrete == "R"
      oPrinter:Say(nLin, 510,+CValToChar("POR CONTA DO REMETENTE"),               oFont10F)
    ElseIf _cNFrete == "D"
      oPrinter:Say(nLin, 510,+CValToChar("POR CONTA DO DESTINATARIO"),            oFont10F)
    Else
      oPrinter:Say(nLin, 510,+CValToChar("SEM FRETE"),           oFont10F)
    endif
    
    nLin += 10
     oPrinter:Line( nLin, 015, nLin, 825)  
    nLin += 10
    oPrinter:Say(nLin, 350, "ITENS DO PEDIDO",                   oFont14TC)
    
    nLin += 10
    oPrinter:FillRect({nLin,  015, nLin+015, 825}, oHGRAY)
    oPrinter:Line( nLin, 015, nLin, 825)
    oPrinter:Line( nLin+015,015 ,nLin+015, 825)
    oPrinter:Line( nLin,015 ,nLin+015, 015)
    oPrinter:Line( nLin,060 ,nLin+015, 060)
    oPrinter:Line( nLin,100 ,nLin+015, 100)
    oPrinter:Line( nLin,300 ,nLin+015, 300)
    oPrinter:Line( nLin,340 ,nLin+015, 340)
    oPrinter:Line( nLin,400 ,nLin+015, 400)
    oPrinter:Line( nLin,465 ,nLin+015, 465)
    oPrinter:Line( nLin,490 ,nLin+015, 490)
    oPrinter:Line( nLin,560 ,nLin+015, 560)
    oPrinter:Line( nLin,590 ,nLin+015, 590)
    oPrinter:Line( nLin,630 ,nLin+015, 630)
    oPrinter:Line( nLin,680 ,nLin+015, 680)
    oPrinter:Line( nLin,750 ,nLin+015, 750)
    oPrinter:Line(nLin,825 ,nLin+020, 825)
    
    nLin += 10
    oPrinter:Say(nLin, 025, "ITENS",                        oFont10T)
    oPrinter:Say(nLin, 065, "CODIGO",                       oFont10T)
    oPrinter:Say(nLin, 160, "DESCRICAO ITEM",               oFont10T)
    oPrinter:Say(nLin, 305, "N.C.M",                        oFont10T)
    oPrinter:Say(nLin, 345, "QUANTIDADE",                   oFont09T)
    oPrinter:Say(nLin, 405, "SALDO/RECEBER",                oFont09T)
    oPrinter:Say(nLin, 470, "U.M",                          oFont10T)
    oPrinter:Say(nLin, 505, "VLR. UNIT.",                   oFont10T)
    oPrinter:Say(nLin, 565, "%IPI",                         oFont10T)
    oPrinter:Say(nLin, 595, "%ICMS",                        oFont10T)
    oPrinter:Say(nLin, 640, "NUM SC",                       oFont10T)
    oPrinter:Say(nLin, 690, "DT. ENTREGA",                  oFont10T)
    oPrinter:Say(nLin, 780, "TOTAL",                        oFont10T)                                                                                            
    
    nLin += 05
    While !("QRC")->(EOF())

    _cCodigo := ALLTRIM(QRC->C7_PRODUTO)
    _cDescricao := ALLTRIM(QRC->C7_DESCRI)
    _cPreco := QRC->PRECO
    _cTotal := QRC->TOTAL
    _nDespesa  := QRC->C7_DESPESA
    _nDesconto := QRC->C7_VLDESC

    If _cConvert == 1
        _nVlconvert     := _cPreco * _nVlmoeda
        _nTotalconvert  := _cTotal * _nVlmoeda
        _nTdconvert     := _nDespesa * _nVlmoeda
        _nTdesconvert   := _nDesconto * _nVlmoeda
   Else
       _nVlconvert    := _cPreco 
       _nTotalconvert := _cTotal
       _nTdconvert    := _nDespesa
       _nTdesconvert  := _nDesconto
   EndIf
   
    oPrinter:Line( nLin,060 ,nLin+015, 060)
    oPrinter:Line( nLin,100 ,nLin+015, 100)
    oPrinter:Line( nLin,300 ,nLin+015, 300)
    oPrinter:Line( nLin,340 ,nLin+015, 340)
    oPrinter:Line( nLin,400 ,nLin+015, 400)
    oPrinter:Line( nLin,465 ,nLin+015, 465)
    oPrinter:Line( nLin,490 ,nLin+015, 490)
    oPrinter:Line( nLin,560 ,nLin+015, 560)
    oPrinter:Line( nLin,590 ,nLin+015, 590)
    oPrinter:Line( nLin,630 ,nLin+015, 630)
    oPrinter:Line( nLin,680 ,nLin+015, 680)
    oPrinter:Line( nLin,750 ,nLin+015, 750)
    
    nLin += 15
    oPrinter:Line(nLin,015 ,nLin, 825)
    oPrinter:Say( nLin - 4, 030, +ALLTRIM(("QRC")->ITEM),                               oFont07F)
   If cEmpAnt == "01" .OR. cEmpAnt == "02"
    oPrinter:Say( nLin - 4, 065, +ALLTRIM(_cCodigo),                                    oFont07F)
   Else
    oPrinter:Say( nLin - 4, 065, +ALLTRIM(SUBSTR(_cCodigo,10, 15)),                     oFont07F)
   EndIf
    oPrinter:Say( nLin - 4, 105, +ALLTRIM(_cDescricao),                                 oFont07F)
    oPrinter:Say( nLin - 4, 305, +ALLTRIM(QRC->B1_POSIPI),                              oFont07F)
    oPrinter:Say( nLin - 4, 345, +TRANSFORM(("QRC")->QUANTIDADE,'@e 999,999.99'),       oFont07F)
    oPrinter:Say( nLin - 4, 410, +TRANSFORM(("QRC")->SALDO,'@e 999,999.99'),            oFont07F)
    oPrinter:Say( nLin - 4, 475, +ALLTRIM(("QRC")->UNIDADE),                            oFont07F)
    oPrinter:Say( nLin - 4, 490, +CValToChar(TRANSFORM(_nVlconvert, '@E 999,999.999')), oFont07F)
    oPrinter:Say( nLin - 4, 560, +TRANSFORM(("QRC")->IPI,'@E 999.99'),                  oFont07F)
    oPrinter:Say( nLin - 4, 595, +TRANSFORM(QRC->C7_PICM,'@E 999.99'),                  oFont07F)
    oPrinter:Say( nLin - 4, 640, +ALLTRIM(QRC->C7_NUMSC),                               oFont07F)
    oPrinter:Say( nLin - 4, 690, +OemToAnsi(Dtoc(QRC->C7_DATPRF)),                      oFont07F)
    oPrinter:Say( nLin - 4, 760, +CValToChar(TRANSFORM(_nTotalconvert, '@E 999,999.999')), oFont07F)

  If !Empty(QRC->C1_OBS)
    nLin += 15
    oPrinter:Line(nLin,015 ,nLin, 825)
    oPrinter:Say( nLin - 4, 030, + "OBS. ITEM - " +ALLTRIM(QRC->ITEM)+ ":",              oFont07F)
    oPrinter:Say( nLin - 4, 115, +ALLTRIM(QRC->C1_OBS),                                  oFont07F)
  EndIf

     nTotal += _nTotalconvert
     nIpi   += (_nTotalconvert * QRC->IPI)/100
     nTotaldesp += _nTdconvert 
     nTotaldesc += _nTdesconvert

     If nNext = 0
       nNext := nNext + 1 
       oPrinter:Say(040,  700, "PAG:",                          oFont07F)
       oPrinter:Say(040,  715, +TRANSFORM(nNext, '@e 999'),     oFont07F)
    EndIf

    xNewpag()
    QRC->(DbSkip())
  EndDo
    xRodpe( _nFretcif,_nFretfob, _nFreteout) 
   

    oPrinter:EndPage()
	If lPreview
	     oPrinter:Preview()
	EndIf                      

	FreeObj(oPrinter)
	oPrinter := Nil  
	
return

  Static Function xCadEmp(dEmissao)

    Local aSM0Data2 := {}

   aSM0Data2 := FWSM0Util():GetSM0Data()
   _cEmp       := ALLTRIM(aSM0Data2[5][2])
   _cEmpTel    := ALLTRIM(aSM0Data2[6][2])
   _cEmpCnpj   := ALLTRIM(aSM0Data2[10][2])
   _cEmpIE     := ALLTRIM(aSM0Data2[12][2])
   _cEmpEnd    := ALLTRIM(aSM0Data2[14][2])
   _cEmpBairro := ALLTRIM(aSM0Data2[16][2])
   _cEmpCidade := ALLTRIM(aSM0Data2[17][2])
   _cEmpUf     := ALLTRIM(aSM0Data2[18][2])
   _cEmpCep    := ALLTRIM(aSM0Data2[19][2])

    oPrinter:SayBitmap( 040, 040, cLogo , 100, 50)
    oPrinter:Say(nLin,150,ALLTRIM(_cEmp),                                           oFont14TC)
    nLin += 10                                      
    oPrinter:Say(nLin,150,_cEmpEnd+"-"+_cEmpBairro+"-"+_cEmpCidade+"-"+_cEmpUf+"- CEP:"+TRANSFORM(_cEmpCep,"@R 99999-999"),oFont09F)
    oPrinter:Say(nLin,700, "DATA:",                                      oFont07F)
    oPrinter:Say(nLin,730, OemToAnsi(dData),                             oFont07F)
    nLin += 10
    oPrinter:Say(nLin,150,TRANSFORM(_cEmpTel, "@R (99) 9999-9999" )+"- CNPJ:"+TRANSFORM(_cEmpCnpj, "@R 99.999.999/9999-99")+"- I.E:"+TRANSFORM(_cEmpIE, "@R 999.999.999.999" ),  oFont09F)
    oPrinter:Say(nLin,700, "HORA:",                                      oFont07F)
    oPrinter:Say(nLin,730, OemToAnsi(hHora),                             oFont07F)
     nLin += 15
    oPrinter:Say(nLin,150, "PEDIDO DE COMPRAS Nº:" +ALLTRIM(cPedCom), oFont14TC)
    oPrinter:Say(nLin,700, "EMISSÃO: " +OemToAnsi(dEmissao), oFont12F)                   
  Return

Static Function xRodpe( _nFretcif,_nFretfob, _nFreteout)

  Local _nFcif := _nFretcif
  Local _nFfob := _nFretfob
  Local _nFout := _nFreteout
    
    nTotalF += (nTotal + nIpi + _nFcif + _nFfob + nTotaldesp + _nFout - nTotaldesc)
    
    nLin += 15
    oPrinter:Say(nLin, 350, " VALORES TOTAIS",                                  oFont14TC)
    nLin += 15
    oPrinter:Say(nLin, 030, "SUBTOTAL MERCADORIA: ",                            oFont14TC)
    oPrinter:Say(nLin, 200, +TRANSFORM(nTotal,'@E 999,999.99'),                 oFont14TC)
    nLin += 15
    oPrinter:Say(nLin, 030, "TOTAL IPI: ",                                      oFont14TC)
    oPrinter:Say(nLin, 200, +TRANSFORM(nIpi,'@E 999,999.99'),                   oFont14TC)
    nLin += 15
    oPrinter:Say(nLin, 030, "DESP. ADICIONAIS/FRETE: ",                        oFont14TC)
    oPrinter:Say(nLin, 200, +TRANSFORM(nTotaldesp,'@E 999,999.99'),            oFont14TC)
    nLin += 15
    oPrinter:Say(nLin, 030, "TOTAL DESCONTO ",                                  oFont14TC)
    oPrinter:Say(nLin, 200, +TRANSFORM(nTotaldesc,'@E 999,999.99'),             oFont14TC)
    nLin += 15
    oPrinter:Say(nLin, 030, "TOTAL FATURAMENTO.: ",                             oFont14TC)
    oPrinter:Say(nLin, 200, +TRANSFORM(nTotalF,'@E 999,999.99'),                oFont14TC)
     
    nLin += 10
    oPrinter:Line( nLin, 015, nLin, 825)
    nLin += 10 
    oPrinter:Say(nLin, 330, " MENSAGENS E OBSERVAÇÕES",                         oFont14TC)
    nLin += 10
     
      oPrinter:Say(nLin, 030, cMensg01 ,    oFont10T)
      nLin += 10
      oPrinter:Say(nLin, 030, cMensg02,     oFont10T)
      nLin += 10
      oPrinter:Say(nLin, 030, cMensg03,     oFont10T)
      nLin += 10
      oPrinter:Say(nLin, 030, cMensg04,     oFont10T)
      nLin += 10
      oPrinter:Say(nLin, 030, cMensg05,     oFont10T)
      nLin += 10
      oPrinter:Say(nLin, 030, cMensg06,     oFont10T)
      xNewPag()
      nLin += 10
      oPrinter:Say(nLin, 030, cMensg07,     oFont10T)
       nLin += 10
      oPrinter:Say(nLin, 030, cMensg08,     oFont10T)
Return

Static Function xNewPag()

 iF nLin >= nLinF
         oPrinter:EndPage()
         oPrinter:StartPage()
         oPrinter:Box (030, 015, 595, 825)
         nLin := 30 
      nNext += 1 
         oPrinter:Say(020,  735, "PAG:",                          oFont07F)
         oPrinter:Say(020,  750, +TRANSFORM(nNext, '@e 999'),     oFont07F)
                
   EndIf

Return

Static Function AjustaSX1(cPerg)
	
	//Local _sAlias := Alias()
	Local aRegs   := {}
	Local i,j
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	
	cPerg := PADR(cPerg,10)
	
	AADD(aRegs,{cPerg,"01","Converte Moeda ?","Converte Moeda ?","Converte Moeda ?","mv_ch1","C",03,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
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
