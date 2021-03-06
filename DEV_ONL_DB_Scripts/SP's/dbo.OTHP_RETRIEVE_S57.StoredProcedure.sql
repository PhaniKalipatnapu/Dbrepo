/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S57]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S57]
(
 @An_OtherParty_IDNO              NUMERIC(9, 0),
 @Ac_TypeOthp_CODE   		      CHAR(1) 			OUTPUT,
 @As_OtherParty_NAME              VARCHAR(60) 		OUTPUT,
 @Ac_Attn_ADDR                    CHAR(40) 			OUTPUT,
 @As_Line1_ADDR                   VARCHAR(50) 		OUTPUT,
 @As_Line2_ADDR                   VARCHAR(50) 		OUTPUT,
 @Ac_City_ADDR                    CHAR(28) 			OUTPUT,
 @Ac_Zip_ADDR                     CHAR(15) 			OUTPUT, 
 @Ac_State_ADDR                   CHAR(2) 			OUTPUT,
 @Ac_Country_ADDR                 CHAR(2) 			OUTPUT,
 @Ac_DescriptionContactOther_TEXT CHAR(30)          OUTPUT,
 @As_Contact_EML                  VARCHAR(100) 		OUTPUT,
 @An_Phone_NUMB                   NUMERIC(15, 0) 	OUTPUT,
 @An_Fax_NUMB                     NUMERIC(15, 0) 	OUTPUT,
 @An_County_IDNO     		      NUMERIC(3, 0) 	OUTPUT,
 @Ac_Eiwn_INDC       		      CHAR(1) 			OUTPUT,
 @An_BarAtty_NUMB    		      NUMERIC(10,0)		OUTPUT,
 @An_TransactionEventSeq_NUMB     NUMERIC(19, 0) 	OUTPUT
 )                                                                                                                                                                      
AS
 /*                                                                                                                                                                                                                             
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S57                                                                                                                                                                                    
  *     DESCRIPTION       : Retrieve Name, ID, Address details, Phone & Fax Number, Address where the document to be delivered of the Other Party for the given Other Party ID when End Validity Date is equal to High Date.    
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                          
  *     DEVELOPED ON      : 23-SEP-2011                                                                                                                                                                                         
  *     MODIFIED BY       :                                                                                                                                                                                                     
  *     MODIFIED ON       :                                                                                                                                                                                                     
  *     VERSION NO        : 1                                                                                                                                                                                                   
 */
 BEGIN
 SELECT
   @An_TransactionEventSeq_NUMB = NULL,
   @Ac_Attn_ADDR = NULL               ,
   @Ac_City_ADDR = NULL               ,
   @Ac_Country_ADDR = NULL            ,
   @As_Contact_EML = NULL             ,
   @As_Line1_ADDR = NULL              ,
   @As_Line2_ADDR = NULL              ,
   @Ac_State_ADDR = NULL              ,
   @Ac_Zip_ADDR = NULL                ,
   @As_OtherParty_NAME = NULL         ,
   @An_Phone_NUMB = NULL              ,
   @An_Fax_NUMB = NULL                ,
   @An_County_IDNO = NULL			  ,
   @Ac_TypeOthp_CODE = NULL			  ,
   @Ac_Eiwn_INDC = NULL				  ,
   @An_BarAtty_NUMB = NULL			  ,
   @Ac_DescriptionContactOther_TEXT = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT   @As_OtherParty_NAME = O.OtherParty_NAME,
      	       @Ac_TypeOthp_CODE = O.TypeOthp_CODE,
      	       @Ac_Eiwn_INDC = o.Eiwn_INDC,
      	       @Ac_Attn_ADDR = O.Attn_ADDR,
      	       @As_Line1_ADDR = O.Line1_ADDR,
               @As_Line2_ADDR = O.Line2_ADDR,
               @Ac_City_ADDR = O.City_ADDR,
               @Ac_State_ADDR = O.State_ADDR,
               @Ac_Zip_ADDR = O.Zip_ADDR,
               @Ac_Country_ADDR = O.Country_ADDR,
               @Ac_DescriptionContactOther_TEXT = O.DescriptionContactOther_TEXT,
               @An_Phone_NUMB = O.Phone_NUMB,
               @An_Fax_NUMB = O.Fax_NUMB,
               @An_County_IDNO = O.County_IDNO,
               @As_Contact_EML = O.Contact_EML,
               @An_BarAtty_NUMB = O.BarAtty_NUMB,
               @An_TransactionEventSeq_NUMB = O.TransactionEventSeq_NUMB
    FROM OTHP_Y1 O
   WHERE O.OtherParty_IDNO = @An_OtherParty_IDNO
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END;--End of OTHP_RETRIEVE_S57


GO
