/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S90]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S90]
(
	@Ac_Worker_ID	CHAR(30),
	@An_Office_IDNO	INT
)  
AS  
/*  
 *     PROCEDURE NAME    : USRL_RETRIEVE_S90
 *     DESCRIPTION       : Retrieve the Quik roles for the given worker.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 08/07/2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN  
	--13552 - QUIK - CR0399 Add New Quick SSP Role - START
	DECLARE
		@Lc_ProcessQuik_ID		CHAR(4) = 'QUIK',
		@Lc_TypeRole_CODE		CHAR(4) = 'ROLE',
		@Ld_High_DATE			DATE	= '12/31/9999',
		@Ld_System_DATE			DATE	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
	
	SELECT DISTINCT
		U.Role_ID,
		R.Role_NAME
    FROM
		USRL_Y1 U
		JOIN
		ROLE_Y1 R
		ON U.Role_ID = R.Role_ID
	WHERE U.Worker_ID = @Ac_Worker_ID 
		AND U.Office_IDNO = @An_Office_IDNO 
		AND U.EndValidity_DATE = @Ld_High_DATE 
		AND R.EndValidity_DATE = @Ld_High_DATE 
		AND U.Expire_DATE > @Ld_System_DATE 
		AND U.Effective_DATE <= @Ld_System_DATE 
		AND U.Role_ID IN ( SELECT E.Reason_CODE
							FROM RESF_Y1 E
							WHERE E.Process_ID = @Lc_ProcessQuik_ID 
							AND E.Type_Code = @Lc_TypeRole_CODE )
	--13552 - QUIK - CR0399 Add New Quick SSP Role - END
END

GO
