/****** Object:  StoredProcedure [dbo].[RSCL_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RSCL_RETRIEVE_S1]
AS
 /*
  *     PROCEDURE NAME    : RSCL_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve the reason code details. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT R.Screen_ID,
         R.Field_NAME,
         R.DependentValue_TEXT,
         R.Column_NAME,
         R.RefType_ID,
         R.Table_ID,
         R.TableSub_ID
    FROM RSCL_Y1 R
   WHERE R.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of RSCL_RETRIEVE_S1

GO
