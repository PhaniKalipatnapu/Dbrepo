/****** Object:  StoredProcedure [dbo].[SORD_UPDATE_S56]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_UPDATE_S56]   (
	 @An_Case_IDNO				NUMERIC(6,0),
	 @Ac_File_ID				CHAR(10),
     @An_OrderSeq_NUMB			NUMERIC(2,0),
     @An_EventGlobalSeq_NUMB	NUMERIC(19,0)            
     )
AS

/*
 *     PROCEDURE NAME    : SORD_UPDATE_S56
 *     DESCRIPTION       : Modify the Existing Sord details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/29/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */
 BEGIN
      DECLARE @Ld_High_DATE     DATE = '12/31/9999',
              @Ld_Current_DATE  DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
	   UPDATE SORD_Y1
          SET EndValidity_DATE       = @Ld_Current_DATE,
              EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
        WHERE Case_IDNO        = @An_Case_IDNO
          AND File_ID          = ISNULL(@Ac_File_ID, File_ID)
          AND OrderSeq_NUMB    = @An_OrderSeq_NUMB
          AND EndValidity_DATE = @Ld_High_DATE;
   
      DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;

       SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
                  
END--END OF SORD_UPDATE_S56


GO
