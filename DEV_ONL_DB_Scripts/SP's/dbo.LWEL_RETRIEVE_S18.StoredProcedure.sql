/****** Object:  StoredProcedure [dbo].[LWEL_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
                                                                                                                           
CREATE PROCEDURE [dbo].[LWEL_RETRIEVE_S18](
     @An_Case_IDNO		      NUMERIC(6)  ,                                                        
     @An_EventGlobalSeq_NUMB  NUMERIC(19) ,                                                         
     @Ad_Batch_DATE		      DATE        ,                                                       
     @An_Batch_NUMB           NUMERIC(4)  ,
     @Ac_SourceBatch_CODE	  CHAR(3),
     @An_SeqReceipt_NUMB	  NUMERIC(6)  ,                                                     
     @An_AppliedGrant_AMNT    NUMERIC(11,2)   OUTPUT ,                                                   
     @An_ExcessOverGrant_AMNT NUMERIC(11,2)   OUTPUT                                                  
   )
AS                                                                                                                           
/*                                                                                                                           
 *     PROCEDURE NAME   : LWEL_RETRIEVE_S18                                                                                  
 *     DESCRIPTION      : Procedure to retrieves the log grant applied details for the given case and receipt                                                                                                 
 *     DEVELOPED BY     : IMP Team
 *     DEVELOPED ON     : 11/30/2011                                                                                      
 *     MODIFIED BY      :                                                                                                   
 *     MODIFIED ON      :                                                                                                   
 *     VERSION NO       : 1                                                                                                 
*/                                                                                                                           
   BEGIN                                                                                                                     
                                                                                                                             
      SELECT @An_AppliedGrant_AMNT    = NULL,                                                                                             
             @An_ExcessOverGrant_AMNT = NULL ;                                                                                             
                                                                                                                             
      DECLARE                                                                                                                
         @Li_Zero_NUMB  SMALLINT=  0,
         @Lc_Agcaa_CODE CHAR(5) = 'AGCAA',                                                                                
         @Lc_Agpaa_CODE CHAR(5) = 'AGPAA',                                                                                
         @Lc_Agtaa_CODE CHAR(5) = 'AGTAA',                                                                                
         @Lc_Axcaa_CODE CHAR(5) = 'AXCAA',                                                                                
         @Lc_Axpaa_CODE CHAR(5) = 'AXPAA',                                                                                
         @Lc_Axtaa_CODE CHAR(5) = 'AXTAA',                                                                                
         @Lc_Cgpaa_CODE CHAR(5) = 'CGPAA',                                                                                
         @Lc_Pgpaa_CODE CHAR(5) = 'PGPAA';
                                                                                                                             
 SELECT @An_AppliedGrant_AMNT = SUM(                                                                                         
         CASE                                                                                                                
            WHEN LW.TypeDisburse_CODE IN (                                                                              
               @Lc_Agpaa_CODE,                                                                                               
               @Lc_Agtaa_CODE,                                                                                               
               @Lc_Agcaa_CODE,                                                                                               
               @Lc_Cgpaa_CODE,                                                                                               
               @Lc_Pgpaa_CODE ) THEN LW.Distribute_AMNT                                                                 
            ELSE @Li_Zero_NUMB                                                                                                           
           END ),
          @An_ExcessOverGrant_AMNT = SUM(                                                                                            
         CASE                                                                                                                
            WHEN LW.TypeDisburse_CODE IN ( @Lc_Axpaa_CODE, @Lc_Axtaa_CODE, @Lc_Axcaa_CODE ) THEN LW.Distribute_AMNT
            ELSE @Li_Zero_NUMB                                                                                                           
         END)                                                                                                                
      FROM LWEL_Y1 LW                                                                                                      
      WHERE LW.Batch_DATE = @Ad_Batch_DATE 
        AND LW.Batch_NUMB = @An_Batch_NUMB 
        AND LW.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND LW.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
        AND LW.Case_IDNO = @An_Case_IDNO 
        AND LW.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB;
        
END; --End Of Procedure LWEL_RETRIEVE_S18 
                                                                                                                             

GO
