/****** Object:  StoredProcedure [dbo].[RBAT_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RBAT_RETRIEVE_S14] 
( 

     @Ad_Batch_DATE             DATE,
     @An_Batch_NUMB             NUMERIC(4,0),
     @Ac_SourceBatch_CODE       CHAR(3),
     @Ac_Dml_INDC               CHAR(1)      OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : RBAT_RETRIEVE_S14
 *     DESCRIPTION       : Procedure to check repost Receipt can Add,Update or Delete repost receipt of the batch
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN

      SET @Ac_Dml_INDC = 'Y';

      DECLARE
         @Lc_BatchStatusReconciled_CODE CHAR(1) = 'R', 
         @Lc_No_CODE					CHAR(1) = 'N', 
         @Ld_High_DATE					DATE    = '12/31/9999', 
         @Ld_Current_DATE				DATE    = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

      SELECT @Ac_Dml_INDC       = @Lc_No_CODE
        FROM RBAT_Y1 r
       WHERE r.Batch_DATE       = @Ad_Batch_DATE 
         AND r.Batch_NUMB       = @An_Batch_NUMB 
         AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE 
         AND r.StatusBatch_CODE = @Lc_BatchStatusReconciled_CODE 
         AND r.EndValidity_DATE = @Ld_High_DATE 
         AND r.Batch_DATE       < @Ld_Current_DATE;
         
END; -- End Of Procedure RBAT_RETRIEVE_S14


GO
