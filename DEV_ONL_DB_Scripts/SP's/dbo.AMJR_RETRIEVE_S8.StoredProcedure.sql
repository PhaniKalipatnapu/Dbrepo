/****** Object:  StoredProcedure [dbo].[AMJR_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMJR_RETRIEVE_S8] (
 @Ac_Category_CODE CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : AMJR_RETRIEVE_S8
  *     DESCRIPTION       : Retrieve the Minor and Major Activity Code and Description for a Subsystem Code.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT
         A.ActivityMajor_CODE,
         A.DescriptionActivity_TEXT
    FROM AMJR_Y1 A
   WHERE A.Subsystem_CODE = @Ac_Category_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE
   ORDER BY A.ActivityMajor_CODE;
 END

GO
