//���������������������������������������������������������������������������
//���Programa  � MT120COR  � Autor � Meliora/Gustavo    � Data �  17/06/15 ��
//������������������������������������������������������������������������ͱ�
//���Descricao � PE Final gravacao Pedido de Compras...                    ��
//���          �                                                           ��
//������������������������������������������������������������������������ͱ�
//���Uso       � Pic Quimica                                               ��
//���������������������������������������������������������������������������

User Function MT120FIM()

Local aAreaC7 := SC7->(GetArea())
Local cBLq    := ALLTRIM(SC7->C7_CONAPRO) //aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CONAPRO"})
Local nOpcao  := PARAMIXB[1]   // Op��o Escolhida pelo usuario 
Local cNumPC  := PARAMIXB[2]   // Numero do Pedido de Compras


If nOpcao == 3 .OR. nOpcao == 4
 If cBLq == "B"
    u_xEmailalcada(cNumPC)
    aviso("BLOQUEIO DE AL�ADA","O pedido foi bloqueado por al�ada, um e-mail foi enviado ao Gestor e est� aguradando libera��o do pedido.", {"OK"},1,"Bloqueio de pedido.")
 EndIf
EndIf

 RestArea(aAreaC7)
Return     

