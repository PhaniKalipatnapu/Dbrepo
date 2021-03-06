/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S72]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S72] (
 @Ac_Worker_ID      CHAR(30),
 @Ac_Role_ID        CHAR(10),
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_RETRIEVE_S72
  *     DESCRIPTION       : Retrieve Office  work the worker Role
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/19/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();  
  SELECT TOP 1 @Ai_Count_QNTY = COUNT(1)
    FROM USRL_Y1 U
   WHERE U.Role_ID = @Ac_Role_ID
     AND U.Worker_ID = @Ac_Worker_ID
	 AND U.Expire_date >=@Ld_Current_DATE
     AND U.EndValidity_DATE = @Ld_High_DATE;
 END


GO
