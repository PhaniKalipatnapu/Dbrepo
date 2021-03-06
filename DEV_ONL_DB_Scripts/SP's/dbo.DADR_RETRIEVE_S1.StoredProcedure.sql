/****** Object:  StoredProcedure [dbo].[DADR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 *     PROCEDURE NAME    : DADR_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves the address details for a check mailed to a recipient
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 1-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
CREATE PROCEDURE [dbo].[DADR_RETRIEVE_S1] (
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ad_Disburse_DATE       DATE,
 @An_DisburseSeq_NUMB    NUMERIC(4, 0),
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ac_Country_ADDR        CHAR(2) OUTPUT,
 @As_Line1_ADDR          VARCHAR(50) OUTPUT,
 @As_Line2_ADDR          VARCHAR(50) OUTPUT,
 @Ac_Attn_ADDR           CHAR(40) OUTPUT,
 @Ac_City_ADDR           CHAR(28) OUTPUT,
 @Ac_State_ADDR          CHAR(2) OUTPUT,
 @Ac_Zip_ADDR            CHAR(15) OUTPUT
 )
AS
 BEGIN
	 SET @Ac_Country_ADDR = NULL;
     SET @As_Line1_ADDR = NULL;
     SET @As_Line2_ADDR = NULL;
     SET @Ac_Attn_ADDR = NULL;
     SET @Ac_City_ADDR = NULL;
     SET @Ac_State_ADDR = NULL;
     SET @Ac_Zip_ADDR = NULL;

  SELECT @Ac_Attn_ADDR = A.Attn_ADDR,
         @As_Line2_ADDR = A.Line2_ADDR,
         @As_Line1_ADDR = A.Line1_ADDR,
         @Ac_City_ADDR = A.City_ADDR,
         @Ac_State_ADDR = A.State_ADDR,
         @Ac_Zip_ADDR = A.Zip_ADDR,
         @Ac_Country_ADDR = A.Country_ADDR
    FROM DADR_Y1 A
   WHERE A.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND A.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND A.Disburse_DATE = @Ad_Disburse_DATE
     AND A.DisburseSeq_NUMB = @An_DisburseSeq_NUMB;
 END


GO
