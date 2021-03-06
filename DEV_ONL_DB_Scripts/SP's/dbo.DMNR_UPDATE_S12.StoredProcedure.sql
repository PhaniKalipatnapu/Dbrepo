/****** Object:  StoredProcedure [dbo].[DMNR_UPDATE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_UPDATE_S12] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @An_Topic_IDNO NUMERIC(10, 0)
 )
AS
 /*                                                                                                      
 *     PROCEDURE NAME    : DMNR_UPDATE_S12                                                            
  *     DESCRIPTION       : Update number of times the post has been viewed for a Case ID and Topic ID.  
  *     DEVELOPED BY      : IMP Team                                                                   
  *     DEVELOPED ON      : 09-AUG-2011                                                                  
  *     MODIFIED BY       :                                                                              
  *     MODIFIED ON       :                                                                              
  *     VERSION NO        : 1                                                                            
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE DMNR_Y1
     SET TotalViews_QNTY = TotalViews_QNTY + 1
   WHERE Case_IDNO = @An_Case_IDNO
     AND Topic_IDNO = @An_Topic_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of DMNR_UPDATE_S12   


GO
