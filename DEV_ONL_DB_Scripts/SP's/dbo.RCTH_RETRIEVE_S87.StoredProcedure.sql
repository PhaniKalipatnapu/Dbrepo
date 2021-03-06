/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S87]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S87] (  
			 @Ad_Batch_DATE          DATE,
			 @Ac_SourceBatch_CODE    CHAR(3),
			 @An_Batch_NUMB          NUMERIC(4,0),
			 @An_SeqReceipt_NUMB     NUMERIC(6,0),
			 @Ac_Exists_INDC         CHAR(1)   OUTPUT
			 )
AS
/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S87
 *     DESCRIPTION       : This procedure checks for the existance of recipt or receipt batch record in RCTH_Y1 table.
 *						   Returns 'Y' if found else returns 'N'.	
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
     DECLARE @Li_Thousand_NUMB		 INT  = 1000,
			 @Lc_Yes_INDC			 CHAR(1) = 'Y'; 			 
      
	  SELECT @Ac_Exists_INDC = 'N'; 
  
      SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC
        FROM RCTH_Y1 a
       WHERE a.Batch_DATE		 = @Ad_Batch_DATE  
         AND a.SourceBatch_CODE	 = @Ac_SourceBatch_CODE 
         AND a.Batch_NUMB		 = @An_Batch_NUMB  
         AND CAST( a.SeqReceipt_NUMB/@Li_Thousand_NUMB AS INT) = @An_SeqReceipt_NUMB;
END


GO
