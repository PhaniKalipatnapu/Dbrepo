/****** Object:  StoredProcedure [dbo].[AMNR_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMNR_RETRIEVE_S17] 
 

AS
 /*
  *     PROCEDURE NAME    : AMNR_RETRIEVE_S17
  *     DESCRIPTION       : Retrieve the Minor Activity Code and Description where Activity Type is not Empty or Minor Activity Code is not equal to Unscheduled Proceeding.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-AUG-2011 
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Space_TEXT              CHAR(1) = ' ',
          @Ld_High_DATE               DATE = '12/31/9999';

  SELECT A.ActivityMinor_CODE,
         A.DescriptionActivity_TEXT
    FROM AMNR_Y1 A
   WHERE A.TypeActivity_CODE != @Lc_Space_TEXT
     AND A.EndValidity_DATE = @Ld_High_DATE
   ORDER BY A.DescriptionActivity_TEXT;
 END; --END OF AMNR_RETRIEVE_S17 


GO
