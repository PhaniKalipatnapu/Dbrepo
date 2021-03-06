/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S51]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S51] (
 @An_Case_IDNO   NUMERIC(6, 0),
 @Ac_Exists_INDC CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S51
  *     DESCRIPTION       : This procedure returns the count of held recipients from RCTH_Y1
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_Exists_INDC = 'N';

  DECLARE @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_StatusReceiptHeld_CODE         CHAR(1) = 'H',
          @Lc_Yes_INDC                       CHAR(1) = 'Y',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_Low_DATE                       DATE = '01/01/0001';

  SELECT @Ac_Exists_INDC = 'Y'
    FROM RCTH_Y1 a
   WHERE a.PayorMCI_IDNO = (SELECT a.MemberMci_IDNO
                              FROM CMEM_Y1 a
                             WHERE a.Case_IDNO = @An_Case_IDNO
                               AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
                               AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)
     AND a.Distribute_DATE = @Ld_Low_DATE
     AND a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND NOT EXISTS (SELECT 1
                       FROM RCTH_Y1 c
                      WHERE a.Batch_DATE = c.Batch_DATE
                        AND a.Batch_NUMB = c.Batch_NUMB
                        AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                        AND a.SourceBatch_CODE = c.SourceBatch_CODE
                        AND c.BackOut_INDC = @Lc_Yes_INDC
                        AND c.EndValidity_DATE = @Ld_High_DATE);
 END; --END OF RCTH_RETRIEVE_S51

GO
