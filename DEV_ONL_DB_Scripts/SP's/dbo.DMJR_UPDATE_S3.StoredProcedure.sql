/****** Object:  StoredProcedure [dbo].[DMJR_UPDATE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_UPDATE_S3] (
 @An_Case_IDNO        NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB NUMERIC(5, 0),
 @Ac_Reference_ID     CHAR(30)
 )
AS
 /*  
 *     PROCEDURE NAME    : DMJR_UPDATE_S3  
  *     DESCRIPTION       : Update Reference ID for the given inputs Case ID and Major activity sequence number in Case Closure activity chain.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 11-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE DMJR_Y1
     SET Reference_ID = @Ac_Reference_ID
   WHERE Case_IDNO = @An_Case_IDNO
     AND MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End Of DMJR_UPDATE_S3


GO
