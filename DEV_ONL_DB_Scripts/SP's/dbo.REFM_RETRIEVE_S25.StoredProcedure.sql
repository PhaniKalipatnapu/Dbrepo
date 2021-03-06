/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S25]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[REFM_RETRIEVE_S25] (                              
     @Ac_TypeReject1_CODE	CHAR(1),      
     @Ac_TypeReject2_CODE   CHAR(1),      
     @Ac_TypeReject3_CODE   CHAR(1),      
     @Ac_TypeReject4_CODE   CHAR(1),      
     @Ac_TypeReject5_CODE   CHAR(1),      
     @Ac_TypeReject6_CODE   CHAR(1),      
     @Ac_Reject1_CODE		CHAR(2),      
     @Ac_Reject2_CODE		CHAR(2),      
     @Ac_Reject3_CODE		CHAR(2),      
     @Ac_Reject4_CODE		CHAR(2),      
     @Ac_Reject5_CODE		CHAR(2),      
     @Ac_Reject6_CODE		CHAR(2) 
     )                  
AS                                                                     
/*    
 *     PROCEDURE NAME    : REFM_RETRIEVE_S25    
 *     DESCRIPTION       : This procedure is used to populate the rejected record type    
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 27-NOV-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
    BEGIN    
    	DECLARE @Lc_TableSubPonr_ID  CHAR(4) = 'PONR',     
				@Lc_TableTaxi_ID	 CHAR(4) = 'TAXI';    
            		
		 SELECT CASE
		        WHEN a.Value_CODE = @Ac_Reject1_CODE
		            THEN @Ac_TypeReject1_CODE
		        WHEN a.Value_CODE = @Ac_Reject2_CODE
		            THEN @Ac_TypeReject2_CODE
		        WHEN a.Value_CODE = @Ac_Reject3_CODE
		            THEN @Ac_TypeReject3_CODE
		        WHEN a.Value_CODE = @Ac_Reject4_CODE
		            THEN @Ac_TypeReject4_CODE
		        WHEN a.Value_CODE = @Ac_Reject5_CODE
		            THEN @Ac_TypeReject5_CODE
		        WHEN a.Value_CODE = @Ac_Reject6_CODE
		            THEN @Ac_TypeReject6_CODE
		        END AS TypeReject_CODE,
		        a.Value_CODE AS Reject_CODE
		   FROM REFM_Y1 a
		  WHERE a.Table_ID	= @Lc_TableTaxi_ID
		    AND a.TableSub_ID  = @Lc_TableSubPonr_ID
		    AND (   a.Value_CODE = @Ac_Reject1_CODE
		        OR a.Value_CODE = @Ac_Reject2_CODE
		        OR a.Value_CODE = @Ac_Reject3_CODE
		        OR a.Value_CODE = @Ac_Reject4_CODE
		        OR a.Value_CODE = @Ac_Reject5_CODE
		        OR a.Value_CODE = @Ac_Reject6_CODE
		        );

  END;   --End of REFM_RETRIEVE_S25.    
  

GO
