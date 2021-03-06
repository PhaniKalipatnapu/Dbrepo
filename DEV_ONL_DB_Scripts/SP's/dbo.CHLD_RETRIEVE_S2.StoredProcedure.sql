/****** Object:  StoredProcedure [dbo].[CHLD_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CHLD_RETRIEVE_S2] (
 @Ac_CheckRecipient_ID CHAR(10)
 )
AS
 /*  
  *     PROCEDURE NAME    : CHLD_RETRIEVE_S2  
  *     DESCRIPTION       : Retrieves Cphold details for a check recipient id with the effective date lesser than current_date and expiration date greater than current date.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 21-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ld_High_DATE    DATE = '12/31/9999',
          @Ld_Current_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT X.Case_IDNO,
         X.Expiration_DATE,
         X.ReasonHold_CODE
    FROM (SELECT TOP (100) PERCENT a.CheckRecipient_ID,
                                   a.CheckRecipient_CODE,
                                   a.ReasonHold_CODE,
                                   a.EventGlobalBeginSeq_NUMB,
                                   a.Case_IDNO,
                                   a.Effective_DATE,
                                   a.Expiration_DATE,
                                   a.EventGlobalEndSeq_NUMB,
                                   a.BeginValidity_DATE,
                                   a.EndValidity_DATE,
                                   a.Sequence_NUMB
            FROM CHLD_Y1 a
           WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
             AND a.Effective_DATE <= @Ld_Current_DATE
             AND a.Expiration_DATE > @Ld_Current_DATE
             AND a.EndValidity_DATE = @Ld_High_DATE
           ORDER BY a.Case_IDNO,
                    a.Expiration_DATE DESC) AS X;
 END; --End Of CHLD_RETRIEVE_S2    

GO
