/****** Object:  StoredProcedure [dbo].[POBL_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[POBL_RETRIEVE_S8]
(
	@An_Record_NUMB		NUMERIC(19,0),
	@Ac_TypeDebt_CODE	CHAR(2),			
	@Ac_PayBack_INDC	CHAR(1) = NULL,
	@Ac_Exists_INDC		CHAR(1) OUTPUT       
)
AS

/*
 *     PROCEDURE NAME    : POBL_RETRIEVE_S8
 *     DESCRIPTION       : The procedure checks for pending Obligation records in POBL_Y1.  
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 13-MAR-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

BEGIN
	SET @Ac_Exists_INDC   =  'N';

	DECLARE @Lc_ProcessL_CODE	CHAR(1)	  = 'L';
	
	SELECT @Ac_Exists_INDC = 'Y'  
	   FROM POBL_Y1 P
      WHERE P.Record_NUMB = @An_Record_NUMB
		AND P.TypeDebt_CODE = @Ac_TypeDebt_CODE		
		AND P.PayBack_INDC = ISNULL(@Ac_PayBack_INDC,P.PayBack_INDC)
		AND P.Process_CODE = @Lc_ProcessL_CODE;
END

GO
