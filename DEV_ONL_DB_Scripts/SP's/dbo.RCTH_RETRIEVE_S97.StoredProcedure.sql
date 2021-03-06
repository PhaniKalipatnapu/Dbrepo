/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S97]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE
    [dbo].[RCTH_RETRIEVE_S97]
        (
            @An_Case_IDNO                 NUMERIC(6,0)  ,
            @Ad_ReceiptFrom_DATE          DATE          ,
            @Ad_ReceiptTo_DATE            DATE          ,
            @An_TotDistributeHeld_AMNT    NUMERIC(15,2)   OUTPUT
        )
AS

/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S97
 *     DESCRIPTION       : Retrieves the sum of distribure amount for the given case id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 14-SEP-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
    BEGIN

      SET @An_TotDistributeHeld_AMNT = NULL;

      DECLARE
         @Lc_RelationshipCaseNcp_CODE     CHAR(1) = 'A',
         @Lc_StatusCaseMemberActive_CODE  CHAR(1) = 'A',
         @Lc_StatusReceiptHeld_CODE       CHAR(1) = 'H',
         @Ld_High_DATE                    DATE = '12/31/9999',
         @Ld_Low_DATE                     DATE = '01/01/0001',
         @Li_Zero_NUMB                    SMALLINT;

     SELECT @An_TotDistributeHeld_AMNT = ISNULL(SUM(b.ToDistribute_AMNT), @Li_Zero_NUMB)
       FROM RCTH_Y1  b
      WHERE b.PayorMCI_IDNO IN ( 
                              SELECT a.MemberMci_IDNO 
            					FROM CMEM_Y1  a
            				   WHERE a.Case_IDNO = @An_Case_IDNO 
            					 AND a.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE
            					 AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                             ) 
      AND b.Case_IDNO IN (@Li_Zero_NUMB, @An_Case_IDNO)
      AND b.Receipt_DATE BETWEEN @Ad_ReceiptFrom_DATE AND @Ad_ReceiptTo_DATE 
      AND b.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE 
      AND b.Distribute_DATE = @Ld_Low_DATE 
      AND b.EndValidity_DATE = @Ld_High_DATE;


END; 
GO
