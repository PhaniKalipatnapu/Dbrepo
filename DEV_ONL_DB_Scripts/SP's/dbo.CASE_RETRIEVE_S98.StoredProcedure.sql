/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S98]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S98] (
     @An_Case_IDNO	NUMERIC(6,0)
     )
AS

/*
 *     PROCEDURE NAME    : CASE_RETRIEVE_S98
 *     DESCRIPTION       : Retrieves Active Members for the given Case_ID.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
BEGIN

	DECLARE @Ld_SystemDatetime_DTTM			DATETIME2	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			@Lc_StatusCaseMemberActive_CODE	CHAR(1) 	= 'A',
			@Lc_StatusCaseOpen_CODE			CHAR(1) 	= 'O',
			@Li_One_NUMB					SMALLINT 	= 1;

	SELECT C.Case_IDNO,
		   M.MemberMci_IDNO,
		   M.CaseRelationship_CODE,
		   D.Last_NAME,
		   D.Suffix_NAME,
		   D.First_NAME,
		   D.Middle_NAME,
		   A.Line1_ADDR,
		   A.Line2_ADDR,
		   A.City_ADDR,
		   A.State_ADDR,
		   A.Country_ADDR,
		   A.Zip_ADDR
	  FROM CASE_Y1 C
			JOIN CMEM_Y1 M
				ON C.Case_IDNO = M.Case_IDNO
			JOIN DEMO_Y1 D
				ON M.MemberMci_IDNO = D.MemberMci_IDNO
			OUTER APPLY (SELECT Line1_ADDR,
								Line2_ADDR,
								City_ADDR,
								State_ADDR,
								Country_ADDR,
								Zip_ADDR
						 FROM dbo.BATCH_COMMON$SF_GET_MEMBER_ADDRESS(M.MemberMci_IDNO,@Ld_SystemDatetime_DTTM)
						 WHERE Ind_ADDR = @Li_One_NUMB) A
	WHERE C.Case_IDNO = @An_Case_IDNO
	AND M.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
	AND C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;

END; --END OF CASE_RETRIEVE_S98


GO
