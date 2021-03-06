/****** Object:  StoredProcedure [dbo].[AMNR_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMNR_RETRIEVE_S10]
AS
 /*
  *	   PROCEDURE NAME  	 : AMNR_RETRIEVE_S10  
  *     DESCRIPTION       : Gets the activity Minor code and description lists from AMNR table. 
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT A.ActivityMinor_CODE,
         A.TypeActivity_CODE,
         A.DescriptionActivity_TEXT
    FROM AMNR_Y1 A
   WHERE A.EndValidity_DATE = @Ld_High_DATE
   ORDER BY A.DescriptionActivity_TEXT,
			A.ActivityMinor_CODE;
 END; --End of AMNR_RETRIEVE_S10

GO
