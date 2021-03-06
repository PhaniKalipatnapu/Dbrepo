/****** Object:  StoredProcedure [dbo].[EFTR_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EFTR_RETRIEVE_S3] (
 @Ac_CheckRecipient_ID CHAR(10),
 @Ac_Exists_INDC       CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : EFTR_RETRIEVE_S3
  *     DESCRIPTION       : Retrieves 'YES' when the given checkrecipient ID not have EFT instruction with 'Pre-note pending','Pre-note generated','Active' EFT Status .
  *     DEVELOPED BY      : IMP Team.
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_Exists_INDC = 'N';

  DECLARE @Lc_EftStatusPrenoteP_CODE CHAR(2) ='PP',
          @Lc_EftStatusPrenoteG_CODE CHAR(2) ='PG',
          @Lc_EftStatusActive_CODE   CHAR(2) ='AC',
          @Ld_High_DATE              DATE = '12/31/9999';

  SELECT @Ac_Exists_INDC = 'Y'
    FROM EFTR_Y1 E
   WHERE E.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND E.statuseft_CODE IN (@Lc_EftStatusActive_CODE, @Lc_EftStatusPrenoteP_CODE, @Lc_EftStatusPrenoteG_CODE)
     AND E.EndValidity_DATE = @Ld_High_DATE;
 END; --End of EFTR_RETRIEVE_S3

GO
