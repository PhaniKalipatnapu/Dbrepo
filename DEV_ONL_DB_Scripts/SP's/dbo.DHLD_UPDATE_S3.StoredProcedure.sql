/****** Object:  StoredProcedure [dbo].[DHLD_UPDATE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_UPDATE_S3] (
 @An_MemberMci_IDNO         NUMERIC(10, 0),
 @Ac_ReasonStatus_CODE      CHAR(4),
 @An_EventGlobalEndSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : DHLD_UPDATE_S3  
  *     DESCRIPTION       : Updates the Log disbursement hold details for the give case idno, check recipient code and status code.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 23-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB					NUMERIC(10),
          @Lc_CheckRecipientCpNcp_CODE			CHAR(1)		= '1',
          @Lc_CaseRelationshipCp_CODE			CHAR(1)		= 'C',
          @Lc_CaseRelationshipNcp_CODE			CHAR(1)		= 'A',
          @Lc_CaseRelationshipPutFather_CODE	CHAR(1)		= 'P',
          @Lc_StatusHeld_CODE					CHAR(1)		= 'H',
          @Lc_StatusReady_CODE					CHAR(1)		= 'R',
          @Ld_High_DATE							DATE		= '12/31/9999',
          @Ld_Current_DATE						DATE		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
          

  UPDATE DHLD_Y1
     SET EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB,
         EndValidity_DATE = @Ld_Current_DATE
   WHERE Case_IDNO IN (SELECT a.Case_IDNO
                         FROM CMEM_Y1 a
                        WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                          AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE))
     AND ISNUMERIC(CheckRecipient_ID) = 1
     AND CAST(CheckRecipient_ID AS NUMERIC(10)) = @An_MemberMci_IDNO
     AND CheckRecipient_CODE  = @Lc_CheckRecipientCpNcp_CODE
     AND EndValidity_DATE = @Ld_High_DATE
     AND (Status_CODE = @Lc_StatusReady_CODE
           OR (Status_CODE = @Lc_StatusHeld_CODE
               AND ReasonStatus_CODE = @Ac_ReasonStatus_CODE));

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End of   DHLD_UPDATE_S3

GO
