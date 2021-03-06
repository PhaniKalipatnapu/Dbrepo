/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S15] (
 @An_CaseWelfare_IDNO      NUMERIC(10),
 @An_WelfareYearMonth_NUMB NUMERIC(6) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S15
  *     DESCRIPTION       : Retrieves the welfare year month for the given welfare case.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_WelfareYearMonth_NUMB = NULL;

  DECLARE @Lc_ConversionUser_TEXT CHAR(30) = 'CONVERSION';

  SELECT @An_WelfareYearMonth_NUMB = MIN(a.WelfareYearMonth_NUMB)
    FROM IVMG_Y1 A,
         GLEV_Y1 G
   WHERE G.EventGlobalSeq_NUMB = A.EventGlobalSeq_NUMB
     AND G.Worker_ID = @Lc_ConversionUser_TEXT
     AND A.CaseWelfare_IDNO = @An_CaseWelfare_IDNO;
 END; -- End of IVMG_RETRIEVE_S15


GO
