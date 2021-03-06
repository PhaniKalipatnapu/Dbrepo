/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S10](
@An_Case_IDNO		 NUMERIC(6),
@Ac_Role_ID			 CHAR(5) OUTPUT
)

AS

/*
 *     PROCEDURE NAME    : CASE_RETRIEVE_S10
 *     DESCRIPTION       : Determines primary Role ID for the given Case ID.
 *     DEVELOPED BY      : IMP TEAM 
 *     DEVELOPED ON      : 09-JAN-2014
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 
BEGIN
	DECLARE	@Ln_County99_IDNO						NUMERIC(3)	= 99,					
			@Lc_TypeCaseNonIvd_CODE					CHAR(1)		= 'H',
			@Lc_RespondInitInitiatingInternal_CODE	CHAR(1)		= 'C',
			@Lc_RespondInitInitiatingState_CODE		CHAR(1)		= 'I',
			@Lc_RespondInitInitiatingTribal_CODE	CHAR(1)		= 'T',
			@Lc_RoleRc005_ID						CHAR(5)		= 'RC005',
			@Lc_RoleRs016_ID						CHAR(5)		= 'RS016',
			@Lc_RoleRe001_ID						CHAR(5)		= 'RE001',
			@Lc_RoleRs002_ID						CHAR(5)		= 'RS002',
			@Lc_RoleRt001_ID						CHAR(5)		= 'RT001';
	DECLARE	@Ld_Current_DATE						DATE		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
     
    SELECT @Ac_Role_ID = CASE 
							WHEN c.County_IDNO = @Ln_County99_IDNO
								THEN @Lc_RoleRs002_ID
							WHEN c.TypeCase_CODE = @Lc_TypeCaseNonIvd_CODE
								THEN @Lc_RoleRc005_ID
							WHEN c.RespondInit_CODE IN (@Lc_RespondInitInitiatingInternal_CODE, @Lc_RespondInitInitiatingState_CODE, @Lc_RespondInitInitiatingTribal_CODE) 
								THEN @Lc_RoleRs016_ID
							-- 13687 - SORD - DECSS Application - Screens' production defect - case assigned to RT001 instead of RE001 - START
							WHEN EXISTS (SELECT 1 
										   FROM SORD_Y1 s 
										  WHERE s.Case_IDNO = c.Case_IDNO
											AND s.OrderEnd_DATE > @Ld_Current_DATE )  
								THEN @Lc_RoleRe001_ID
							-- 13687 - SORD - DECSS Application - Screens' production defect - case assigned to RT001 instead of RE001 - END
							ELSE @Lc_RoleRt001_ID
						  END
      FROM CASE_Y1 c
     WHERE c.Case_IDNO = @An_Case_IDNO;
                  
END


GO
