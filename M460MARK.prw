#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "topconn.ch"
#DEFINE ENTER CHR(13) + CHR(10)

User Function M460MARK()

Local aAreaSC9 := SC9->(GetArea())
Local lRet

 iF SC9->C9_DATENT > dDataBase
  lRet := ApMsgYesNo('Pedido Fora da data de Faturmento - Continua ?')
 EndIf

RestArea(aAreaSC9)

Return lRet
