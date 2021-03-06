/****** Object:  StoredProcedure [dbo].[MSSN_RETRIEVE_S25]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MSSN_RETRIEVE_S25] (
 @An_MemberSsn_NUMB NUMERIC(9, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19,0), 
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : MSSN_RETRIEVE_S25
  *     DESCRIPTION       : Retrieve the record count from Member SSN table for Members SSN and the Verification Code Received for SSN Verification other than CONFIRMED BAD (B).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_EnumerationBad_CODE CHAR(1) = 'B',
          @Ld_High_DATE           DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT (1)
    FROM MSSN_Y1 M
   WHERE M.MemberSsn_NUMB = @An_MemberSsn_NUMB
     AND M.Enumeration_CODE != @Lc_EnumerationBad_CODE
     AND TransactionEventSeq_NUMB != @An_TransactionEventSeq_NUMB
     AND M.EndValidity_DATE = @Ld_High_DATE;
 END; -- END of  MSSN_RETRIEVE_S25


GO
