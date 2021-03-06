/****** Object:  StoredProcedure [dbo].[ROLE_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ROLE_RETRIEVE_S5](
 @As_Role_NAME VARCHAR(50),
 @Ac_Role_ID   CHAR(10) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME     : ROLE_RETRIEVE_S5
  *     DESCRIPTION       : Retrieve the Role ID for the Role Name
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/11/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_Role_ID = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_Role_ID = R.Role_ID
    FROM ROLE_Y1 R
   WHERE R.Role_NAME = @As_Role_NAME
     AND R.EndValidity_DATE = @Ld_High_DATE;
 END


GO
