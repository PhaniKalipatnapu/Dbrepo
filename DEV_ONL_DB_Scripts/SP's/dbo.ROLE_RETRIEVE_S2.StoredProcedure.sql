/****** Object:  StoredProcedure [dbo].[ROLE_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ROLE_RETRIEVE_S2]
AS
 /*
  *     PROCEDURE NAME    : ROLE_RETRIEVE_S2
  *     DESCRIPTION       : It retrieve the Role id & Role Name for all Current Roles.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE        DATE = '12/31/9999',
          @Lc_HyphenWithSpace_TEXT CHAR(3) = ' - ';

  SELECT R.Role_ID   ,
         R.Role_NAME ,
         (RTRIM(R.Role_ID) + @Lc_HyphenWithSpace_TEXT + R.Role_NAME) AS RoleName_TEXT
    FROM ROLE_Y1 R
   WHERE R.EndValidity_DATE = @Ld_High_DATE
   ORDER BY Role_NAME;
 END


GO
