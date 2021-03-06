/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S11] (
 @Ac_ReasonStatus_CODE CHAR(4),
 @An_MemberMci_IDNO    NUMERIC(10),
 @Ai_Count_QNTY        INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : DHLD_RETRIEVE_S11  
  *     DESCRIPTION       : Retrieves the record count from Disbursement hold details table 
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 29-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CheckRecipientCpNcp_CODE			CHAR(1)	= '1',
          @Lc_CheckRecipientFips_CODE			CHAR(1)	= '2',
          @Lc_CaseRelationshipCp_CODE			CHAR(1)	= 'C',
          @Lc_CaseRelationshipNcp_CODE			CHAR(1)	= 'A',
          @Lc_CaseRelationshipPutFather_CODE	CHAR(1)	= 'P',
          @Lc_StatusHeld_CODE					CHAR(1)	= 'H',
          @Lc_StatusReady_CODE					CHAR(1)	= 'R',
          @Ld_High_DATE							DATE	= '12/31/9999';

  SELECT TOP 1 @Ai_Count_QNTY = COUNT(1)
    FROM DHLD_Y1 a
   WHERE a.Case_IDNO IN (SELECT c.Case_IDNO
                           FROM CMEM_Y1 c
                          WHERE c.MemberMci_IDNO = @An_MemberMci_IDNO
                            AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE))
     AND ISNUMERIC(a.CheckRecipient_ID) = 1
     AND CAST(a.CheckRecipient_ID AS NUMERIC(10)) = @An_MemberMci_IDNO
     AND a.CheckRecipient_CODE  = @Lc_CheckRecipientCpNcp_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND (a.Status_CODE = @Lc_StatusReady_CODE
           OR (a.Status_CODE = @Lc_StatusHeld_CODE
               AND a.ReasonStatus_CODE = @Ac_ReasonStatus_CODE));
 END; --End of DHLD_RETRIEVE_S11

GO
