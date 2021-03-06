/****** Object:  StoredProcedure [dbo].[NRRQ_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NRRQ_RETRIEVE_S9] (
 @An_Barcode_NUMB   NUMERIC(12), 
 @An_Case_IDNO      NUMERIC(6) OUTPUT,
 @An_MemberMci_IDNO	NUMERIC(10) OUTPUT,
 @Ac_Notice_ID      CHAR(8) OUTPUT
 
 )
AS
 /*
  *     PROCEDURE NAME    : NRRQ_RETRIEVE_S9
  *     DESCRIPTION       : Retrieve Notice Reprint Request details for a given Barcode number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-APR-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 DECLARE @Ac_CaseRelationshipNcp_CODE		CHAR(1)	=	'A',
		 @Ac_CaseRelationshipPf_CODE		CHAR(1)	=	'P',
		 @Ac_CaseMemberStatusActive_CODE	CHAR(1)	=	'A',
		 @Ac_RecipientCp_CODE				CHAR(2)	=	'MC',
		 @Ac_RecipientNcp_CODE				CHAR(2)	=	'MN',
		 -- 13534 - EDOC not indexing PMLs with barcodes to correct Members  - Start
		 @Ac_RecipientPm_CODE				CHAR(2)	=	'PM';
		 -- 13534 - EDOC not indexing PMLs with barcodes to correct Members  - End

 SELECT TOP 1 @Ac_Notice_ID = N1.Notice_ID,
			  @An_Case_IDNO = N1.Case_IDNO,
              @An_MemberMci_IDNO = CASE WHEN N1.Recipient_CODE IN ( @Ac_RecipientCp_CODE, @Ac_RecipientNcp_CODE,@Ac_RecipientPm_CODE )
									  THEN CAST(N1.Recipient_ID AS NUMERIC(10))
									  ELSE (SELECT TOP 1 c.MemberMci_IDNO
											 FROM CMEM_Y1 c
											WHERE c.Case_IDNO = N1.Case_IDNO
											  AND c.CaseRelationship_CODE IN (@Ac_CaseRelationshipNcp_CODE, @Ac_CaseRelationshipPf_CODE)
											  AND c.CaseMemberStatus_CODE = @Ac_CaseMemberStatusActive_CODE)
									END 
    FROM NRRQ_Y1 N1         
   WHERE N1.Barcode_NUMB = @An_Barcode_NUMB 
   END; -- END OF NRRQ_RETRIEVE_S9

GO
