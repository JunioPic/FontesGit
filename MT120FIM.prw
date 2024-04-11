
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±ºPrograma  ³ MT120COR  º Autor ³ Meliora/Gustavo    º Data ³  17/06/15 ±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ±±
//±±ºDescricao ³ PE Final gravacao Pedido de Compras...                    ±±
//±±º          ³                                                           ±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ±±
//±±ºUso       ³ Pic Quimica                                               ±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function MT120FIM()

Local aAreaC7  := SC7->(GetArea())
Local cBLq     := ALLTRIM(SC7->C7_CONAPRO) //aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CONAPRO"})
Local nOpcao   := PARAMIXB[1]   // Opção Escolhida pelo usuario 
Local cNumPC   := PARAMIXB[2]   // Numero do Pedido de Compras
Local nOpcaoA  := PARAMIXB[3] 


If nOpcaoA == 1
 If nOpcao == 3 .OR. nOpcao == 4
  If cBLq == "B"
    u_xEmailalcada(cNumPC)
    aviso("BLOQUEIO DE ALÇADA","O pedido foi bloqueado por alçada, um e-mail foi enviado ao Gestor e está aguradando liberação do pedido.", {"OK"},1,"Bloqueio de pedido.")
  EndIf
 EndIf
EndIf
 RestArea(aAreaC7)
 
Return     

