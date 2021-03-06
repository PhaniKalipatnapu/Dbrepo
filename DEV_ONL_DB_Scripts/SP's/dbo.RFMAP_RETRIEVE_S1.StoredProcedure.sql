/****** Object:  StoredProcedure [dbo].[RFMAP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RFMAP_RETRIEVE_S1] ( 

		 @Ad_Begin_DATE                         DATE ,
		 @Ad_End_DATE                           DATE ,
		 @Ai_RowFrom_NUMB                       INT  = 1 ,
		 @Ai_RowTo_NUMB                         INT  = 10 
		 )          
AS

/*
 *     PROCEDURE NAME    : RFMAP_RETRIEVE_S1
 *     DESCRIPTION       : The procedure selects the Federal Medical Percentage details
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN

         DECLARE @Ld_High_DATE		DATE = '12/31/9999',
				 @Ld_Current_DATE	DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();				
        
		   SELECT y.Begin_DATE, 
				  y.End_DATE, 
				  y.Amount_PCT, 
				  y.TransactionEventSeq_NUMB, 
				  y.RowCount_NUMB 
			 FROM (
					SELECT x.Begin_DATE, 
						   x.End_DATE, 
						   x.Amount_PCT, 
						   x.TransactionEventSeq_NUMB, 
						   x.RowCount_NUMB, 
						   x.Row_NUMB  
					  FROM (
							SELECT a.Begin_DATE, 
								   a.End_DATE, 
								   a.Amount_PCT, 
								   a.TransactionEventSeq_NUMB, 
								   COUNT(1) OVER() AS RowCount_NUMB, 
								   ROW_NUMBER() OVER ( ORDER BY a.Begin_DATE DESC, a.End_DATE DESC
													 ) AS Row_NUMB
							  FROM RFMAP_Y1 a
							 WHERE a.Begin_DATE BETWEEN @Ad_Begin_DATE AND ISNULL(@Ad_End_DATE,@Ld_Current_DATE) 
							   AND a.EndValidity_DATE = @Ld_High_DATE
						    )  x
					 WHERE x.Row_NUMB <= @Ai_RowTo_NUMB
				  ) y
			WHERE y.Row_NUMB >= @Ai_RowFrom_NUMB ;
                
END;  --END OF RFMAP_RETRIEVE_S1


GO
