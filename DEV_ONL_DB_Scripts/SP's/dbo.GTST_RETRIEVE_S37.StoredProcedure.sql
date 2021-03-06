/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S37]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S37]  
(  
     @An_Case_IDNO                            NUMERIC(6,0)  ,  
     @An_Schedule_NUMB                        NUMERIC(10,0) ,  
     @An_TransactionEventSeq_NUMB             NUMERIC(19,0)  
 )  
AS  
  
/*  
*      PROCEDURE NAME    : GTST_RETRIEVE_S37  
 *     DESCRIPTION       : This sp will retrieve list of member Mci id and Schedule number for single schedule test  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 02-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
  
   BEGIN  
  
      DECLARE  
         @Lc_TestReslutConducted_CODE CHAR(1) = 'K',  
         @Lc_TestReslutCancel_CODE    CHAR(1) = 'C',  
         @Lc_TestReslutFailedToAppear_CODE    CHAR(1) = 'F',  
         @Ld_High_DATE     DATE    = '12/31/9999';  
           
     SELECT MemberMci_IDNO,
     		Schedule_NUMB 
     			FROM GTST_Y1 g  
   				WHERE g.Case_IDNO  =@An_Case_IDNO   
   				AND g.schedule_NUMB  = ISNULL(@An_Schedule_NUMB , g.schedule_NUMB )
   				AND g.EndValidity_DATE =@Ld_High_DATE  
   				AND g.TestResult_CODE NOT IN (@Lc_TestReslutConducted_CODE,@Lc_TestReslutCancel_CODE,@Lc_TestReslutFailedToAppear_CODE)  
   				AND g.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB  ;
  
          
END   ----END of GTST_RETRIEVE_S37  
  

GO
