/****** Object:  StoredProcedure [dbo].[CSDB_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSDB_RETRIEVE_S1]
 @Ad_Transaction_DATE               DATE,
 @Ac_IVDOutOfStateFips_CODE         CHAR(2),
 @An_TransHeader_IDNO               NUMERIC(12, 0),
 @Ac_TypeCase_CODE                  CHAR(1)       OUTPUT,
 @Ac_StatusCase_CODE		 		CHAR(1)	 	  OUTPUT,  
 @Ac_PaymentLine1_ADDR		 		CHAR(25)	  OUTPUT,  
 @Ac_PaymentLine2_ADDR		 		CHAR(25)	  OUTPUT, 
 @Ac_PaymentCity_ADDR		 		CHAR(18)	  OUTPUT, 
 @Ac_PaymentState_ADDR		 		CHAR(2)	 	  OUTPUT,  
 @Ac_PaymentZip_ADDR                CHAR(15)      OUTPUT,
 @Ac_Last_NAME		 				CHAR(20)	  OUTPUT,
 @Ac_First_NAME		 				CHAR(16)	  OUTPUT,
 @Ac_Middle_NAME		 			CHAR(20)	  OUTPUT,
 @Ac_Suffix_NAME		 			CHAR(4)	 	  OUTPUT,  
 @Ac_ContactLine1_ADDR		 		CHAR(25)	  OUTPUT,  
 @Ac_ContactLine2_ADDR		 		CHAR(25)	  OUTPUT,  
 @Ac_ContactCity_ADDR		 		CHAR(18)	  OUTPUT, 
 @Ac_ContactState_ADDR		 		CHAR(2)	 	  OUTPUT, 
 @Ac_ContactZip_ADDR                CHAR(15)      OUTPUT,
 @An_ContactPhone_NUMB		 		NUMERIC(10,0) OUTPUT,  
 @An_PhoneExtensionCount_NUMB		NUMERIC(6,0)  OUTPUT,  
 @Ac_RespondingFile_ID		 		CHAR(17)	  OUTPUT,
 @An_Fax_NUMB		 				NUMERIC(15,0) OUTPUT,  
 @As_Contact_EML		 			VARCHAR(100)  OUTPUT,  
 @Ac_InitiatingFile_ID		 	   	CHAR(17)	  OUTPUT,  
 @Ac_AcctSendPaymentsBankNo_TEXT    CHAR(20)	  OUTPUT,
 @Ac_SendPaymentsRouting_ID		 	CHAR(10)	  OUTPUT,  
 @Ac_StateWithCej_CODE		 		CHAR(2)	 	  OUTPUT,
 @Ac_PayFipsSt_CODE		 			CHAR(2)	 	  OUTPUT,
 @As_State_NAME                     VARCHAR(60)   OUTPUT,
 @Ac_NondisclosureFinding_INDC      CHAR(1)       OUTPUT
AS
 /*
  *     PROCEDURE NAME    : CSDB_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Case Type and Non Disclosure Finding indicator and Csenet Case Data Block details for a Transaction Header Block, State FIPS for the state and Transaction Date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT  @Ac_TypeCase_CODE = NULL,
          @Ac_StatusCase_CODE = NULL,		 		
          @Ac_PaymentLine1_ADDR = NULL,		 	
          @Ac_PaymentLine2_ADDR = NULL,		 	
          @Ac_PaymentCity_ADDR = NULL,		 	
          @Ac_PaymentState_ADDR = NULL,		 	
          @Ac_PaymentZip_ADDR = NULL,             
          @Ac_Last_NAME = NULL,	 	 			
          @Ac_First_NAME = NULL,		 			
          @Ac_Middle_NAME = NULL,		 			
          @Ac_Suffix_NAME = NULL,		 			
          @Ac_ContactLine1_ADDR = NULL,		 	
          @Ac_ContactLine2_ADDR = NULL,		 	
          @Ac_ContactCity_ADDR = NULL,		 	
          @Ac_ContactState_ADDR = NULL,		 	
          @Ac_ContactZip_ADDR = NULL,             
          @An_ContactPhone_NUMB = NULL,		 	
          @An_PhoneExtensionCount_NUMB = NULL,	
          @Ac_RespondingFile_ID = NULL,		 	
          @An_Fax_NUMB = NULL,		 			
          @As_Contact_EML = NULL,		 			
          @Ac_InitiatingFile_ID = NULL,		 	
          @Ac_AcctSendPaymentsBankNo_TEXT = NULL, 
          @Ac_SendPaymentsRouting_ID = NULL,			
          @Ac_StateWithCej_CODE = NULL,		 	
          @Ac_PayFipsSt_CODE = NULL,
          @As_State_NAME = NULL,
          @Ac_NondisclosureFinding_INDC = NULL;		 		

  SELECT @Ac_TypeCase_CODE = C.TypeCase_CODE,
       @Ac_StatusCase_CODE = C.StatusCase_CODE,		 		        
       @Ac_PaymentLine1_ADDR = C.PaymentLine1_ADDR,		 	       
       @Ac_PaymentLine2_ADDR = C.PaymentLine2_ADDR,		 	       
       @Ac_PaymentCity_ADDR = C.PaymentCity_ADDR,		 	        
       @Ac_PaymentState_ADDR = C.PaymentState_ADDR,		 	       
       @Ac_PaymentZip_ADDR = C.PaymentZip_ADDR,             
       @Ac_Last_NAME = C.Last_NAME,		 			             
       @Ac_First_NAME = C.First_NAME,		 			            
       @Ac_Middle_NAME = C.Middle_NAME,		 			           
       @Ac_Suffix_NAME = C.Suffix_NAME,		 			           
       @Ac_ContactLine1_ADDR = C.ContactLine1_ADDR,		 	       
       @Ac_ContactLine2_ADDR = C.ContactLine2_ADDR,		 	       
       @Ac_ContactCity_ADDR = C.ContactCity_ADDR,		 	        
       @Ac_ContactState_ADDR = C.ContactState_ADDR,		 	       
       @Ac_ContactZip_ADDR = C.ContactZip_ADDR,             
       @An_ContactPhone_NUMB = C.ContactPhone_NUMB,		 	       
       @An_PhoneExtensionCount_NUMB = C.PhoneExtensionCount_NUMB,	   
       @Ac_RespondingFile_ID = C.RespondingFile_ID,		 	       
       @An_Fax_NUMB = C.Fax_NUMB,		 			              
       @As_Contact_EML = C.Contact_EML,		 			           
       @Ac_InitiatingFile_ID = C.InitiatingFile_ID,		 	       
       @Ac_AcctSendPaymentsBankNo_TEXT = C.AcctSendPaymentsBankNo_TEXT, 
       @Ac_SendPaymentsRouting_ID = C.SendPaymentsRouting_ID,		    
       @Ac_StateWithCej_CODE = C.StateWithCej_CODE,		 	       
       @Ac_PayFipsSt_CODE = C.PayFipsSt_CODE,
	   @As_State_NAME    =(SELECT S.State_NAME
							FROM STAT_Y1 S
						   WHERE S.StateFips_CODE = C.PayFipsSt_CODE),		 		         
       @Ac_NondisclosureFinding_INDC = C.NondisclosureFinding_INDC
    FROM CSDB_Y1 C
   WHERE C.TransHeader_IDNO = @An_TransHeader_IDNO
     AND C.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND C.Transaction_DATE = @Ad_Transaction_DATE;

 END;--End of CSDB_RETRIEVE_S1


GO
