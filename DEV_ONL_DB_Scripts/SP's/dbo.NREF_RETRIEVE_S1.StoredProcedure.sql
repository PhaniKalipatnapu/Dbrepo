/****** Object:  StoredProcedure [dbo].[NREF_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREF_RETRIEVE_S1] (
 @Ac_Notice_ID              CHAR(8),
 @Ac_CategoryForm_CODE      CHAR(3) OUTPUT,
 @Ac_BatchOnline_CODE       CHAR(1) OUTPUT,
 @As_DescriptionNotice_TEXT VARCHAR(100) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NREF_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve the Description, Category, and whether Notice will be the printer Online or Batch for a Notice.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_CategoryForm_CODE = NULL,
         @As_DescriptionNotice_TEXT = NULL,
         @Ac_BatchOnline_CODE = NULL;

  SELECT @Ac_CategoryForm_CODE = N.CategoryForm_CODE,
         @Ac_BatchOnline_CODE = N.BatchOnline_CODE,
         @As_DescriptionNotice_TEXT = N.DescriptionNotice_TEXT
    FROM NREF_Y1 N
   WHERE N.Notice_ID = @Ac_Notice_ID
     AND N.EndValidity_DATE = @Ld_High_DATE;
 END; --End of NREF_RETRIEVE_S1


GO
