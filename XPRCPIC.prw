#INCLUDE "topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"
#include 'parmtype.ch'

/*
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
 ******************************FORMAÇÃO DE PREÇO NA PIC************************************************
 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
*/

user function XPRCPIC(cTipo)

  	Local cProd 	:= aScan(aHeader,{|x| Alltrim(x[2]) == "C6_PRODUTO"})
  	Local cTab  	:= ALLTRIM(M->C5_TABELA)
  	Local cCliente	:= ALLTRIM(M->C5_CLIENTE)
  	Local cLojaCli	:= ALLTRIM(M->C5_LOJACLI)
  	Local nImp  	:= 0
  	Local nPrc  	:= 0
  	//Local nMim  	:= 0
  	Local nMax  	:= 0
  	Local lRet  	:= .T. 
  	Local nRet  	:= 0
	
	cQuery := " SELECT	SB1.B1_ORIGEM, "
	cQuery += " 		SB1.B1_PRV1, "  		
	cQuery += " 		SA1.A1_EST, "  		
	cQuery += " 		DA1.DA1_XPRCMI, " 
	cQuery += " 		DA1.DA1_XPRCDJ "  
	cQuery += " FROM	" +RetSqlName("SB1")+ "	SB1 (NOLOCK), "  		
	cQuery += " 		" +RetSqlName("SA1")+ "	SA1 (NOLOCK), "  		
	cQuery += " 		" +RetSqlName("DA1")+ "	DA1 (NOLOCK) "  
	cQuery += " WHERE	SB1.B1_FILIAL			= '" + xFilial ("SB1") + "' "
	cQuery += " AND		SB1.B1_COD				= '" + ALLTRIM(aCols[n,cProd]) + "' " 
	cQuery += " AND		SB1.D_E_L_E_T_			= '' "  
	cQuery += " AND		SA1.A1_FILIAL			= '" + xFilial ("SA1") + "' "
	cQuery += " AND		SA1.A1_COD				= '" + cCliente + "' " 
	cQuery += " AND		SA1.A1_LOJA				= '" + cLojaCli + "' " 
	cQuery += " AND		SA1.D_E_L_E_T_			= '' "  
	cQuery += " AND		DA1.DA1_FILIAL			= '" + xFilial ("DA1") + "' "
	cQuery += " AND		DA1.DA1_CODPRO			= SB1.B1_COD " 
	cQuery += " AND		DA1.DA1_CODTAB			= '" + cTab + "' "
	cQuery += " AND		DA1.D_E_L_E_T_			= '' "
	
    
    If Select("PRC") > 0
        DbSelectArea("PRC")
        PRC->(DbClosearea())        
    EndIf
    
    TcQuery cQuery New Alias "PRC"
    
 
  iF cEmpAnt == '01'  
   iF ALLTRIM(M->C5_TABELA) != ""
  	 iF PRC->DA1_XPRCMI != 0     
    	iF PRC->A1_EST == 'SP'
	      	nImp := 0.744150 //Calculo antigo -->(100-18-7.6-1.65)/100 ----- Calculo novo ->(1-(0,18+((0,0165+0,076)*0,82))) ou (100,00/ 0,744150)
	      	nPrc := (PRC->DA1_XPRCMI / nImp)
	      	nMin := (PRC->DA1_XPRCMI / nImp)
		  	nMax := (PRC->DA1_XPRCDJ / nImp)
		  	
		  	iF cTipo == "C6_PRCVEN" 
     	          nRet := nPrc
                ElseIf cTipo == "DA1_XPRCMI"
                    nRet := nMin
                ElseIf cTipo == "DA1_XPRCDJ"
                    nRet := nMax   
            EndIf
            
		ElseIf PRC->A1_EST $ ('MG,PR,RS,RJ,SC')
	    	iF PRC->B1_ORIGEM $ ('1,2,3,8') 
	         	nImp := 0.871200  //Calculo antigo ->(100-4-7.6-1.65)/100 ----- Calculo novo ->(1-(0,04+((0,0165+0,076)*0,96))) ou (100,00/ 0.871200)
             	nPrc := (PRC->DA1_XPRCMI / nImp)
             	nMin := (PRC->DA1_XPRCMI / nImp)
	         	nMax := (PRC->DA1_XPRCDJ / nImp)
	         	
	         iF cTipo == "C6_PRCVEN" 
     	          nRet := nPrc
                ElseIf cTipo == "DA1_XPRCMI"
                    nRet := nMin
                ElseIf cTipo == "DA1_XPRCDJ"
                    nRet := nMax   
              EndIf
              
	     	Else
	         	nImp := 0.798600 // Calculo antigo ->(100-12-7.6-1.65)/100 ----- Calculo novo ->(1-(0,12+((0,0165+0,076)*0,88))) ou (100,00/ 0.798600)
             	nPrc := (PRC->DA1_XPRCMI / nImp)
             	nMin := (PRC->DA1_XPRCMI / nImp)
	         	nMax := (PRC->DA1_XPRCDJ / nImp)
	         	
	         iF cTipo == "C6_PRCVEN" 
     	          nRet := nPrc
                ElseIf cTipo == "DA1_XPRCMI"
                    nRet := nMin
                ElseIf cTipo == "DA1_XPRCDJ"
                    nRet := nMax   
              EndIf
              
	  		EndIf
	  		
		ElseIf PRC->A1_EST $ ('AL,AC,AM,AP,BA,CE,DF,ES,GO,MA,MT,MS,PA,PB,PE,PI,RN,RO,RR,SE,TO')
	  		iF PRC->B1_ORIGEM $ ('1,2,3,8') 
	     		nImp := 0.871200 //Calculo antigo ->(100-4-7.6-1.65)/100 ----- Calculo novo ->(1-(0,4+((0,0165+0,076)*0,96))) ou (100,00/ 0.871200)
             	nPrc := (PRC->DA1_XPRCMI / nImp)
        	 	nPrc := (PRC->DA1_XPRCMI / nImp)
         		nMin := (PRC->DA1_XPRCMI / nImp)
	     		nMax := (PRC->DA1_XPRCDJ / nImp)
	     		
	     	iF cTipo == "C6_PRCVEN" 
     	          nRet := nPrc
                ElseIf cTipo == "DA1_XPRCMI"
                    nRet := nMin
                ElseIf cTipo == "DA1_XPRCDJ"
                    nRet := nMax   
             EndIf
             
	   	Else
	     		nImp := 0.843975 // Calculo antigo ->(100-7-7.6-1.65)/100 ----- Calculo novo ->(1-(0,07+((0,0165+0,076)*0,93))) ou (100,00/ 0.843975)
         		nPrc := (PRC->DA1_XPRCMI / nImp)
         		nMin := (PRC->DA1_XPRCMI / nImp)
	     		nMax := (PRC->DA1_XPRCDJ / nImp)
	     		
	     	iF cTipo == "C6_PRCVEN" 
     	          nRet := nPrc
                ElseIf cTipo == "DA1_XPRCMI"
                    nRet := nMin
                ElseIf cTipo == "DA1_XPRCDJ"
                    nRet := nMax   
            EndIF            	 	  	   
   	     EndIf			 	  	
	   EndIf
  	 EndIF
  	  iF PRC->DA1_XPRCMI == 0 
  	    MsgAlert('Preço Base no cadastro do produto zerado, impossível formar preço. Verifique!!!')
  	  EndIf 
  EndIf
   iF ALLTRIM(M->C5_TABELA) == ""
     MsgAlert('Campo tabela de preço não foi preenchido no pedido. Verifique!!!')
     lRet := .F.
   EndIf	 
 EndIf
   	      	
Return(nRet)
