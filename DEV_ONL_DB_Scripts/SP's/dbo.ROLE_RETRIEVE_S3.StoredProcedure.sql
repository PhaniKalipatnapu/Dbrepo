/****** Object:  StoredProcedure [dbo].[ROLE_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ROLE_RETRIEVE_S3](
 @Ac_Role_ID   CHAR(10),
 @As_Role_NAME VARCHAR(50) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : ROLE_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve the Row Count for a Role Id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/12/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_Role_NAME = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @As_Role_NAME = R.Role_NAME
    FROM ROLE_Y1 R
   WHERE R.Role_ID = @Ac_Role_ID
     AND R.EndValidity_DATE = @Ld_High_DATE;
 END


GO
