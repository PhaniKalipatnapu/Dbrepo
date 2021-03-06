/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S5]                              
 (                                   
     @An_Case_IDNO         NUMERIC(6)               ,  
     @An_MemberMci_IDNO    NUMERIC(10)              ,                            
     @An_Schedule_NUMB     NUMERIC(10,0)            ,  
     @An_TransactionEventSeq_NUMB  NUMERIC(19,0)  OUTPUT  
  )                                                            
AS                                                             
                                                               
/*  
 *     PROCEDURE NAME    : GTST_RETRIEVE_S5  
 *     DESCRIPTION       : This sp is used to get the count of data present for the particular case id or member id.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 02-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
  
   BEGIN  
   
      DECLARE  
          @Ld_High_DATE DATE = '12/31/9999';
                  
      SELECT @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
      FROM GTST_Y1 a  
      WHERE a.Case_IDNO = @An_Case_IDNO   
        AND a.Schedule_NUMB = @An_Schedule_NUMB   
        AND a.MemberMci_IDNO = @An_MemberMci_IDNO   
        AND a.EndValidity_DATE = @Ld_High_DATE;  
  
END  -- End of GTST_RETRIEVE_S5;  
   
GO
