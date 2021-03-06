/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                                                                
CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S8] 
   (     
        @An_Case_IDNO		      NUMERIC(6,0), 
        @An_OrderSeq_NUMB		  NUMERIC(2,0),                                                                
        @An_ObligationSeq_NUMB	  NUMERIC(2,0),         
        @An_SupportYearMonth_NUMB NUMERIC(6,0),     
        @An_AppTotFuture_AMNT	  NUMERIC(11,2)	 OUTPUT,    
        @An_OweTotNaa_AMNT		  NUMERIC(11,2)	 OUTPUT,
        @An_AppTotNaa_AMNT		  NUMERIC(11,2)	 OUTPUT,        
        @An_OweTotPaa_AMNT		  NUMERIC(11,2)	 OUTPUT, 
        @An_AppTotPaa_AMNT		  NUMERIC(11,2)	 OUTPUT,   
        @An_OweTotTaa_AMNT		  NUMERIC(11,2)	 OUTPUT,
        @An_AppTotTaa_AMNT		  NUMERIC(11,2)	 OUTPUT,        
        @An_OweTotCaa_AMNT		  NUMERIC(11,2)	 OUTPUT,
        @An_AppTotCaa_AMNT		  NUMERIC(11,2)	 OUTPUT,
        @An_OweTotUpa_AMNT		  NUMERIC(11,2)	 OUTPUT,
        @An_AppTotUpa_AMNT		  NUMERIC(11,2)	 OUTPUT,
        @An_OweTotUda_AMNT		  NUMERIC(11,2)	 OUTPUT,
        @An_AppTotUda_AMNT		  NUMERIC(11,2)	 OUTPUT,         
        @An_OweTotIvef_AMNT		  NUMERIC(11,2)	 OUTPUT, 
        @An_AppTotIvef_AMNT		  NUMERIC(11,2)	 OUTPUT,   
        @An_OweTotMedi_AMNT		  NUMERIC(11,2)	 OUTPUT,
        @An_AppTotMedi_AMNT		  NUMERIC(11,2)	 OUTPUT,    
        @An_OweTotNffc_AMNT	      NUMERIC(11,2)	 OUTPUT,
        @An_AppTotNffc_AMNT		  NUMERIC(11,2)	 OUTPUT,    
        @An_OweTotNonIvd_AMNT	  NUMERIC(11,2)	 OUTPUT,
        @An_AppTotNonIvd_AMNT	  NUMERIC(11,2)	 OUTPUT 
        )
   AS                                                                           
 /*                                                                           
   *     PROCEDURE NAME    : LSUP_RETRIEVE_S8                                   
    *     DESCRIPTION       :   Procedure to retrive the direct pay credit transaction  details.                                                
    *     DEVELOPED BY      : IMP Team                                        
    *     DEVELOPED ON      : 02-SEP-2011                                       
    *     MODIFIED BY       :                                                   
    *     MODIFIED ON       :                                                   
    *     VERSION NO        : 1                                                 
   */                                                                           
