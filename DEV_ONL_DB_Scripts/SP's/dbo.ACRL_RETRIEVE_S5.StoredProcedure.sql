/****** Object:  StoredProcedure [dbo].[ACRL_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACRL_RETRIEVE_S5] (
 @Ac_Category_CODE		CHAR(2),
 @Ac_SubCategory_CODE	CHAR(4),
 @Ac_ActivityMinor_CODE CHAR(5)
 )
AS
 /*
  *     PROCEDURE NAME    : ACRL_RETRIEVE_S5
  *     DESCRIPTION       : Retrieve Minor Activity Code and Description for Category Code, Sub Category Code, and a common Minor Activity between two tables.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT
         A.ActivityMinor_CODE,
         B.DescriptionActivity_TEXT
    FROM ACRL_Y1 A
         JOIN AMNR_Y1 B
          ON A.ActivityMinor_CODE = B.ActivityMinor_CODE
   WHERE A.Category_CODE = @Ac_Category_CODE
     AND A.SubCategory_CODE = @Ac_SubCategory_CODE
     AND A.ActivityMinor_CODE = ISNULL( @Ac_ActivityMinor_CODE, A.ActivityMinor_CODE)
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND B.EndValidity_DATE = @Ld_High_DATE
   ORDER BY A.ActivityMinor_CODE;
 END -- End of ACRL_RETRIEVE_S5

GO
