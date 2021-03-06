/****** Object:  StoredProcedure [dbo].[MSSN_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MSSN_RETRIEVE_S2](
 @An_MemberMci_IDNO	NUMERIC(10,0),           
 @An_MemberSsn_NUMB NUMERIC(9,0),               
 @Ai_RowFrom_NUMB   INT =1,           
 @Ai_RowTo_NUMB     INT =10
 )         
AS

/*
 *     PROCEDURE NAME    : MSSN_RETRIEVE_S2
 *     DESCRIPTION       : Retrieve Member's SSN History details for the given MemberMCI,ssn.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN 
      DECLARE @Ld_High_DATE DATE= '12/31/9999';
              
      SELECT Y.MemberSsn_NUMB , 
             Y.TypePrimary_CODE , 
             Y.Enumeration_CODE , 
             Y.SourceVerify_CODE , 
             Y.Status_DATE , 
             Y.WorkerUpdate_ID, 
             Y.Update_DTTM, 
             Y.RowCount_NUMB 
       FROM (SELECT X.MemberSsn_NUMB, 
                    X.TypePrimary_CODE, 
				    X.Enumeration_CODE, 
                    X.SourceVerify_CODE, 
                    X.Status_DATE, 
                    X.WorkerUpdate_ID, 
                    X.Update_DTTM, 
                    X.RowCount_NUMB, 
                    X.Row_NUMB
             FROM(SELECT  M.MemberSsn_NUMB , 
                          M.TypePrimary_CODE , 
                          M.Enumeration_CODE , 
                          M.SourceVerify_CODE , 
                          M.Status_DATE , 
                          M.Update_DTTM , 
                          M.WorkerUpdate_ID, 
                          COUNT(1) OVER() AS RowCount_NUMB, 
                          ROW_NUMBER() OVER(
                               ORDER BY M.TransactionEventSeq_NUMB DESC) AS Row_NUMB
                   FROM MSSN_Y1 M
                  WHERE  M.MemberMci_IDNO = @An_MemberMci_IDNO 
                    AND  M.MemberSsn_NUMB = @An_MemberSsn_NUMB
                    AND  M.EndValidity_DATE != @Ld_High_DATE
                 )AS X
            WHERE X.Row_NUMB <= @Ai_RowTo_NUMB
         )  AS Y
      WHERE Y.Row_NUMB >= @Ai_RowFrom_NUMB
ORDER BY Row_NUMB;
END;--End Of MSSN_RETRIEVE_S2


GO
