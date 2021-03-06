/****** Object:  StoredProcedure [dbo].[ORDB_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ORDB_INSERT_S1]  
	(
     @An_Case_IDNO					NUMERIC(6,0),
     @An_OrderSeq_NUMB				NUMERIC(2,0),
     @Ac_TypeDebt_CODE				CHAR(2),
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0),
     @Ac_Allocated_INDC				CHAR(1),
     @An_Order_AMNT					NUMERIC(11,2)     
	)
AS

/*
 *     PROCEDURE NAME    : ORDB_INSERT_S1
 *     DESCRIPTION       : Insert the record in the ORDB_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
		DECLARE
			@Li_Zero_NUMB			    SMALLINT	  = 0,
			@Ld_Current_DATE			DATE		  = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			@Ld_High_DATE				DATE		  = '12/31/9999';
			
      INSERT ORDB_Y1
				(Case_IDNO, 
				OrderSeq_NUMB, 
				TypeDebt_CODE, 
				Allocated_INDC, 
				Order_AMNT, 
				BeginValidity_DATE, 
				EndValidity_DATE, 
				EventGlobalBeginSeq_NUMB, 
				EventGlobalEndSeq_NUMB
				)
         VALUES (@An_Case_IDNO,					
			 	 @An_OrderSeq_NUMB,				
				 @Ac_TypeDebt_CODE,				
				 @Ac_Allocated_INDC,			
				 @An_Order_AMNT,				
				 @Ld_Current_DATE,				
				 @Ld_High_DATE,					
				 @An_EventGlobalBeginSeq_NUMB,	
				 @Li_Zero_NUMB	    
				);

                  
END;--End of ORDB_INSERT_S1 


GO
