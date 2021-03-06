/****** Object:  StoredProcedure [dbo].[OFIC_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OFIC_RETRIEVE_S16]
 @An_Office_IDNO NUMERIC(3),
 @Ai_Count_QNTY  INT OUTPUT
AS
 /*
  *     PROCEDURE NAME    : OFIC_RETRIEVE_S16
  *     DESCRIPTION       : Retrieve the Row Count for an Office and County.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 DECLARE @Li_CentralCounty_IDNO INT = 99,
         @Ld_High_DATE         DATE = '12/31/9999';

 BEGIN
  SET @Ai_Count_QNTY = 0;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM OFIC_Y1 O
   WHERE O.Office_IDNO = @An_Office_IDNO
     AND O.County_IDNO = @Li_CentralCounty_IDNO
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END

GO
