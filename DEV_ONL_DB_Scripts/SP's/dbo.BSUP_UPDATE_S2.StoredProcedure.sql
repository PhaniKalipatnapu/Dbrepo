/****** Object:  StoredProcedure [dbo].[BSUP_UPDATE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSUP_UPDATE_S2] (    
 @Ad_Begin_DATE					DATE,
 @An_Case_IDNO					NUMERIC(6,0),                                                          
 @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0),
 @An_EventGlobalEndSeq_NUMB		NUMERIC(19,0)  
 )     
AS

/*
 *     PROCEDURE NAME    : BSUP_UPDATE_S1
 *     DESCRIPTION       : Update existing billing suppression end dates by Case ID.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE			DATE = '12/31/9999',
  		  @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
	      @Ln_RowsAffected_NUMB	NUMERIC(10);                                      
	      
  UPDATE BSUP_Y1 
     SET EndValidity_DATE = @Ld_Current_DATE, 
         EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB 
   WHERE Case_IDNO = @An_Case_IDNO 
     AND Begin_DATE = @Ad_Begin_DATE 
     AND EndValidity_DATE = @Ld_High_DATE 
     AND EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB;
   
   SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
   
   SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
   
 END; --END OF BSUP_UPDATE_S1 
 

GO
