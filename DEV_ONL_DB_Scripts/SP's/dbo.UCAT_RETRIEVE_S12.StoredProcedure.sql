/****** Object:  StoredProcedure [dbo].[UCAT_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UCAT_RETRIEVE_S12]  
(
     @Ac_HoldLevel_CODE		CHAR(4) ,
     @Ac_Udc_CODE			CHAR(4)  
 )              
AS

/*
 *     PROCEDURE NAME    : UCAT_RETRIEVE_S12
 *     DESCRIPTION       : Retrieves UDC Code and Description for the given Table ID and Table Sub Id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

      DECLARE
         @Ld_High_DATE               DATE = '12/31/9999',
         @Lc_InitiateUcatManual_CODE CHAR(10) = 'MANUAL',
         @Ld_Current_DATE            DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();  
        
         SELECT a.Udc_CODE ,  
            (  
               SELECT b.DescriptionValue_TEXT  
               FROM REFM_Y1   b  
               WHERE b.Table_ID = a.Table_ID    
                 AND b.TableSub_ID = a.TableSub_ID    
                 AND b.Value_CODE = a.Udc_CODE  
            ) AS DescriptionValue_TEXT,   
         a.Table_ID ,   
         a.TableSub_ID ,   
         @Ld_Current_DATE AS HoldNumDays_DATE,  
         a.NumDaysHold_QNTY   
      FROM UCAT_Y1  a  
      WHERE a.HoldLevel_CODE=ISNULL(@Ac_HoldLevel_CODE,a.HoldLevel_CODE)   
        AND a.Initiate_CODE = @Lc_InitiateUcatManual_CODE    
        AND a.Udc_CODE = ISNULL(@Ac_Udc_CODE,a.Udc_CODE)   
        AND a.EndValidity_DATE = @Ld_High_DATE  
      ORDER BY DescriptionValue_TEXT; 

                  
END;--End of UCAT_RETRIEVE_S12


GO
