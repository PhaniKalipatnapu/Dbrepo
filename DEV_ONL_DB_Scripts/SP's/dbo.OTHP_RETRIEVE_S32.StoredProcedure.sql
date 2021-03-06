/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S32]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S32](  
@An_OtherParty_IDNO                NUMERIC(9,0) ,
@Ac_Table_ID                       CHAR(4)      ,
@Ac_TableSub_ID                    CHAR(4)      ,
@Ai_Count_QNTY                     INT  OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : OTHP_RETRIEVE_S32
 *     DESCRIPTION       : Check whether the record is exist for the given othp id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

	SET @Ai_Count_QNTY = NULL;

	DECLARE
		@Ld_High_DATE   DATE = '12/31/9999';

	SELECT @Ai_Count_QNTY = COUNT(1)
	   FROM OTHP_Y1 O
	WHERE 
		O.OtherParty_IDNO = @An_OtherParty_IDNO 
	AND O.EndValidity_DATE = @Ld_High_DATE 
	AND O.TypeOthp_CODE IN  (SELECT R.Value_CODE
								FROM REFM_Y1 R
							 WHERE R.Table_ID = @Ac_Table_ID 
							   AND R.TableSub_ID = @Ac_TableSub_ID);		

                  
END;--End Of OTHP_RETRIEVE_S32


GO
