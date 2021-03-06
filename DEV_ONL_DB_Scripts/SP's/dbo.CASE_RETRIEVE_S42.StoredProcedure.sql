/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S42]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S42](
@An_Case_IDNO				NUMERIC(6),
@An_MemberMci_IDNO			NUMERIC(10),
@Ac_TypeDocument_CODE		CHAR(3)
)
AS

/*
*     PROCEDURE NAME    : CASE_RETRIEVE_S42
*     DESCRIPTION       : Retrieves the Role ID or Case Worker ID based on given Type Document Code and Case ID.
*     DEVELOPED BY      : IMP Team                                                                                                                                                                                                             
*     DEVELOPED ON      : 03/22/2012                                                                                                                                                                                                      
*     MODIFIED BY       :                                                                                                                                                                                                                        
*     MODIFIED ON       :                                                                                                                                                                                                                        
*     VERSION NO        : 1 
*/
BEGIN
	DECLARE @Lc_StatusCaseOpen_CODE				CHAR(1)		= 'O',
			@Lc_CaseMemberStatusActive_CODE		CHAR(1)		= 'A',
			@Lc_CategoryEd_CODE					CHAR(2)		= 'ED',
			@Lc_HyphenWithSpace_TEXT			CHAR(3)		= ' - ',
			@Lc_ProcessUdoc_ID					CHAR(4)		= 'UDOC',
			@Lc_TableEdcm_ID					CHAR(4)		= 'EDCM',
			@Lc_TableSubEdcm_ID					CHAR(4)		= 'EDCM',
			@Ld_High_DATE						DATE		= '12/31/9999';
	
	
	WITH  AlertRole AS (SELECT RTRIM(a.Role_ID) + @Lc_HyphenWithSpace_TEXT + l.Role_NAME AS Role_ID
						 FROM ROLE_Y1 l
						 JOIN ACRL_Y1 a
						   ON a.ActivityMinor_CODE = (SELECT r.Type_CODE
													  FROM RESF_Y1 r
													 WHERE r.Process_ID = @Lc_ProcessUdoc_ID
													   AND r.Table_ID = @Lc_TableEdcm_ID
													   AND r.TableSub_ID = @Lc_TableSubEdcm_ID
													   AND r.Reason_CODE = @Ac_TypeDocument_CODE)
						   AND a.EndValidity_DATE = @Ld_High_DATE
						   AND a.Category_CODE = @Lc_CategoryEd_CODE
						   AND a.Role_ID = l.Role_ID
						WHERE l.EndValidity_DATE = @Ld_High_DATE)
	SELECT DISTINCT ISNULL((SELECT Role_ID FROM AlertRole), c.Worker_ID) RoleOrWorker_ID,
		   c.Case_IDNO
	  FROM CASE_Y1 c 
	 WHERE c.Case_IDNO = ISNULL(@An_Case_IDNO, c.Case_IDNO)
	   AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
	   AND EXISTS ( SELECT 1
					  FROM CMEM_Y1 m
					 WHERE m.Case_IDNO = c.Case_IDNO
					   AND m.MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO, m.MemberMci_IDNO)
					   AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE);

END; -- End Of CASE_RETRIEVE_S42

GO
