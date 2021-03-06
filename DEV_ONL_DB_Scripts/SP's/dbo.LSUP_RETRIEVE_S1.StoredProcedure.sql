/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S1] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve the count of records from Log Support table for the Member in Member Demographics table who is an Active Non-Custodial Parent (A) or Putative Father (P) in Case Members table whose Case does exist in Log Support table with Current Support due greater than 0 for Temporarily Assigned Arrears (TAA) / Permanently Assigned Arrears (PAA) / Conditionally Assigned Arrears (CAA).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
		  @Li_Zero_NUMB                      INT = 0;

  SELECT @Ai_Count_QNTY = COUNT (1)
    FROM (SELECT SUM (L.OweTotTaa_AMNT - L.AppTotTaa_AMNT) AS Taa_AMNT,
                 SUM (L.OweTotPaa_AMNT - L.AppTotPaa_AMNT) AS Paa_AMNT,
                 SUM (L.OweTotCaa_AMNT - L.AppTotCaa_AMNT) AS Caa_AMNT
            FROM DEMO_Y1 D
                 JOIN CMEM_Y1 M
                  ON D.MemberMci_IDNO = M.MemberMci_IDNO
                 JOIN LSUP_Y1 L
                  ON M.Case_IDNO = L.Case_IDNO
           WHERE D.MemberMci_IDNO = @An_MemberMci_IDNO
             AND M.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
             AND M.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
             AND L.SupportYearMonth_NUMB = (SELECT MAX (L1.SupportYearMonth_NUMB)
                                              FROM LSUP_Y1 L1
                                             WHERE L.Case_IDNO = L1 .Case_IDNO
                                               AND L.OrderSeq_NUMB = L1 .OrderSeq_NUMB
                                               AND L.ObligationSeq_NUMB = L1 .ObligationSeq_NUMB)
             AND L.EventGlobalSeq_NUMB = (SELECT MAX (L2.EventGlobalSeq_NUMB)
                                            FROM LSUP_Y1 L2
                                           WHERE L.Case_IDNO = L2.Case_IDNO
                                             AND L.OrderSeq_NUMB = L2.OrderSeq_NUMB
                                             AND L.ObligationSeq_NUMB = L2.ObligationSeq_NUMB
                                             AND L.SupportYearMonth_NUMB = L2.SupportYearMonth_NUMB)) AS X
   WHERE X.Taa_AMNT > @Li_Zero_NUMB
      OR X.Paa_AMNT > @Li_Zero_NUMB
      OR X.Caa_AMNT > @Li_Zero_NUMB;
 END; -- END of LSUP_RETRIEVE_S1


GO
