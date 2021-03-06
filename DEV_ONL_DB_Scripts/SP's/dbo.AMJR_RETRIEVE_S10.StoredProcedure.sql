/****** Object:  StoredProcedure [dbo].[AMJR_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMJR_RETRIEVE_S10] (
 @Ac_Category_CODE					CHAR(2),
 @Ac_SubCategory_CODE				CHAR(4),
 @As_DescriptionActivity_TEXT       VARCHAR(75) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AMJR_RETRIEVE_S10
  *     DESCRIPTION       : This gets Description Activity Text for the given inputs Subsystem Code and Major Activity.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @As_DescriptionActivity_TEXT = A.DescriptionActivity_TEXT
    FROM AMJR_Y1 A
   WHERE A.Subsystem_CODE = ISNULL(@Ac_Category_CODE,A.Subsystem_CODE)
     AND A.ActivityMajor_CODE = @Ac_SubCategory_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END

GO
