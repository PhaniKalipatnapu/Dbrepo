/****** Object:  StoredProcedure [dbo].[RBAT_UPDATE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RBAT_UPDATE_S3] (
 @Ad_Batch_DATE                  DATE,
 @Ac_SourceBatch_CODE            CHAR(3),
 @An_Batch_NUMB                  NUMERIC(4, 0),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*                                                                                                                                                                                                                                                                                                                  
  *     PROCEDURE NAME    : RBAT_UPDATE_S3                                                                                                                                                                                                                                                                            
  *     DESCRIPTION       : Procedure To Update The Receipt Details
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                                                                               
  *     DEVELOPED ON      : 13-OCT-2011                                                                                                                                                                                                                                                                              
  *     MODIFIED BY       :                                                                                                                                                                                                                                                                                          
  *     MODIFIED ON       :                                                                                                                                                                                                                                                                                          
  *     VERSION NO        : 1                                                                                                                                                                                                                                                                                        
 */
 BEGIN
  DECLARE @Ld_High_DATE    DATE ='12/31/9999',
          @Ld_Current_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE RBAT_Y1
     SET EndValidity_DATE = @Ld_Current_DATE,
         EventGlobalEndSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
   WHERE Batch_DATE = @Ad_Batch_DATE
     AND SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND Batch_NUMB = @An_Batch_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB;
 END; --END OF Procedure RBAT_UPDATE_S3

GO
