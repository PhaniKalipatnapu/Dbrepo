/****** Object:  StoredProcedure [dbo].[ACRL_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACRL_RETRIEVE_S1] (
 @Ac_ActivityMinor_CODE CHAR(5)
 )
AS
 /*
  *     PROCEDURE NAME    : ACRL_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves information such as Role, Category and Sub Category for the given Minor Activity Code.      
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT A.Role_ID,
         R.Role_NAME,
         A.Category_CODE,
         A.SubCategory_CODE,
         A1.DescriptionActivity_TEXT
    FROM ACRL_Y1 A
         JOIN AMJR_Y1 A1
          ON A.Category_CODE = A1.Subsystem_CODE
             AND A.SubCategory_CODE = A1.ActivityMajor_CODE
         JOIN ROLE_Y1 R
          ON A.Role_ID = R.Role_ID
   WHERE A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND R.EndValidity_DATE = @Ld_High_DATE
     AND A1.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of ACRL_RETRIEVE_S1

GO
