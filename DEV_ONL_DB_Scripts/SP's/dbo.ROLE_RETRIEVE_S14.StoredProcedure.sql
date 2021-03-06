/****** Object:  StoredProcedure [dbo].[ROLE_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 *     PROCEDURE NAME    : ROLE_RETRIEVE_S14
 *     DESCRIPTION       : Max Role ID for Like Role ID
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 10/14/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
CREATE PROCEDURE [dbo].[ROLE_RETRIEVE_S14](
 @Ac_RoleLike_ID CHAR(10),
 @Ac_Role_ID     CHAR(10) OUTPUT
 )
AS
 BEGIN
  SET @Ac_Role_ID = NULL;

  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Lc_Percentage_TEXT CHAR(1) ='%';

  SELECT @Ac_Role_ID = MAX(R.Role_ID)
    FROM ROLE_Y1 R
   WHERE R.EndValidity_DATE = @Ld_High_DATE
     AND R.Role_ID LIKE RTRIM(@Ac_RoleLike_ID) + @Lc_Percentage_TEXT;
 END


GO
