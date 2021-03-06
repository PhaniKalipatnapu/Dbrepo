/****** Object:  StoredProcedure [dbo].[AMJR_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMJR_RETRIEVE_S9] (
 @Ac_ActivityMajor_CODE       CHAR(4),
 @As_DescriptionActivity_TEXT VARCHAR(75) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : AMJR_RETRIEVE_S9  
  *     DESCRIPTION       : Retrieve the Description for a Major Activity.  
  *     DEVELOPED BY      : IMP TEAM  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SET @As_DescriptionActivity_TEXT = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT
         @As_DescriptionActivity_TEXT = A.DescriptionActivity_TEXT
    FROM AMJR_Y1 A
   WHERE A.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF AMJR_RETRIEVE_S9       


GO
