/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S75]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 *     PROCEDURE NAME    : USRL_RETRIEVE_S75
 *     DESCRIPTION       : Retrieve count of worker working under the Supervisor
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 10/20/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */
CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S75] (
 @Ac_Worker_ID        CHAR(30),
 @An_Office_IDNO      NUMERIC(3),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM USRL_Y1 U
   WHERE U.Supervisor_ID = @Ac_Worker_ID
     AND U.Office_IDNO = ISNULL(@An_Office_IDNO,U.Office_IDNO)
     AND @Ld_Current_DATE BETWEEN U.Effective_DATE AND U.Expire_DATE
     AND U.EndValidity_DATE = @Ld_High_DATE;
     
 END;-- End of USRL_RETRIEVE_S75


GO
