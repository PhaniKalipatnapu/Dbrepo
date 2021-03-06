/****** Object:  StoredProcedure [dbo].[CHLD_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CHLD_RETRIEVE_S3] (
 @Ac_CheckRecipient_ID CHAR(10),
 @An_Case_IDNO         NUMERIC(6, 0),
 @Ad_Effective_DATE    DATE,
 @Ad_Expiration_DATE   DATE,
 @Ai_Count_QNTY        INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : CHLD_RETRIEVE_S3  
  *     DESCRIPTION       : Retrieves the record count for a check recipient id, case idno having end validity date as high date.  
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 23-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Li_Zero_NUMB SMALLINT = 0;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CHLD_Y1 a
   WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND (a.Case_IDNO = ISNULL(@An_Case_IDNO, @Li_Zero_NUMB))
     AND ((@Ad_Effective_DATE < a.Effective_DATE)
           OR (@Ad_Expiration_DATE BETWEEN a.Effective_DATE AND a.Expiration_DATE)
           OR (a.Effective_DATE > @Ad_Effective_DATE)
           OR (a.Expiration_DATE > @Ad_Effective_DATE
               AND a.Expiration_DATE < @Ad_Expiration_DATE))
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of CHLD_RETRIEVE_S3  

GO
