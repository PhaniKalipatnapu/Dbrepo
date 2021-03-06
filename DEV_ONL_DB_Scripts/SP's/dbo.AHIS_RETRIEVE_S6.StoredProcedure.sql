/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S6](  
 @An_MemberMci_IDNO           NUMERIC(10, 0),  
 @Ac_TypeAddress_CODE         CHAR(1),  
 @As_Line1_ADDR               VARCHAR(50),  
 @As_Line2_ADDR               VARCHAR(50),  
 @Ac_City_ADDR                CHAR(28),  
 @Ac_State_ADDR               CHAR(2),  
 @Ac_Zip_ADDR                 CHAR(15),  
 @Ac_Country_ADDR             CHAR(2),  
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) = NULL,  
 @Ai_Count_QNTY               INT OUTPUT  
 )  
AS  
 /*  
  *     PROCEDURE NAME    : AHIS_RETRIEVE_S6  
  *     DESCRIPTION       : Get the Similar address count for the address   
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 10/16/2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */  
 BEGIN  
  SET @Ai_Count_QNTY = 0;  
  
  DECLARE @Ld_High_DATE  DATE = '12/31/9999',  
          @Ln_Zero_NUMB  NUMERIC(19, 0) = 0,  
          @Lc_Space_TEXT CHAR(1) = ' ';  
  
  SELECT @Ai_Count_QNTY = COUNT(1)  
    FROM AHIS_Y1 AD  
   WHERE AD.MemberMci_IDNO = @An_MemberMci_IDNO  
     AND AD.TypeAddress_CODE = @Ac_TypeAddress_CODE  
     AND AD.End_DATE = @Ld_High_DATE  
     AND AD.TransactionEventSeq_NUMB != ISNULL( @An_TransactionEventSeq_NUMB,@Ln_Zero_NUMB)  
     AND AD.Line1_ADDR = ISNULL(@As_Line1_ADDR, @Lc_Space_TEXT)  
     AND AD.Line2_ADDR = ISNULL(@As_Line2_ADDR, @Lc_Space_TEXT)  
     AND AD.City_ADDR = ISNULL(@Ac_City_ADDR, @Lc_Space_TEXT)  
     AND AD.State_ADDR = ISNULL(@Ac_State_ADDR, @Lc_Space_TEXT)  
     AND AD.Zip_ADDR = ISNULL(@Ac_Zip_ADDR, @Lc_Space_TEXT)  
     AND AD.Country_ADDR = ISNULL(@Ac_Country_ADDR, @Lc_Space_TEXT);  
 END  

GO
