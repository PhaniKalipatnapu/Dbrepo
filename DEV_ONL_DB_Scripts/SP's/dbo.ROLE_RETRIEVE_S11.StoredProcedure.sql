/****** Object:  StoredProcedure [dbo].[ROLE_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ROLE_RETRIEVE_S11] (
 @Ac_ActivityMinor_CODE CHAR(5),
 @Ac_Category_CODE      CHAR(2),
 @Ac_SubCategory_CODE   CHAR(4),
 @Ac_Role_ID            CHAR(10),
 @As_Role_NAME          VARCHAR(50) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ROLE_RETRIEVE_S11
  *     DESCRIPTION       : Retrieve the role name for a given Activity minor and the specific category,sub category
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_Role_NAME = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @As_Role_NAME = R.Role_NAME
    FROM ACRL_Y1 A
         JOIN ROLE_Y1 R
          ON A.Role_ID = R.Role_ID
   WHERE A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND A.Category_CODE = @Ac_Category_CODE
     AND A.SubCategory_CODE = @Ac_SubCategory_CODE
     AND R.Role_ID = @Ac_Role_ID
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND R.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF ROLE_RETRIEVE_S11


GO
