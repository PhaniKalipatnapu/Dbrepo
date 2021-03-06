/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S11] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*    
  *     PROCEDURE NAME    : SORD_RETRIEVE_S11    
  *     DESCRIPTION       : Retrieve Order sequence,File ID  and Order Effective Date For Case ID and it is Order by Order Effective Date.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 09-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT S.OrderSeq_NUMB,
         S.File_ID,
         S.OrderEffective_DATE
    FROM SORD_Y1 S
   WHERE S.Case_IDNO = @An_Case_IDNO
     AND S.EndValidity_DATE = @Ld_High_DATE
   ORDER BY OrderEffective_DATE DESC;
 END; --END OF SORD_RETRIEVE_S11


GO
