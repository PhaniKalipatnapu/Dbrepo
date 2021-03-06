/****** Object:  StoredProcedure [dbo].[AMNR_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMNR_RETRIEVE_S12] (
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_Category_CODE            CHAR(2),
 @Ac_SubCategory_CODE         CHAR(4),
 @As_DescriptionActivity_TEXT VARCHAR(75) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AMNR_RETRIEVE_S12
  *     DESCRIPTION       : Retrieveing the description of the Minor activity. 
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_DescriptionActivity_TEXT = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @As_DescriptionActivity_TEXT = A.DescriptionActivity_TEXT
    FROM AMNR_Y1 A
   WHERE A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND EXISTS (SELECT 1
                   FROM ACRL_Y1 A
                  WHERE A.Category_CODE = @Ac_Category_CODE
                    AND A.SubCategory_CODE = @Ac_SubCategory_CODE
                    AND A.ActivityMinor_CODE = A.ActivityMinor_CODE
                    AND A.EndValidity_DATE = @Ld_High_DATE)
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF AMNR_RETRIEVE_S12

GO
