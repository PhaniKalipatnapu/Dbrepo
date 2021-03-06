/****** Object:  StoredProcedure [dbo].[NREF_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREF_RETRIEVE_S13]
AS
 /*  
  *     PROCEDURE NAME    : NREF_RETRIEVE_S13  
  *     DESCRIPTION       : Fetch the Unique id assigned to the notices as Document id and Field stores the description as description document when End Validity date is equal to High date.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 09-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT
         N.Notice_ID,
         N.DescriptionNotice_TEXT
    FROM NREF_Y1 N
   WHERE N.EndValidity_DATE = @Ld_High_DATE
   ORDER BY N.DescriptionNotice_TEXT;
 END; --End of NREF_RETRIEVE_S13

GO
