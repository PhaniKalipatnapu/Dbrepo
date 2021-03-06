/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S10]  
(
     @An_OrderSeq_NUMB       NUMERIC(2,0),
     @An_Case_IDNO		 NUMERIC(6,0),
     @Ai_Count_QNTY      INT    OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S10
 *     DESCRIPTION       : Retrieve the row count for case id with a voluntary order type.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 17-JAN-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Lc_OrderTypeVoluntary_CODE CHAR(1) = 'V', 
         @Ld_High_DATE				 DATE    = '12/31/9999',
         @Ld_Current_DATE			 DATE    = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
        SELECT @Ai_Count_QNTY = 1
          FROM SORD_Y1 S
         WHERE S.Case_IDNO = @An_Case_IDNO  
		   AND S.OrderSeq_NUMB = @An_OrderSeq_NUMB  
		   AND @Ld_Current_DATE BETWEEN S.OrderEffective_DATE AND S.OrderEnd_DATE  
	   	   AND S.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE  
		   AND S.EndValidity_DATE = @Ld_High_DATE;
                  
END --END of SORD_RETRIEVE_S10


GO
