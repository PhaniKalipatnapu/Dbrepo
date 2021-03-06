/****** Object:  StoredProcedure [dbo].[CPAF_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPAF_INSERT_S1]  
     @An_Case_IDNO		 NUMERIC(6,0),         
     @An_Assessed_AMNT		 NUMERIC(11,2),
     @An_Paid_AMNT		 NUMERIC(11,2),
     @An_Waived_AMNT		 NUMERIC(11,2),     
     @As_DescriptionReason_TEXT		 VARCHAR(70),
     @Ac_FeeCheckNo_TEXT		 CHAR(20),
     @An_TransactionEventSeq_NUMB		 NUMERIC(19,0)
AS

/*
 *     PROCEDURE NAME    : CPAF_INSERT_S1
 *     DESCRIPTION       : inserting the cp fees details.
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 10-AUG-2011 
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

	DECLARE
          @Ld_High_DATE	            DATE  = '12/31/9999', 
          @Ld_Systemdatetime_DTTM	DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
        
      INSERT CPAF_Y1(
         Case_IDNO, 
         Assessed_AMNT,          
         Paid_AMNT, 
         Waived_AMNT,          
         DescriptionReason_TEXT, 
         FeeCheckNo_TEXT,
         TransactionEventSeq_NUMB,  
         BeginValidity_DATE, 
         EndValidity_DATE
         )
         VALUES (
            @An_Case_IDNO,             
            @An_Assessed_AMNT, 
            @An_Paid_AMNT, 
            @An_Waived_AMNT,             
            @As_DescriptionReason_TEXT,
            @Ac_FeeCheckNo_TEXT,
            @An_TransactionEventSeq_NUMB,  
            @Ld_Systemdatetime_DTTM, 
            @Ld_High_DATE
            );
                  
END;--End Of CPAF_INSERT_S1
  

GO
