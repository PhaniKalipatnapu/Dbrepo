/****** Object:  StoredProcedure [dbo].[ACRL_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACRL_RETRIEVE_S6] (
 @Ac_ActivityMinor_CODE		CHAR(5),
 @Ac_Category_CODE			CHAR(2),
 @Ac_SubCategory_CODE		CHAR(4),
 @Ac_ScreenFunction_CODE	CHAR(10) OUTPUT,
 @Ac_TypeOfficeAssign_CODE	CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ACRL_RETRIEVE_S6
  *     DESCRIPTION       : Retrieve the Function AND Type office Assign code for a Minor Activity, Category Code, Sub Category.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_ScreenFunction_CODE = NULL;
  SET @Ac_TypeOfficeAssign_CODE = NULL;

  DECLARE @Ld_High_DATE  DATE = '12/31/9999';

  SELECT TOP 1 @Ac_ScreenFunction_CODE = A.ScreenFunction_CODE,
		@Ac_TypeOfficeAssign_CODE = A.TypeOfficeAssign_CODE
    FROM ACRL_Y1 A
   WHERE A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND A.Category_CODE = @Ac_Category_CODE
     AND A.SubCategory_CODE = @Ac_SubCategory_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END

GO
