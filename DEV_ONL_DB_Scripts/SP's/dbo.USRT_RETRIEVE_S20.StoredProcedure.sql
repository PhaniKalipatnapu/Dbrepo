/****** Object:  StoredProcedure [dbo].[USRT_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRT_RETRIEVE_S20] (
	@An_Case_IDNO	NUMERIC(6, 0),
	@Ac_Worker_ID	CHAR(30),
	@Ai_Count_QNTY	INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USRT_RETRIEVE_S20
  *     DESCRIPTION       : check whether the entered officiating id is authorised worker for the entered case and also for the case member
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
BEGIN

  DECLARE @Ld_High_DATE	    DATE = '12/31/9999',
          @Lc_Yes_INDC      CHAR(1) = 'Y',
          @Lc_RoleId_TEXT   CHAR(5) = 'RS001',
          @Li_One_NUMB	    SMALLINT = 1,
          @Ld_Current_DATE  DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

	SELECT  @Ai_Count_QNTY = COUNT(@Li_One_NUMB)
	FROM USRT_Y1 t
    WHERE 
    	t.Case_IDNO = @An_Case_IDNO                             
	AND ((   t.HighProfile_INDC = @Lc_Yes_INDC
        AND NOT EXISTS (SELECT 1 
                        FROM USRL_Y1 z
                        WHERE z.Worker_ID = @Ac_Worker_ID
                        AND z.Role_ID = @Lc_RoleId_TEXT
                        AND z.Effective_DATE <= CAST(@Ld_Current_DATE AS DATE)
                        AND z.Expire_DATE > CAST(@Ld_Current_DATE AS DATE)
                        AND z.EndValidity_DATE = @Ld_High_DATE
                        )
        )
        OR (   t.Familial_INDC = @Lc_Yes_INDC 
             AND t.Worker_ID = @Ac_Worker_ID
           )
        )
     AND t.EndValidity_DATE = @Ld_High_DATE;
                
 END; -- END OF USRT_RETRIEVE_S20

GO
