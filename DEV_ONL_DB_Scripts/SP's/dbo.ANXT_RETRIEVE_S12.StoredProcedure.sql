/****** Object:  StoredProcedure [dbo].[ANXT_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ANXT_RETRIEVE_S12] (
 @Ac_ActivityMajor_CODE CHAR(4)
 )
AS
 /*  
  *     PROCEDURE NAME    : ANXT_RETRIEVE_S12  
  *     DESCRIPTION       : Retrieve distinct record of Minor Activity code and Minor Activity description for a Major & Minor Activity code and no of activity order is 1.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Li_One_NUMB  SMALLINT = 1,
          @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT m.ActivityMajor_CODE,
         m.ActivityMinor_CODE,
         a.DescriptionActivity_TEXT
    FROM ANXT_Y1 m
         JOIN AMNR_Y1 a
          ON m.ActivityMinor_CODE = a.ActivityMinor_CODE
   WHERE m.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND m.ActivityOrder_QNTY = @Li_One_NUMB
     AND m.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of ANXT_RETRIEVE_S12


GO