BEGIN                                                                     
                                                                                
         SELECT @An_AppTotCaa_AMNT = NULL,                                          
				@An_AppTotFuture_AMNT = NULL,                                       
				@An_AppTotIvef_AMNT = NULL,                                         
				@An_AppTotMedi_AMNT = NULL,                                         
				@An_AppTotNaa_AMNT = NULL,                                          
				@An_AppTotNffc_AMNT = NULL,                                         
				@An_AppTotNonIvd_AMNT = NULL,                                       
				@An_AppTotPaa_AMNT = NULL,                                          
				@An_AppTotTaa_AMNT = NULL,                                          
				@An_AppTotUda_AMNT = NULL,                                          
				@An_AppTotUpa_AMNT = NULL,                                          
				@An_OweTotCaa_AMNT = NULL,                                          
				@An_OweTotIvef_AMNT = NULL,                                         
				@An_OweTotMedi_AMNT = NULL,                                         
				@An_OweTotNaa_AMNT = NULL,                                          
				@An_OweTotNffc_AMNT = NULL,                                         
				@An_OweTotNonIvd_AMNT = NULL,                                       
				@An_OweTotPaa_AMNT = NULL,                                          
				@An_OweTotTaa_AMNT = NULL,                                          
				@An_OweTotUda_AMNT = NULL,                                          
				@An_OweTotUpa_AMNT = NULL;                                          
                                                                                
        DECLARE @Li_Zero_NUMB SMALLINT = 0;                                         
                                                                                
         SELECT @An_OweTotNaa_AMNT = ISNULL(a.OweTotNaa_AMNT,@Li_Zero_NUMB),       
				@An_AppTotNaa_AMNT = ISNULL(a.AppTotNaa_AMNT,@Li_Zero_NUMB),       
				@An_OweTotTaa_AMNT = ISNULL(a.OweTotTaa_AMNT,@Li_Zero_NUMB),       
				@An_AppTotTaa_AMNT = ISNULL(a.AppTotTaa_AMNT,@Li_Zero_NUMB),       
				@An_OweTotPaa_AMNT = ISNULL(a.OweTotPaa_AMNT,@Li_Zero_NUMB),       
				@An_AppTotPaa_AMNT = ISNULL(a.AppTotPaa_AMNT,@Li_Zero_NUMB),       
				@An_OweTotCaa_AMNT = ISNULL(a.OweTotCaa_AMNT,@Li_Zero_NUMB),       
				@An_AppTotCaa_AMNT = ISNULL(a.AppTotCaa_AMNT,@Li_Zero_NUMB),       
				@An_OweTotUpa_AMNT = ISNULL(a.OweTotUpa_AMNT,@Li_Zero_NUMB),       
				@An_AppTotUpa_AMNT = ISNULL(a.AppTotUpa_AMNT,@Li_Zero_NUMB),       
				@An_OweTotUda_AMNT = ISNULL(a.OweTotUda_AMNT,@Li_Zero_NUMB),       
				@An_AppTotUda_AMNT = ISNULL(a.AppTotUda_AMNT,@Li_Zero_NUMB),       
				@An_OweTotIvef_AMNT = ISNULL(a.OweTotIvef_AMNT,@Li_Zero_NUMB),     
				@An_AppTotIvef_AMNT = ISNULL(a.AppTotIvef_AMNT,@Li_Zero_NUMB),     
				@An_OweTotNffc_AMNT = ISNULL(a.OweTotNffc_AMNT,@Li_Zero_NUMB),     
				@An_AppTotNffc_AMNT = ISNULL(a.AppTotNffc_AMNT,@Li_Zero_NUMB),     
				@An_OweTotNonIvd_AMNT = ISNULL(a.OweTotNonIvd_AMNT,@Li_Zero_NUMB), 
				@An_AppTotNonIvd_AMNT = ISNULL(a.AppTotNonIvd_AMNT,@Li_Zero_NUMB), 
				@An_OweTotMedi_AMNT = ISNULL(a.OweTotMedi_AMNT,@Li_Zero_NUMB),     
				@An_AppTotMedi_AMNT = ISNULL(a.AppTotMedi_AMNT,@Li_Zero_NUMB),     
				@An_AppTotFuture_AMNT = ISNULL(a.AppTotFuture_AMNT,@Li_Zero_NUMB)  
           FROM LSUP_Y1 a                                                 
          WHERE a.Case_IDNO = @An_Case_IDNO 
            AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
            AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
            AND a.SupportYearMonth_NUMB =                                                    
							(                                                                   
							   SELECT MAX(c.SupportYearMonth_NUMB)                               
								 FROM LSUP_Y1 c                                           
								WHERE c.Case_IDNO = a.Case_IDNO 
								  AND c.OrderSeq_NUMB = a.OrderSeq_NUMB 
								  AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
								  AND c.SupportYearMonth_NUMB <= @An_SupportYearMonth_NUMB                            
							) 
            AND a.EventGlobalSeq_NUMB =                                                 
							(                                                                   
							   SELECT MAX(b.EventGlobalSeq_NUMB)                            
								 FROM LSUP_Y1   b                                           
								WHERE b.Case_IDNO = a.Case_IDNO 
								  AND b.OrderSeq_NUMB = a.OrderSeq_NUMB 
								  AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
								  AND b.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB                               
							);                                                                   
                                                                                
 END;--End of LSUP_RETRIEVE_S8                                                                          
                                                                                

GO
