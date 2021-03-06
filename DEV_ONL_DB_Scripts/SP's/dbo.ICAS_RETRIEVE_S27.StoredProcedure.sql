/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S27]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S27] (
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ai_Count_QNTY             INT OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : ICAS_RETRIEVE_S27    
  *     DESCRIPTION       : Retrieve the Row Count for a Case Idno.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Lc_StatusOpen_CODE CHAR(1)='O';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM ICAS_Y1 I
   WHERE I.Case_IDNO = @An_Case_IDNO
     AND I.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND I.Status_CODE = @Lc_StatusOpen_CODE
     AND I.EndValidity_DATE = @Ld_High_DATE;
 END; --End of ICAS_RETRIEVE_S27     


GO
