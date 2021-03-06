/****** Object:  StoredProcedure [dbo].[CERR_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CERR_RETRIEVE_S5] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : CERR_RETRIEVE_S5    
  *     DESCRIPTION       : Retrieve the Row Count for a Case Idno.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CERR_Y1 CE
   WHERE CE.Case_IDNO = @An_Case_IDNO
     AND CE.ActionTaken_DATE = @Ld_High_DATE;
 END; --End of CERR_RETRIEVE_S5

GO
