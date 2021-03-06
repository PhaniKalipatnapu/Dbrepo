/****** Object:  StoredProcedure [dbo].[MSSN_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MSSN_RETRIEVE_S1] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_RowFrom_NUMB   INT = 1,
 @Ai_RowTo_NUMB     INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : MSSN_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Member's SSN details from Member SSN table for Unique Number Assigned by the System to the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE  @Lc_Yes_INDC  CHAR(1) = 'Y',
           @Lc_No_INDC   CHAR(1) = 'N',
		   @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.MemberSsn_NUMB,
         Y.TransactionEventSeq_NUMB,
         Y.Enumeration_CODE,
         Y.TypePrimary_CODE,
         Y.SourceVerify_CODE,
         Y.Status_DATE,
         Y.WorkerUpdate_ID,
         Y.Update_DTTM,
         ISNULL ((SELECT TOP 1 @Lc_Yes_INDC
                    FROM MSSN_Y1 h
                   WHERE h.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND h.MemberSsn_NUMB = Y.MemberSsn_NUMB
                     AND h.EndValidity_DATE != @Ld_High_DATE), @Lc_No_INDC) AS History_INDC,
         Y.RowCount_NUMB
    FROM (SELECT X.MemberSsn_NUMB,
                 X.TypePrimary_CODE,
                 X.Enumeration_CODE,
                 X.SourceVerify_CODE,
                 X.Status_DATE,
                 X.WorkerUpdate_ID,
                 X.Update_DTTM,
                 X.TransactionEventSeq_NUMB,
                 X.RowCount_NUMB,
                 X.Row_NUMB
            FROM (SELECT M.MemberSsn_NUMB,
                         M.TypePrimary_CODE,
                         M.Enumeration_CODE,
                         M.SourceVerify_CODE,
                         M.Status_DATE,
                         M.WorkerUpdate_ID,
                         M.Update_DTTM,
                         M.TransactionEventSeq_NUMB,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY M.TransactionEventSeq_NUMB DESC ) AS Row_NUMB
                    FROM MSSN_Y1 M
                   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND M.EndValidity_DATE = @Ld_High_DATE) AS X
           WHERE X.Row_NUMB <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.Row_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY Y.Row_NUMB;
 END; -- END of MSSN_RETRIEVE_S1


GO
