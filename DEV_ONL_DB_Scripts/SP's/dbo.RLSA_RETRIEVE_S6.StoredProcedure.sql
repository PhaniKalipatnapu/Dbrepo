/****** Object:  StoredProcedure [dbo].[RLSA_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 *    PROCEDURE NAME    : RLSA_RETRIEVE_S6
 *     DESCRIPTION       : Retireve Count Role Screen Access for the Role_Name
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 10/26/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
CREATE PROCEDURE [dbo].[RLSA_RETRIEVE_S6](
 @As_Role_NAME  VARCHAR(50),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM RLSA_Y1 RL
         JOIN ROLE_Y1 R
          ON RL.RolE_ID = R.Role_ID
   WHERE R.Role_NAME = @As_Role_NAME
     AND RL.EndValidity_DATE = @Ld_High_DATE
     AND R.EndValidity_DATE = @Ld_High_DATE;
 END


GO
