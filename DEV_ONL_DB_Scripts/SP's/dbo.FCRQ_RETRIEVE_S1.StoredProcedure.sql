/****** Object:  StoredProcedure [dbo].[FCRQ_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FCRQ_RETRIEVE_S1] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_RowFrom_NUMB   INT=1,
 @Ai_RowTo_NUMB     INT=10
 )
AS
 /*
 *     PROCEDURE NAME     : FCRQ_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Quarterly wage details for a Member Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT Y.Fein_IDNO,
         Y.QtrReporting_CODE,
         Y.StateReporting_CODE,
         Y.TypeAddress_CODE,
         Y.Wage_AMNT,
         Y.SsnMatch_CODE,
         Y.AgencyReporting_NAME,
         Y.DodStatus_CODE,
         Y.Sein_IDNO,
         Y.TypeParticipant_CODE,
         RowCount_NUMB
    FROM (SELECT X.StateReporting_CODE,
                 X.TypeAddress_CODE,
                 X.Wage_AMNT,
                 X.Fein_IDNO,
                 X.SsnMatch_CODE,
                 X.QtrReporting_CODE,
                 X.AgencyReporting_NAME,
                 X.DodStatus_CODE,
                 X.Sein_IDNO,
                 X.TypeParticipant_CODE,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM AS row_num
            FROM (SELECT fc.StateReporting_CODE,
                         fc.TypeAddress_CODE,
                         fc.Wage_AMNT,
                         fc.Fein_IDNO,
                         fc.SsnMatch_CODE,
                         fc.QtrReporting_CODE,
                         fc.AgencyReporting_NAME,
                         fc.DodStatus_CODE,
                         fc.Sein_IDNO,
                         fc.TypeParticipant_CODE,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY fc.StateReporting_CODE, fc.TypeAddress_CODE) AS ORD_ROWNUM
                    FROM FCRQ_Y1 fc
                   WHERE fc.MemberMci_IDNO = @An_MemberMci_IDNO) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.row_num >= @Ai_RowFrom_NUMB
   ORDER BY ROW_NUM;
 END; --End of FCRQ_RETRIEVE_S1


GO
